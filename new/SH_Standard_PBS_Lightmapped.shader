// vim: ft=cg
Shader "Custom/Standard_PBS_Lightmapped" 
{
	Properties 
    {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		//_Glossiness ("Smoothness", Range(0,1)) = 0.5

        _MetallicGlossMap ("Metallic map", 2D) = "white" {}
		_Metallic ("Metallic", Range(0,1)) = 0.0
        
        _Emission ("Emission", 2D) = "black" {}
        _NormalMap ("Normal", 2D) = "bump" {}
        _Lightmap ("Lightmap (RGBA)", 2D) = "black" {}
	}
	SubShader 
    {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		struct Input 
        {
			float2 uv_MainTex;
            float2 uv2_LightMap;
            float2 uv_NormalMap;
            float2 uv_MetallicGlossMap;
            float2 uv_Emission;
		};
		sampler2D _MainTex;
        sampler2D _Lightmap;
        sampler2D _NormalMap;
        sampler2D _Emission;

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) 
        {
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            half4 lm = tex2D(_Lightmap, IN.uv2_LightMap);
            half3 norm = UnpackNormal (tex2D (_NormalMap, IN.uv_NormalMap));
            half4 emis = tex2D(_Emission, IN.uv_Emission);

            fixed2 g = tex2D (_MetallicGlossMap, IN.uv_MetallicGlossMap).ra;
			g.g *= _Metallic;


            o.Metallic = g.x;
            o.Smoothness = g.y;


  
            o.Normal = norm;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
            o.Emission = lm.rgb * emis.rgb;
			o.Alpha = lm.a * c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
