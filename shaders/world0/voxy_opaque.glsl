vec2 voxy_OctWrap(vec2 v) {
    return (1.0 - abs(v.yx)) * (step(vec2(0.0), v.xy) * 2.0 - 1.0);
}

vec2 voxy_normalEncode(vec3 n) {
    n /= (abs(n.x) + abs(n.y) + abs(n.z));
    n.xy = n.z >= 0.0 ? n.xy : voxy_OctWrap(n.xy);
    return n.xy * 0.5 + 0.5;
}

vec3 voxy_faceNormal(uint face) {
    return vec3(uint((face >> 1) == 2), uint((face >> 1) == 0), uint((face >> 1) == 1))
        * (float(int(face) & 1) * 2.0 - 1.0);
}

layout(location = 0) out vec4 color0;
layout(location = 1) out vec4 color1;
layout(location = 2) out vec4 color2;
layout(location = 3) out vec4 color3;

void voxy_emitFragment(VoxyFragmentParameters parameters) {
    vec4 base = parameters.sampledColour;
    base.rgb *= parameters.tinting.rgb;

    vec3 n = normalize(voxy_faceNormal(parameters.face));
    vec2 encN = voxy_normalEncode(n);

    color0 = vec4(base.rgb, 1.0);
    color1 = vec4(parameters.lightMap, float(parameters.customId) / 10000.0, 1.0);
    color2 = vec4(encN, encN);
    color3 = vec4(0.0);
}
