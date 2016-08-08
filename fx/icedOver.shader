// vim: ft=cg

Shader "icedOver"
{
    Properties 
    {
        _icyNormals("Icy Normal Map", 2D) = "bump" {}
        _icyness("Icyness", Range(0.5,50) ) = 0.5
        _icyColor("Ice Color", Color) = (1,1,1,1)
        _glossiness("Icyness", Range(0,1) ) = 0.5
        _specularColor("Moisture Color", Color) = (1,1,1,1)
        _colorTexture("Thawed Color", 2D) = "black" {}
        _mainNormals("Thawed Normal", 2D) = "black" {}

    }

    SubShader 
    {

        Tags
        {
            "Queue"="Geometry"
            "IgnoreProjector"="False"
            "RenderType"="Opaque"
        }


        Cull Back
        ZWrite On
        ZTest LEqual
        ColorMask RGBA
        Fog { }


        CGPROGRAM
        #pragma surface surf BlinnPhongEditor  vertex:vert
        #pragma target 3.0


        sampler2D _icyNormals;
        float _icyness;
        float4 _icyColor;
        float _glossiness;
        float4 _specularColor;
        sampler2D _colorTexture;
        sampler2D _mainNormals;

        struct EditorSurfaceOutput {
            half3 Albedo;
            half3 Normal;
            half3 Emission;
            half3 Gloss;
            half Specular;
            half Alpha;
            half4 Custom;
        };

        inline half4 LightingBlinnPhongEditor_PrePass (EditorSurfaceOutput s, half4 light)
        {
            half3 spec = light.a * s.Gloss;
            half4 c;
            c.rgb = (s.Albedo * light.rgb + light.rgb * spec);
            c.a = s.Alpha;
            return c;

        }

        inline half4 LightingBlinnPhongEditor (EditorSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            half3 h = normalize (lightDir + viewDir);

            half diff = max (0, dot ( lightDir, s.Normal ));

            float nh = max (0, dot (s.Normal, h));
            float spec = pow (nh, s.Specular*128.0);

            half4 res;
            res.rgb = _LightColor0.rgb * diff;
            res.w = spec * Luminance (_LightColor0.rgb);
            res *= atten * 2.0;

            return LightingBlinnPhongEditor_PrePass( s, res );
        }

        struct Input
        {
            float2 uv_colorTexture;
            float2 uv_mainNormals;
            float3 viewDir;
            float2 uv_icyNormals;
        };

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float4 VertexOutputMaster0_0_NoInput = float4(0,0,0,0);
            float4 VertexOutputMaster0_1_NoInput = float4(0,0,0,0);
            float4 VertexOutputMaster0_2_NoInput = float4(0,0,0,0);
            float4 VertexOutputMaster0_3_NoInput = float4(0,0,0,0);
        }


        void surf (Input IN, inout EditorSurfaceOutput o)
        {
            o.Normal = float3(0.0,0.0,1.0);
            o.Alpha = 1.0;
            o.Albedo = 0.0;
            o.Emission = 0.0;
            o.Gloss = 0.0;
            o.Specular = 0.0;
            o.Custom = 0.0;

            float4 Sampled2D1=tex2D(_colorTexture,IN.uv_colorTexture.xy);
            float4 Sampled2D2=tex2D(_mainNormals,IN.uv_mainNormals.xy);
            float4 UnpackNormal1=float4(UnpackNormal(Sampled2D2).xyz, 1.0);
            float4 Sampled2D0=tex2D(_icyNormals,IN.uv_icyNormals.xy);
            float4 UnpackNormal0=float4(UnpackNormal(Sampled2D0).xyz, 1.0);
            float4 Fresnel0=(1.0 - dot( normalize( float4( IN.viewDir.x, IN.viewDir.y,IN.viewDir.z,1.0 ).xyz), normalize( UnpackNormal0.xyz ) )).xxxx;
            float4 Pow0=pow(Fresnel0,_icyness.xxxx);
            float4 Multiply0=_icyColor * Pow0;
            float4 Master0_5_NoInput = float4(1,1,1,1);
            float4 Master0_7_NoInput = float4(0,0,0,0);
            float4 Master0_6_NoInput = float4(1,1,1,1);
            o.Albedo = Sampled2D1;
            o.Normal = UnpackNormal1;
            o.Emission = Multiply0;
            o.Specular = _glossiness.xxxx;
            o.Gloss = _specularColor;

            o.Normal = normalize(o.Normal);
        }
        ENDCG
    }
    Fallback "Standard"
}
