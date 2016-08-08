Shader "SimpleSpot"
{
	Properties 
	{
		_MainTex("Base Map", 2D) = "black" {}
		_SpotTex("Spotlight Map", 2D) = "black" {}
	    _SpotReverseIntensity("Spotlight Reverse Intensity", float) = 1
	    _AmbientIntensity("Ambient Intensity", float) = 0.5
	}

	SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 200
	Cull Back
	
	Pass {
	
	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	sampler2D _SpotTex;
	float _SpotReverseIntensity;
	float _AmbientIntensity;
	float4 _SpotColor;
	
	struct invertex {
	    float4 vertex : POSITION;
	    float4 texcoord : TEXCOORD0;
	    float4 texcoord1 : TEXCOORD1;
	};
	
	struct v2f {
    	float4 pos : SV_POSITION;
    	float2 uv0 : TEXCOORD0;
    	float2 uv1 : TEXCOORD1;
    	half4 color : COLOR0;
	};
 
	v2f vert (invertex v)
	{
	    v2f o; 
	    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
	    o.uv0 = v.texcoord;
	    o.uv1 = v.texcoord1;
	    return o;
	}

	struct Input {
		float2 uv_MainTex : TEXCOORD;
	}; 

	half4 frag (v2f i) : COLOR
	{
		return tex2D(_MainTex, i.uv0) * (_AmbientIntensity + 1.6 * max(tex2D(_SpotTex, i.uv1) - _SpotReverseIntensity, 0.0));
	}
	
	ENDCG
	}
} 
FallBack "Self-Illumin/VertexLit"
}