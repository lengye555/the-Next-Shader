#include "/lib/basefiles.glsl"

varying vec2 texcoord;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

#ifdef FSH

    #include "/lib/light.glsl"
    #include "/lib/sky.glsl"
    #include "/lib/cloud.glsl"

    /* RENDERTARGETS: 4,5 */
    layout(location = 0) out vec4 color4;
    layout(location = 1) out vec4 color5;

    void main() {
        vec4 outcol4 = texelFetch(colortex4, texelUV, 0);
        vec3 outcol5 = texelFetch(colortex5, texelUV, 0).rgb;

        vec2 texcoord4 = texcoord * 2.0;
        if(inScreen(texcoord4)) {
            float depth = texelFetch(depthtex1, ivec2(texcoord4 * viewSize), 0).r;
            if(depth < 1.0) {
                outcol4 = rsmBlur(colortex4, texcoord, vec2(1.0, 0.0));
            }
        }

        vec2 texcoord5 = texcoord * 4.0;
        if(inScreen(texcoord5)) {
            vec3 skyDir = tex2sph(texcoord5);
            vec3 skyCol = RenderSky(skyDir);
            //vec4 cloud2D = RenderCloud2D(cameraLocation, skyDir, lightDir, lightLuminance);
            //skyCol = skyCol * cloud2D.a + cloud2D.rgb;

            outcol5 = skyCol;
        }

        if(texelUV == ivec2(viewSize- 1.0) - ivec2(0, 0)) outcol5 = sunLuminance * TransToAtmos(cameraLocation, sunDir);
        if(texelUV == ivec2(viewSize- 1.0) - ivec2(1, 0)) outcol5 = moonLuminance * TransToAtmos(cameraLocation, moonDir);

        color4 = outcol4;
        color5 = vec4(outcol5, 1.0);
    }

#endif