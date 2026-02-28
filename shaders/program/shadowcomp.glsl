#include "/lib/basefiles.glsl"

varying vec2 texcoord;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

#ifdef FSH

    #include "/lib/water.glsl"

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color0;

    void main() {
        vec4 data0 = texelFetch(shadowcolor0, texelUV, 0);
        vec4 outcol = data0;
        if(abs(data0.a - 0.5) < 0.01) {
            float waterdepth = max0(
                shadowLinearDepth(texcoord, texture(shadowtex1, texcoord).r) -
                shadowLinearDepth(texcoord, texture(shadowtex0, texcoord).r)
            );
            outcol.r = texelFetch(shadowcolor0, texelUV + ivec2(1, 1), 0).r;
            outcol.b = texelFetch(shadowcolor0, texelUV + ivec2(-1, -1), 0).b;
            outcol.rgb *= exp(-waterdepth * WaterAbsorptionCoefficient);
            //outcol.a = 0.0;
        }

        color0 = outcol;
    }

#endif
