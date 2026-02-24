#ifndef TAA_GLSL
    #define TAA_GLSL a

    vec3 getClosestOffset(vec2 uv){
        float closestDepth = 1.0f;
        vec2 closestUV = uv;

        for(int i = -1; i <= 1; i++){
            for(int j = -1; j <= 1; j++){
                vec2 nowUV = uv + vec2(i, j) * invViewSize;
                float nowDepth = texture(depthtex1, nowUV).r;

                if(nowDepth < closestDepth){
                    closestDepth = nowDepth;
                    closestUV = nowUV;
                }
            }
        }
        return vec3(closestUV, closestDepth);
    }

    vec3 RGB2YCoCgR(vec3 rgbColor){
        vec3 YCoCgRColor;

        YCoCgRColor.y = rgbColor.r - rgbColor.b;
        float temp = rgbColor.b + YCoCgRColor.y / 2;
        YCoCgRColor.z = rgbColor.g - temp;
        YCoCgRColor.x = temp + YCoCgRColor.z / 2;

        return YCoCgRColor;
    }
    vec3 YCoCgR2RGB(vec3 YCoCgRColor){
        vec3 rgbColor;

        float temp = YCoCgRColor.x - YCoCgRColor.z / 2;
        rgbColor.g = YCoCgRColor.z + temp;
        rgbColor.b = temp - YCoCgRColor.y / 2;
        rgbColor.r = rgbColor.b + YCoCgRColor.y;

        return rgbColor;
    }
    vec3 ToneMap(vec3 color){
        return color / (1.0 + color);
    }
    vec3 UnToneMap(vec3 color){
        return color / (1.0 - color);
    }

    #ifndef TAA_VARIANCE_CLIP_GAMMA
        #define TAA_VARIANCE_CLIP_GAMMA 1.25
    #endif

    const vec2 offsetAABB[8] = vec2[](
        vec2(1.0, 0.0), vec2(-1.0, 0.0),
        vec2(0.0, 1.0), vec2(0.0, -1.0),
        vec2(1.0, 1.0), vec2(-1.0, 1.0),
        vec2(1.0, -1.0), vec2(-1.0, -1.0)
    );
    vec3 textureTAA(vec3 currColor, vec2 uv){
        vec2 velocity = texture(colortex4, getClosestOffset(uv).xy).xy;
        vec2 historyUv = uv - velocity;
        vec2 historyUvClamped = clamp(historyUv, invViewSize * 0.5, 1.0 - invViewSize * 0.5);
        vec3 historyColor = SampleTextureCatmullRom5(colortex7, historyUvClamped, viewSize).rgb;

        currColor = RGB2YCoCgR(ToneMap(currColor));
        historyColor = RGB2YCoCgR(ToneMap(historyColor));

        vec3 m1 = currColor;
        vec3 m2 = currColor * currColor;
        for(int i = 0; i < 8; i++){
            vec2 offset = offsetAABB[i] * invViewSize;
            vec3 color = RGB2YCoCgR(ToneMap(texture(colortex0, uv + offset).rgb));
            m1 += color;
            m2 += color * color;
        }
        vec3 mu = m1 / 9.0;
        vec3 sigma = sqrt(max(m2 / 9.0 - mu * mu, vec3(0.0)));

        historyColor = clamp(historyColor, mu - TAA_VARIANCE_CLIP_GAMMA * sigma, mu + TAA_VARIANCE_CLIP_GAMMA * sigma);

        historyColor = UnToneMap(YCoCgR2RGB(historyColor));
        currColor = UnToneMap(YCoCgR2RGB(currColor));

        float camDelta = length(cameraPosition - previousCameraPosition);
        float reset = float(frameCounter < 2 || camDelta > 16.0);
        float validHistory = float(inScreen(historyUv));

        float mixFactor = mix(0.05, 1.0, max(reset, 1.0 - validHistory));

        return mix(historyColor, currColor, mixFactor);
    }

#endif
