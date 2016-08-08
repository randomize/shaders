Shader "Bully!/StageFloor"
{
	Properties 
	{
		_MainTex("Texture ", 2D) = "black" {}
		_MainColor("Color ", Color) = (1,1,1,1)
		_Tiles("Tiles", Float) = 2
		_PanSpeed("Pan Speed", Float) = 10
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
		#pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd halfasview novertexlights
		#pragma target 2.0

		sampler2D _MainTex;
		float4 _MainColor;
		float _Tiles;
		float _PanSpeed;

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
			
			inline fixed4 LightingMobileBlinnPhong (EditorSurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
			{
				fixed diff = max (0, dot (s.Normal, lightDir));
				fixed nh = max (0, dot (s.Normal, halfDir));
				fixed spec = pow (nh, s.Specular*128) * s.Gloss;
				
				fixed4 c;
				c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten*2);
				c.a = 0.0;
				return c;
			}

			struct Input
			{
				float2 uv_MainTex;
			};

			void surf (Input IN, inout EditorSurfaceOutput o) {
			
				
				float4 Multiply0=(IN.uv_MainTex.xyxy) * _Tiles.xxxx;
				float4 Multiply1=_Time * _PanSpeed.xxxx;
				float4 UV_Pan0=float4(Multiply0.x,Multiply0.y + Multiply1.x,Multiply0.z,Multiply0.w);
				float4 Tex2D0=tex2D(_MainTex,UV_Pan0.xy);
				float4 IMG=Tex2D0*_MainColor;
				o.Albedo = IMG;
				o.Emission = IMG;
			}
		ENDCG
	}
	Fallback "Diffuse"
}