#include "/lib/basefiles.glsl"

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 normal;
varying vec4 glcolor;
varying float blockID;
varying vec4 view_pos;

#ifdef VSH

    #if MC_VERSION >= 11500
    layout(location = 11) in vec4 mc_Entity;
    #else
    layout(location = 10) in vec4 mc_Entity;
    #endif

    void main() {
        vec3 model_pos = gl_Vertex.xyz;
             view_pos = gl_ModelViewMatrix * vec4(model_pos, 1.0);
        vec4 clip_pos = gl_ProjectionMatrix * view_pos;
        clip_pos.xyz = shadowDistort(clip_pos.xyz);
        gl_Position = clip_pos;

        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        lmcoord = clamp(lmcoord, 0.5/16, 15.5/16);
        normal = gl_NormalMatrix * gl_Normal;
        normal = mat3(shadowModelViewInverse) * normal; 
        glcolor = gl_Color;
        blockID = mc_Entity.x;
    }

#endif

#ifdef FSH

    #include "/lib/water.glsl"

    /* RENDERTARGETS: 0,1 */
    layout(location = 0) out vec4 color0;
    layout(location = 1) out vec4 color1;

    void main() {
        vec4 texcolor = texture(gtexture, texcoord);
        if(texcolor.a < alphaTestRef) {
            discard;
        }
        texcolor.rgb *= glcolor.rgb;

        vec4 outcol = vec4(GammaToLinear(texcolor.rgb), 1.0);
        vec3 n = normalize(normal);
        if(!gl_FrontFacing) n = -n;

        if(abs(blockID - 8.0) < 0.5 || abs(blockID - 9.0) < 0.5) {
            vec3 world_pos = matrixMultiply(shadowModelViewInverse, view_pos);
            vec3 mc_pos = abs(world_pos + cameraPosition);

            outcol.rgb = vec3(1.0);
            #ifdef WaterCaustics_ON
                outcol.rgb *= drawCaustics(mc_pos.xz) + 0.2;
            #endif
            outcol.a = 0.5;
        }
        if(entityId == 99) {
            outcol.a *= 0.0;
        }

        color0 = outcol;
        color1 = vec4(n * 0.5 + 0.5, 1.0);
    }

#endif
