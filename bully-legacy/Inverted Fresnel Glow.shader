Shader "Bully!/Fresnel/Glow"
{
	Properties 
	{
		_RimColor("Glow Color", Color) = (0,0.1188812,1,1)
		_RimPower("Glow Power", Range(0.1,10) ) = 1.707772
	}
	
	SubShader 
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
		}

		
		ZWrite Off
		ZTest LEqual
		Blend SrcAlpha One
		Cull Front

		CGPROGRAM
		#pragma surface surf Unlit 
		//nolightmap approxview exclude_path:prepass noforwardadd noambient
		//#pragma target 2.0


		float4 _RimColor;
		float _RimPower;


			struct Input
			{
				float3 viewDir;
			};

			fixed4 LightingUnlit(SurfaceOutput s, half3 lightDir, half atten)
			{
				fixed4 c;
				c.rgb = s.Albedo;
				c.a = s.Alpha;
				return c;
			}

			void surf (Input IN, inout SurfaceOutput o) {

				
				fixed4 Fresnel = (1.0 - dot( normalize( IN.viewDir ), normalize( fixed3(0,0,1) ) )).xxxx;
				fixed4 Pow = pow(Fresnel, _RimPower.xxxx);
				fixed Invert = abs((Pow * .0007) - 1);
				
				Invert = abs(Invert - 1);				
																
				o.Albedo = _RimColor;
				o.Alpha = clamp(Invert.r * 2,0,1);

				o.Normal = normalize(o.Normal);
			}
		
		ENDCG
	}
	
	Fallback "Diffuse"
}