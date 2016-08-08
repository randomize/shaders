// vim: ft=cg
Shader "Custom/GrabDarken"
{
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags
		{ 
			"Queue" = "Transparent" 
			"RenderType" = "Transparent" 	
		}
		
		Blend SrcAlpha OneMinusSrcAlpha

		GrabPass { }

		Pass
		{
			CGPROGRAM
			
			#include "UnityCG.cginc"
			
			#pragma vertex ComputeVertex
			#pragma fragment ComputeFragment
			
			sampler2D _MainTex;
			sampler2D _GrabTexture;
			fixed4 _Color;
			
			struct VertexInput
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
			};
			
			VertexOutput ComputeVertex (VertexInput vertexInput)
			{
				VertexOutput vertexOutput;
				
				vertexOutput.vertex = mul(UNITY_MATRIX_MVP, vertexInput.vertex);
				vertexOutput.screenPos = vertexOutput.vertex;	
				vertexOutput.texcoord = vertexInput.texcoord;
				vertexOutput.color = vertexInput.color * _Color;
							
				return vertexOutput;
			}
			
            fixed G (fixed4 c) { return .299 * c.r + .587 * c.g + .114 * c.b; }

            fixed4 Darken (fixed4 a, fixed4 b)
            { 
                fixed4 r = min(a, b);
                r.a = b.a;
                return r;
            }

            fixed4 Multiply (fixed4 a, fixed4 b)
            { 
                fixed4 r = a * b;
                r.a = b.a;
                return r;
            }

            fixed4 ColorBurn (fixed4 a, fixed4 b) 
            { 
                fixed4 r = 1.0 - (1.0 - a) / b;
                r.a = b.a;
                return r;
            }

            fixed4 LinearBurn (fixed4 a, fixed4 b)
            { 
                fixed4 r = a + b - 1.0;
                r.a = b.a;
                return r;
            }

            fixed4 DarkerColor (fixed4 a, fixed4 b) 
            { 
                fixed4 r = G(a) < G(b) ? a : b;
                r.a = b.a;
                return r; 
            }

            fixed4 Lighten (fixed4 a, fixed4 b)
            { 
                fixed4 r = max(a, b);
                r.a = b.a;
                return r;
            }

            fixed4 Screen (fixed4 a, fixed4 b) 
            { 	
                fixed4 r = 1.0 - (1.0 - a) * (1.0 - b);
                r.a = b.a;
                return r;
            }

            fixed4 ColorDodge (fixed4 a, fixed4 b) 
            { 
                fixed4 r = a / (1.0 - b);
                r.a = b.a;
                return r;
            }

            fixed4 LinearDodge (fixed4 a, fixed4 b)
            { 
                fixed4 r = a + b;
                r.a = b.a;
                return r;
            } 

            fixed4 LighterColor (fixed4 a, fixed4 b) 
            { 
                fixed4 r = G(a) > G(b) ? a : b;
                r.a = b.a;
                return r; 
            }

            fixed4 Overlay (fixed4 a, fixed4 b) 
            {
                fixed4 r = a > .5 ? 1.0 - 2.0 * (1.0 - a) * (1.0 - b) : 2.0 * a * b;
                r.a = b.a;
                return r;
            }

            fixed4 SoftLight (fixed4 a, fixed4 b)
            {
                fixed4 r = (1.0 - a) * a * b + a * (1.0 - (1.0 - a) * (1.0 - b));
                r.a = b.a;
                return r;
            }

            fixed4 HardLight (fixed4 a, fixed4 b)
            {
                fixed4 r = b > .5 ? 1.0 - (1.0 - a) * (1.0 - 2.0 * (b - .5)) : a * (2.0 * b);
                r.a = b.a;
                return r;
            }

            fixed4 VividLight (fixed4 a, fixed4 b)
            {
                fixed4 r = b > .5 ? a / (1.0 - (b - .5) * 2.0) : 1.0 - (1.0 - a) / (b * 2.0);
                r.a = b.a;
                return r;
            }

            fixed4 LinearLight (fixed4 a, fixed4 b)
            {
                fixed4 r = b > .5 ? a + 2.0 * (b - .5) : a + 2.0 * b - 1.0;
                r.a = b.a;
                return r;
            }

            fixed4 PinLight (fixed4 a, fixed4 b)
            {
                fixed4 r = b > .5 ? max(a, 2.0 * (b - .5)) : min(a, 2.0 * b);
                r.a = b.a;
                return r;
            }

            fixed4 HardMix (fixed4 a, fixed4 b)
            {
                fixed4 r = (b > 1.0 - a) ? 1.0 : .0;
                r.a = b.a;
                return r;
            }

            fixed4 Difference (fixed4 a, fixed4 b) 
            { 
                fixed4 r = abs(a - b);
                r.a = b.a;
                return r; 
            }

            fixed4 Exclusion (fixed4 a, fixed4 b)
            { 
                fixed4 r = a + b - 2.0 * a * b;
                r.a = b.a;
                return r; 
            }

            fixed4 Subtract (fixed4 a, fixed4 b)
            { 
                fixed4 r = a - b;
                r.a = b.a;
                return r; 
            }

            fixed4 Divide (fixed4 a, fixed4 b)
            { 
                fixed4 r = a / b;
                r.a = b.a;
                return r; 
            }   		

			fixed4 ComputeFragment (VertexOutput vertexOutput) : SV_Target
			{
				half4 color = tex2D(_MainTex, vertexOutput.texcoord) * vertexOutput.color;
				
				float2 grabTexcoord = vertexOutput.screenPos.xy / vertexOutput.screenPos.w; 
				grabTexcoord.x = (grabTexcoord.x + 1.0) * .5;
				grabTexcoord.y = (grabTexcoord.y + 1.0) * .5; 
				#if UNITY_UV_STARTS_AT_TOP
				grabTexcoord.y = 1.0 - grabTexcoord.y;
				#endif
				
				fixed4 grabColor = saturate(tex2D(_GrabTexture, grabTexcoord));
				
				return saturate(VividLight(grabColor, color));
			}
			
			ENDCG
		}
	}

	Fallback "UI/Default"
}
