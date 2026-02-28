#ifndef TEMPORAL_GLSL
    #define TEMPORAL_GLSL a

    vec4 rsmTemporal(vec4 curColor, vec3 preScreenPos, vec3 worldNormal, float depthCurrent) {
        if(depthCurrent >= 1.0) return curColor;

        if(outScreen(preScreenPos.xy - vec2(-invViewSize.x, -invViewSize.y))) return curColor;
        if(preScreenPos.z <= 0.0 || preScreenPos.z >= 1.0) return curColor;

        float normalX = texture(colortex7, preScreenPos.xy * 0.5 + vec2(0.0, 0.5)).a;
        float normalY = texture(colortex7, preScreenPos.xy * 0.5 + vec2(0.5, 0.0)).a;
        vec3 normalPrevNow = normalDecode(vec2(normalX, normalY));
        float normalOk = smoothstep(0.5, 0.9, dot(normalPrevNow, worldNormal));
/*
        float depthAtPrevNow = normalAndDepth.a;
        float viewZCurrent = linearDepth(depthCurrent);
        float viewZPrevNow = linearDepth(depthAtPrevNow);
        float depthDiff = abs(viewZPrevNow - viewZCurrent) / max(viewZCurrent, 1e-3);
        float depthOk = 1.0 - smoothstep(0.05, 0.1, depthDiff);
*/
        float camDelta = length(cameraPosition - previousCameraPosition);
        float reset = float(frameCounter < 2 || camDelta > 16.0);

        vec4 historyWeight = vec4(0.95, 0.95, 0.95, 0.5) * normalOk * (1.0 - reset);

        vec4 preColor = texture(colortex6, preScreenPos.xy * 0.5);
        return mix(curColor, preColor, saturate(historyWeight));
    }

    float godrayTemporal(float curColor, vec3 preScreenPos) {
        if(outScreen(preScreenPos.xy - vec2(invViewSize.x, invViewSize.y))) return curColor;

        float preColor = texture(colortex6, preScreenPos.xy * 0.5 + 0.5).a;
        return mix(preColor, curColor, 0.25);
    }

    vec4 cloudTemporal(vec4 curColor, vec3 worldPos) {
        vec3 preScreenPos = getPreScreenPos(worldPos);
        if(outScreen(preScreenPos.xy - vec2(invViewSize.x, -invViewSize.y))) return curColor;

        vec4 preColor = texture(colortex6, preScreenPos.xy * 0.5 + vec2(0.5, 0.0));
        return mix(preColor, curColor, 0.25);
    }

#endif