Shader "Custom/S_Mirror_Surf" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
        _Mask ("Mask (RGB)", 2D) = "white" {}
        [HideInInspector] _ReflectionTex ("", 2D) = "white" {}
        _NormalMap ("Normals", 2D) = "blue" {}
        _Power ("Normal distortion", Range(0, 2.2)) = 0
        _Trsh ("Trsh", Range(0, 1.2)) = 0
        _FrsnlExp ("Fresnel exp", float) = 1
        _FrsnlPwr ("Fresnel power", Range(0, 1)) = 0.5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert
		/* #pragma surface surf Standard fullforwardshadows */

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0


		struct Input {
			float2 uv_MainTex;
			float2 uv_NormalMap;
            float3 viewDir;
            float4 screenPos;
            float4 refl;
		};

		sampler2D _MainTex;
		sampler2D _NormalMap;
        sampler2D _ReflectionTex;
        sampler2D _Mask;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
        float _Power;
        float _Trsh;
        float _FrsnlPwr;
        float _FrsnlExp;

        // Vertex modifier function
        /* void vert (inout appdata_full v) */
        void vert (inout appdata_full v, out Input data)
        {
            UNITY_INITIALIZE_OUTPUT(Input,data);

            data.refl = ComputeScreenPos ( mul(UNITY_MATRIX_MVP, v.vertex));


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
                data.refl.x = (data.refl.x * 0.5f);
            }
            else if (unity_CameraProjection[0][2] > 0)
            {
                data.refl.x = (data.refl.x * 0.5f) + (data.refl.w * 0.5f);
            }
#endif
        }

		void surf (Input IN, inout SurfaceOutputStandard o)
        {
            
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 m = tex2D (_Mask, IN.uv_MainTex);
            fixed3 n = UnpackNormal (tex2D (_NormalMap, IN.uv_NormalMap));

            float4 uvs = IN.refl;
            uvs.xy += (n.xy * c.r) * _Power;

            fixed4 refl = tex2Dproj(
                _ReflectionTex, 
                UNITY_PROJ_COORD(uvs));

            // Fresnel
            float frsnl = dot(normalize(IN.viewDir.xyz), n);
            frsnl = saturate(pow(frsnl, _FrsnlExp));
            m = lerp(1, m, _FrsnlPwr * frsnl);


			o.Albedo = lerp(refl.rgb, c.rgb, saturate(m.r + _Trsh));
			o.Metallic = _Metallic;
            o.Normal = n;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
