#include "/lib/basefiles.glsl"

varying vec2 texcoord;
varying vec4 skySHR;
varying vec4 skySHG;
varying vec4 skySHB;

#ifdef VSH

    #include "/lib/sky.glsl"

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

        SetSkylightSH(skySHR, skySHG, skySHB);
    }

#endif

#ifdef FSH

    #include "/lib/light.glsl"

    /* RENDERTARGETS: 4,5,6 */
    layout(location = 0) out vec4 color4;
    layout(location = 1) out vec4 color5;
    layout(location = 2) out vec4 color6;

    void main() {
        vec4 outcol4 = texelFetch(colortex4, texelUV, 0);
        vec4 outcol5 = texelFetch(colortex5, texelUV, 0);
        vec4 outcol6 = texelFetch(colortex6, texelUV, 0);

        if(inScreen(texcoord * 2.0)) {
            outcol4.rgb = rsmBlur(colortex4, texcoord, vec2(0.0, 1.0));
            outcol6 = outcol4;
        }

        vec2 texcoord6 = (texcoord - vec2(0.0, 0.5)) * 2.0;
        if(inScreen(texcoord6)) {
            float depth = texelFetch(depthtex1, ivec2(texcoord6 * viewSize), 0).r;
            vec4 data2 = texelFetch(colortex2, ivec2(texcoord6 * viewSize), 0);

            vec3 worldOriNormal = normalDecode(data2.xy);
            vec3 worldNormal = normalDecode(data2.zw);

            outcol6 = vec4(worldOriNormal, depth);
        }

        if(texelUV == ivec2(viewSize- 1.0) - ivec2(2, 0)) {
            vec3 suncol = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(0, 0), 0).rgb;
            vec3 mooncol = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(1, 0), 0).rgb;
            outcol5.rgb = sunDir.y > 0.0 ? suncol : mooncol;
        }
        if(texelUV == ivec2(viewSize- 1.0) - ivec2(3, 0)) outcol5 = skySHR;
        if(texelUV == ivec2(viewSize- 1.0) - ivec2(4, 0)) outcol5 = skySHG;
        if(texelUV == ivec2(viewSize- 1.0) - ivec2(5, 0)) outcol5 = skySHB;

        color4 = outcol4;
        color5 = outcol5;
        color6 = outcol6;
    }

#endif