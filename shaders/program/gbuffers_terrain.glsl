#include "/lib/basefiles.glsl"

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 normal;
varying float blockID;
varying mat3 tbnMatrix;

#ifdef VSH

    #if MC_VERSION >= 11500
    layout(location = 11) in vec4 mc_Entity;
    #else
    layout(location = 10) in vec4 mc_Entity;
    #endif

    in vec4 at_tangent;

    void main() {
        vec3 model_pos = gl_Vertex.xyz;
        vec4 view_pos = gl_ModelViewMatrix * vec4(model_pos, 1.0);
        //if(abs(mc_Entity.x - 10.5) < 1.0) view_pos.y += 10000.0;
        vec4 clip_pos = gl_ProjectionMatrix * view_pos;
        #ifdef TAA
	        clip_pos.xy += taaJitter * TAA_Intensity * clip_pos.w;
        #endif
        gl_Position = clip_pos;

        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        lmcoord = clamp(lmcoord, 0.5 / 16.0, 15.5 / 16.0);
        glcolor = gl_Color;
        normal = gl_NormalMatrix * gl_Normal;
        normal = normalize(mat3(gbufferModelViewInverse) * normal);
        blockID = mc_Entity.x;

        vec3 tangent = gl_NormalMatrix * normalize(at_tangent.xyz);
        tangent = normalize(mat3(gbufferModelViewInverse) * tangent);
        tbnMatrix = mat3(tangent, normalize(cross(tangent, normal) * at_tangent.w), normal);
    }

#endif

#ifdef FSH

    /* RENDERTARGETS: 0,1,2,3 */
    layout(location = 0) out vec4 color0;
    layout(location = 1) out vec4 color1;
    layout(location = 2) out vec4 color2;
    layout(location = 3) out vec4 color3;

    void main() {
        vec4 texcolor = texture(gtexture, texcoord);
        if(texcolor.a < alphaTestRef) {
            discard;
        }
        texcolor.rgb *= glcolor.rgb;
        #ifdef VanillaAO
            texcolor.rgb *= glcolor.a;
        #endif
        //texcolor.rgb *= texture(lightmap, lmcoord).rgb;

        vec4 normalData = texture(normals, texcoord);
        normalData.xyz = normalize(normalData.xyz * 2.0 - 1.0);
        vec3 mappedNormal = normalize(tbnMatrix * normalData.xyz);
        vec4 specularData = texture(specular, texcoord);

        color0 = vec4(texcolor.rgb, 1.0);
        color1 = vec4(lmcoord, blockID / 10000.0, 1.0);
        color2 = vec4(normalEncode(normal), normalEncode(mappedNormal));
        color3 = vec4(specularData);
    }

#endif
