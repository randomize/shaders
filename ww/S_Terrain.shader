// vim: ft=cg
Shader "Custom/S_Terrain" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Displace ("Displace", float) = 0.0
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _DispMap ("Displace Map", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0


		struct Input {
			float2 uv_MainTex;
            float2 uv_BumpMap;
            /* float2 uv_DispMap; */
		};

		half _Glossiness;
		half _Metallic;
		half _Displace;
		fixed4 _Color;
		sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _DispMap;
        float4 _DispMap_ST;


        void vert (inout appdata_full v)
        {
			fixed4 c = tex2Dlod (_DispMap, float4(v.texcoord.xy * _DispMap_ST.xy,0,0));
			/* fixed4 c = tex2D (_DispMap, v.texcoord); */
            v.vertex.z += _Displace * c.r;
        }

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
			o.Alpha = c.a;

			/* fixed4 n = tex2Dlod (_DispMap, float4(IN.uv_MainTex,0,0)); */
			/* fixed4 n = tex2D (_DispMap, IN.uv_DispMap); */
            /* o.Albedo = n.r; */
		}
		ENDCG
	}
	FallBack "Diffuse"
}
