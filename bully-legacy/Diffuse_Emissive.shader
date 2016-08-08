Shader "Bully!/EmissiveDiffuse"
{
	Properties 
	{
		_MainTex("_MainTex", 2D) = "black" {}
		_Illum("_Emissive", 2D) = "black" {}
		_Power("_Emission", Range(0,1) ) = 1
	}

	SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 200
	
	CGPROGRAM
	#pragma surface surf Lambert noforwardadd halfasview
	
	sampler2D _MainTex;
	sampler2D _Illum;
	float _Power;
	
	struct Input {
		float2 uv_MainTex : TEXCOORD;
		float2 uv_Illum : TEXCOORD;
	};

	void surf (Input IN, inout SurfaceOutput o)
	{
		fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
		o.Albedo = tex.rgb;
		fixed4 illum = tex2D(_Illum, IN.uv_MainTex);
		o.Emission = illum*_Power;
	}
	
ENDCG
} 
FallBack "Self-Illumin/VertexLit"
}