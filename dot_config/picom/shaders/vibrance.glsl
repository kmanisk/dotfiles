#version 330
in vec2 texcoord;

uniform sampler2D tex;

vec4 default_post_processing(vec4 c);

vec4 window_shader() {
    vec2 texsize = textureSize(tex, 0);
    vec4 color = texture(tex, texcoord / texsize);

    // Vibrance factor (30% boost)
    const float vibrance = 0.30;

    // Perceptual luma (Rec. 709)
    float luma = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));

    // Calculate saturation spread
    float maxColor = max(color.r, max(color.g, color.b));
    float minColor = min(color.r, min(color.g, color.b));
    float colorSat = maxColor - minColor;

    // Natural vibrance boost
    color.rgb = mix(color.rgb, mix(vec3(luma), color.rgb, 1.0 + vibrance * 1.25), 1.0 - colorSat * 0.35);
    color.rgb = clamp(color.rgb, 0.0, 1.0);

    return default_post_processing(color);
}
