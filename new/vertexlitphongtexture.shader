//vertex lit phong shader with spec map


Shader "CG Shaders/Phong/Vertex Lit Phong Texture"
{
	Properties
	{
		_diffuseColor("Diffuse Color", Color) = (1,1,1,1)
		_diffuseMap("Diffuse / Specular (A)", 2D) = "white" {}
		_FrenselPower ("Rim Power", Range(1.0, 10.0)) = 2.5
		_FrenselPower (" ", Float) = 2.5
		_rimColor("Rim Color", Color) = (1,1,1,1)
		_specularPower ("Specular Power", Range(1.0, 50.0)) = 10
		_specularPower (" ", Float) = 10
		_specularColor("Specular Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" } 
            
			CGPROGRAM
			
			#pragma vertex vShader
			#pragma fragment pShader
			#include "UnityCG.cginc"
			#pragma multi_compile_fwdbase
			
			uniform fixed3 _diffuseColor;
			uniform sampler2D _diffuseMap;
			uniform half4 _diffuseMap_ST;			
			uniform fixed4 _LightColor0; 
			uniform half _FrenselPower;
			uniform fixed4 _rimColor;
			uniform half _specularPower;
			uniform fixed3 _specularColor;
			
			struct app2vert {
				float4 vertex 	: 	POSITION;
				fixed2 texCoord : 	TEXCOORD0;
				fixed4 normal 	:	NORMAL;
			};
			struct vert2Pixel
			{
				float4 pos 						: 	SV_POSITION;
				fixed2 uvs						:	TEXCOORD0;
				fixed4 lighting					:	TEXCOORD1;	
			};
			
			fixed lambert(fixed3 N, fixed3 L)
			{
				return saturate(dot(N, L));
			}
			fixed frensel(fixed3 V, fixed3 N, half P)
			{	
				return pow(1 - saturate(dot(V,N)), P);
			}
			fixed phong(fixed3 R, fixed3 L)
			{
				//similarly to lambert we get the dot product of the reflection vector compared to world normal
				//we saturate to prevent < 0 results from dot product and power according to the _specularPower of the shader	
				return pow(saturate(dot(R, L)), _specularPower);
			}
			vert2Pixel vShader(app2vert IN)
			{
				vert2Pixel OUT;
				float4x4 WorldViewProjection = UNITY_MATRIX_MVP;
				float4x4 WorldInverseTranspose = _World2Object; 
				float4x4 World = _Object2World;
							
				OUT.pos = mul(WorldViewProjection, IN.vertex);
				OUT.uvs = IN.texCoord;	
				
				//derived vectors
				fixed3 normalDir = normalize(mul(IN.normal, WorldInverseTranspose).xyz);
				half3 posWorld = mul(World, IN.vertex).xyz;
				fixed3 viewDir = normalize(_WorldSpaceCameraPos - posWorld);
				fixed3 reflectionVector = -reflect(viewDir , normalDir);
				
				//vertex lights
				fixed3 vertexLighting = fixed3(0.0, 0.0, 0.0);
				#ifdef VERTEXLIGHT_ON
				 for (int index = 0; index < 4; index++)
					{    						
						half3 vertexToLightSource = half3(unity_4LightPosX0[index], unity_4LightPosY0[index], unity_4LightPosZ0[index]) - posWorld;
						fixed attenuation  = (1.0/ length(vertexToLightSource)) *.5;	
						fixed3 diffuse = unity_LightColor[index].xyz * lambert(normalDir, normalize(vertexToLightSource)) * attenuation;
						vertexLighting = vertexLighting + diffuse;
					}
					vertexLighting = saturate( vertexLighting );
				#endif
				
				//Main Light calculation - includes directional lights
				half3 vertexToLightSource =_WorldSpaceLightPos0.xyz - (posWorld*_WorldSpaceLightPos0.w);
				fixed attenuation  = lerp(1.0, 1.0/ length(vertexToLightSource), _WorldSpaceLightPos0.w);				
				fixed3 lightDirection = normalize(vertexToLightSource);
				fixed3 ambientL = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed diffuseL = lambert(normalDir, lightDirection);
				
				//rimLight calculation
				fixed rimLight = frensel(normalDir, viewDir, _FrenselPower);
				rimLight *= saturate(dot(fixed3(0,1,0),normalDir)* 0.5 + 0.5)* saturate(dot(fixed3(0,1,0),-viewDir)+ 1.75);	
				fixed3 diffuse = _LightColor0.xyz * (diffuseL+ (rimLight * diffuseL) )* attenuation;
				rimLight *= (1-diffuseL);
				
				//add all the diffuse lighting together
				fixed3 diffuseTotal = saturate(ambientL + vertexLighting + diffuse + (rimLight*_rimColor));
				fixed specular = phong(reflectionVector ,lightDirection)*attenuation;
				OUT.lighting = fixed4(diffuseTotal,specular) ;
				
				return OUT;
			}
			
			fixed4 pShader(vert2Pixel IN): COLOR
			{
				fixed4 outColor;							
				half2 diffuseUVs = TRANSFORM_TEX(IN.uvs, _diffuseMap);
				fixed4 texSample = tex2D(_diffuseMap, diffuseUVs);
				fixed3 diffuse = (IN.lighting.xyz * texSample.xyz) * _diffuseColor;
				//pull out specular and multiply it by spec map
				//since it is in the alpha already this is all we have to do :)
				fixed3 specular = (IN.lighting.w * _specularColor * texSample.w);
				outColor = fixed4( diffuse + specular,1.0);
				return outColor;
			}
			
			ENDCG
		}	
		
		//the second pass for additional lights
		Pass
		{
			Tags { "LightMode" = "ForwardAdd" } 
			Blend One One 
			
			CGPROGRAM
			#pragma vertex vShader
			#pragma fragment pShader
			#include "UnityCG.cginc"
			
			uniform fixed3 _diffuseColor;
			uniform sampler2D _diffuseMap;
			uniform half4 _diffuseMap_ST;
			uniform fixed4 _LightColor0; 		
			uniform half _specularPower;
			uniform fixed3 _specularColor;
			
			
			
			struct app2vert {
				float4 vertex 	: 	POSITION;
				fixed2 texCoord : 	TEXCOORD0;
				fixed4 normal 	:	NORMAL;
			};
			struct vert2Pixel
			{
				float4 pos 						: 	SV_POSITION;
				fixed2 uvs						:	TEXCOORD0;	
				//changing to a fixed4 to allow the specular in alpha
				fixed4 lighting					:	TEXCOORD1;	
			};
			
			fixed lambert(fixed3 N, fixed3 L)
			{
				return saturate(dot(N, L));
			}			
			fixed phong(fixed3 R, fixed3 L)
			{
				//similarly to lambert we get the dot product of the reflection vector compared to world normal
				//we saturate to prevent < 0 results from dot product and power according to the _specularPower of the shader	
				return pow(saturate(dot(R, L)), _specularPower);
			}
			vert2Pixel vShader(app2vert IN)
			{
				vert2Pixel OUT;
				float4x4 WorldViewProjection = UNITY_MATRIX_MVP;
				float4x4 WorldInverseTranspose = _World2Object; 
				float4x4 World = _Object2World;
				
				OUT.pos = mul(WorldViewProjection, IN.vertex);
				OUT.uvs = IN.texCoord;	
				
				//derived vectors
				fixed3 normalDir = normalize(mul(IN.normal, WorldInverseTranspose).xyz);
				half3 posWorld = mul(World, IN.vertex).xyz;
				fixed3 viewDir = normalize(_WorldSpaceCameraPos - posWorld);
				fixed3 reflectionVector = -reflect(viewDir , normalDir);
				
				//Fill lights
				half3 vertexToLightSource = _WorldSpaceLightPos0.xyz - (posWorld*_WorldSpaceLightPos0.w);
				fixed attenuation  = lerp(1.0, 1.0/ length(vertexToLightSource), _WorldSpaceLightPos0.w);				
				fixed3 lightDirection = normalize(vertexToLightSource);
				
				fixed diffuseL = lambert(normalDir, lightDirection);				
				fixed3 diffuse = _LightColor0.xyz * diffuseL * attenuation;
				
				//specular highlight
				fixed specular = phong(reflectionVector ,lightDirection)*attenuation;
				OUT.lighting = fixed4(diffuse,specular) ;				
				return OUT;
			}
			fixed4 pShader(vert2Pixel IN): COLOR
			{
				fixed4 outColor;							
				half2 diffuseUVs = TRANSFORM_TEX(IN.uvs, _diffuseMap);
				fixed4 texSample = tex2D(_diffuseMap, diffuseUVs);
				//pull out diffuse lighting 
				fixed3 diffuse = (IN.lighting.xyz * texSample.xyz) * _diffuseColor;
				//pull out specular and multiply it by spec map
				//since it is in the alpha already this is all we have to do :)
				fixed3 specular = IN.lighting.w * _specularColor * texSample.w;
				outColor = fixed4( diffuse + specular,1.0);
				return outColor;
			}
			
			ENDCG
		}	
		
	}
}