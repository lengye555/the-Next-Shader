#ifndef SKY_GLSL
    #define SKY_GLSL a

    vec3 RenderSky(vec3 dir) {
        float d = sqrt(max0(pow2(cameraHeight) - pow2(EarthRadius + ReferenceHeight)));
        float r = cameraHeight;
        float sintheta = -d / r;
        if(dir.y < sintheta) {
            vec2 dirxz = normalize(vec2(dir.x, dir.z));
            dirxz *= sqrt(max0(1.0 - pow2(sintheta)));
            dir = vec3(dirxz.x, sintheta, dirxz.y);
            dir = normalize(dir);
        }

        vec3  pos = cameraLocation;
        vec2  lenToAtmos = rayIntersectSphereVec2(pos, dir, AtmosphereRadiusSquared);
        float lenToEarth = rayIntersectSphere(pos, dir, EarthRadiusSquared);

        float len = 0.0;
        if(cameraHeight < AtmosphereRadius) {
            if(lenToEarth > 0.0) {
                len = lenToEarth;
            } else {
                len = lenToAtmos.y;
            }

        } else {
            if(lenToAtmos.x < 0.0) return vec3(0.0);

            if(lenToEarth > 0.0) {
                len = max0(lenToEarth - lenToAtmos.x);
            } else {
                len = max0(lenToAtmos.y - lenToAtmos.x);
            }

            pos += dir * lenToAtmos.x;
        }

        vec3 sun_skycol = vec3(0.0);
        if(rayIntersectSphere(vec3(0.0, AtmosphereRadius, 0.0), sunDir, EarthRadiusSquared) <= 0.0) {
            sun_skycol = AtmosphereScattering(pos, dir, len, sunDir, sunLuminance);
        }

        vec3 moon_skycol = vec3(0.0);
        if(rayIntersectSphere(vec3(0.0, AtmosphereRadius, 0.0), moonDir, EarthRadiusSquared) <= 0.0) {
            moon_skycol = AtmosphereScattering(pos, dir, len, moonDir, moonLuminance);
        }

        return (sun_skycol + moon_skycol);
    }

    vec3 drawSun(vec3 skyColor, vec3 worldDir) {
        float r2 = dot(cameraLocation, cameraLocation);
        float d = sqrt(max(0.0, r2 - EarthRadiusSquared));
        float r = sqrt(max(r2, 1e-12));

        vec3 suncol = sunLuminance * TransToAtmos(cameraLocation, worldDir) * 100.0;
        float VdotL = dot(worldDir, sunDir);
        if(VdotL > 0.9998 && worldDir.y > -d / r + 0.04) {
            skyColor += suncol;
        }
        if(VdotL > 0.9995 && worldDir.y > -d / r + 0.04) {
            skyColor += mix(suncol, vec3(0.0), sqrt(smoothstep(1.0, 0.9995, VdotL)));
        }

        return skyColor;
    }

    vec2 skyboxuvwarp(vec2 uv) {
        float r = length(cameraLocation);
        float s = EarthRadius / r;
        float y = -sqrt(-s * s + 1.0);
        float t = saturate(y * 0.5 + 0.5);

        float x = uv.y < t ? linearstep(t, 0.0, uv.y) : linearstep(t, 1.0, uv.y);
        x = pow4(x);

        return vec2(uv.x, uv.y < t ? (-x * t + t) : (x * (1.0 - t) + t));
    }
    vec2 skyboxuvunwarp(vec2 uv) {
        float r = length(cameraLocation);
        float s = EarthRadius / r;
        float y = -sqrt(-s * s + 1.0);
        float t = saturate(y * 0.5 + 0.5);

        float x = uv.y < t ? linearstep(t, 0.0, uv.y) : linearstep(t, 1.0, uv.y);
        x = (sqrt(sqrt(x)));

        return vec2(uv.x, uv.y < t ? (-x * t + t) : (x * (1.0 - t) + t));
    }

    vec3 sampleSkybox(vec3 dir) {
        vec2 uv = sph2tex(dir);
        return texture(colortex5, uv * 0.25 - 0.0005).rgb;
    }

    vec4 ToSphericalHarmonics(float x, vec3 v) {
        return vec4(v * x, x);
    }
    vec3 FromSphericalHarmonics(vec4 shR, vec4 shG, vec4 shB, vec3 v) {
        vec4 sh = vec4(v * 0.57735026919, 0.5);
        return vec3(dot(shR, sh), dot(shG, sh), dot(shB, sh));
    }
    void SetSkylightSH(out vec4 skySHR, out vec4 skySHG, out vec4 skySHB) {
        skySHR = vec4(0.0);
        skySHG = vec4(0.0);
        skySHB = vec4(0.0);

        const float iSteps = 8.0;
        const float jSteps = 16.0;

        for (float i = 0.0; i < iSteps; i++) {
            float alpha;
            if(true) {
                alpha = (i) * (PI * 0.5 / iSteps);//only sample the upper half sphere
            } else {
                alpha = (i) * (PI * -0.1 / iSteps);
            }
            //float alpha = (i) * (PI / iSteps) - (PI / 2.0);
            float cosAlpha = cos(alpha);
            float sinAlpha = sin(alpha);
            for(float j = 0.0; j < jSteps; j++) {
                float beta = (j) * (PI * 2.0 / jSteps);
                float cosBeta = cos(beta);
                float sinBeta = sin(beta);

                vec3 dir = vec3(cosAlpha * cosBeta, sinAlpha, cosAlpha * sinBeta);
                vec3 col = sampleSkybox(dir);
                skySHR += ToSphericalHarmonics(col.r, dir);
                skySHG += ToSphericalHarmonics(col.g, dir);
                skySHB += ToSphericalHarmonics(col.b, dir);
            }
        }

        const float steps = iSteps * jSteps;

        skySHR /= steps;
        skySHG /= steps;
        skySHB /= steps;
    }

#endif
