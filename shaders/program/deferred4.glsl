#include "/lib/basefiles.glsl"

varying vec2 texcoord;
varying vec3 lightcol;
varying vec3 upskylight;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

        lightcol   = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(2, 0), 0).rgb;
        upskylight = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(6, 0), 0).rgb;
    }

#endif

#ifdef FSH

    #include "/lib/sky.glsl"
    #include "/lib/fog.glsl"
    #include "/lib/cloud.glsl"
    #include "/lib/temporal.glsl"

    /* RENDERTARGETS: 4,6,10 */
    layout(location = 0) out vec4 color4;
    layout(location = 1) out vec4 color6;
    layout(location = 2) out vec4 color10;

    void main() {
        vec4 outcol4 = vec4(0.0, 0.0, 0.0, 1.0);
        vec4 outcol6 = texelFetch(colortex6, texelUV, 0);

        vec2 texcoord4 = texcoord * 2.0;
        if(inScreen(texcoord4)) {
            bool issky = false;
            for(int i = -1; i <= 1; i++){
                for(int j = -1; j <= 1; j++){
                    ivec2 nowUV = ivec2(texcoord4 * viewSize) + ivec2(i, j);
                    float nowDepth = texelFetch(depthtex1, nowUV, 0).r;

                    issky = issky || (nowDepth == 1.0);
                }
            }
            if(issky) {
                float depth = texture(depthtex1, texcoord4).r;

                vec3 viewPos = GetViewPosition(texcoord4, depth);
                vec3 worldPos = matrixMultiply(gbufferModelViewInverse, vec4(viewPos, 1.0));
                vec3 worldDir = normalize(mat3(gbufferModelViewInverse) * viewPos);
                float worldDis = length(worldPos);

                vec3 skyColor = RenderSky(worldDir);
                skyColor = drawSun(skyColor, worldDir);
                vec4 cloud2D = RenderCloud2D(cameraLocation, worldDir, lightDir, lightLuminance);
                skyColor = skyColor * cloud2D.a + cloud2D.rgb;

                float jitter = blueNoise * 0.01;
                outcol4.rgb = skyColor + vec3(blueNoise / 255.0) * lightcol;
            }
        }

        vec2 texcoord41 = (texcoord - vec2(0.5, 0.0)) * 2.0;
        if(inScreen(texcoord41) || rainStrength > 0.5) {
            int radius = lightDir.y > 0.25 ? 1 : 2;
            bool issky = false;
            for(int i = -radius; i <= radius; i++){
                for(int j = -radius; j <= radius; j++){
                    ivec2 nowUV = ivec2(texcoord41 * viewSize) + ivec2(i, j);
                    float nowDepth = texelFetch(depthtex1, nowUV, 0).r;

                    issky = issky || (nowDepth == 1.0);
                }
            }
            if(issky) {
                float depth = texture(depthtex1, texcoord41).r;

                vec3 viewPos = GetViewPosition(texcoord41, depth);
                vec3 worldPos = matrixMultiply(gbufferModelViewInverse, vec4(viewPos, 1.0));
                vec3 worldDir = normalize(mat3(gbufferModelViewInverse) * viewPos);

                vec3 skylight = upskylight;
                vec4 cloud3D = RenderCloud(cameraLocation, worldDir, lightDir, lightLuminance, skylight);

                outcol4 = cloud3D;
                outcol4 = cloudTemporal(outcol4, worldPos);
            }
            outcol6 = outcol4;
        }

        color4 = outcol4;
        color6 = outcol6;
        color10 = color4;
    }

#endif
