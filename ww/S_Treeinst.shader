// vim: ft=cg
Shader "Instanced/S_Treeinst" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Range ("Wind", Range(0,1)) = 1.0
		_BumpPower ("Depth", Range(0,1)) = 1.0
        _BumpMap ("Bumpmap", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		// And generate the shadow pass with instancing support
		#pragma surface surf Standard fullforwardshadows addshadow vertex:vert finalcolor:mycolor noshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		// Enable instancing for this shader
		#pragma multi_compile_instancing

		// Config maxcount. See manual page.
		// #pragma instancing_options

		sampler2D _MainTex;
        sampler2D _BumpMap;

		struct Input {
			float2 uv_MainTex;
            float2 uv_BumpMap;
		};

		half _Glossiness;
		half _Metallic;
		half _Range;
		half _BumpPower;

        void vert (inout appdata_full v)
        {
            float3 p = v.vertex.xyz;
            float d = _Range * _CosTime.z * p.z;
            v.vertex.xyz = float3(
                p.x + d * _CosTime.x,
                p.y + d * _SinTime.x,
                p.z
            );
        }

        void mycolor (Input IN, SurfaceOutputStandard o, inout fixed4 color)
        {
#ifdef UNITY_PASS_FORWARDADD
            fixed upper = 0.5;
#endif
            color.rgb = clamp (color.rgb, 0, 0.1);
        }
		// Declare instanced properties inside a cbuffer.
		// Each instanced property is an array of by default 500(D3D)/128(GL) elements. Since D3D and GL imposes a certain limitation
		// of 64KB and 16KB respectively on the size of a cubffer, the default array size thus allows two matrix arrays in one cbuffer.
		// Use maxcount option on #pragma instancing_options directive to specify array size other than default (divided by 4 when used
		// for GL).
		UNITY_INSTANCING_CBUFFER_START(Props)
			UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)	// Make _Color an instanced property (i.e. an array)
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * UNITY_ACCESS_INSTANCED_PROP(_Color);
            /* o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap)); */
            fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)); 
            normal.z = normal.z / _BumpPower; 
            o.Normal = normalize(normal); 
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
            /* o.Gloss = 0.3; */
		}
		ENDCG
	}
	FallBack "Diffuse"
}
