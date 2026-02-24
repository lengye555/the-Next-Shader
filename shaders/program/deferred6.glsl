#include "/lib/basefiles.glsl"

varying vec2 texcoord;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

#ifdef FSH

    #include "/lib/sky.glsl"
    #include "/lib/fog.glsl"

    /* RENDERTARGETS: 0,4 */
    layout(location = 0) out vec4 color0;
    layout(location = 1) out vec4 color4;

    void main() {
        vec3 outcol = texelFetch(colortex0, texelUV, 0).rgb;

        float depth = texelFetch(depthtex1, texelUV, 0).r;

        if(depth == 1.0) {
            vec3 skyColor = textureBicubic(colortex4, texcoord * 0.5, viewSize).rgb;
            vec4 cloud3D = textureBicubic(colortex4, texcoord * 0.5 + vec2(0.5, 0.0), viewSize);
            skyColor = skyColor * cloud3D.a + cloud3D.rgb;

            outcol = skyColor;
        }

        outcol = max0(outcol);

        color0 = vec4(outcol, 1.0);
        color4 = color0;
    }

#endif
