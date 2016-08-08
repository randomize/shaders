// vim: ft=cg
Shader "Bully/Effects/ColorSelect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_KeysTex ("Keys", 2D)    = "white" {}
		_KeyColor ("Key", Color)  = (1.0, 0.0, 0.0, 1.0)
		_CutColor ("Cut", Color)  = (0.0, 0.0, 0.0, 1.0)
		_Toler ("Tolerance", Float)  = 0.01
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
        //Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        //Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            #define AA 4.0

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
			
			sampler2D _MainTex;
			sampler2D _KeysTex;
			fixed4 _KeyColor;
			fixed4 _CutColor;
			float _Toler;

            fixed4 sample (float2 uv, fixed4 col)
            {

				//half4 col = tex2D(_MainTex, uv);
				float4 key = tex2D(_KeysTex, uv);
                float r = abs(key.r - _KeyColor.r) ;
                float g = abs(key.g - _KeyColor.g) ;
                float b = abs(key.b - _KeyColor.b) ;

                //half mr = smoothstep(-_Toler, _Toler, r) * smoothstep(-_Toler, _Toler, g)* smoothstep(-_Toler, _Toler, b);
                float mr = 1 - smoothstep(0, _Toler, r);
                float mg = 1 - smoothstep(0, _Toler, g);
                float mb = 1 - smoothstep(0, _Toler, b);

                float m = mr * mg * mb * smoothstep(0.01, 0.02, key.a);

                m = smoothstep(0.49, 0.50, m);

                return lerp(col, _CutColor, m); // has
                //return lerp(fixed4(0,1,0,1), fixed4(1,0,0,1), m);
                //return lerp(col, _CutColor, mr * mg * mb ); // has bug
                //return lerp(col, _CutColor, 0); // has no bug
                
            }

			fixed4 frag (v2f i) : SV_Target
			{
                float4 col = 0.;
                float2 uv = i.uv;
				fixed4 basecol = tex2D(_MainTex, uv);
                //return sample(uv, basecol);

                //float e = 1. / min(_ScreenParams.x, _ScreenParams.y);    
                float e = 1. / 512.;
                for (float i = -AA; i < AA; ++i) {
                    for (float j = -AA; j < AA; ++j) {
                        col += sample(
                            uv + float2(i, j) * (e/AA),
                            basecol
                        ) / (4.*AA*AA);
                    }
                }
                return col;
			}
			ENDCG
		}
	}
}
