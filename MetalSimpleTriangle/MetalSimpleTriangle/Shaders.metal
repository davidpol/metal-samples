#include <metal_stdlib>

using namespace metal;

struct VertexOutput
{
    float4 position [[position]];
    float4 color;
};

vertex VertexOutput vertexShader(constant float4* position [[buffer(0)]],
                                 constant float4* color [[buffer(1)]],
                                 uint id [[vertex_id]])
{
    VertexOutput v;
    v.position = position[id];
    v.color = color[id];
    return v;
}

fragment float4 fragmentShader(VertexOutput v [[stage_in]])
{
    return v.color;
}