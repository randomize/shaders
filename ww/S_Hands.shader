// vim: ft=cg
Shader "Custom/S_Hands" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Normal (RGB)", 2D) = "white" {}
		_Glossiness ("Glossiness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_MetallicGlossMap ("Metallic map", 2D) = "white" {}
		_AlphaMap ("Alpha", 2D) = "white" {}
	}
	SubShader {
		Tags { "Queue"="Transparent" "RenderType"="Transparent"}
		LOD 200

            Pass {
                ColorMask 0
            }
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		/* #pragma surface surf Standard fullforwardshadows noambient */
		#pragma surface surf Standard fullforwardshadows noambient alpha:fade

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MetallicGlossMap;
		sampler2D _BumpMap;
		sampler2D _AlphaMap;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_MetallicGlossMap;
			float2 uv_AlphaMap;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed2 g = tex2D (_MetallicGlossMap, IN.uv_MetallicGlossMap).ra;
			g.g *= _Metallic;

            fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)); 
			o.Albedo = c.rgb;
			/* o.Albedo = g; */
			// Metallic and smoothness come from slider variables
			o.Metallic = g.x;
            o.Normal = normalize(normal);
			o.Smoothness = g.y;
			o.Emission = c * _Glossiness * (1 - g.x);
			o.Alpha = _Color.a * tex2D (_AlphaMap, IN.uv_AlphaMap);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
