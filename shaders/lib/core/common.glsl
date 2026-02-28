////////////////////////////////////数学运算//////////////////////////////////

float pow3_2(float x) {
    return x * sqrt(x);
}
vec2 pow3_2(vec2 x) {
    return x * sqrt(x);
}
vec3 pow3_2(vec3 x) {
    return x * sqrt(x);
}
vec4 pow3_2(vec4 x) {
    return x * sqrt(x);
}
float pow2(float x) {
    return x * x;
}
vec2 pow2(vec2 x) {
    return x * x;
}
vec3 pow2(vec3 x) {
    return x * x;
}
vec4 pow2(vec4 x) {
    return x * x;
}
float pow3(float x) {
    float x2 = x * x;
    return x2 * x;
}
vec2 pow3(vec2 x) {
    vec2 x2 = x * x;
    return x2 * x;
}
vec3 pow3(vec3 x) {
    vec3 x2 = x * x;
    return x2 * x;
}
vec4 pow3(vec4 x) {
    vec4 x2 = x * x;
    return x2 * x;
}
float pow4(float x) {
    float x2 = x * x;
    return x2 * x2;
}
vec2 pow4(vec2 x) {
    vec2 x2 = x * x;
    return x2 * x2;
}
vec3 pow4(vec3 x) {
    vec3 x2 = x * x;
    return x2 * x2;
}
vec4 pow4(vec4 x) {
    vec4 x2 = x * x;
    return x2 * x2;
}
float pow5(float x) {
    float x2 = x * x;
    return x2 * x2 * x;
}
vec2 pow5(vec2 x) {
    vec2 x2 = x * x;
    return x2 * x2 * x;
}
vec3 pow5(vec3 x) {
    vec3 x2 = x * x;
    return x2 * x2 * x;
}
vec4 pow5(vec4 x) {
    vec4 x2 = x * x;
    return x2 * x2 * x;
}
float pow10(float x) {
    float x2 = x * x;
    float x4 = x2 * x2;
    return x4 * x4 * x2;
}

float fastSin(float x) {
    x = mod(x + PI, _2PI) - PI;
    float x2 = x * x;
    return x * (1.0 - x2 / 6.0 * (1.0 - x2 / 20.0 * (1.0 - x2 / 42.0)));
}
float fastCos(float x) {
    return fastSin(x + HALF_PI);
}

float max0(float x) {
    return max(0.0, x);
}
vec2 max0(vec2 x) {
    return max(vec2(0.0), x);
}
vec3 max0(vec3 x) {
    return max(vec3(0.0), x);
}
vec4 max0(vec4 x) {
    return max(vec4(0.0), x);
}

float saturate(float x) {
    return clamp(x, 0.0, 1.0);
}
vec2 saturate(vec2 x) {
    return clamp(x, vec2(0.0), vec2(1.0));
}
vec3 saturate(vec3 x) {
    return clamp(x, vec3(0.0), vec3(1.0));
}
vec4 saturate(vec4 x) {
    return clamp(x, vec4(0.0), vec4(1.0));
}

float linearstep(float a, float b, float x) {
    return saturate((x - a) / (max(b - a, 1e-5)));
}
vec2 linearstep(vec2 a, vec2 b, float x) {
    return saturate((vec2(x) - a) / (max(b - a, 1e-5)));
}
vec3 linearstep(vec3 a, vec3 b, float x) {
    return saturate((vec3(x) - a) / (max(b - a, 1e-5)));
}
vec4 linearstep(vec4 a, vec4 b, float x) {
    return saturate((vec4(x) - a) / (max(b - a, 1e-5)));
}

float remap(float x, float a, float b, float c, float d) {
    return (x - a) / (max(b - a, 1e-5)) * (d - c) + c;
}
vec2 remap(vec2 x, vec2 a, vec2 b, vec2 c, vec2 d) {
    return (x - a) / (max(b - a, 1e-5)) * (d - c) + c;
}
vec3 remap(vec3 x, vec3 a, vec3 b, vec3 c, vec3 d) {
    return (x - a) / (max(b - a, 1e-5)) * (d - c) + c;
}
vec4 remap(vec4 x, vec4 a, vec4 b, vec4 c, vec4 d) {
    return (x - a) / (max(b - a, 1e-5)) * (d - c) + c;
}

float remapSaturate(float x, float a, float b, float c, float d) {
    return saturate((x - a) / (max(b - a, 1e-5))) * (d - c) + c;
}
vec2 remapSaturate(vec2 x, vec2 a, vec2 b, vec2 c, vec2 d) {
    return saturate((x - a) / (max(b - a, 1e-5))) * (d - c) + c;
}
vec3 remapSaturate(vec3 x, vec3 a, vec3 b, vec3 c, vec3 d) {
    return saturate((x - a) / (max(b - a, 1e-5))) * (d - c) + c;
}
vec4 remapSaturate(vec4 x, vec4 a, vec4 b, vec4 c, vec4 d) {
    return saturate((x - a) / (max(b - a, 1e-5))) * (d - c) + c;
}

float smoothmin(float a, float b, float k) {
    float h = saturate(0.5 + 0.5 * (b - a) / k);
    return mix(b - k * h, a, h);
}
vec2 smoothmin(vec2 a, vec2 b, float k) {
    vec2 h = saturate(0.5 + 0.5 * (b - a) / vec2(k));
    return mix(b - k * h, a, h);
}
vec3 smoothmin(vec3 a, vec3 b, float k) {
    vec3 h = saturate(0.5 + 0.5 * (b - a) / vec3(k));
    return mix(b - k * h, a, h);
}
vec4 smoothmin(vec4 a, vec4 b, float k) {
    vec4 h = saturate(0.5 + 0.5 * (b - a) / vec4(k));
    return mix(b - k * h, a, h);
}
float smoothmax(float a, float b, float k) {
    return -smoothmin(-a, -b, k);
}
vec2 smoothmax(vec2 a, vec2 b, float k) {
    return -smoothmin(-a, -b, k);
}
vec3 smoothmax(vec3 a, vec3 b, float k) {
    return -smoothmin(-a, -b, k);
}
vec4 smoothmax(vec4 a, vec4 b, float k) {
    return -smoothmin(-a, -b, k);
}

vec4 textureNice(sampler2D sam, vec2 uv, vec2 resolution) {
    uv = uv * resolution + 0.5;
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    uv = iuv + fuv * fuv * (3.0 - 2.0 * fuv);
    uv = (uv - 0.5) / resolution;
    return texture(sam, uv);
}

/////////////////////////////////////矩阵运算/////////////////////////////////////

vec3 matrixMultiply(mat4 matrix, vec4 vector) {
    return (matrix * vector).xyz;
}
vec3 projectAndDivide(mat4 projectionMatrix, vec4 position) {
    vec4 homPos = projectionMatrix * position;
    return homPos.xyz / homPos.w;
}

vec3 ViewSpaceToScreenSpace(vec3 viewPosition, mat4 projection) {
	vec3 screenPosition = vec3(projection[0].x, projection[1].y, projection[2].z) * viewPosition + projection[3].xyz;

	return screenPosition * (0.5 / -viewPosition.z) + 0.5;
}
vec3 ScreenSpaceToViewSpace(vec3 screenPosition, mat4 projectionInverse) {
	screenPosition = screenPosition * 2.0 - 1.0;

	vec3 viewPosition  = vec3(vec2(projectionInverse[0].x, projectionInverse[1].y) * screenPosition.xy + projectionInverse[3].xy, projectionInverse[3].z);
	     viewPosition /= projectionInverse[2].w * screenPosition.z + projectionInverse[3].w;

	return viewPosition;
}

vec3 GetViewPosition(vec2 coord, float depth) {
    #ifdef TAA
        coord -= taaJitter * TAA_Intensity * 0.5;
    #endif

    return ScreenSpaceToViewSpace(vec3(coord, depth), gbufferProjectionInverse);
}

vec3 getPreScreenPos(vec3 worldPos){
    vec3 cameraOffset = cameraPosition - previousCameraPosition;
    vec4 prePos = vec4(worldPos + cameraOffset, 1.0);
    prePos = gbufferPreviousModelView * prePos;
    prePos = gbufferPreviousProjection * prePos;
    return prePos.xyz / prePos.w * 0.5 + 0.5;
}
vec2 getPreCoord(vec2 coord) {
    float hitDepth = texture(depthtex1, coord).r;
    if(hitDepth > 1.0) return coord;

    vec3 hitViewPos = GetViewPosition(coord, hitDepth);
    vec3 hitWorldPos = matrixMultiply(gbufferModelViewInverse, vec4(hitViewPos, 1.0));
    return getPreScreenPos(hitWorldPos).xy;
}

vec3 shadowDistort(vec3 shadowCilpPos) {
    float dist = length(shadowCilpPos.xy);
    float distortFactor = mix(1.0, dist, SHADOW_BIAS);
    shadowCilpPos.xy /= distortFactor;
    shadowCilpPos.z = mix(shadowCilpPos.z, 0.5, 0.8);

    return shadowCilpPos;
}
vec3 shadowUnDistort(vec3 shadowCilpPos) {
    float r = length(shadowCilpPos.xy);
    float a = 1.0 - SHADOW_BIAS;
    float b = SHADOW_BIAS;
    shadowCilpPos.xy *= a / (1.0 - b * r);
    shadowCilpPos.z = (shadowCilpPos.z - 0.5 * 0.8) / 0.2;

    return shadowCilpPos;
}

vec3 WorldSpaceToShadowSpace(vec3 worldPosition) {
    vec4 shadowViewPosition = shadowModelView * vec4(worldPosition, 1.0);
    vec4 shadowClipPosition = shadowProjection * shadowViewPosition;
    shadowClipPosition.xyz = shadowDistort(shadowClipPosition.xyz);

    vec3 shadowNdcPosition = shadowClipPosition.xyz / shadowClipPosition.w;
    vec3 shadowScreenPosition = shadowNdcPosition * 0.5 + 0.5;

    return shadowScreenPosition;
}
vec3 WorldSpaceToShadowSpaceNoDistort(vec3 worldPosition) {
    vec4 shadowViewPosition = shadowModelView * vec4(worldPosition, 1.0);
    vec4 shadowClipPosition = shadowProjection * shadowViewPosition;

    vec3 shadowNdcPosition = shadowClipPosition.xyz / shadowClipPosition.w;
    vec3 shadowScreenPosition = shadowNdcPosition * 0.5 + 0.5;

    return shadowScreenPosition;
}
vec3 ShadowSpaceToWorldSpace(vec3 shadowScreenPosition) {
    vec3 shadowClipPosition = shadowScreenPosition * 2.0 - 1.0;
    shadowClipPosition = shadowUnDistort(shadowClipPosition);
    vec4 shadowViewPosition = shadowProjectionInverse * vec4(shadowClipPosition, 1.0);
    shadowViewPosition /= shadowViewPosition.w;

    return matrixMultiply(shadowModelViewInverse, shadowViewPosition);
}
vec3 ShadowSpaceToWorldSpaceNoDistort(vec3 shadowScreenPosition) {
    vec3 shadowClipPosition = shadowScreenPosition * 2.0 - 1.0;
    vec4 shadowViewPosition = shadowProjectionInverse * vec4(shadowClipPosition, 1.0);
    shadowViewPosition /= shadowViewPosition.w;

    return matrixMultiply(shadowModelViewInverse, shadowViewPosition);
}

float shadowLinearDepth(vec2 uv, float depth) {
    vec3 shadowClipPos = vec3(uv, depth) * 2.0 - 1.0;
    shadowClipPos = shadowUnDistort(shadowClipPos);
    vec4 shadowViewPos = shadowProjectionInverse * vec4(shadowClipPos, 1.0);
    shadowViewPos /= shadowViewPos.w;
    return -shadowViewPos.z;
}

float exponentialDepth(float linDepth) {
    float z = (far + near - 2.0 * near * far / linDepth) / (far - near);
    return (z + 1.0) * 0.5;
}
float linearDepth(float expDepth) {
    float z = expDepth * 2.0 - 1.0;
    return (2.0 * near * far) / (far + near - z * (far - near));
}
float linearDepth(sampler2D depthtex, vec2 uv) {
    float z = texture(depthtex, uv).r * 2.0 - 1.0;
	return (2.0 * near * far) / (far + near - z * (far - near));
}

/////////////////////////////////////数据包装/////////////////////////////////////

vec2 OctWrap(vec2 v) {
    return (1.0 - abs(v.yx)) * (step(vec2(0.0), v.xy) * 2.0 - 1.0);
}
vec2 normalEncode(vec3 n) {
    n /= (abs(n.x) + abs(n.y) + abs(n.z));
    n.xy = n.z >= 0.0 ? n.xy : OctWrap(n.xy);
    n.xy = n.xy * 0.5 + 0.5;
    return n.xy;
}
vec3 normalDecode(vec2 encN) {
    encN = encN * 2.0 - 1.0;
    vec3 n;
    n.z = 1.0 - abs(encN.x) - abs(encN.y);
    n.xy = n.z >= 0.0 ? encN.xy : OctWrap(encN.xy);
    n = normalize(n);
    return n;
}

float PackTwo16BitTo32Bit(vec2 v) {
    return dot(floor(v * 8191.9999), vec2(1.0 / 8192.0 , 1.0));
}
vec2 UnpackTwo16BitFrom32Bit(float v) {
    return vec2(fract(v) * (8192.0 / 8191.0), floor(v) / 8191.0);
}

float PackTwo8BitTo16Bit(vec2 v) {
	float data;

	v.x = clamp(v.x, 0.0, 255.0 / 256.0);
	v.y = clamp(v.y, 0.0, 255.0 / 256.0);

	v.x *= 255.0;
	v.y *= 255.0;

	v.x = floor(v.x);
	v.y = floor(v.y);

	data = v.x * exp2(8.0);
	data += v.y;



	data /= exp2(16.0) - 1;

	return data;
}
vec2 UnpackTwo8BitFrom16Bit(float value) {
	vec2 data;

	value *= exp2(16.0) - 1;

	data.x = floor(value / exp2(8.0));
	data.y = mod(value, exp2(8.0));

	data.x /= 255.0;
	data.y /= 255.0;

	return data;
}

/////////////////////////////////////噪声/////////////////////////////////////

float sample2DNoise(vec2 p) {
    return textureNice(noisetex, p / noiseTextureResolution, vec2(noiseTextureResolution)).r;
}
float sample3DNoise(vec3 p) {
    vec3 pi = floor(p);
    vec3 pf = fract(p);

    vec2 uv = (pi.xz + vec2(37.0, 17.0) * pi.y) + pf.xz;
    float n1 = sample2DNoise(uv);
    float n2 = sample2DNoise(uv + vec2(37.0, 17.0));

    return mix(n1, n2, pf.y);
}

uint HashWellons32(uint x){
	x ^= x >> 17;
	x *= 0xed5ad4bbu;
	x ^= x >> 11;
	x *= 0xac4c1b51u;
	x ^= x >> 15;
	x *= 0x31848babu;
	x ^= x >> 14;
	return x;
}

float u01(uint x) {
    return float(x) * (1.0 / 4294967296.0);
}
uint hash_uvec2(uvec2 v) {
    uint h = HashWellons32(v.x);
    h = HashWellons32(h ^ v.y);
    return h;
}
uint hash_uvec3(uvec3 v) {
    uint h = HashWellons32(v.x);
    h = HashWellons32(h ^ v.y);
    h = HashWellons32(h ^ v.z);
    return h;
}

float rand2_1(vec2 p) {
    return u01(hash_uvec2(floatBitsToUint(p)));
}
float rand3_1(vec3 p) {
    return u01(hash_uvec3(floatBitsToUint(p)));
}
vec2 rand2_2(vec2 p) {
    uint h = hash_uvec2(floatBitsToUint(p));
    h = HashWellons32(h);
    float x = u01(h);
    h = HashWellons32(h);
    float y = u01(h);
    return vec2(x, y);
}
vec2 rand3_2(vec3 p) {
    uint h = hash_uvec3(floatBitsToUint(p));
    h = HashWellons32(h);
    float x = u01(h);
    h = HashWellons32(h);
    float y = u01(h);
    return vec2(x, y);
}
vec3 rand2_3(vec2 p) {
    uint h = hash_uvec2(floatBitsToUint(p));
    h = HashWellons32(h);
    float x = u01(h);
    h = HashWellons32(h);
    float y = u01(h);
    h = HashWellons32(h);
    float z = u01(h);
    return vec3(x, y, z);
}
vec3 rand3_3(vec3 p) {
    uint h = hash_uvec3(floatBitsToUint(p));
    h = HashWellons32(h);
    float x = u01(h);
    h = HashWellons32(h);
    float y = u01(h);
    h = HashWellons32(h);
    float z = u01(h);
    return vec3(x, y, z);
}

float hashInt(ivec2 p) {
    int n = p.x * 3 + p.y * 113;

	n = (n << 13) ^ n;
    n = n * (n * n * 15731 + 789221) + 1376312589;
    return -1.0 + 2.0 * float(n & 0x0fffffff) / float(0x0fffffff);
}
float noise(vec2 p) {
    ivec2 i = ivec2(floor(p));
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    vec4 h = vec4(hashInt(i + ivec2(0)), hashInt(i + ivec2(0, 1)), hashInt(i + ivec2(1, 0)), hashInt(i + ivec2(1)));

    vec2 n = mix(h.xy, h.zw, u.x);
    return mix(n.x, n.y, u.y);
}

vec2 hash22(vec2 p) {
    p = vec2( dot(p,vec2(127.1,311.7)),
              dot(p,vec2(269.5,183.3)));

    return -1.0 + 2.0 * fract(sin(p)*43758.5453123);
}
vec2 hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+19.19);
    return -1. + 2.*fract((p3.xx+p3.yz)*p3.zy);
}
float simplex2d(vec2 p){
    const float K1 = 0.366025404;
    const float K2 = 0.211324865;

    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - (i - (i.x + i.y) * K2);
    vec2 o = (a.x < a.y) ? vec2(0.0, 1.0) : vec2(1.0, 0.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;
    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    vec3 n = h * h * h * h * vec3(dot(a, hash(i)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));

    return dot(vec3(70.0, 70.0, 70.0), n) * 0.5 + 0.5;
}

float worley2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float d1 = 1e10;
    float d2 = 1e10;

    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 g = vec2(x, y);
            vec2 cell = i + g;
            vec2 r = rand2_2(cell);
            vec2 d = g + r - f;
            float dist2 = dot(d, d);

            if(dist2 < d1) {
                d2 = d1;
                d1 = dist2;
            } else if(dist2 < d2) {
                d2 = dist2;
            }
        }
    }

    d1 = sqrt(d1);
    d2 = sqrt(d2);
    return saturate(d2 - d1);
}
float worley2DCell(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float d1 = 1e10;

    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 g = vec2(x, y);
            vec2 cell = i + g;
            vec2 r = rand2_2(cell);
            vec2 d = g + r - f;
            d1 = min(d1, dot(d, d));
        }
    }

    float F1 = sqrt(d1);
    return saturate(F1 / 1.41421356237);
}

vec2 perlin2DGrad(vec2 p) {
    float a = rand2_1(p) * (PI * 2.0);
    return vec2(cos(a), sin(a));
}
float perlin2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

    float n00 = dot(perlin2DGrad(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0));
    float n10 = dot(perlin2DGrad(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float n01 = dot(perlin2DGrad(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float n11 = dot(perlin2DGrad(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));

    float nx0 = mix(n00, n10, u.x);
    float nx1 = mix(n01, n11, u.x);
    float nxy = mix(nx0, nx1, u.y);

    return saturate(0.5 + 0.5 * nxy * 1.41421356237);
}

float getBlueNoise(vec2 coord) {
    float blueNoise = texelFetch(noisetex, ivec2(coord) % noiseTextureResolution, 0).r;
    return fract(blueNoise + float(frameCounter) * GOLDEN_RATIO);
}
#ifdef FSH
    float blueNoise  = getBlueNoise(gl_FragCoord.xy * vec2(1.0, 1.0) + vec2(0.0, 0.0));
    float blueNoise1 = getBlueNoise(gl_FragCoord.xy * vec2(1.61803398875, 2.41421356237) + vec2(17.0, 37.0));
    float blueNoise2 = getBlueNoise(gl_FragCoord.yx * vec2(0.70710678118, 1.32471795724) + vec2(113.0, 271.0));
/*
    uint randSeed = HashWellons32(uint(gl_FragCoord.x + viewSize.x * gl_FragCoord.y) * uint(frameCounter));
    uint HashWellons() {
        return randSeed = HashWellons32(randSeed);
    }
    #define RandWellons() (float(HashWellons()) / float(0xffffffffu))

	float whiteNoise  = RandWellons();
	float whiteNoise1 = RandWellons();
	float whiteNoise2 = RandWellons();
*/
#endif

/////////////////////////////////////常用工具/////////////////////////////////////

float getPhase(float cos_theta, float g) {
    float g2 = g * g;

    float a = 3.0 / (8.0 * PI);
    float b = (1.0 - g2) / (2.0 + g2);
    float c = 1.0 + cos_theta * cos_theta;
    float d = pow3_2(max(1e-7, 1.0 + g2 - 2.0 * g * cos_theta));

    return a * b * (c / d);
}

vec3 tex2sph(vec2 uv){
    uv *= vec2(PI * 2.0, PI);
    vec2 p = vec2(sin(uv.x), cos(uv.x)) * sin(uv.y);
    return vec3(p.x, (2.0 / PI) * uv.y - 1.0, p.y);
}
vec2 sph2tex(vec3 dir){
    float l = atan(-dir.x, -dir.z);
    return vec2(l * (0.5 / PI) + 0.5, 0.5 * dir.y + 0.5);
}

float rayIntersectSphere(vec3 P, vec3 dir, float R2) {
    float PoD = dot(P, dir);
    float r2 = dot(P, P);
    float discriminant = R2 - r2 + PoD * PoD;

    if((R2 < r2 && PoD > 0.0) || discriminant < 0.0) return -1.0;

    discriminant = sqrt(discriminant);
    return (R2 > r2 ? discriminant : -discriminant) - PoD;
}
vec2 rayIntersectSphereVec2(vec3 P, vec3 dir, float R2) {
    float PoD = dot(P, dir);
    float r2 = dot(P, P);
    float discriminant = R2 - r2 + PoD * PoD;

    if(discriminant < 0.0) return vec2(-1.0);

    discriminant = sqrt(discriminant);
    return vec2(-PoD - discriminant, -PoD + discriminant);
}
vec2 standardRayIntersectSphere(vec3 pos, vec3 dir, vec3 ballCenter, float R) {
    vec3 P = pos - ballCenter;
    float PoD = dot(P, dir);
    float r2 = dot(P, P);
    float R2 = R * R;
    float discriminant = R2 - r2 + PoD * PoD;

    if(discriminant < 0.0) return vec2(-1.0);

    discriminant = sqrt(discriminant);
    return vec2(-PoD - discriminant, -PoD + discriminant);
}

vec3 LinearToGamma(vec3 c) {
    return pow(c, vec3(1.0 / 2.2));
}
vec3 GammaToLinear(vec3 c) {
    return pow(c, vec3(2.2));
}
float getLuminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}
vec3 saturation(vec3 color, float t) {
    return mix(vec3(getLuminance(color)), color, t);
}

bool outScreen(vec2 uv) {
    return uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0;
}
bool inScreen(vec2 uv) {
    return uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0;
}

#ifdef FSH
    void screenRayTracing(vec3 viewPos, vec3 rayDir, inout vec3 screenPos, inout bool isHit) {
        const int sampleCount = 200;

        float jitter = blueNoise;

        float ds = 0.05;
        vec3 stepVec = rayDir * ds;

        isHit = false;
        for(int i = 0; i < sampleCount; i++) {
            float fi = float(i);
            vec3 testPoint = viewPos + stepVec * (fi + jitter);

            vec3 newScreenPos = ViewSpaceToScreenSpace(testPoint, gbufferProjection);
            if(outScreen(newScreenPos.xy)) break;

            float testDepth = -testPoint.z;
            float sampleDepth = -GetViewPosition(newScreenPos.xy, texture(depthtex1, newScreenPos.xy).r).z;

            if(testDepth > sampleDepth && testDepth - sampleDepth < ds) {
                float isturnback = 1.0;
                vec3 haflStepVec = stepVec * 0.5;
                for(int j = 0; j < 4; j++) {
                    testPoint -= haflStepVec * isturnback;

                    newScreenPos = ViewSpaceToScreenSpace(testPoint, gbufferProjection);

                    testDepth = -testPoint.z;
                    sampleDepth = -GetViewPosition(newScreenPos.xy, texture(depthtex1, newScreenPos.xy).r).z;

                    isturnback = (testDepth > sampleDepth && testDepth - sampleDepth < length(haflStepVec)) ? 1.0 : -1.0;
                    haflStepVec *= 0.5;
                }
                screenPos = newScreenPos;
                isHit = true;
                break;
            }
        }
    }
    void screenRayTracingDDA(vec3 startViewPos, vec3 rayDirView, inout vec2 screenPos, inout bool isHit) {
        vec4 rayDirTempClip = gbufferProjection * vec4(startViewPos + rayDirView, 1.0);
        vec3 rayDirTempNDC = rayDirTempClip.xyz / rayDirTempClip.w;
        vec3 rayDirTempScreen = rayDirTempNDC;
        rayDirTempScreen = rayDirTempScreen * 0.5 + 0.5;

        vec3 startScreenPos = ViewSpaceToScreenSpace(startViewPos, gbufferProjection).xyz;
        vec3 rayDirScreen = normalize(rayDirTempScreen - startScreenPos);
        vec3 rcpRayDirScreen = 1.0 / rayDirScreen;

        float maxT = 10000.0;
        maxT = rayDirScreen.z != 0.0f ? min((float(rayDirScreen.z > 0.0f) - startScreenPos.z) * rcpRayDirScreen.z, maxT) : maxT;
        maxT = rayDirScreen.x != 0.0f ? min((float(rayDirScreen.x > 0.0f) - startScreenPos.x) * rcpRayDirScreen.x, maxT) : maxT;
        maxT = rayDirScreen.y != 0.0f ? min((float(rayDirScreen.y > 0.0f) - startScreenPos.y) * rcpRayDirScreen.y, maxT) : maxT;

        vec3 endScreenPos = startScreenPos + rayDirScreen * maxT;
        vec3 endViewPos = ScreenSpaceToViewSpace(endScreenPos, gbufferProjectionInverse);

        float inverseStartViewZ = 1.0 / startViewPos.z;
        float inverseEndViewZ = 1.0 / endViewPos.z;

        const int steps = 16;
        const float fs = float(steps);

        float jitter = blueNoise;

        isHit = false;
        for(int i = 0; i < steps; i++) {
            float fi = float(i);
            float t = (fi + jitter) / fs;

            vec2 newScreenPos = mix(startScreenPos.xy, endScreenPos.xy, t);
            if(outScreen(newScreenPos)) break;

            float inverseViewZ = mix(inverseStartViewZ, inverseEndViewZ, t);
            float viewPosZ = 1.0 / inverseViewZ;
            if(viewPosZ > -near || viewPosZ < -far) break;

            float testDepth = -viewPosZ;
            float sampleDepth = -GetViewPosition(newScreenPos.xy, texture(depthtex1, newScreenPos.xy).r).z;

            float thickness = remapSaturate(testDepth, near, far, 1.0, 100.0);
            if(testDepth > sampleDepth && testDepth - sampleDepth < thickness) {
                float isturnback = 1.0;
                float haflstep = 0.5 / fs;
                for(int j = 0; j < 4; j++) {
                    t -= haflstep * isturnback;

                    newScreenPos = mix(startScreenPos.xy, endScreenPos.xy, t);
                    inverseViewZ = mix(inverseStartViewZ, inverseEndViewZ, t);

                    testDepth = -1.0 / inverseViewZ;
                    sampleDepth = -GetViewPosition(newScreenPos.xy, texture(depthtex1, newScreenPos.xy).r).z;

                    isturnback = (testDepth > sampleDepth && testDepth - sampleDepth < thickness) ? 1.0 : -1.0;
                    haflstep *= 0.5;
                    thickness *= 0.5;
                }
                screenPos = newScreenPos;
                isHit = true;
                break;
            }
        }
    }
#endif

/////////////////////////////////////BRDF/////////////////////////////////////

vec3 Oren_Nayar(vec3 albedo, float roughness, vec3 N, vec3 V, vec3 L, float NdotV, float NdotL) {
    float a = roughness * roughness;
    float A = 1.0 - 0.5 * a / (a + 0.33);
    float B = 0.45 * a / (a + 0.09);

    vec3 V_tangent = V - N * NdotV;
    vec3 L_tangent = L - N * NdotL;
    float cosPhiDiff = 0.0;
    if(length(V_tangent) > 1e-5 && length(L_tangent) > 1e-5) {
        vec3 V_dir = normalize(V_tangent);
        vec3 L_dir = normalize(L_tangent);
        cosPhiDiff = dot(V_dir, L_dir);
    }

    float cosAlpha = min(NdotV, NdotL);
    float cosBeta  = max(NdotV, NdotL);
    float sinAlpha = sqrt(max(0.0, 1.0 - cosAlpha * cosAlpha));
    float tanBeta  = sqrt(max(0.0, 1.0 - cosBeta * cosBeta)) / max(cosBeta, 1e-5);

    return albedo / PI * (A + B * max(0.0, cosPhiDiff) * sinAlpha * tanBeta);
}

float fresnelSchlick(float cosTheta, float F0) {
    return F0 + (1.0 - F0) * pow5(saturate(1.0 - cosTheta));
}
vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow5(saturate(1.0 - cosTheta));
}

float DistributionGGX(vec3 N, vec3 H, float roughness) {
    float a      = roughness*roughness;
    float a2     = a*a;
    float NdotH  = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;

    float num   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return num / max(denom, 1e-7);
}

float GeometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;

    float num   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return num / denom;
}
float GeometrySmith(float NdotV, float NdotL, float roughness) {
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}

vec3 Cook_Torrance_BRDF(vec3 albedo, float roughness, float metallic, vec3 N, vec3 V, vec3 L) {
    roughness = max(roughness, 0.02); // 避免低粗糙度下的数值问题

    vec3 F0 = vec3(0.04); 
    F0 = mix(F0, albedo, metallic);

	vec3 H = normalize(V + L);

    float NdotV = max(dot(N, V), 0.001);
    float NdotL = max(dot(N, L), 0.001);

	float NDF = DistributionGGX(N, H, roughness);
	float G = GeometrySmith(NdotV, NdotL, roughness);
	vec3 F = fresnelSchlick(max(dot(H, V), 0.0), F0);

	vec3 numerator = NDF * G * F;
	float denominator = 4.0 * NdotV * NdotL;
	vec3 specular = numerator / denominator;

	vec3 kS = F;
	vec3 kD = vec3(1.0) - kS;
	kD *= 1.0 - metallic;

    vec3 diffuse = Oren_Nayar(albedo, roughness, N, V, L, NdotV, NdotL);
    //vec3 diffuse = albedo / PI;

	return kD * diffuse + specular;
}

/////////////////////////////////////大气散射/////////////////////////////////////

float RayleighPhase(float cos_theta) {
	return (3.0 / (16.0 * PI)) * (1.0 + cos_theta * cos_theta);
}
float MiePhase(float cos_theta) {
    return getPhase(cos_theta, 0.7034);
}

float sampleRayleighDensity(float altitude) {
    #if AtmosphereType == 0

        float x = max0(altitude);

        const float a0 = 0.00947927584794;
        const float a1 = -0.138528179963;
        const float a2 = -0.00235619411773;
        return exp2(a0 + a1 * x + a2 * x * x);

    #else

        float x = max0(altitude);

        return exp(-x / RayleighScalarAltitude);

    #endif
}
float sampleMieDensity(float altitude) {
    float x = max0(altitude);

    return exp(-x / MieScalarAltitude);
}
float sampleOzoneDensity(float altitude) {
    #if AtmosphereType == 0

        float x = max0(altitude);
        float x2 = x * x;
        float x3 = x2 * x;
        float x4 = x2 * x2;

        const float d10 = 3.14463183276;
        const float d11 = 0.0498300739786;
        const float d12 = -0.13053950591;
        const float d13 = 0.021937805502;
        const float d14 = -0.000931031499395;
        float d1 = exp2(d10 + d11 * x + d12 * x2 + d13 * x3 + d14 * x4);

        const float d20 = -15.9975955967;
        const float d21 = 2.79421136239;
        const float d22 = -0.128226752502;
        const float d23 = 0.00249280242662;
        const float d24 = -0.0000185558309121;
        float d2 = exp2(d20 + d21 * x + d22 * x2 + d23 * x3 + d24 * x4);

        return d1 + d2;

    #else

        float x = max0(altitude);
        float center = 25.0;
        float width = 15.0;

        return max0(1.0 - abs(x - center) / width);

    #endif
}
vec3 sampleParticleDensity(float altitude) {
    vec3 density = vec3(
        sampleRayleighDensity(altitude),
        sampleMieDensity     (altitude),
        sampleOzoneDensity   (altitude));
    return density;
}
vec3 AtmosphereOpticalDepth(vec3 pos, vec3 dir, float len) {
    const int N_SAMPLE = 5;

    if(len <= 0.0) return vec3(0.0);

    float ds = len / float(N_SAMPLE);
    vec3 samplePos = pos;
    vec3 stepVec = dir * ds;

    float altitude0 = length(samplePos) - EarthRadius;
    vec3 density0 = sampleParticleDensity(altitude0);

    vec3 opticalDepth = vec3(0.0);
    for(int i = 0; i < N_SAMPLE; i++) {
        samplePos += stepVec;

        float altitude = length(samplePos) - EarthRadius;
        vec3 density = sampleParticleDensity(altitude);

        opticalDepth += density0 + density;
        density0 = density;
    }

    return opticalDepth * 0.5 * ds;
}

vec2 GetTransmittanceLutUV(vec3 pos, vec3 dir) {
    float r = length(pos);
    float mu = dot(pos / r, dir);

    float H = sqrt(AtmosphereRadiusSquared - EarthRadiusSquared);
    float rho = sqrt(r * r - EarthRadiusSquared);

    float discriminant = r * r * (mu * mu - 1.0) + AtmosphereRadiusSquared;
	float d = max0(-r * mu + sqrt(discriminant));

    float d_min = AtmosphereRadius - r;
    float d_max = rho + H;

    float x_mu = (d - d_min) / (d_max - d_min);
    float x_r = rho / H;

    return vec2(x_mu, x_r);
}
vec2 UvToTransmittanceLutParams(vec2 uv) {
    float x_mu = uv.x;
    float x_r = uv.y;

    float H = sqrt(max0(AtmosphereRadiusSquared - EarthRadiusSquared));
    float rho = H * x_r;
    float r = sqrt(max0(rho * rho + EarthRadiusSquared));

    float d_min = AtmosphereRadius - r;
    float d_max = rho + H;
    float d = d_min + x_mu * (d_max - d_min);
    float mu = d == 0.0 ? 1.0 : clamp((H * H - rho * rho - d * d) / (2.0 * r * d), -1.0, 1.0);

    return vec2(mu, r);
}
vec3 Transmittance(vec3 pos, vec3 dir, float dis) {
    vec3 optic = AtmosphereOpticalDepth(pos, dir, dis);
    return exp(-(optic.x * RayleighScatteringCoefficient + 
                 optic.y * MieScatteringCoefficient + 
                 optic.y * MieAbsorptionCoefficient + 
                 optic.z * OzoneAbsorptionCoefficient));
}
vec3 TransToAtmos(vec3 pos, vec3 dir) {
    #ifdef UseTransmittanceLut
        vec2 lutUV = GetTransmittanceLutUV(pos, dir);
        return texture(TransmittanceLut, lutUV * 0.1 + vec2(0.5, 0.0)).rgb;
    #else
        float lenToEarth = rayIntersectSphere(pos, dir, EarthRadiusSquared);
        if(lenToEarth > 0.0) return vec3(0.0);

        float len = rayIntersectSphere(pos, dir, AtmosphereRadiusSquared);
        if(len <= 0.0) return vec3(1.0);

        return Transmittance(pos, dir, len);
    #endif
}

vec3 AtmosphereScattering(vec3 pos, vec3 dir, float len, vec3 lightdir, vec3 lightcol) {
    const int N_SAMPLE = 16;

    if(len <= 0.0) return vec3(0.0);

    float ds = len / float(N_SAMPLE);
    vec3 stepVec = dir * ds;
    vec3 samplePos = pos;
    #ifdef FSH
        samplePos += stepVec * blueNoise * 0.1;
    #endif

    float altitude0 = length(samplePos) - EarthRadius;
    vec3 density0 = sampleParticleDensity(altitude0);

    vec3 optic_viewdir = vec3(0.0);

    vec3 trans_lightdir0 = TransToAtmos(samplePos, lightdir);
    vec3 trans0 = trans_lightdir0;

    vec3 scattering_rayleigh = vec3(0.0);
    vec3 scattering_mie = vec3(0.0);
    for(int i = 0; i < N_SAMPLE; i++) {
        samplePos += stepVec;

        float altitude = length(samplePos) - EarthRadius;
        vec3 density = sampleParticleDensity(altitude);

        optic_viewdir += (density0 + density) * 0.5 * ds;

        vec3 trans_lightdir = TransToAtmos(samplePos, lightdir);
        vec3 trans_viewdir = exp(-(optic_viewdir.x * RayleighScatteringCoefficient + 
                                   optic_viewdir.y * MieScatteringCoefficient + 
                                   optic_viewdir.y * MieAbsorptionCoefficient + 
                                   optic_viewdir.z * OzoneAbsorptionCoefficient));
        vec3 trans = trans_lightdir * trans_viewdir;

        scattering_rayleigh += trans0 * density0.x + trans * density.x;
        scattering_mie += trans0 * density0.y + trans * density.y;

        density0 = density;
        trans0 = trans;
    }
    scattering_rayleigh *= 0.5 * ds;
    scattering_mie *= 0.5 * ds;

    float cos_theta = dot(dir, lightdir);
    float phase_rayleigh = RayleighPhase(cos_theta);
    float phase_mie = MiePhase(cos_theta);

    return lightcol * (scattering_rayleigh * phase_rayleigh * RayleighScatteringCoefficient + 
                       scattering_mie * phase_mie * MieScatteringCoefficient);
}
mat2x3 AtmosphereScattering(vec3 pos, vec3 dir, float len, vec3 lightdir, vec3 lightcol, int N_SAMPLE) {
    float ds = len / float(N_SAMPLE);
    vec3 stepVec = dir * ds;
    vec3 samplePos = pos;
    #ifdef FSH
        samplePos += stepVec * blueNoise * 0.1;
    #endif

    float altitude0 = length(samplePos) - EarthRadius;
    vec3 density0 = sampleParticleDensity(altitude0);

    vec3 optic_viewdir = vec3(0.0);

    vec3 trans_lightdir0 = TransToAtmos(samplePos, lightdir);
    vec3 trans0 = trans_lightdir0;

    vec3 scattering_rayleigh = vec3(0.0);
    vec3 scattering_mie = vec3(0.0);
    for(int i = 0; i < N_SAMPLE; i++) {
        samplePos += stepVec;

        float altitude = length(samplePos) - EarthRadius;
        vec3 density = sampleParticleDensity(altitude);

        optic_viewdir += (density0 + density) * 0.5 * ds;

        vec3 trans_lightdir = TransToAtmos(samplePos, lightdir);
        vec3 trans_viewdir = exp(-(optic_viewdir.x * RayleighScatteringCoefficient + 
                                   optic_viewdir.y * MieScatteringCoefficient + 
                                   optic_viewdir.y * MieAbsorptionCoefficient + 
                                   optic_viewdir.z * OzoneAbsorptionCoefficient));
        vec3 trans = trans_lightdir * trans_viewdir;

        scattering_rayleigh += trans0 * density0.x + trans * density.x;
        scattering_mie += trans0 * density0.y + trans * density.y;

        density0 = density;
        trans0 = trans;
    }
    scattering_rayleigh *= 0.5 * ds;
    scattering_mie *= 0.5 * ds;

    float cos_theta = dot(dir, lightdir);
    float phase_rayleigh = RayleighPhase(cos_theta);
    float phase_mie = MiePhase(cos_theta);

    vec3 issca = lightcol * (scattering_rayleigh * phase_rayleigh * RayleighScatteringCoefficient + 
                       scattering_mie * phase_mie * MieScatteringCoefficient);
    vec3 outsca = exp(-(optic_viewdir.x * RayleighScatteringCoefficient + 
                                   optic_viewdir.y * MieScatteringCoefficient + 
                                   optic_viewdir.y * MieAbsorptionCoefficient + 
                                   optic_viewdir.z * OzoneAbsorptionCoefficient));
    return mat2x3(issca, outsca);
}

/////////////////////////////////////图像操作/////////////////////////////////////

vec4 sampleLevel0(sampler2D tex, vec2 uv){
    return textureLod(tex, uv, 0.0);
}

float w0(float a) {
    return (1.0 / 6.0) * (a * (a * (-a + 3.0) - 3.0) + 1.0);
}
float w1(float a) {
    return (1.0 / 6.0) * (a * a * (3.0 * a - 6.0) + 4.0);
}
float w2(float a) {
    return (1.0 / 6.0) * (a * (a * (-3.0 * a + 3.0) + 3.0) + 1.0);
}
float w3(float a) {
    return (1.0 / 6.0) * (a * a * a);
}

float g0(float a) {
    return w0(a) + w1(a);
}
float g1(float a) {
    return w2(a) + w3(a);
}

float h0(float a) {
    return -1.0 + w1(a) / (w0(a) + w1(a));
}
float h1(float a) {
    return 1.0 + w3(a) / (w2(a) + w3(a));
}
vec4 textureBicubic(sampler2D text, vec2 uv, vec2 resolution) {
	uv = uv * resolution + 0.5;
	vec2 iuv = floor(uv);
	vec2 fuv = fract(uv);

    float g0x = g0(fuv.x);
    float g1x = g1(fuv.x);
    float h0x = h0(fuv.x);
    float h1x = h1(fuv.x);
    float h0y = h0(fuv.y);
    float h1y = h1(fuv.y);

	vec2 p0 = (vec2(iuv.x + h0x, iuv.y + h0y) - 0.5) / resolution;
	vec2 p1 = (vec2(iuv.x + h1x, iuv.y + h0y) - 0.5) / resolution;
	vec2 p2 = (vec2(iuv.x + h0x, iuv.y + h1y) - 0.5) / resolution;
	vec2 p3 = (vec2(iuv.x + h1x, iuv.y + h1y) - 0.5) / resolution;
	
    return g0(fuv.y) * (g0x * sampleLevel0(text, p0)  +
                        g1x * sampleLevel0(text, p1)) +
           g1(fuv.y) * (g0x * sampleLevel0(text, p2)  +
                        g1x * sampleLevel0(text, p3));
}

vec4 SampleTextureCatmullRom5(sampler2D tex, vec2 uv, vec2 texSize){
    vec4 rtMetrics = vec4( 1.0 / texSize, texSize);
    
    vec2 position = rtMetrics.zw * uv;
    vec2 centerPosition = floor(position - 0.5) + 0.5;
    vec2 f = position - centerPosition;
    vec2 f2 = f * f;
    vec2 f3 = f * f2;


    const float c = 0.4;
    vec2 w0 =        -c  * f3 +  2.0 * c         * f2 - c * f;
    vec2 w1 =  (2.0 - c) * f3 - (3.0 - c)        * f2         + 1.0;
    vec2 w2 = -(2.0 - c) * f3 + (3.0 -  2.0 * c) * f2 + c * f;
    vec2 w3 =         c  * f3 -                c * f2;

    vec2 w12 = w1 + w2;
    vec2 tc12 = rtMetrics.xy * (centerPosition + w2 / w12);
    vec3 centerColor = sampleLevel0(tex, vec2(tc12.x, tc12.y)).rgb;

    vec2 tc0 = rtMetrics.xy * (centerPosition - 1.0);
    vec2 tc3 = rtMetrics.xy * (centerPosition + 2.0);
    vec4 color = vec4(sampleLevel0(tex, vec2(tc12.x, tc0.y )).rgb, 1.0) * (w12.x * w0.y ) +
                 vec4(sampleLevel0(tex, vec2(tc0.x,  tc12.y)).rgb, 1.0) * (w0.x  * w12.y) +
                 vec4(centerColor,                                 1.0) * (w12.x * w12.y) +
                 vec4(sampleLevel0(tex, vec2(tc3.x,  tc12.y)).rgb, 1.0) * (w3.x  * w12.y) +
                 vec4(sampleLevel0(tex, vec2(tc12.x, tc3.y )).rgb, 1.0) * (w12.x * w3.y );
    return vec4( color.rgb / color.a, 1.0 );
}
