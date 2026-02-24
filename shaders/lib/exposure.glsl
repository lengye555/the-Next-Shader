#ifndef EXPOSURE_GLSL
    #define EXPOSURE_GLSL

    float calculateAverageLuminance(sampler2D tex, vec2 texSize) {
        int samplerLod = int(log2(min(texSize.x, texSize.y))) - 2;

        float lum = 0.0;
        lum += getLuminance(textureLod(tex, vec2(0.5, 0.5), samplerLod).rgb) * 0.5;
        lum += getLuminance(textureLod(tex, vec2(0.25, 0.25), samplerLod).rgb) * 0.125;
        lum += getLuminance(textureLod(tex, vec2(0.75, 0.25), samplerLod).rgb) * 0.125;
        lum += getLuminance(textureLod(tex, vec2(0.25, 0.75), samplerLod).rgb) * 0.125;
        lum += getLuminance(textureLod(tex, vec2(0.75, 0.75), samplerLod).rgb) * 0.125;
        return lum;
    }

    #define TARGET_BRIGHTNESS 0.2      // [0.06 0.07 0.08 0.09 0.1 0.11 0.012 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2]
    #define LIGHT_SENSITIVITY 1.5       // [0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.5 3.0 3.5 4.0 4.5 5.0]
    #define EXPOSURE_DELTA 0.5          // [0.1 0.2 0.3 0.4 0.5 0.55 0.6 0.7 0.8 0.9 1.0]

    vec3 avgExposure(vec3 color, float avgLuminance){
        float t = TARGET_BRIGHTNESS;
        float d = EXPOSURE_DELTA;
        float s = LIGHT_SENSITIVITY;
        float exposure = pow(mix(1.0, t / (avgLuminance + 0.01), d), s);

        return color * exposure;
    }

#endif