#include "/lib/basefiles.glsl"

varying vec2 texcoord;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

#ifdef FSH

    #include "/lib/fog.glsl"
    #include "/lib/temporal.glsl"

    /* RENDERTARGETS: 4,6 */
    layout(location = 0) out vec4 color4;
    layout(location = 1) out vec4 color6;

    void main() {
        vec4 outcol4 = vec4(0.0);
        vec4 outcol6 = texelFetch(colortex6, texelUV, 0);

        vec2 texcoord4 = texcoord * 2.0 - 1.0;
        if(inScreen(texcoord4)) {
            float depth = texture(depthtex0, texcoord4).r;

            if(depth == 1.0) {
                outcol4.a = 1.0;
            } else {
                vec3 viewPos  = GetViewPosition(texcoord4, depth);
                vec3 worldPos = matrixMultiply(gbufferModelViewInverse, vec4(viewPos, 1.0));

                vec3  worldDir = normalize(mat3(gbufferModelViewInverse) * viewPos);
                float worldDis = length(worldPos);

                if(isEyeInWater == 0) {
                    outcol4.a = baseGodRay(worldDir, worldDis);
                } else {
                    outcol4.a = baseGodRayWater(worldDir, worldDis);
                }

                vec3 preScreenPos = getPreScreenPos(worldPos);
                float blockID = texture(colortex1, texcoord4).b * 10000.0;
                bool ishand = abs(blockID - 9999.0) < 0.5;
                if(ishand) preScreenPos = vec3(texcoord4, depth);

                outcol4.a = godrayTemporal(outcol4.a, preScreenPos);
            }
            outcol6.a = outcol4.a;
        }

        color4 = outcol4;
        color6 = outcol6;
    }

#endif