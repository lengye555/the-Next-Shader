
layout(location = 0) out vec4 color0;

void voxy_emitFragment(VoxyFragmentParameters parameters) {
    vec4 base = parameters.sampledColour;
    base.rgb *= parameters.tinting.rgb;
    color0 = base;
}
