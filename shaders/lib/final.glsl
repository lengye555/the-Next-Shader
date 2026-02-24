#ifndef FINAL_GLSL
    #define FINAL_GLSL a

    #define AGX_ADDITIVE 7.0
    #define AGX_EV 14.0
    // 0: Default, 1: Golden, 2: Punchy
    #ifndef AGX_LOOK
        #define AGX_LOOK 3
    #endif

    const mat3 LINEAR_REC2020_TO_LINEAR_SRGB = mat3(
        1.6605, -0.1246, -0.0182,
        -0.5876, 1.1329, -0.1006,
        -0.0728, -0.0083, 1.1187
    );
    const mat3 LINEAR_SRGB_TO_LINEAR_REC2020 = mat3(
        0.6274, 0.0691, 0.0164,
        0.3293, 0.9195, 0.0880,
        0.0433, 0.0113, 0.8956
    );
    const mat3 AgXInsetMatrix = mat3(
        0.856627153315983, 0.137318972929847, 0.11189821299995,
        0.0951212405381588, 0.761241990602591, 0.0767994186031903,
        0.0482516061458583, 0.101439036467562, 0.811302368396859
    );
    const mat3 AgXOutsetMatrix = mat3(
        1.1271005818144368, -0.1413297634984383, -0.14132976349843826,
        -0.11060664309660323, 1.157823702216272, -0.11060664309660294,
        -0.016493938717834573, -0.016493938717834257, 1.2519364065950405
    );
    vec3 agxAscCdl(vec3 color, vec3 slope, vec3 offset, vec3 power, float sat) {
        float luma = getLuminance(color);
        vec3 c = pow(color * slope + offset, power);
        return luma + sat * (c - luma);
    }
    vec3 agx(vec3 color) {
        color *= AGX_ADDITIVE;
        color = LINEAR_SRGB_TO_LINEAR_REC2020 * color;

        color = AgXInsetMatrix * color;

        color = max(color, 1e-10);

        const float hev = AGX_EV * 0.5;
        const float middle_grey = 0.18;
        color = clamp(log2(color / middle_grey), -hev, hev);
        color = (color + hev) / AGX_EV;

        color = clamp(color, 0.0, 1.0);

        vec3 x  = color;
        vec3 x2 = x * x;
        vec3 x4 = x2 * x2;
        vec3 x6 = x4 * x2;
        color = - 17.86     * x6 * x
                + 78.01     * x6
                - 126.7     * x4 * x
                + 92.06     * x4
                - 28.72     * x2 * x
                + 4.361     * x2
                - 0.1718    * x
                + 0.002857;

        #if AGX_LOOK == 1
            color = agxAscCdl(color, vec3(1.0, 0.9, 0.5), vec3(0.0), vec3(0.8), 1.3);
        #elif AGX_LOOK == 2
            color = agxAscCdl(color, vec3(1.0), vec3(0.0), vec3(1.35), 1.4);
        #elif AGX_LOOK == 3
            color = agxAscCdl(color, vec3(1.0), vec3(0.0), vec3(1.15), 1.25);
        #endif

        color = AgXOutsetMatrix * color;

        color = pow(max(vec3(0.0), color), vec3(2.2));

        color = LINEAR_REC2020_TO_LINEAR_SRGB * color;
        color = clamp(color, 0.0, 1.0);

        return color;
    }

    vec3 genshintonemap(vec3 color) {
        return (1.36 * color + 0.047) * color / ((0.93 * color + 0.56) * color + 0.14);
    }

#endif