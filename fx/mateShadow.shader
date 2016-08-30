Shader "rf/Lit/Mate Shadow" 
{
	Properties
	{
		_Color("ShadowColor", Color) = (1, 1, 1, 1)
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent" "LightMode" = "ForwardBase" }
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			struct a2v
			{
				half4 vertex	: POSITION;
			};

			struct v2f
			{
				half4 pos		: POSITION;
				LIGHTING_COORDS(0,1)
			};

			fixed4				_Color;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				fixed atten = LIGHT_ATTENUATION(i);
				return fixed4(_Color.rgb, _Color.a * (1.0 - atten));
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}