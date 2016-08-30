// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// vim: ft=cg
Shader "FX/MirrorReflection"
{
Properties
{
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _Mask ("Mask (RGB)", 2D) = "white" {}
    [HideInInspector] _ReflectionTex ("", 2D) = "white" {}
    _NormalMap ("Normals", 2D) = "blue" {}
    _Power ("Powor", Range(0, 1.2)) = 0
    _Trsh ("Trsh", Range(0, 1.2)) = 0
    _FrsnlExp ("Fresnel exp", float) = 1
    _FrsnlPwr ("Fresnel power", Range(0, 1)) = 0.5
}
SubShader
{
    Tags { "RenderType"="Opaque" }
    LOD 200

    Pass {
        CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"
        #include "Lighting.cginc"

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 refl : TEXCOORD1;
            float4 pos : SV_POSITION;
            float3 tangent : TEXCOORD2;  
            float3 normal : TEXCOORD3;
            float3 binormal : TEXCOORD4;
            float4 viewDir	: TEXCOORD5;
        };

        float4 _MainTex_ST;
        sampler2D _MainTex;
        sampler2D _ReflectionTex;
        sampler2D _NormalMap;
        sampler2D _Mask;
        float _Power;
        float _Trsh;
        float _FrsnlPwr;
        float _FrsnlExp;


        v2f vert(float4 pos : POSITION, float2 uv : TEXCOORD0, float3 nrm : NORMAL, float4 tg : TANGENT)
        {
            v2f o;

            o.pos = mul (UNITY_MATRIX_MVP, pos);
            o.uv = TRANSFORM_TEX(uv, _MainTex);
            o.refl = ComputeScreenPos (o.pos);


            // If we're not using single pass stereo rendering, then ComputeScreenPos will not give us the
            // correct coordinates needed when the reflection texture contains a side-by-side stereo image.
            // In this case, we need to manually adjust the the reflection coordinates, and we can determine
            // which eye is being rendered by observing the horizontal skew in the projection matrix.  If
            // the value is non-zero, then we assume that this render pass is part of a stereo camera, and
            // sign of the skew value tells us which eye.
            // TODO: Eugene - replace with smooth step
#ifndef UNITY_SINGLE_PASS_STEREO
            if (unity_CameraProjection[0][2] < 0)
            {
                o.refl.x = (o.refl.x * 0.5f);
            }
            else if (unity_CameraProjection[0][2] > 0)
            {
                o.refl.x = (o.refl.x * 0.5f) + (o.refl.w * 0.5f);
            }
#endif

            float4x4 mm = unity_ObjectToWorld;
            float4x4 mmi = unity_WorldToObject;
 
            o.normal = normalize( mul(float4(nrm, 0.0), mmi).xyz);
            o.tangent = normalize( mul(mm, float4(tg.xyz, 0.0)).xyz);
            o.binormal = normalize( cross(o.normal, o.tangent) * tg.w);

            float4 wvertex = mul(unity_ObjectToWorld, pos);
            o.viewDir.xyz = _WorldSpaceCameraPos - wvertex.xyz;

            return o;
        }


 		float3 DecodeNormal(float4 texel)
		{
				float4 norm = 2.0 * texel - 1.0;
#ifdef UNITY_NO_DXT5nm
				// use as is
#else
				norm.xy = norm.wy;
				norm.z = sqrt(1.0 - norm.x * norm.x - norm.y * norm.y);
#endif
				return norm.xyz;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            // Sample things
            fixed4 diffc = tex2D(_MainTex, i.uv);
            fixed4 m = tex2D(_Mask, i.uv);
            float3 nrm_l = DecodeNormal(tex2D(_NormalMap, i.uv));

            float3 lightDirection;
            float atten;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               atten = 1.0; // no atten
               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            } 
            else // point or spot light
            {
               float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - i.pos.xyz;
               float dist = length(vertexToLightSource);
               atten = 1.0 / dist; // linear atten 
               lightDirection = normalize(vertexToLightSource);
            }

            // Decode normal
            float3x3 l2w_tr = float3x3( i.tangent, i.binormal, i.normal);
            float3 nrm = normalize(mul(nrm_l, l2w_tr));
            float4 uvs = i.refl;
            uvs.xy += nrm_l.xy * _Power;
            fixed4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(uvs));

            // Lighting
            float3 diffuseReflection = atten * _LightColor0.rgb * diffc * max(0.0, dot(nrm, lightDirection));

            float frsnl = dot(normalize(i.viewDir.xyz), nrm);
            frsnl = saturate(pow(frsnl, _FrsnlExp));
            m = lerp(1, m, _FrsnlPwr * frsnl);

            return lerp(refl, diffc, saturate(m.r + _Trsh));
        }

        ENDCG
    }
}
}
