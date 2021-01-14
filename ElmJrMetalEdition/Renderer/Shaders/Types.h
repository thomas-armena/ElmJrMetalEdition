//
//  Types.h
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-13.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

#ifndef Types_h
#define Types_h

#import <simd/simd.h>

/* Light Types */
typedef enum {
    Undefined = 0,
    Directional = 1,
    Ambient = 2
} LightType;

struct Light {
    vector_float3 position;
    vector_float3 color;
    float intensity;
    LightType type;
};

typedef enum {
    Unlit = 0,
    Lit = 1
} SurfaceType;

/* Primitive Types */
struct PrimitiveVertexUniforms {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float3x3 normalMatrix;
    vector_float4 color;
};

struct PrimitiveFragmentUniforms {
    uint lightCount;
    vector_float3 cameraPosition;
    SurfaceType surfaceType;
};

/* Bezier Types */
struct BezierVertexUniforms {
    matrix_float4x4 modelViewMatrix;
    vector_float4 color;
    vector_float2 p0;
    vector_float2 p1;
    vector_float2 p2;
    vector_float2 p3;
};

#endif /* Types_h */
