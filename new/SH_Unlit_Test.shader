// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// vim: ft=cg
Shader "Unlit/SH_Unlit_Test"
{
	Properties
	{
        _OcclusionStrength("Occlusion Strength", Range(0, 1)) = 1
		_OcclusionMap ("Occlusion (G)", 2D) = "white" {}

		_EmissionMap ("Emission", 2D) = "white" {}
        _EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
        _EmissionMultiplier ("Emission Multiplier", Range(0.0, 2.0)) = 0.0

		_GradientOne ("Gradient One", Color) = (0,0,0,1)
		_GradientTwo ("Gradient Two", Color) = (1,1,1,1)
        _GradientStrength("Gradient Strength", Range(0.0, 1.0)) = 0.2
        _GradientMultiplier("Gradient Multiplier", Float) = 1.0
        _GradientShift("Gradient Shift", Range(0.2, 6)) = 1
        _GradientOffset("Gradient Offset", Range(-1.0, 1.0)) = 0.0
        //_GradFactor("Grad Factor", Float) = 1.0

        _FresnelColorA ("Fresnel Color A", Color) = (1, 1, 1, 1)
        _FresnelColorB ("Fresnel Color B", Color) = (1, 1, 1, 1)
        _FresnelPower ("Fresnel Power", Float) = 1.0
        _FresnelStrength ("Fresnel Strength", Range(0, 1)) = 1.0


        _Dim("Dimming Effect", Range(0, 3)) = 0.0
        _DimColor("Dimming Color", Color) = (0, 0, 0, 0)

        _Dim("Dimming Effect", Range(0, 3)) = 0.0
        _DimColor("Dimming Color", Color) = (0, 0, 0, 0)
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
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
                float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
			};

			struct v2f
			{
                float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                half3 worldNormal : TEXCOORD3;
                //float4 raw_vertex : COLOR;
			};
            float4 _OcclusionMap_ST;

            sampler2D _OcclusionMap;
            sampler2D _EmissionMap;
            half _OcclusionStrength;
            fixed4 _EmissionColor;
            half _EmissionMultiplier;

            fixed4 _GradientOne;
            fixed4 _GradientTwo;
            fixed _GradientStrength;
            fixed _GradientMultiplier;
            fixed _GradientShift;
            fixed _GradientOffset;

            fixed4 _FresnelColorA;
            fixed4 _FresnelColorB;
            fixed _FresnelPower;
            fixed _FresnelStrength;

            half _Dim;
            fixed4 _DimColor;


            inline half Occlusion(fixed2 uv)
            {
#if (SHADER_TARGET < 30)
                return tex2D(_OcclusionMap, uv).g;
#else
                half occ = tex2D(_OcclusionMap, uv).g;
                return LerpOneTo(occ, _OcclusionStrength);
#endif
            }
            inline half3 Emission(fixed2 uv)
            {
                return tex2D(_EmissionMap, uv).rgb * _EmissionColor.rgb;
            }




			
			v2f vert (appdata v)
			{
				v2f o;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldDir(v.normal);
                    
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = worldPos;
                o.worldNormal = worldNormal;
				o.uv = TRANSFORM_TEX(v.uv, _OcclusionMap);
                o.uv2 = TRANSFORM_TEX(v.uv2, _OcclusionMap);

                //o.raw_vertex = v.vertex;
				return o;
			}
			
			fixed4 frag (v2f IN) : SV_Target
			{
                float3 worldPos = IN.worldPos;
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                
                fixed4 c = 0.0;


                half fresnel = saturate(dot(IN.worldNormal, normalize(viewDir)));
                fixed3 rimColor = lerp(_FresnelColorA, _FresnelColorB, fresnel * _FresnelPower);


                half inuv = IN.uv2.y;
                inuv = saturate(inuv + _GradientOffset);
                half gradAlpha = 1.0 - pow(1.0 - inuv, _GradientShift);
                //gradAlpha = saturate(gradAlpha + _GradientOffset);
                half3 grad = lerp(_GradientOne, _GradientTwo, gradAlpha) * _GradientMultiplier;
                half occ = tex2D(_OcclusionMap, IN.uv).g;


                half3 emission = Emission(IN.uv);
                c.rgb = emission;
                c.rgb = lerp(c.rgb, c.rgb * grad, _GradientStrength);
                c.rgb = lerp(c.rgb, c.rgb * occ, _OcclusionStrength);
                c.rgb = lerp(c.rgb, c.rgb * rimColor, _FresnelStrength);
                c.rgb = c.rgb + (emission * _EmissionMultiplier);


                c.rgb = c.rgb * (_Dim * _DimColor);
				return c;
			}
			ENDCG
		}
	}
}
