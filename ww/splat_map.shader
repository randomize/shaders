// vim: ft=cg
// Upgrade NOTE: replaced 'defined _COMBINE_RG' with 'defined (_COMBINE_RG)'
// Upgrade NOTE: replaced 'defined _COMBINE_RGBA' with 'defined (_COMBINE_RGBA)'

// Upgrade NOTE: replaced 'defined _COMBINE_RG' with 'defined (_COMBINE_RG)'

Shader "Unlit/Splat Map"
{
	Properties
	{
		[Header(Mask)]
		_MainTex	("Map", 2D) = "black" {}

		[Space(20)][Header(Textures)]
		_BaseTex	("Base",  2D) = "white" {}
		_RTex		("Red ",  2D) = "white" {}
		_GTex		("Green", 2D) = "white" {}
		_BTex		("Blue",  2D) = "white" {}
		_ATex		("Alpha", 2D) = "white" {}
		[Space(20)][KeywordEnum(R, RG, RGB, RGBA)]
		_Combine	("Combined textures", float) = 3
		_MixFactor	("Mix Factor x:r | y:g | z:b | w:a", Vector) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _COMBINE_R _COMBINE_RG _COMBINE_RGB _COMBINE_RGBA
			#include "UnityCG.cginc"


			struct a2v
			{
				float4 vertex	: POSITION;
				float2 uv		: TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex	: SV_POSITION;
				float2 uv		: TEXCOORD0;
				float2 uv1		: TEXCOORD1;
				float2 uv2		: TEXCOORD2;
				float2 uv3		: TEXCOORD3;
				float2 uv4		: TEXCOORD4;
				float2 uv5		: TEXCOORD5;
			};



			sampler2D _MainTex;
			sampler2D _BaseTex;
			sampler2D _RTex;
			sampler2D _GTex;
			sampler2D _BTex;
			sampler2D _ATex;

			float4 _MainTex_ST;
			float4 _BaseTex_ST;
			float4 _RTex_ST;
			float4 _GTex_ST;
			float4 _BTex_ST;
			float4 _ATex_ST;

			fixed4 _MixFactor;



			fixed4 GetDiffuseColor(v2f input)
			{
				fixed4 mask = tex2D(_MainTex, input.uv);
				fixed4 col = tex2D(_BaseTex, input.uv1);
				col = lerp(col, tex2D(_RTex, input.uv2), saturate(mask.r * _MixFactor.x));

#				if defined (_COMBINE_RG) || _COMBINE_RGB || _COMBINE_RGBA
				col = lerp(col, tex2D(_GTex, input.uv3), saturate(mask.g * _MixFactor.y));
#				endif

#				if defined (_COMBINE_RGB) || _COMBINE_RGBA
				col = lerp(col, tex2D(_BTex, input.uv4), saturate(mask.b * _MixFactor.z));
#				endif

#				if defined (_COMBINE_RGBA)
				col = lerp(col, tex2D(_ATex, input.uv5), saturate(mask.a * _MixFactor.w));
#				endif

				return col;
			}

			v2f vert (a2v v)
			{
				v2f o;
				// uvs
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv1 = TRANSFORM_TEX(v.uv, _BaseTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _RTex);
#				if defined (_COMBINE_RG) || _COMBINE_RGB || _COMBINE_RGBA
				o.uv3 = TRANSFORM_TEX(v.uv, _GTex);
#				endif
#				if defined (_COMBINE_RGB) || _COMBINE_RGBA
				o.uv4 = TRANSFORM_TEX(v.uv, _BTex);
#				endif
#				ifdef _COMBINE_RGBA
				o.uv5 = TRANSFORM_TEX(v.uv, _ATex);
#				endif
				// pos
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}
			


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 fragCol = GetDiffuseColor(i);
				return fragCol;
			}
			ENDCG
		}
	}
}
