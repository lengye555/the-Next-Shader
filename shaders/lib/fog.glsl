#ifndef FOG_GLSL
    #define FOG_GLSL a

    #include "/lib/cloud.glsl"
    #include "/lib/water.glsl"

    float baseGodRay(vec3 worldDir, float worldDis) {
        int sampleCount = int(remapSaturate(worldDis, near, far, 4.0, 12.0));
        float f_sample = float(sampleCount);

        float ds = worldDis / f_sample;

        vec3 stepVec = worldDir * ds;
        vec3 jitter  = stepVec * blueNoise;

        float baseGodRay = 0.0;
        for(int i = 0; i < sampleCount; i++) {
            float fi = float(i);
            vec3 worldPos = stepVec * fi + jitter;
            vec3 shadowPos = WorldSpaceToShadowSpace(worldPos);

            float sampleDepth = textureLod(shadowtex1, shadowPos.xy, 0).r;
            float testDepth = shadowPos.z - 0.00005;

            baseGodRay += step(testDepth, sampleDepth);
        }
        baseGodRay /= f_sample;

        return baseGodRay;
    }
    float baseGodRayWater(vec3 worldDir, float worldDis) {
        int sampleCount = int(remapSaturate(worldDis, near, far, 4.0, 12.0));
        float f_sample = float(sampleCount);

        float ds = worldDis / f_sample;

        vec3 stepVec = worldDir * ds;
        vec3 jitter  = stepVec * blueNoise;

        float baseGodRay = 0.0;
        for(int i = 0; i < sampleCount; i++) {
            float fi = float(i);
            vec3 worldPos = stepVec * fi + jitter;
            vec3 shadowPos = WorldSpaceToShadowSpace(worldPos);

            float sampleDepth = textureLod(shadowtex1, shadowPos.xy, 0).r;
            float testDepth = shadowPos.z - 0.00005;

            vec3 mcPos = worldPos + cameraPosition;
            float lenToWater = abs(64.0 - mcPos.y) / max(lightDir.y, 1e-5);
            float caustics = pow2(sample2DNoise(mcPos.xz + lightDir.xz * lenToWater * sqrt(1.0 - pow2(lightDir.y)))) * 2.0;

            baseGodRay += step(testDepth, sampleDepth) * caustics;
        }
        baseGodRay /= f_sample;

        return baseGodRay;
    }

    const float unitDistance = 0.01;
    vec3 atmosFog(vec3 worldDir, float worldDis) {
        float len = worldDis * unitDistance;
        float lenToEarth = rayIntersectSphere(cameraLocation, worldDir, EarthRadiusSquared);
        if(lenToEarth > 0.0) {
            len = min(len, lenToEarth);
        }

        vec3 sunFog = vec3(0.0);
        if(rayIntersectSphere(vec3(0.0, AtmosphereRadius, 0.0), sunDir, EarthRadiusSquared) <= 0.0) {
            sunFog = AtmosphereScattering(cameraLocation, worldDir, len, sunDir, sunLuminance);
        }

        vec3 moonFog = vec3(0.0);
        if(rayIntersectSphere(vec3(0.0, AtmosphereRadius, 0.0), moonDir, EarthRadiusSquared) <= 0.0) {
            moonFog = AtmosphereScattering(cameraLocation, worldDir, len, moonDir, moonLuminance);
        }

        return sunFog + moonFog;
    }
    vec3 atmosOutSca(vec3 worldDir, float worldDis) {
        float len = worldDis * unitDistance;
        float lenToEarth = rayIntersectSphere(cameraLocation, worldDir, EarthRadiusSquared);
        if(lenToEarth > 0.0) {
            len = min(len, lenToEarth);
        }

        vec3 outsca = Transmittance(cameraLocation, worldDir, len);

        return outsca;
    }

    vec3 waterFog(vec3 worldPos, vec3 worldDir, float worldDis, vec3 lightCol, vec3 skylight, float godray) {
        int sampleCount = 32;
        float f_sample = float(sampleCount);

        const float waterHeight = 64.0;

        float ds = worldDis / f_sample;

        vec3 stepVec = worldDir * ds;
        vec3 jitter  = stepVec * blueNoise;

        mat2x3 integral = mat2x3(0.0);
        for(int i = 0; i < sampleCount; i++) {
            float fi = float(i);
            vec3 worldPos = stepVec * fi + jitter;
            vec3 mcPos = worldPos + cameraPosition;

            float lenToWater = max0(waterHeight - mcPos.y) / max(lightDir.y, 1e-5);

            vec3 t1 = waterOutScatter(lenToWater);
            vec3 t2 = waterOutScatter(max0(waterHeight - mcPos.y));
            vec3 t = waterOutScatter(length(worldPos));
            integral += mat2x3(t1 * t, t2 * t);
        }
        float cosTheta = dot(lightDir, worldDir);
        float forwardPhase = getPhase(cosTheta, 0.7);
        float rearPhase = getPhase(cosTheta, -0.1);
        float phase = mix(forwardPhase, rearPhase, 0.2);

        vec3 waterFog = (lightCol * godray * phase * integral[0] + skylight * integral[1]) * ds * WaterScatteringCoefficient;

        return waterFog;
    }

    vec3 heightFog(vec3 worldDir, float worldDis) {
        vec3 mcPos = cameraPosition + worldDir * worldDis;
        if(mcPos.y < 60.0) return vec3(0.0);

        float a = 0.005;
        float b = 0.1;
        float Oy = cameraPosition.y;

        float bky = b * worldDir.y;
        vec2 data = vec2(-b * (Oy - 70.0), -bky * worldDis);
        vec2 expData = exp(data);
        float fog = a * expData.x * (1.0 - expData.y) / bky;
        fog *= remapSaturate(mcPos.y, 60.0, 70.0, 0.0, 1.0);

        return vec3(fog);
    }

    #define VolumetricFogHeight 60.0
    #define VolumetricFogThickness 20.0

    const float FogBottomHeight = VolumetricFogHeight;
    const float FogTopHeight = VolumetricFogHeight + VolumetricFogThickness;

    float sampleFogDensity(vec3 pos) {/*
        float frequency = 0.01;
        float weight = 1.0;
        float time = 0.005 * frameTimeCounter;

        float n = 0.0;
        float c = 0.0;
        for(int i = 0; i < 3; i++) {
            n += sample2DNoise(pos.xz * frequency + time) * weight;
            c += weight;

            frequency *= 2.0;
            weight *= 0.5;
            time *= 1.1;
        }
        n /= c;

        n = max0(n - 0.5);
        n = remapSaturate(n, 0.0, 0.5, 0.0, 1.0);
*/
        float h = remapSaturate(pos.y, FogBottomHeight, FogTopHeight, 0.0, 1.0);
        float s = min(1.0, exp(-h * 5.0));

        return s * remapSaturate(sunDir.y, 0.0, 0.3, 1.0, 0.0) * 0.1;
    }
    vec4 RenderVolumetricFog(vec3 worldDir, float worldDis, vec3 lightcol) {
        int sampleCount = int(remap(worldDis, near, far, 4.0, 12.0));
        float f_sample = float(sampleCount);

        float len = worldDis * unitDistance;
        float ds = len / f_sample;

        vec3 stepVec  = worldDir * worldDis / f_sample;
        vec3 jitter   = stepVec * blueNoise;
        vec3 startPos = cameraPosition + jitter;

        float cosTheta = dot(lightDir, worldDir);
        float forwardPhase = getPhase(cosTheta, 0.5);
        float rearPhase = getPhase(cosTheta, -0.5);
        float phase = mix(forwardPhase, rearPhase, 0.2);
        float uniform_phase = 1.0 / (4.0 * PI);

        float transmittance = 1.0;
        vec3 scattering = vec3(0.0);
        for(int i = 0; i < sampleCount; i++) {
            float fi = float(i);
            vec3 samplePos = startPos + stepVec * fi;

            float sampleDensity = sampleFogDensity(samplePos);
            if(sampleDensity > 1e-5) {
                float sigmaS = sampleDensity * CloudScatteringCoefficient;
                float sigmaA = sampleDensity * CloudAbsorptionCoefficient;
                float sigmaE = sigmaS + sigmaA;
                float stepTransmittance = exp(-sigmaE * ds);

                vec3 stepScattering = lightcol * sigmaS * phase;
                stepScattering = stepScattering * (1.0 - stepTransmittance) / max(sigmaE, 1e-6);

                scattering += stepScattering * transmittance;
                transmittance *= stepTransmittance;
            }
        }

        return vec4(scattering, transmittance);
    }

#endif
