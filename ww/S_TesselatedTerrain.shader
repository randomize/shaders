// vim: ft=cg
Shader "Custom/S_TesselatedTerrain" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Normal (RGB)", 2D) = "white" {}
		_Glossiness ("Glossiness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_MetallicGlossMap ("Metallic map", 2D) = "white" {}
        _Displacement ("Displacement", Range(0, 62.0)) = 0.3
        _DispTex ("Disp Texture", 2D) = "gray" {}
        _Tess ("Tessellation", Range(1,64)) = 4
        _MinDist ("Min", Float) = 10
        _MaxDist ("Mak", Float) = 25
	}
	SubShader {
		Tags { "RenderType"="Opaque-1" }
		LOD 300
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		/* #pragma surface surf Standard fullforwardshadows noambient */
		#pragma surface surf Standard fullforwardshadows vertex:disp tessellate:tessDistance 
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 4.6
        #include "Tessellation.cginc"

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        float _Tess;
        float _MinDist;
        float _MaxDist;

        float4 tessDistance (appdata v0, appdata v1, appdata v2) {
            float minDist = _MinDist;
            float maxDist = _MaxDist;
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
        }

        sampler2D _DispTex;
        float _Displacement;

        void disp (inout appdata v)
        {
            float d = tex2Dlod(_DispTex, float4(v.texcoord.xy,0,0)).r * _Displacement;
            v.vertex.xyz += v.normal * d;
        }

		sampler2D _MainTex;
		sampler2D _MetallicGlossMap;
		sampler2D _BumpMap;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_MetallicGlossMap;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed2 g = tex2D (_MetallicGlossMap, IN.uv_MetallicGlossMap).ra;
			g.g *= _Metallic;

            fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)); 
			o.Albedo = c.rgb;
			/* o.Albedo = g; */
			// Metallic and smoothness come from slider variables
			o.Metallic = g.x;
            o.Normal = normalize(normal);
			o.Smoothness = g.y;
			/* o.Emission = c * _Glossiness * (1 - g.x); */
			/* o.Alpha = c.a; */
		}
		ENDCG
	}
	FallBack "Diffuse"
}
