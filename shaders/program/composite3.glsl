#include "/lib/basefiles.glsl"

varying vec2 texcoord;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

#ifdef FSH

    /* RENDERTARGETS: 4 */
    layout(location = 0) out vec4 color4;

    void main() {
        float depth = texelFetch(depthtex1, texelUV, 0).r;

        vec3 viewPos = GetViewPosition(texcoord, depth);
        vec3 worldPos = matrixMultiply(gbufferModelViewInverse, vec4(viewPos, 1.0));

        vec3 preScreenPos = getPreScreenPos(worldPos);
	    vec2 velocity = texcoord - preScreenPos.xy;

        float blockID = texture(colortex1, texcoord).b * 10000.0;
        bool ishand = abs(blockID - 9999.0) < 0.5;
        velocity *= float(depth < 1.0 && inScreen(preScreenPos.xy));
        velocity *= float(!ishand);

        color4 = vec4(velocity, 0.0, 1.0);
    }

#endif
