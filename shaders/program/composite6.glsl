#include "/lib/basefiles.glsl"

varying vec2 texcoord;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

#ifdef FSH

    #include "/lib/bloom.glsl"

    /* RENDERTARGETS: 4 */
    layout(location = 0) out vec4 color4;

    void main() {
        vec3 outcol4 = vec3(0.0);
        for(int i = 0; i < 6; i++) {
            float lod = float(i + 2);
            vec2 newUV = (texcoord - samplingOffset[i]) * exp2(lod);
            if(inScreen(newUV)) {
                outcol4 = gaussianBlur1D_R5(colortex4, texcoord, vec2(0.0, 1.0)).rgb;
            }
        }

        color4 = vec4(outcol4, 1.0);
    }

#endif
