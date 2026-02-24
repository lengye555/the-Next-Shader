#ifndef TEMPORAL_GLSL
    #define TEMPORAL_GLSL a

    vec4 rsmTemporal(vec4 curColor, vec3 preScreenPos, vec3 worldNormal, float depthCurrent) {
        if(depthCurrent >= 1.0) return curColor;

        if(outScreen(preScreenPos.xy - vec2(-invViewSize.x, -invViewSize.y))) return curColor;
        if(preScreenPos.z <= 0.0 || preScreenPos.z >= 1.0) return curColor;

        vec4 normalAndDepth = texture(colortex6, preScreenPos.xy * 0.5 + vec2(0.0, 0.5));
        float depthAtPrevNow = normalAndDepth.a;
        if(depthAtPrevNow >= 1.0) return curColor;

        float viewZCurrent = linearDepth(depthCurrent);
        float viewZPrevNow = linearDepth(depthAtPrevNow);
        float depthDiff = abs(viewZPrevNow - viewZCurrent) / max(viewZCurrent, 1e-3);
        float depthOk = 1.0 - smoothstep(0.05, 0.1, depthDiff);

        vec3 normalPrevNow = normalAndDepth.xyz;
        float normalOk = smoothstep(0.5, 0.9, dot(normalPrevNow, worldNormal));

        float camDelta = length(cameraPosition - previousCameraPosition);
        float reset = float(frameCounter < 2 || camDelta > 16.0);

        float historyWeight = 0.95 * depthOk * normalOk * (1.0 - reset);

        vec4 preColor = texture(colortex6, preScreenPos.xy * 0.5);
        return mix(curColor, preColor, saturate(historyWeight));
    }

    float godrayTemporal(float curColor, vec3 preScreenPos) {
        if(outScreen(preScreenPos.xy - vec2(invViewSize.x, invViewSize.y))) return curColor;

        float preColor = texture(colortex6, preScreenPos.xy * 0.5 + 0.5).r;
        return mix(preColor, curColor, 0.2);
    }

    vec4 cloudTemporal(vec4 curColor, vec3 worldPos) {
        vec3 preScreenPos = getPreScreenPos(worldPos);
        if(outScreen(preScreenPos.xy - vec2(invViewSize.x, -invViewSize.y))) return curColor;

        vec4 preColor = texture(colortex6, preScreenPos.xy * 0.5 + vec2(0.5, 0.0));
        return mix(preColor, curColor, 0.3);
    }

#endif