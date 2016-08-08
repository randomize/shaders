// vim: ft=cg

Shader "Hidden/LaplaceEffect"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
		 
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			uniform sampler2D _MainTex;
			uniform float4 _Pix2UV; // holds precomuped 1/screen.w, 1/screen.h, 0, 0
            // _ScreenParams will be used intead - had 1+1/w and 1+1/h in zw coords

			fixed sample_offset(sampler2D tex, half2 uv, half px, half py)
            {
				half ux = uv.x + px * _Pix2UV.x;// -px;
				half uy = uv.y + py * _Pix2UV.y;// -py;
                fixed4 c = tex2D(tex, half2(ux, uy));
                return (c.r + c.g + c.b)/3.0;
                //return c.r;
            }

			fixed4 frag (v2f i) : SV_Target
			{
				fixed sum = 
                -4 * sample_offset(_MainTex, i.uv, 0, 0) +
                sample_offset(_MainTex, i.uv, 1, 0) +
                sample_offset(_MainTex, i.uv, 0, 1) +
                sample_offset(_MainTex, i.uv, -1, 0) +
                sample_offset(_MainTex, i.uv, 0, -1);

                sum*=50;

				return fixed4(sum, sum, sum, 1);
			}
			ENDCG
		}
	}
}
