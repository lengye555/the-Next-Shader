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
        vec4 outcol7 = texelFetch(colortex7, texelUV, 0);

        #ifdef TAA
            outcol0 = textureTAA(outcol0, texcoord);
        #endif
        outcol7.rgb = outcol0.rgb;

        vec2 texcoord7 = (texcoord - vec2(0.0, 0.5)) * 2.0;
        if(inScreen(texcoord7)) {
            float depth = texelFetch(depthtex1, ivec2(texcoord7 * viewSize), 0).r;
            if(depth < 1.0) {
                vec2 data2 = texelFetch(colortex2, ivec2(texcoord7 * viewSize), 0).xy;

                vec3 worldOriNormal = normalDecode(data2);
                outcol7.a = normalEncode(worldOriNormal).r;
            } else {
                outcol7.a = 0.0;
            }
        }
        vec2 texcoord71 = (texcoord - vec2(0.5, 0.0)) * 2.0;
        if(inScreen(texcoord71)) {
            float depth = texelFetch(depthtex1, ivec2(texcoord71 * viewSize), 0).r;
            if(depth < 1.0) {
                vec2 data2 = texelFetch(colortex2, ivec2(texcoord71 * viewSize), 0).xy;

                vec3 worldOriNormal = normalDecode(data2);
                outcol7.a = normalEncode(worldOriNormal).g;
            } else {
                outcol7.a = 0.0;
            }
        }
        vec2 texcoord72 = (texcoord - vec2(0.5, 0.5)) * 2.0;
        if(inScreen(texcoord72)) {
            float depth = texelFetch(depthtex1, ivec2(texcoord72 * viewSize), 0).r;
            outcol7.a = depth;
        }
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