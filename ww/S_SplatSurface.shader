// vim: ft=cg
Shader "Custom/S_SplatSurface" {
	Properties {
		[Header(Mask)]
		_MainTex ("Albedo (RGB)", 2D) = "white" {}

		[Space(20)][Header(Textures)]
		_BaseTex	("Base",  2D) = "white" {}
		_RTex		("Red ",  2D) = "white" {}
		_GTex		("Green", 2D) = "white" {}
		_BTex		("Blue",  2D) = "white" {}
		_ATex		("Alpha", 2D) = "white" {}

		[Space(20)][KeywordEnum(R, RG, RGB, RGBA)]
		_Combine	("Combined textures", float) = 3
		_MixFactor	("Mix Factor x:r | y:g | z:b | w:a", Vector) = (1,1,1,1)

		[Space(20)][Header(BasicStuff)]
		_Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
        #pragma multi_compile _COMBINE_R _COMBINE_RG _COMBINE_RGB _COMBINE_RGBA

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BaseTex;
		sampler2D _RTex;
		sampler2D _GTex;
		sampler2D _BTex;
		sampler2D _ATex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BaseTex;
			float2 uv_RTex;
			/* float2 uv_GTex; */
			/* float2 uv_BTex; */
			/* float2 uv_ATex; */
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
        fixed4 _MixFactor;

		void surf (Input IN, inout SurfaceOutputStandard o)
        {
			// Albedo comes from a texture tinted by color
			fixed4 mask = tex2D (_MainTex, IN.uv_MainTex);
			fixed4 col = tex2D (_BaseTex, IN.uv_BaseTex);

            col = lerp(col, tex2D(_RTex, IN.uv_RTex), saturate(mask.r * _MixFactor.x));

#			if defined (_COMBINE_RG) || _COMBINE_RGB || _COMBINE_RGBA
            col = lerp(col, tex2D(_GTex, IN.uv_RTex), saturate(mask.g * _MixFactor.y));
#			endif

#			if defined (_COMBINE_RGB) || _COMBINE_RGBA
            col = lerp(col, tex2D(_BTex, IN.uv_RTex), saturate(mask.b * _MixFactor.z));
#			endif

#			if defined (_COMBINE_RGBA)
            col = lerp(col, tex2D(_ATex, IN.uv_RTex), saturate(mask.a * _MixFactor.w));
#			endif


			o.Albedo = col.rgb * _Color.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = col.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
