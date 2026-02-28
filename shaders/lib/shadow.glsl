#ifndef SHADOW_GLSL
    #define SHADOW_GLSL a

    float shadowTest(vec3 shadowPos) {
        float sampleDepth = textureLod(shadowtex1, shadowPos.xy, 0).r;
        float testDepth = shadowPos.z - 0.00005;

        return step(testDepth, sampleDepth);
    }
    vec3 sampleShadow(vec3 shadowPos) {
        float testDepth = shadowPos.z - 0.00005;

        float sampleDepth0 = textureLod(shadowtex0, shadowPos.xy, 0).r;
        if(step(testDepth, sampleDepth0) == 1.0) return vec3(1.0);

        float sampleDepth1 = textureLod(shadowtex1, shadowPos.xy, 0).r;
        if(step(testDepth, sampleDepth1) == 0.0) return vec3(0.0);

        vec3 shadowColor = textureLod(shadowcolor0, shadowPos.xy, 0).rgb;
        return shadowColor;
    }
    vec3 PCF(vec3 shadowPos, float radius) {
        const int sampleCount = 9;
        const float f_sample = float(sampleCount);
        radius /= float(shadowMapResolution);

        float jitter = blueNoise;

        float angle = blueNoise1 * _2PI;
        vec2 dir = vec2(cos(angle), sin(angle));

        shadowPos = shadowUnDistort(shadowPos * 2.0 - 1.0) * 0.5 + 0.5;

        vec3 shadow = vec3(0.0);
        for(int i = 0; i < sampleCount; i++) {
            float fi = float(i);
            vec2 offst = radius * dir * sqrt((fi + jitter) / f_sample);
            vec2 coord = shadowPos.xy + offst;

            vec3 newShadowPos = shadowDistort(vec3(coord, shadowPos.z) * 2.0 - 1.0) * 0.5 + 0.5;
            if(outScreen(newShadowPos.xy)) continue;

            shadow += sampleShadow(newShadowPos);

            dir = goldenRot * dir;
        }

        return shadow / f_sample;
    }

    float blockerSearch(vec3 shadowPos, float radius) {
        const int sampleCount = 16;
        radius /= float(shadowMapResolution);

        float jitter = blueNoise;

        float angle = blueNoise1 * _2PI;
        vec2  dir = vec2(cos(angle), sin(angle));

        shadowPos = shadowUnDistort(shadowPos * 2.0 - 1.0) * 0.5 + 0.5;

        float blockerAccum = 0.0;
        int c = 0;
        for(int i = 0; i < sampleCount; i++) {
            float fi = float(i);
            vec2 offst = radius * dir * sqrt((fi + jitter) / float(sampleCount));
            vec2 coord = shadowPos.xy + offst;

            vec3 newShadowPos = shadowDistort(vec3(coord, shadowPos.z) * 2.0 - 1.0) * 0.5 + 0.5;
            if(outScreen(newShadowPos.xy)) continue;

            float dBlocker = textureLod(shadowtex0, newShadowPos.xy, 0).r;
            if(newShadowPos.z - 0.00005 > dBlocker) {
                blockerAccum += dBlocker;
                c++;
            }

            dir = goldenRot * dir;
        }

        if(c < 1) return -1.0;

        return blockerAccum / float(c);
    }
    vec3 PCSS(vec3 shadowPos) {
        float searchRadius = 10.0;
        float avgBlockerDepth = blockerSearch(shadowPos, searchRadius);
        if(avgBlockerDepth < 0.0) return vec3(1.0);

        float dReceiver = shadowPos.z;
        float dBlocker = avgBlockerDepth;
        float w = (dReceiver - dBlocker) / dBlocker * 50.0;
        w = max(w, 0.0);

        float pcfRadius = clamp(w, 0.2, searchRadius - 0.5);
        return PCF(shadowPos, pcfRadius);
    }

    vec3 getShadow(vec3 worldPos) {
        vec3 shadowPos = WorldSpaceToShadowSpace(worldPos);

        return PCSS(shadowPos);
    }
    vec3 getShadow(vec3 worldPos, float pcfRadius) {
        vec3 shadowPos = WorldSpaceToShadowSpace(worldPos);

        return PCF(shadowPos, pcfRadius);
    }

    float getScreenShadow(vec3 viewPos) {
        vec3 rayTracingPos = vec3(0.0);
        bool rayTracingIsHit = false;
        screenRayTracing(viewPos, lightViewDir, rayTracingPos, rayTracingIsHit);

        return float(!rayTracingIsHit);
    }

    #define GTAO_SLICE_COUNT 3            // [2 3 4 5 6 7 8 9 10]
    #define GTAO_DIRECTION_SAMPLE_COUNT 5 // [1 2 3 4 5 6 7 8 9 10]
    #define GTAO_SEARCH_RADIUS 0.75        // [0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.5 3.0 3.5 4.0 4.5 5.0]
    #define GTAO_INTENSITY 5.0            // [0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.5 3.0 3.5 4.0 5.0]

    vec3 GTAOMultiBounce(float ao, vec3 albedo) {
        vec3 a = 2.0404 * albedo - 0.3324;
        vec3 b = -4.7951 * albedo + 0.6417;
        vec3 c = 2.7552 * albedo + 0.6903;
        
        return max(vec3(ao), ((ao * a + b) * ao + c) * ao);
    }
    // Practical Real-Time Strategies for Accurate Indirect Occlusion
    // https://www.activision.com/cdn/research/Practical_Real_Time_Strategies_for_Accurate_Indirect_Occlusion_NEW%20VERSION_COLOR.pdf
    float GTAO(vec3 viewPos, vec3 normal, vec2 coord) {
        float rand = blueNoise;
        float dist = length(viewPos);
        const int sliceCount = GTAO_SLICE_COUNT;
        const int directionSampleCount = GTAO_DIRECTION_SAMPLE_COUNT;
        float scaling = GTAO_SEARCH_RADIUS / dist;
        
        float visibility = 0.0;
        viewPos += normal * 0.05;
        vec3 viewV = normalize(-viewPos);
        
        for (int slice = 0; slice < sliceCount; slice++) {
            float phi = (PI / float(sliceCount)) * (float(slice) + rand * 17.3333);
            vec2 omega = normalize(vec2(cos(phi), sin(phi)));
            vec3 directionV = vec3(omega.x, omega.y, 0.0);
            
            vec3 orthoDirectionV = directionV - dot(directionV, viewV) * viewV;
            vec3 axisV = cross(directionV, viewV);
            
            vec3 projNormalV = normal - axisV * dot(normal, axisV);
            
            float sgnN = sign(dot(orthoDirectionV, projNormalV));
            float cosN = saturate(dot(projNormalV, viewV) / max(length(projNormalV), 0.0001));
            float n = sgnN * acos(cosN);
            
            for (int side = 0; side <= 1; side++) {
                float cHorizonCos = -1.0;
                for (int samples = 0; samples < directionSampleCount; samples++) {
                    float s = (float(samples) + rand) / float(directionSampleCount);
                    
                    vec2 offset = (2.0 * float(side) - 1.0) * s * scaling * omega;
                    vec2 sampleUV = coord + offset * 2.0;
                    if(outScreen(sampleUV))
                        continue;

                    float sampleDepth = texture(depthtex1, sampleUV).r;
                    vec3 sampleScreenPos = vec3(sampleUV, sampleDepth);
                    vec3 sPosV = ScreenSpaceToViewSpace(sampleScreenPos, gbufferProjectionInverse);
                    
                    vec3 sHorizonV = normalize(sPosV - viewPos);
                    float horizonCos = dot(sHorizonV, viewV);
                    horizonCos = mix(-1.0, horizonCos, (smoothstep(0.0, 1.0, GTAO_SEARCH_RADIUS * 1.41 / distance(sPosV, viewPos))));
                    cHorizonCos = max(cHorizonCos, horizonCos);
                } 

                float h = n + clamp((2.0 * float(side) - 1.0) * acos(cHorizonCos) - n, -PI/2.0, PI/2.0);
                visibility += length(projNormalV) * (cosN + 2.0 * h * sin(n) - cos(2.0 * h - n)) / 4.0;
            }
        }
        visibility /= float(sliceCount);

        float gtao = pow(visibility, GTAO_INTENSITY);
        return max0(gtao);
    }

#endif
