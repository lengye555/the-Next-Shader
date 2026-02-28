varying vec2 lmcoord;
varying vec4 glcolor;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        lmcoord = clamp(lmcoord, 0.5/16, 15.5/16);
        glcolor = gl_Color;
    }

#endif

#ifdef FSH

    uniform sampler2D lightmap;

    uniform float alphaTestRef = 0.1;

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        color = glcolor * texture(lightmap, lmcoord);
        if (color.a < alphaTestRef) {
            discard;
        }
    }

#endif
