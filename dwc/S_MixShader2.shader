// vim: ft=cg
Shader "Unlit/MixShader2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_A ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _A;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//fixed4 a = i.uv;
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col2 = tex2D(_A, i.uv);
                //fixed4 a = 1.0;
                //return a;
                return col * col2;
			}
			ENDCG
		}
	}
}
