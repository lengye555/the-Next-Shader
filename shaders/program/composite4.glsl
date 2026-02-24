#include "/lib/basefiles.glsl"

varying vec2 texcoord;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

#ifdef FSH

    #include "/lib/taa.glsl"
    #include "/lib/exposure.glsl"

    const bool colortex0MipmapEnabled = true;

    /* RENDERTARGETS: 0,7 */
    layout(location = 0) out vec4 color0;
    layout(location = 1) out vec4 color7;

    void main() {
        vec3 outcol0 = texelFetch(colortex0, texelUV, 0).rgb;
        vec4 outcol7 = vec4(0.0);

        #ifdef TAA
            outcol0 = textureTAA(outcol0, texcoord);
        #endif
        outcol7.rgb = outcol0.rgb;

        if(texelUV == ivec2(0, 0)) {
            float currLum = calculateAverageLuminance(colortex0, vec2(viewWidth, viewHeight));
            float historyLum = texelFetch(colortex7, ivec2(0, 0), 0).a;
            float AverageLum = mix(historyLum, currLum, saturate(frameTime * 5.0));
            outcol7.a = AverageLum;
        }

        outcol0.rgb = max0(outcol0.rgb);
        outcol7.rgb = max0(outcol7.rgb);

        color0 = vec4(outcol0, 1.0);
        color7 = outcol7;
    }

#endif