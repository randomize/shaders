// vim: ft=cg
Shader "Bully/Legacy/Lightmapped/Fresnel Diffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_LightMap ("Lightmap (RGB)", 2D) = "black" {}
    _RimPower ("Fresnel", Float) = 2
}

SubShader {
	LOD 200
	Tags { "RenderType" = "Opaque" }
    CGPROGRAM
    #pragma surface surf Lambert nodynlightmap


    struct Input {
        float2 uv_MainTex;
        float2 uv2_LightMap;
        float3 worldRefl;
        float3 viewDir;
    };
    sampler2D _MainTex;
    sampler2D _LightMap;
    fixed4 _Color;
    fixed _RimPower;


    void surf (Input IN, inout SurfaceOutput o)
    {
        half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
        half4 lm = tex2D (_LightMap, IN.uv2_LightMap);

        float rim = 1.0 - saturate(dot(o.Normal, normalize(IN.viewDir)));
        rim = pow(rim, _RimPower);

        o.Albedo = c;
        o.Emission = lm.rgb * o.Albedo.rgb * rim;
        o.Alpha = lm.a * _Color.a;
    }
    ENDCG
}
FallBack "Legacy Shaders/Lightmapped/VertexLit"
}
