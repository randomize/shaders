// Upgrade NOTE: replaced 'PositionFog()' with multiply of UNITY_MATRIX_MVP by position
// Upgrade NOTE: replaced 'V2F_POS_FOG' with 'float4 pos : SV_POSITION'

Shader "XRay Bump noblend" {

Properties {

    _Color ("Tint (RGB)", Color) = (1,1,1,1)

    _BumpMap ("Bumpmap", 2D) = "bump" {}

    _RampTex ("Facing Ratio Ramp (RGB)", 2D) = "white" {}

}

SubShader {

    Pass {

    

CGPROGRAM 
// Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members uv,viewT)
#pragma exclude_renderers xbox360

#pragma vertex vert

#pragma fragment frag

 

#include "UnityCG.cginc" 

 

struct v2f {

    float4 pos : SV_POSITION;

    float4 uv : TEXCOORD;

    float3 viewT;

};

 

v2f vert (appdata_tan v) {

    v2f o;

    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);

 

    TANGENT_SPACE_ROTATION;

    float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));

    o.viewT = mul(rotation,viewDir);

    

    o.uv = v.texcoord;

 

    return o;

}

 

uniform float4 _Color;

uniform sampler2D _RampTex;

uniform sampler2D _BumpMap;

 

half4 frag(v2f i) : COLOR {

    half3 n = tex2D( _BumpMap, i.uv.xy ).rgb * 2 - 1;

    float r = saturate(dot(i.viewT, n));

    float2 uv = float2( r, 0.5 );

    return tex2D( _RampTex, uv ) * _Color;

}

 

ENDCG 

    }

}

}