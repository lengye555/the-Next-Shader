#include "/lib/basefiles.glsl"

varying vec2 texcoord;

#ifdef VSH

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

#ifdef FSH

    #include "/lib/light.glsl"
    #include "/lib/shadow.glsl"
    #include "/lib/temporal.glsl"

    /* RENDERTARGETS: 4,5 */
    layout(location = 0) out vec4 color4;
    layout(location = 1) out vec4 color5;

    void main() {
        vec4 outcol4 = vec4(0.0);
        vec3 outcol5 = vec3(0.0);

        vec2 texcoord4 = texcoord * 2.0;
        if(inScreen(texcoord4)) {
            float depth = texelFetch(depthtex1, ivec2(texcoord4 * viewSize), 0).r;
            vec4 data2 = texelFetch(colortex2, ivec2(texcoord4 * viewSize), 0);

            vec3 viewPos = GetViewPosition(texcoord4, depth);
            vec3 worldPos = matrixMultiply(gbufferModelViewInverse, vec4(viewPos, 1.0));

            vec3 worldOriNormal = normalDecode(data2.xy);
            vec3 worldNormal = normalDecode(data2.zw);
            vec3 viewOriNormal = normalize(mat3(gbufferModelView) * worldOriNormal);

            #ifdef RSM_ON
                vec3 data1 = texelFetch(colortex1, texelUV, 0).rgb;
                vec2 uv1 = remap(data1.rg, vec2(0.5 / 16.0), vec2(15.5 / 16.0), vec2(0.0), vec2(1.0));

                vec3 rsm = vec3(0.0);
                if(uv1.y > 0.0) rsm = RSM(worldPos, worldNormal);

                outcol4.rgb = rsm;
            #else
                vec3 ambient = vec3(0.008, 0.016, 0.012);
                ambient *= dot(worldNormal, vec3(0.0, -1.0, 0.0)) * 0.5 + 0.5;

                outcol4.rgb = ambient;
            #endif

            float gtao = GTAO(viewPos, viewOriNormal, texcoord4);
            outcol4.a = gtao;

            vec3 preScreenPos = getPreScreenPos(worldPos);
            float blockID = texture(colortex1, texcoord4).b * 10000.0;
            bool ishand = abs(blockID - 9999.0) < 0.5;
            if(ishand) preScreenPos = vec3(texcoord4, depth);

            outcol4 = rsmTemporal(outcol4, preScreenPos, worldNormal, depth);
        }

        #ifdef UseTransmittanceLut
            vec2 texcoord5 = (texcoord - vec2(0.5, 0.0)) * 10.0;
            if(inScreen(texcoord5)) {
                vec2 TransmittanceLutParams = UvToTransmittanceLutParams(texcoord5);
                float cos_theta = TransmittanceLutParams.x;
                float r = TransmittanceLutParams.y;

                float sin_theta = sqrt(1.0 - cos_theta * cos_theta);
                vec3 dir = vec3(sin_theta, cos_theta, 0.0);
                vec3 pos = vec3(0.0, r, 0.0);

                float len = rayIntersectSphere(pos, dir, AtmosphereRadiusSquared);
                outcol5 = Transmittance(pos, dir, len);
            }
        #endif

        color4 = outcol4;
        color5 = vec4(outcol5, 1.0);
    }

#endif
