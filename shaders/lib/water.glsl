#ifndef WATER_GLSL
    #define WATER_GLSL a

    #include "/lib/sky.glsl"
    #include "/lib/cloud.glsl"

    float getWaterWave(vec2 pos, int quality) {
        float frequency = 0.2;
        float weight = 1.0;
        float time = 2.0 * frameTimeCounter;

        float waterHeight = 0.0;
        float c = 0.0;
        for(int i = 0; i < quality; i++) {
            float x = pos.x * frequency + time;

            float wave = sin(x) * weight;
            waterHeight += wave;
            c += weight;

            float offset = cos(x) * weight * 1.0;
            pos.x -= offset;
            pos = goldenRot * pos;

            frequency *= 1.2;
            weight *= 0.8;
            time *= 1.12;
        }
        waterHeight /= c;
        waterHeight = waterHeight * 0.5 + 0.5;

        return mix(1.0, waterHeight, 0.5);
    }
    float getWaterWave1(vec2 pos, int quality) {
        float frequency = 0.1;
        float weight = 1.0;
        float time = 0.5 * frameTimeCounter;

        pos += pos.y;

        float waterHeight = 0.0;
        float c = 0.0;
        for(int i = 0; i < quality; i++) {
            vec2 p = pos * frequency + time;

            float wave = noise(p) * weight;
            waterHeight += wave;
            c += weight;

            pos += pos.y * 0.1;

            frequency *= 2.0;
            weight *= 0.75;
            time *= -1.5;
        }
        waterHeight /= c;
        waterHeight = waterHeight * 0.5 + 0.5;

        return mix(1.0, waterHeight, 0.2);
    }
    float getWaterWave2(vec2 pos, int quality) {
        float frequency = 0.15;
        float weight = 1.0;
        float time = 0.75 * frameTimeCounter;

        float waterHeight = 0.0;
        float c = 0.0;
        for(int i = 0; i < quality; i++) {
            vec2 p = pos * frequency + time;

            float wave = (1.0 - abs(noise(p))) * weight;
            waterHeight += wave;
            c += weight;

            pos -= (1.0 - wave) * 0.7;
            pos = goldenRot * pos;

            frequency *= 1.4;
            weight *= 0.7;
            time *= 1.2;
        }
        waterHeight /= c;

        return mix(1.0, waterHeight, 0.5);
    }
    float getWaterHeight(vec2 pos) {
        //return getWaterWave(pos, 20);
        //return getWaterWave1(pos, 5);
        return getWaterWave2(pos, 15);
    }
    float getWaterHeightLod(vec2 pos) {
        //return getWaterWave(pos, 8);
        //return getWaterWave1(pos, 5);
        return getWaterWave2(pos, 5);
    }

    vec3 getWaterNormal(vec2 uv) {
        float e = 1e-3;

        float hC = getWaterHeight(uv);
        float hX1 = getWaterHeight(uv + vec2(e, 0.0));
        float hX0 = getWaterHeight(uv - vec2(e, 0.0));
        float hY1 = getWaterHeight(uv + vec2(0.0, e));
        float hY0 = getWaterHeight(uv - vec2(0.0, e));

        float dHx = hX1 - hX0;
        float dHy = hY1 - hY0;

        return normalize(vec3(-dHx, -dHy, 2.0 * e));
    }

    #define WAVE_PARALLAX_HEIGHT 2.5    // [0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.5 5.0]
    #define WAVE_PARALLAX_MIN_SAMPLES 5.0   // [5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0]
    #define WAVE_PARALLAX_MAX_SAMPLES 15.0  // [5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0]

    vec2 waveParallaxMapping(vec2 uv, vec3 viewDirTS, out float currHeight) {
        const float slicesMin = WAVE_PARALLAX_MIN_SAMPLES;
        const float slicesMax = WAVE_PARALLAX_MAX_SAMPLES;

        float slicesNum = ceil(mix(slicesMax, slicesMin, abs(dot(vec3(0, 0, 1), viewDirTS))));
        float dHeight = 1.0 / slicesNum;
        float rayHeight = 1.0 - dHeight;
        vec2 dUV = WAVE_PARALLAX_HEIGHT * (viewDirTS.xy / viewDirTS.z) / slicesNum;
        vec2 currUVOffset = -dUV;
        
        float prevHeight = getWaterHeightLod(uv);
        currHeight = getWaterHeightLod(uv + currUVOffset);
        
        for(int i = 0; i < slicesNum; ++i) {
            if(currHeight > rayHeight) {
                break;
            }
            prevHeight = currHeight;
            currUVOffset -= dUV;
            rayHeight -= dHeight;
            currHeight = getWaterHeightLod(uv + currUVOffset);
        }

        float currDeltaHeight = currHeight - rayHeight;
        float prevDeltaHeight = rayHeight + dHeight - prevHeight;
        float weight = currDeltaHeight / (currDeltaHeight + prevDeltaHeight);

        vec2 parallaxUV = uv + currUVOffset + weight * dUV;
        return parallaxUV;
    }

    float causticsNoise(vec2 uv) {
        return pow5(worley2DCell(uv)) * 10.0;
    }
    float drawCaustics(vec2 pos) {
        float frequency = 0.5;
        float weight = 1.0;
        float time = 1.3 * frameTimeCounter;

        float caustics = 0.0;
        float c = 0.0;
        for(int i = 0; i < 5; i++) {
            vec2 p = pos * frequency + time;

            float noise = causticsNoise(p) * weight;
            caustics += noise;
            c += weight;

            pos -= noise;
            pos = goldenRot * pos;

            frequency *= 1.25;
            weight *= 0.9;
            time *= 1.1;
        }
        caustics /= c;

        return caustics * 10.0;
    }

    const vec3 WaterScatteringCoefficient = vec3(0.01, 0.012, 0.014);
    const vec3 WaterAbsorptionCoefficient = vec3(0.3, 0.14, 0.11);
    //const vec3 WaterScatteringCoefficient = vec3(0.05, 0.042, 0.038) * 1.0;
    //const vec3 WaterAbsorptionCoefficient = vec3(0.4, 0.41, 0.42) * 1.0;

    vec3 waterOutScatter(float linearDepthepth) {
        vec3 outsca = exp(-linearDepthepth * WaterAbsorptionCoefficient);
        return outsca;
    }
    vec3 waterInScatter(vec3 worldDir, float linearDepthepth, vec3 lightColor, vec3 skylight) {
        float cosTheta = dot(lightDir, worldDir);
        float forwardPhase = getPhase(cosTheta, 0.7);
        float rearPhase = getPhase(cosTheta, -0.2);
        float phase = mix(forwardPhase, rearPhase, 0.2);

        vec3 a = -WaterAbsorptionCoefficient * (1.0 + abs(worldDir.y / lightDir.y));
        vec3 integral = (exp(a * linearDepthepth) - 1.0) / a;
        vec3 insca = (lightColor * phase + skylight) * integral * WaterScatteringCoefficient;

        return insca;
    }
    vec3 waterScatter(vec3 color, vec3 worldDir, float linearDepthepth, vec3 lightColor, vec3 skylight) {
        vec3 insca = waterInScatter(worldDir, linearDepthepth, lightColor, skylight);
        vec3 outsca = waterOutScatter(linearDepthepth);
        return color * outsca + insca;
    }

#endif
