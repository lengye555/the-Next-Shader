#include "/lib/basefiles.glsl"

varying vec2 texcoord;
varying vec3 suncol;
varying vec3 mooncol;
varying vec3 lightcol;
varying vec4 skySHR;
varying vec4 skySHG;
varying vec4 skySHB;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

        suncol   = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(0, 0), 0).rgb;
        mooncol  = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(1, 0), 0).rgb;
        lightcol = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(2, 0), 0).rgb;
        skySHR   = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(3, 0), 0);
        skySHG   = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(4, 0), 0);
        skySHB   = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(5, 0), 0);
    }

#endif

#ifdef FSH

    #include "/lib/fog.glsl"
    #include "/lib/water.glsl"

    /* RENDERTARGETS: 4 */
    layout(location = 0) out vec4 color4;

    void main() {
        vec4 outcol4 = vec4(0.0, 0.0, 0.0, 1.0);

        vec2 texcoord4 = texcoord * 2.0;
        if(inScreen(texcoord4)) {
            float depth = texture(depthtex0, texcoord4).r;
            if(depth < 1.0) {
                vec3 viewPos = GetViewPosition(texcoord4, depth);
                vec3 worldPos = matrixMultiply(gbufferModelViewInverse, vec4(viewPos, 1.0));
                vec3 worldDir = normalize(mat3(gbufferModelViewInverse) * viewPos);
                float worldDis = length(worldPos);

                float godray = texture(colortex4, texcoord4 * 0.5 + 0.5).r;
                if(isEyeInWater == 0) {
                    outcol4.rgb = atmosFog(worldDir, worldDis) * godray;
                } else {
                    vec3 skylight = FromSphericalHarmonics(skySHR, skySHG, skySHB, vec3(0.0, 1.0, 0.0));
                    outcol4.rgb = waterFog(worldPos, worldDir, worldDis, lightcol, skylight, godray);
                }
            }
        }

        vec2 texcoord41 = (texcoord - vec2(0.5, 0.5)) * 2.0;
        if(inScreen(texcoord41)) {
            float depth = texture(depthtex0, texcoord41).r;

            if(depth < 1.0) {/*
                vec3 viewPos = GetViewPosition(texcoord41, depth);
                vec3 worldPos = matrixMultiply(gbufferModelViewInverse, vec4(viewPos, 1.0));
                vec3 worldDir = normalize(mat3(gbufferModelViewInverse) * viewPos);
                float worldDis = length(worldPos);
*/
            }
            float godray = texture(colortex4, texcoord41 * 0.5 + 0.5).r;
            outcol4.rgb = vec3(godray);
        }

        color4 = outcol4;
    }

#endif
