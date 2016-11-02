//basic phong CG shader with spec map


Shader "CG Shaders/Unlit/Hologram"
{
	Properties
	{
		_baseColor("Base Color", Color) = (1,1,1,1)
		_baseBloom("Base Bloom", Range(1,5)) = 1.0
		_baseBloom(" ", Float) = 1.0
		_baseMap("Base", 2D) = "white" {}
		_hologramColor("Hologram Color", Color) = (1,1,1,1)
		_holoBloom("Hologram Bloom", Range(1,5)) = 1.0
		_holoBloom(" ", Float) = 1.0
		_blendMap("Hologram", 2D) = "white" {}
		_holoPower("Hologram Power", Range(1,10)) = 1.0
		_holoPower(" ", Float) = 1.0
		_destinationPos("Destination Position", Float) = (0,-1,0,1)
		_blended("Blended", Range(1,3.5)) = 2
		_vertexFalloff("Vertex Falloff", Range(0,5)) = 1
		_vertexFalloff(" ", Float) = 1
		_alphaFalloff("Alpha Falloff", Range(1,10)) = 5
		_alphaFalloff(" ", Float) = 5
		_uvScale("UV Scale", Range(0,5)) = 1.0
		_uvScale(" ", Float) = 1.0
	}
	SubShader
	{
		//set the render queue to transparent so it renders last
		Tags {"Queue" = "Transparent" } 
		
		Pass
		{
			// don't write to depth buffer in order not to occlude other objects
			ZWrite Off 
			//Additive Alpha Blending 
			Blend SrcAlpha One 
            Cull Front
			
			CGPROGRAM
			
			#pragma vertex vShader
			#pragma fragment pShader
			#include "UnityCG.cginc"
			
			uniform fixed3 _baseColor;
			uniform fixed _baseBloom;
			uniform sampler2D _baseMap;
			uniform half4 _baseMap_ST;	
			uniform fixed3 _hologramColor;
			uniform fixed _holoBloom;
			uniform sampler2D _blendMap;
			uniform half4 _blendMap_ST;	
			uniform half _holoPower;
			uniform half3 _destinationPos;
			uniform half _blended;
			uniform half _vertexFalloff;
			uniform half _alphaFalloff;
			
			//uv attributes			
			half _uvScale;
			
			struct app2vert {
				float4 vertex 	: 	POSITION;
				fixed2 texCoord : 	TEXCOORD0;
				fixed4 normal 	:	NORMAL;
				
			};
			struct vert2Pixel
			{
				float4 pos 						: 	SV_POSITION;
				fixed2 uvs							:	TEXCOORD0;
				fixed3 normalDir					:	TEXCOORD1;	
				half3 posWorld						:	TEXCOORD2;	
				fixed3 blendDir						:	TEXCOORD3;	
			};
			
			
			vert2Pixel vShader(app2vert IN)
			{
				vert2Pixel OUT;
				float4x4 WorldViewProjection = UNITY_MATRIX_MVP;
				float4x4 WorldInverseTranspose = _World2Object; 
				float4x4 World = _Object2World;
				
				float4 deformedPosition = IN.vertex;
				deformedPosition = mul( World, deformedPosition  );
				
				//calculate the direction to blend in
				//this is done via destination position - 0,0,0
				OUT.blendDir = normalize(_destinationPos.xyz  - fixed3(0,0,0));
				fixed blend = saturate((dot(OUT.blendDir, IN.normal) + (_blended-2)) * _vertexFalloff);
				//lerp the position via blend
				deformedPosition.xyz = lerp(deformedPosition.xyz, deformedPosition.xyz + _destinationPos.xyz, blend);
				
				OUT.posWorld = deformedPosition;
				
				deformedPosition = float4(mul(  WorldInverseTranspose, deformedPosition ).xyz, 1);
				OUT.pos = mul(WorldViewProjection, deformedPosition);
				
				OUT.uvs = IN.texCoord;
				//technically this is now incorrect thanks to vertex manipulation
				//however the visual difference is minimal, since we only use it to project uvs
				//therefore i just pass the normals along to save instructions
				OUT.normalDir = normalize(mul(IN.normal, WorldInverseTranspose).xyz);
				
				
				return OUT;
			}
			
			fixed4 pShader(vert2Pixel IN): COLOR
			{
				half3 posMap = IN.posWorld / _uvScale;				
				fixed3 maskNormal = abs(IN.normalDir);
				half2 uvs = half2(0,0);
				fixed otherDir = 0;
				if (maskNormal.x  >= maskNormal.z )
				{		
					otherDir = 	maskNormal.x;	
					uvs = half2(posMap.z,posMap.y);
				}
				else
				{
					otherDir = 	maskNormal.z;	
					uvs = half2(posMap.x,posMap.y);
					
				}
				if(maskNormal.y  >= otherDir )
				{
					uvs = half2(posMap.x,posMap.z);
				}
				//recreate the blend in the pixel shader
				//It would be cheaper to pass from the vertex shader but this is slightly less accurate
				//Instead I just pass the blend direction
				fixed blend = (dot(IN.blendDir, IN.normalDir) + (_blended-2)) * _vertexFalloff;
				//multiply and saturate the blend to control the alpha blend differently
				blend = saturate(blend * _alphaFalloff);
				
				
				fixed4 outColor;							
				half2 diffuseUVs = TRANSFORM_TEX(IN.uvs, _baseMap);
				fixed4 texSample = tex2D(_baseMap, diffuseUVs);
				//I only use a single channel for the hologram
				half2 blendUVs = TRANSFORM_TEX(uvs, _blendMap);
				fixed3 blendSample = pow((tex2D(_blendMap, blendUVs).x * texSample.w),_holoPower) ;
				//colors and bloom
				texSample.xyz = texSample.xyz * (_baseColor.xyz * _baseBloom);
				blendSample = blendSample* (_hologramColor.xyz * _holoBloom);
				//lerp the 2 samples
				texSample.xyz = lerp(texSample.xyz, blendSample, blend);
				//multiply the base alpha by the blend alpha to create a total alpha
				fixed alpha = texSample.w * (1 - blend );
				//be sure to multiply the sample against the alpha, since this is an additive shader.
				outColor = fixed4( texSample.xyz * alpha, alpha);
				return outColor;
			}
			
			ENDCG
		}	
		
		Pass
		{
			// don't write to depth buffer in order not to occlude other objects
			ZWrite Off 
			//Additive Alpha Blending 
			Blend SrcAlpha One 
            Cull Back
			
			CGPROGRAM
			
			#pragma vertex vShader
			#pragma fragment pShader
			#include "UnityCG.cginc"
			
			uniform fixed3 _baseColor;
			uniform fixed _baseBloom;
			uniform sampler2D _baseMap;
			uniform half4 _baseMap_ST;	
			uniform fixed3 _hologramColor;
			uniform fixed _holoBloom;
			uniform sampler2D _blendMap;
			uniform half4 _blendMap_ST;	
			uniform half _holoPower;
			uniform half3 _destinationPos;
			uniform half _blended;
			uniform half _vertexFalloff;
			uniform half _alphaFalloff;
			
			//uv attributes			
			half _uvScale;
			
			struct app2vert {
				float4 vertex 	: 	POSITION;
				fixed2 texCoord : 	TEXCOORD0;
				fixed4 normal 	:	NORMAL;
				
			};
			struct vert2Pixel
			{
				float4 pos 						: 	SV_POSITION;
				fixed2 uvs							:	TEXCOORD0;
				fixed3 normalDir					:	TEXCOORD1;	
				half3 posWorld						:	TEXCOORD2;	
				fixed3 blendDir						:	TEXCOORD3;	
			};
			
			
			vert2Pixel vShader(app2vert IN)
			{
				vert2Pixel OUT;
				float4x4 WorldViewProjection = UNITY_MATRIX_MVP;
				float4x4 WorldInverseTranspose = _World2Object; 
				float4x4 World = _Object2World;
				
				float4 deformedPosition = IN.vertex;
				deformedPosition = mul( World, deformedPosition  );
				
				//calculate the direction to blend in
				//this is done via destination position - 0,0,0
				OUT.blendDir = normalize(_destinationPos.xyz  - half3(0,0,0));
				fixed blend = saturate((dot(OUT.blendDir, IN.normal) + (_blended-2)) * _vertexFalloff);
				//lerp the position via blend
				deformedPosition.xyz = lerp(deformedPosition.xyz, deformedPosition.xyz + _destinationPos.xyz, blend);
				
				OUT.posWorld = deformedPosition;
				
				deformedPosition = float4(mul(  WorldInverseTranspose, deformedPosition ).xyz, 1);
				OUT.pos = mul(WorldViewProjection, deformedPosition);
				
				OUT.uvs = IN.texCoord;
				//technically this is now incorrect thanks to vertex manipulation
				//however the visual difference is minimal, since we only use it to project uvs
				//therefore i just pass the normals along to save instructions
				OUT.normalDir = normalize(mul(IN.normal, WorldInverseTranspose).xyz);
				
				
				return OUT;
			}
			
			fixed4 pShader(vert2Pixel IN): COLOR
			{
				half3 posMap = IN.posWorld / _uvScale;				
				fixed3 maskNormal = abs(IN.normalDir);
				half2 uvs = half2(0,0);
				fixed otherDir = 0;
				if (maskNormal.x  >= maskNormal.z )
				{		
					otherDir = 	maskNormal.x;	
					uvs = half2(posMap.z,posMap.y);
				}
				else
				{
					otherDir = 	maskNormal.z;	
					uvs = half2(posMap.x,posMap.y);
					
				}
				if(maskNormal.y  >= otherDir )
				{
					uvs = half2(posMap.x,posMap.z);
				}
				//recreate the blend in the pixel shader
				//It would be cheaper to pass from the vertex shader but this is slightly less accurate
				//Instead I just pass the blend direction
				fixed blend = (dot(IN.blendDir, IN.normalDir) + (_blended-2)) * _vertexFalloff;
				//multiply and saturate the blend to control the alpha blend differently
				blend = saturate(blend * _alphaFalloff);
				
				
				fixed4 outColor;							
				half2 diffuseUVs = TRANSFORM_TEX(IN.uvs, _baseMap);
				fixed4 texSample = tex2D(_baseMap, diffuseUVs);
				//I only use a single channel for the hologram
				half2 blendUVs = TRANSFORM_TEX(uvs, _blendMap);
				fixed3 blendSample = pow((tex2D(_blendMap, blendUVs).x * texSample.w),_holoPower) ;
				//colors and bloom
				texSample.xyz = texSample.xyz * (_baseColor.xyz * _baseBloom);
				blendSample = blendSample* (_hologramColor.xyz * _holoBloom);
				//lerp the 2 samples
				texSample.xyz = lerp(texSample.xyz, blendSample, blend);
				//multiply the base alpha by the blend alpha to create a total alpha
				fixed alpha = texSample.w * (1 - blend );
				//be sure to multiply the sample against the alpha, since this is an additive shader.
				outColor = fixed4( texSample.xyz * alpha, alpha);
				return outColor;
			}
			
			ENDCG
		}	
		
		
	}
}