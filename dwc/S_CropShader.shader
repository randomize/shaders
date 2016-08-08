// vim: ft=cg
Shader "Unlit/CropShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LineartTex ("Texture linear", 2D) = "white" {}
		_LutTex ("Texture lut", 2D) = "white" {}
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
            //#pragma target 3.0
			
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
			sampler2D _LineartTex;
			sampler2D _LutTex;
			uniform float4x4 _Rect;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			//custom lerp from MAD
			fixed fix(half w0, half w1, fixed t)
			{
				return ((t*w0) / ((1 - t)*w1 + t*w0));
			}

            // Pass lut texture and color, returns interpolated color
            fixed3 Lut(sampler2D _LUT, fixed3 c)
            {
                // TODO: use fixed/halfes where possible

                float b = c.b * 63.0;

                float2 q1, q2, t1, t2;

                q1.y = floor(floor(b) / 8.0);
                q1.x = floor(b) - (q1.y * 8.0);

                q2.y = floor(ceil(b) / 8.0);
                q2.x = ceil(b) - (q2.y * 8.0);

                t1.x = (q1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * c.r);
                t1.y = (q1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * c.g);

                t2.x = (q2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * c.r);
                t2.y = (q2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * c.g);

                // perform 2 lookups
                fixed3 col1 = tex2D(_LUT, t1).rgb;
                fixed3 col2 = tex2D(_LUT, t2).rgb;

                return lerp(col1, col2, b - floor(b));
            }

			fixed4 frag(v2f i) : SV_Target
			{
				half3 lt = _Rect[0].xyz;
				half3 rt = _Rect[1].xyz;
				half3 rb = _Rect[2].xyz;
				half3 lb = _Rect[3].xyz;
				fixed2 uv = i.uv;

				// get non linear inversions
				fixed topZ = fix(rt.z, lt.z, uv.x);
				fixed bottomZ = fix(rb.z, lb.z, uv.x);

				// use them with simple lerp to get the u-axis
				half3 top = lerp(lt, rt, topZ);
				half3 bottom = lerp(lb, rb, bottomZ);

				// but use linear lerp for z values
				half zTop = lerp(lt.z, rt.z, uv.x);
				half zBottom = lerp(lb.z, rb.z, uv.y);

				// get non linear on uv.y-axis
				fixed uvy = fix(zTop, zBottom, uv.y);

				float2 horizontal = lerp(bottom, top, uvy);

				horizontal.y = 1.0 - horizontal.y;

				fixed4 color = tex2D(_MainTex, horizontal);
				fixed4 lineart = tex2D(_LineartTex, uv);
                color.rgb = Lut(_LutTex, color.rgb);

				return fixed4(color.rgb * (1-lineart.a), 1.);
			}
			

			ENDCG
		}
	}
}
