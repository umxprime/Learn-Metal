//
//  Shaders.metal
//  Learn Metal 02
//
//  Created by Maxime CHAPELET on 02/09/2018.
//  Copyright © 2018 Maxime CHAPELET. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct ColoredVertex
{
    float4 position [[position]];
    float4 color;
};

vertex ColoredVertex vertex_main(constant float4 *positions [[buffer(0)]],
                                 constant float4 *colors [[buffer(1)]],
                                 uint vid [[vertex_id]]) {
    ColoredVertex vert;
    vert.position = positions[vid];
    vert.color = colors[vid];
    return vert;
}

fragment float4 fragment_main(ColoredVertex vert [[stage_in]]) {
    return vert.color;
}
