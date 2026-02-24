#include "/lib/basefiles.glsl"

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 normal;
varying vec4 glcolor;
varying float blockID;
varying vec4 view_pos;
varying vec4 clip_pos;
varying mat3 tbnMatrix;
varying vec3 lightcol;
varying vec4 skySHR;
varying vec4 skySHG;
varying vec4 skySHB;

#ifdef VSH

    #if MC_VERSION >= 11500
    layout(location = 11) in vec4 mc_Entity;
    #else
    layout(location = 10) in vec4 mc_Entity;
    #endif

    in vec4 at_tangent;

    void main() {
        vec3 model_pos = gl_Vertex.xyz;
        view_pos = gl_ModelViewMatrix * vec4(model_pos, 1.0);
        clip_pos = gl_ProjectionMatrix * view_pos;
        #ifdef TAA
	        clip_pos.xy += taaJitter * TAA_Intensity * clip_pos.w;
        #endif
        gl_Position = clip_pos;

        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        lmcoord = clamp(lmcoord, 0.5 / 16.0, 15.5 / 16.0);
        normal = gl_NormalMatrix * gl_Normal;
        normal = normalize(mat3(gbufferModelViewInverse) * normal);
        glcolor = gl_Color;
        blockID = mc_Entity.x;

        vec3 tangent = gl_NormalMatrix * normalize(at_tangent.xyz);
        tangent = normalize(mat3(gbufferModelViewInverse) * tangent);
        tbnMatrix = mat3(tangent, normalize(cross(tangent, normal) * at_tangent.w), normal);

        lightcol = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(2, 0), 0).rgb;
        skySHR   = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(3, 0), 0);
        skySHG   = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(4, 0), 0);
        skySHB   = texelFetch(colortex5, ivec2(viewSize - 1.0) - ivec2(5, 0), 0);
    }

#endif

#ifdef FSH

    #include "/lib/water.glsl"

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color0;

    void main() {
        vec4 texcolor = texture(gtexture, texcoord);
        if(texcolor.a < alphaTestRef) {
            discard;
        }
        texcolor.rgb *= glcolor.rgb;
        //texcolor.rgb *= texture(lightmap, lmcoord).rgb;
        texcolor.rgb = GammaToLinear(texcolor.rgb);

        vec3 screen_pos = (clip_pos.xyz / clip_pos.w) * 0.5 + 0.5;
        vec3 outcol = vec3(0.0);
        if(abs(blockID - 8.0) < 0.5 || abs(blockID - 9.0) < 0.5) {
            vec3 world_pos = matrixMultiply(gbufferModelViewInverse, view_pos);
            vec3 world_dir = normalize(mat3(gbufferModelViewInverse) * view_pos.xyz);
            vec3 mc_pos = world_pos + cameraPosition;

            float currHeight;
            vec2 water_uv = waveParallaxMapping(mc_pos.xz + mc_pos.y, transpose(tbnMatrix) * world_dir, currHeight);
            vec3 water_normal = getWaterNormal(water_uv);
            vec3 world_normal = tbnMatrix * water_normal;

            vec2 distortCoord = screen_pos.xy + water_normal.xy * 0.03;
            outcol = texture(colortex4, distortCoord).rgb;

            float viewdepth = abs(
                linearDepth(texture(depthtex1, screen_pos.xy).r) * float(isEyeInWater == 0) - 
                linearDepth(screen_pos.z)
            );
            vec3 skylight = FromSphericalHarmonics(skySHR, skySHG, skySHB, world_normal);
            outcol = waterScatter(outcol, world_dir, viewdepth, lightcol, skylight);

            outcol = waterReflect(outcol, world_pos, view_pos.xyz, world_dir, world_normal, normal, skylight, lmcoord.y);
        }

        else {
            outcol = mix(texcolor.rgb, outcol, texcolor.a);
        }

        color0 = vec4(outcol, 1.0);
    }

#endif
