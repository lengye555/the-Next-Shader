#include "/lib/basefiles.glsl"

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        lmcoord = clamp(lmcoord, 0.5/16, 15.5/16);
        glcolor = gl_Color;
    }

#endif

#ifdef FSH

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        color = texture(gtexture, texcoord) * glcolor;
        color *= texture(lightmap, lmcoord);
        if (color.a < alphaTestRef) {
            discard;
        }
        color = vec4(vec3(0.001, 0.0015, 0.002) * 0.5, 0.1);
    }

#endif
