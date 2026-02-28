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

    void buildTBN(in vec3 n, out vec3 t, out vec3 b){
        vec3 up = (abs(n.z) < 0.999) ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
        t = normalize(cross(up, n));
        b = cross(n, t);
    }
    vec3 SSPT(vec3 viewPos, vec3 normal) {
        vec3 tangent, bitangent;
        buildTBN(normal, tangent, bitangent);
        mat3 tbn = mat3(tangent, bitangent, normal);

        viewPos += normal * 0.1;
        vec3 col = vec3(0.0);
        for(int i = 0; i < 10; i++) {
            vec3 dir = vec3(blueNoise, blueNoise1, blueNoise2);
            dir.xy = dir.xy * 2.0 - 1.0;
            dir = normalize(dir);

            vec3 viewDir = normalize(tbn * dir);
            vec3 screenPos; bool isHit;
            screenRayTracing(viewPos, viewDir, screenPos, isHit);
            if(!isHit) continue;

            vec3 newViewPos = GetViewPosition(screenPos.xy, texture(depthtex1, screenPos.xy).r);
            vec3 worldPos = matrixMultiply(gbufferModelViewInverse, vec4(newViewPos, 1.0));
            vec3 shadowPos = WorldSpaceToShadowSpace(worldPos);
            vec3 shadow = sampleShadow(shadowPos);

            vec3 data0 = texture(colortex0, screenPos.xy).rgb;
            vec3 data1 = texture(colortex1, screenPos.xy).rgb;
            vec4 data2 = texture(colortex2, screenPos.xy);

            vec3 albedo = GammaToLinear(data0);
            vec3 worldNormal = normalDecode(data2.zw);
            vec3 viewNormal = normalize(mat3(gbufferModelView) * worldNormal);
            vec2 uv1 = remap(data1.rg, vec2(0.5 / 16.0), vec2(15.5 / 16.0), vec2(0.0), vec2(1.0));
            float blockID = data1.b * 10000.0;
            bool isLight = abs(blockID - 89.0) < 0.5;

            vec3  viewDir_pq = normalize(newViewPos - viewPos);
            float viewDis_pq = distance(newViewPos, viewPos);

            vec3 flux_q = albedo * max0(dot(worldNormal, lightDir)) * shadow;
            flux_q *= linearstep(0.035, 0.1, uv1.y);
            if(isLight) flux_q += albedo * 1.0;

            float costheta_p = max0(dot(normal,  viewDir_pq));
            float costheta_q = max0(dot(viewNormal, -viewDir_pq));

            col += flux_q / PI * costheta_p * costheta_q * (1.0 / pow2(viewDis_pq * 0.1 + 0.1)) * 0.1;
        }

        return col;
    }

    /* RENDERTARGETS: 4,5 */
    layout(location = 0) out vec4 color4;
    layout(location = 1) out vec4 color5;

    void main() {
        vec4 outcol4 = vec4(0.0);
        vec3 outcol5 = vec3(0.0);

        vec2 texcoord4 = texcoord * 2.0;
        if(inScreen(texcoord4)) {
            float depth = texelFetch(depthtex1, ivec2(texcoord4 * viewSize), 0).r;
            if(depth < 1.0) {
                vec4 data2 = texelFetch(colortex2, ivec2(texcoord4 * viewSize), 0);

                vec3 viewPos = GetViewPosition(texcoord4, depth);
                vec3 worldPos = matrixMultiply(gbufferModelViewInverse, vec4(viewPos, 1.0));

                vec3 worldOriNormal = normalDecode(data2.xy);
                vec3 worldNormal = normalDecode(data2.zw);
                vec3 viewOriNormal = normalize(mat3(gbufferModelView) * worldOriNormal);

                vec3 preScreenPos = getPreScreenPos(worldPos);
                float blockID = texture(colortex1, texcoord4).b * 10000.0;
                bool ishand = abs(blockID - 9999.0) < 0.5;
                if(ishand) preScreenPos = vec3(texcoord4, depth);

                #ifdef GTAO_ON
                    float gtao = GTAO(viewPos, viewOriNormal, texcoord4);
                #else
                    float gtao = 1.0;
                #endif

                #ifdef RSM_ON
                    vec3 data1 = texture(colortex1, texcoord4).rgb;
                    vec2 uv1 = remap(data1.rg, vec2(0.5 / 16.0), vec2(15.5 / 16.0), vec2(0.0), vec2(1.0));

                    vec3 rsm = vec3(0.0);
                    if(uv1.y > 0.02) rsm = RSM(worldPos, worldNormal) * uv1.y;

                    outcol4 = vec4(rsm, gtao);
                    outcol4 = rsmTemporal(outcol4, preScreenPos, worldNormal, depth);
                #else
                    vec3 ambient = vec3(0.008, 0.012, 0.016);
                    ambient *= dot(worldNormal, vec3(0.0, -1.0, 0.0)) * 0.5 + 0.5;

                    outcol4 = vec4(ambient, gtao);
                    outcol4.a = rsmTemporal(outcol4, preScreenPos, worldNormal, depth).a;
                #endif

            }
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
