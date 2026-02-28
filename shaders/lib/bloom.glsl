#ifndef BLOOM_GLSL
    #define BLOOM_GLSL a

    vec2 samplingOffset[7] = vec2[](
        vec2(0.0, 0.0),
        vec2(0.35, 0.0),
        vec2(0.575, 0.0),
        vec2(0.7375, 0.0),
        vec2(0.86875, 0.0),
        vec2(0.0, 0.35),
        vec2(0.1078125, 0.35)
    );

    const float gaussianKernelR5[6] = float[](
        0.24609375,
        0.205078125,
        0.1171875,
        0.0439453125,
        0.009765625,
        0.0009765625
    );
    vec3 gaussianBlur1D_R5(sampler2D tex, vec2 uv, vec2 dir, float lod) {
        vec2 imageSize = viewSize / exp2(lod);
        vec2 stepUV = dir / imageSize;
        vec3 sum = textureLod(tex, uv, lod).rgb * gaussianKernelR5[0];
        for(int i = 1; i <= 5; i++) {
            float o = float(i);
            sum += (textureLod(tex, uv + stepUV * o, lod).rgb + textureLod(tex, uv - stepUV * o, lod).rgb) * gaussianKernelR5[i];
        }
        return sum;
    }
    vec3 gaussianBlur1D_R5(sampler2D tex, vec2 uv, vec2 dir) {
        vec3 sum = vec3(0.0);
        sum = gaussianBlur1D_R5(tex, uv, dir, 0.0);
        return sum;
    }

#endif