Shader "Bully!/NormalAlpha-Specular-Reflection"
{
	Properties 
	{
_MainTex("_MainTex", 2D) = "white" {}
_Normal("_Normal", 2D) = "bump" {}
_Gloss("_Gloss", Range(0,1) ) = 0.5016741
_SpecularColor("_SpecularColor", Color) = (0.8751911,0.2705,0.1250527,1)
_EnvColor("_EnvColor", Color) = (0,0.3,0.8,1)
_Mask("_Mask", 2D) = "black" {}
_Reflection("_Reflection", Cube) = "black" {}

	}
	
	SubShader 
	{
		Tags
		{
"Queue"="Geometry"
"IgnoreProjector"="True"
"RenderType"="Opaque"

		}

		
Cull Back
ZWrite On
ZTest LEqual
ColorMask RGBA
Fog{
}


		CGPROGRAM
#pragma surface surf BlinnPhongEditor  noforwardadd vertex:vert
#pragma target 2.0


sampler2D _MainTex;
sampler2D _Normal;
float _Gloss;
float4 _SpecularColor;
float4 _EnvColor;
sampler2D _Mask;
samplerCUBE _Reflection;

			struct EditorSurfaceOutput {
				half3 Albedo;
				half3 Normal;
				half3 Emission;
				half3 Gloss;
				half Specular;
				half Alpha;
				half4 Custom;
			};
			
			inline half4 LightingBlinnPhongEditor_PrePass (EditorSurfaceOutput s, half4 light)
			{
half3 spec = light.a * s.Gloss;
half4 c;
c.rgb = (s.Albedo * light.rgb + light.rgb * spec);
c.a = s.Alpha;
return c;

			}

			inline half4 LightingBlinnPhongEditor (EditorSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
			{
				half3 h = normalize (lightDir + viewDir);
				
				half diff = max (0, dot ( lightDir, s.Normal ));
				
				float nh = max (0, dot (s.Normal, h));
				float spec = pow (nh, s.Specular*128.0);
				
				half4 res;
				res.rgb = _LightColor0.rgb * diff;
				res.w = spec * Luminance (_LightColor0.rgb);
				res *= atten * 2.0;

				return LightingBlinnPhongEditor_PrePass( s, res );
			}
			
			struct Input {
				float2 uv_MainTex;
float2 uv_Normal;
float3 viewDir;
float2 uv_Mask;

			};

			void vert (inout appdata_full v, out Input o) {
float4 VertexOutputMaster0_0_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_1_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_2_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_3_NoInput = float4(0,0,0,0);


			}
			

			void surf (Input IN, inout EditorSurfaceOutput o) {
				o.Normal = float3(0.0,0.0,1.0);
				o.Alpha = 1.0;
				o.Albedo = 0.0;
				o.Emission = 0.0;
				o.Gloss = 0.0;
				o.Specular = 0.0;
				o.Custom = 0.0;
				
float4 Tex2D0=tex2D(_MainTex,(IN.uv_MainTex.xyxy).xy);
float4 Tex2DNormal0=float4(UnpackNormal( tex2D(_Normal,(IN.uv_Normal.xyxy).xy)).xyz, 1.0 );
float4 TexCUBE0=texCUBE(_Reflection,float4( IN.viewDir.x, IN.viewDir.y,IN.viewDir.z,1.0 ));

		TexCUBE0 *= _EnvColor;

float4 Lerp0=lerp(Tex2D0,TexCUBE0,_Gloss.xxxx);
float4 Multiply1=_SpecularColor * Lerp0;
float4 Tex2D1=tex2D(_Mask,(IN.uv_Mask.xyxy).xy);
float4 Splat0=Tex2D1.x;
float4 Multiply2=Multiply1 * Splat0;
float4 Multiply3=Multiply2 * _Gloss.xxxx;
float4 Splat1=Tex2D1.y;
float4 Multiply4=Splat1 * float4( 2,2,2,2 );
float4 Multiply0=Tex2D0.aaaa * _SpecularColor;
float4 Master0_5_NoInput = float4(1,1,1,1);
float4 Master0_7_NoInput = float4(0,0,0,0);
float4 Master0_6_NoInput = float4(1,1,1,1);
o.Albedo = Tex2D0;
o.Normal = Tex2DNormal0;
o.Emission = Multiply3;
o.Specular = Multiply4;
o.Gloss = Multiply0;

				o.Normal = normalize(o.Normal);
			}
		ENDCG
	}
	Fallback "Diffuse"
}