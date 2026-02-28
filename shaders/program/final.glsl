#include "/lib/basefiles.glsl"

varying vec2 texcoord;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

#ifdef FSH

    #include "/lib/final.glsl"
    #include "/lib/exposure.glsl"

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color0;

    void main() {
        vec3 outcol = texture(colortex0, texcoord).rgb;

        float avgLuminance = texelFetch(colortex7, ivec2(0, 0), 0).a;
        outcol = avgExposure(outcol, avgLuminance);

        float halo = pow2(1.0 - length(texcoord * 2.0 - 1.0) / sqrt(2.0)) * 0.5 + 0.5;
        outcol *= halo;

        outcol = agx(outcol);
        outcol = LinearToGamma(outcol);

        color0 = vec4(outcol, 1.0);
    }

#endif
