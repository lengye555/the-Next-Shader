varying vec2 texcoord;
varying vec4 glcolor;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        glcolor = gl_Color;
    }

#endif

#ifdef FSH

    uniform sampler2D gtexture;

    uniform float alphaTestRef = 0.1;

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        color = texture(gtexture, texcoord) * glcolor;
        if (color.a < alphaTestRef) {
            discard;
        }
    }

#endif