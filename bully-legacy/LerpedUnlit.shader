Shader "Bully!/Unlit/2TextureLerp"
{
	Properties 
	{
		_Texture1("First Texture", 2D) = "black" {}
		_Texture2("Second Texture", 2D) = "white" {}
		_BlendAmount("Amount to blend by", Range(0,1) ) = 0.5

	}
	
	SubShader 
	{
		Tags
		{
			"Queue"="Geometry"
			"IgnoreProjector"="False"
			"RenderType"="Opaque"
		}

		
		Cull Back
		ZWrite On
		ZTest LEqual
		ColorMask RGBA
		Fog{
		}


		CGPROGRAM
		#pragma surface surf Unlit exclude_path:prepass noambient noforwardadd halfasview
		#pragma target 2.0
		
		sampler2D _Texture1;
		sampler2D _Texture2;
		float _BlendAmount;

			struct EditorSurfaceOutput
			{
				half3 Albedo;
				half3 Normal;
				half3 Emission;
				half3 Gloss;
				half Specular;
				half Alpha;
				half4 Custom;
			};

			inline half4 LightingUnlit(EditorSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
			{
				return 0;
			}
			
			struct Input
			{
				float2 uv_Texture1;
				float2 uv_Texture2;
			};
			

			void surf (Input IN, inout EditorSurfaceOutput o)
			{
				float4 Tex2D0=tex2D(_Texture1,(IN.uv_Texture1.xyxy).xy);
				float4 Tex2D1=tex2D(_Texture2,(IN.uv_Texture2.xyxy).xy);
				float4 Lerp0=lerp(Tex2D0,Tex2D1,_BlendAmount.xxxx);
				o.Emission = Lerp0;
			}
		ENDCG
	}
	Fallback "Diffuse"
}