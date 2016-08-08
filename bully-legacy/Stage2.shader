Shader "Bully!/Stage2" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EmissiveColor("Emissive Color", Color) = (1,1,1)
		_Power("_Power", Range(0,5) ) = 1.5

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert halfAsView

		sampler2D _MainTex;
		float4 _EmissiveColor;
		float _Power;
		
		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Emission = (c.rgb * _EmissiveColor.rgb) * (c.a * _Power);
			//o.Alpha = c.a;
			
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
