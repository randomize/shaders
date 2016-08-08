// vim: ft=cg
Shader "Bully!/DisolveUIImage"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
	_Color("Tint", Color) = (1,1,1,1)

		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255

		_ColorMask("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0

		_DisolveProgress("Disolve Progress", Range(0,1)) = 0
		_NoiseTexture("Noise Texture", 2D) = "white" {}
		_DisolveWidth("Width", Range(0,0.5)) = 0
		_GradientTexture("Gradient Texture", 2D) = "gradient" {}
	}

		SubShader
	{
		Tags
	{
		"Queue" = "Transparent"
		"IgnoreProjector" = "True"
		"RenderType" = "Transparent"
		"PreviewType" = "Plane"
		"CanUseSpriteAtlas" = "True"
	}

		Stencil
	{
		Ref[_Stencil]
		Comp[_StencilComp]
		Pass[_StencilOp]
		ReadMask[_StencilReadMask]
		WriteMask[_StencilWriteMask]
	}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest[unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask[_ColorMask]

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"
#include "UnityUI.cginc"

#pragma multi_compile __ UNITY_UI_ALPHACLIP

	struct appdata_t
	{
		float4 vertex   : POSITION;
		float4 color    : COLOR;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 vertex   : SV_POSITION;
		fixed4 color : COLOR;
		half2 texcoord  : TEXCOORD0;
		float4 worldPosition : TEXCOORD1;
		float2 texcoord2	: TEXCOORD2;
	};

	fixed4 _Color;
	fixed4 _TextureSampleAdd;
	float4 _ClipRect;
	float _DisolveProgress;
	float _DisolveWidth;
	sampler2D _NoiseTexture;
	sampler2D _MainTex;
	sampler2D _GradientTexture;

	fixed4 CombineNoiseWithMainImage(v2f IN)
	{
		fixed4 noiseColor = tex2D(_NoiseTexture, IN.texcoord);
		fixed4 mainColor = tex2D(_MainTex, IN.texcoord);
		fixed4 gradientCol = tex2D(_GradientTexture, IN.texcoord2);

		float alpha =  gradientCol.r;
		mainColor.a *= lerp(noiseColor.r * lerp(0, 1, alpha * 2), 1, alpha);
		return mainColor;
	}

	v2f vert(appdata_t IN)
	{
		v2f OUT;
		OUT.worldPosition = IN.vertex;
		OUT.vertex = mul(UNITY_MATRIX_MVP, OUT.worldPosition);

		OUT.texcoord = IN.texcoord;
		OUT.texcoord2 = IN.texcoord;

		float2x2 rotation = float2x2(0.707, 0.707, -0.707, 0.707);
		OUT.texcoord2 = OUT.texcoord2 - 0.5;
		OUT.texcoord2 = mul(rotation, OUT.texcoord2);
		OUT.texcoord2 = OUT.texcoord2 + (-1.707 * _DisolveProgress + 1.3535);
		OUT.texcoord2 *= 1 - _DisolveWidth;

#ifdef UNITY_HALF_TEXEL_OFFSET
		OUT.vertex.xy += (_ScreenParams.zw - 1.0)*float2(-1,1);
#endif

		OUT.color = IN.color * _Color;
		return OUT;
	}

	fixed4 frag(v2f IN) : SV_Target
	{
		fixed4 mainCol = CombineNoiseWithMainImage(IN);
		half4 color = (mainCol + _TextureSampleAdd) * IN.color;
		color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

#ifdef UNITY_UI_ALPHACLIP
		clip(color.a - 0.001);
#endif

		return color;
	}
		ENDCG
	}
	}
}
