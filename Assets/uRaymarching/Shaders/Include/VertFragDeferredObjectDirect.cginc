﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#ifndef VERT_FRAG_DEFERRED_OBJECT_DIRECT_H
#define VERT_FRAG_DEFERRED_OBJECT_DIRECT_H

#include "UnityCG.cginc"
#include "./Structs.cginc"
#include "./Raymarching.cginc"
#include "./Utils.cginc"

float _MinDistance;
int _Loop;
float4 _Diffuse;
float4 _Specular;
float4 _Emission;

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
};

struct v2f
{
    float4 vertex    : SV_POSITION;
    float4 screenPos : TEXCOORD0;
};

v2f Vert(appdata i)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(i.vertex);
    o.worldPos = mul(unity_ObjectToWorld, i.vertex);
    o.worldNormal = mul(unity_ObjectToWorld, i.normal);
    return o;
}

GBufferOut Frag(v2f i)
{
    RaymarchInfo ray;
    UNITY_INITIALIZE_OUTPUT(RaymarchInfo, ray);
    ray.rayDir = normalize(i.worldPos - GetCameraPosition());
    ray.startPos = i.worldPos;
    ray.polyNormal = i.worldNormal;
    ray.minDistance = _MinDistance;
    ray.maxDistance = GetCameraMaxDistance();
    ray.maxLoop = _Loop;

    Raymarch(ray);

    GBufferOut o;
    o.diffuse  = _Diffuse;
    o.specular = _Specular;
    o.emission = _Emission;
    o.normal   = float4(ray.normal, 1.0);
#ifdef USE_RAYMARGHING_DEPTH
    o.depth    = ray.depth;
#endif

#ifdef POST_EFFECT
    POST_EFFECT(ray, o);
#endif

#ifndef UNITY_HDR_ON
    o.emission = exp2(-o.emission);
#endif

    return o;
}

#endif
