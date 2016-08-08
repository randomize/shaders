// vim: ft=cg
// this shader uses lowest mip level of input texutre to effectively calculate
// average and substract it from each pixel value, then square, so resulting
// output texture being averaged will contain variance

Shader "Hidden/VarianceCompute"
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
			uniform float _Avg;

			fixed4 frag (v2f i) : SV_Target
			{
                //fixed4 a = tex2D(_MainTex, float2(0,0), );

                fixed4 c = tex2D(_MainTex, i.uv);
                fixed lc =  (c.r + c.g + c.b)/3.0;

                fixed la = _Avg;

                fixed sum = (lc-la)*(lc-la);

				return fixed4(sum, sum, sum, 1);
			}
			ENDCG
		}
	}
}
