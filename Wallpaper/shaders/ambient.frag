#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 resolution;
} ubuf;

void main()
{
    vec2 uv = qt_TexCoord0;
    float t = ubuf.time * 0.12;

    vec2 p = uv - vec2(0.5);
    p.x *= max(ubuf.resolution.x / max(ubuf.resolution.y, 1.0), 0.1);

    float wave1 = sin((uv.x * 4.2) + t) * 0.5 + 0.5;
    float wave2 = cos((uv.y * 3.1) - t * 0.8) * 0.5 + 0.5;
    float glow = 0.5 + 0.5 * sin(length(p) * 8.0 - t * 2.0);

    vec3 deepBlue = vec3(0.018, 0.025, 0.11);
    vec3 violet = vec3(0.20, 0.055, 0.36);
    vec3 cyan = vec3(0.025, 0.34, 0.42);

    vec3 color = mix(deepBlue, violet, smoothstep(0.1, 0.95, wave1 * 0.75 + glow * 0.25));
    color = mix(color, cyan, smoothstep(0.62, 1.0, wave2) * 0.45);

    float vignette = 1.0 - smoothstep(0.28, 0.85, length(p));
    color *= 0.45 + vignette * 0.75;

    fragColor = vec4(color, 1.0) * ubuf.qt_Opacity;
}
