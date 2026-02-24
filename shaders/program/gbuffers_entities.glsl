#include "/lib/basefiles.glsl"

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 normal;

#ifdef VSH

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
        lmcoord = clamp(lmcoord, 0.5/16, 15.5/16);
        glcolor = gl_Color;
        normal = gl_NormalMatrix * gl_Normal;
        normal = mat3(gbufferModelViewInverse) * normal;
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
        //texcolor.rgb *= texture(lightmap, lmcoord).rgb;

        vec4 normalData = texture(normals, texcoord);
        vec4 specularData = texture(specular, texcoord);

        color0 = vec4(texcolor.rgb, 1.0);
        color1 = vec4(lmcoord, 9998.0 / 10000.0, 1.0);
        color2 = vec4(normalEncode(normal), normalEncode(normal));
        color3 = vec4(specularData);
    }

#endif
