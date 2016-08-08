// vim: ft=cg

Shader "Bully!/Lit/BRDFDetail" {

    Properties { 

        _MainTex ("Texture", 2D) = "white" {}
        _DetailAlbedoMap ("Detail", 2D) = "white" {}
        _DetailAlbedoMap2 ("Linework", 2D) = "black" {}
        _Ramp ("Ramp", 2D) = "Black" {}
        _Multi ("Multiplier", Range(0.0,2)) = 1.25

    }

    SubShader {

        Tags { "Queue"="geometry" "RenderType" = "opaque" }
        
        LOD 200
        //Blend SrcAlpha OneMinusSrcAlpha 
        //Lighting Off
        // Cull Back

        CGPROGRAM

        //#pragma target 3.0
        // TODO: check if we are using 3.0 features really here
        #pragma surface surf Ramp noambient

        sampler2D _MainTex;
        sampler2D _DetailAlbedoMap;
        sampler2D _DetailAlbedoMap2;
        sampler2D _Ramp;
        fixed _Multi;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv2_DetailAlbedoMap;
            float2 uv2_DetailAlbedoMap2;
            float3 viewDir;
        };

        half4 LightingRamp (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) 
        {

            float NdotL = dot(s.Normal,lightDir);
            float NdotE = dot(s.Normal,viewDir);

            float diff = (NdotL*.5)+.5;
            float clamdiff = clamp(diff,0,1);
            float clampe =clamp(NdotE,0,1);

            float2 brdfUV = float2( clampe,clamdiff);
            float3 BRDF = tex2D(_Ramp, brdfUV.xy).rgb;

            float3 lightcomp = s.Albedo*(BRDF*_Multi*(clamp(atten+.75,0,1)));

            float4 c;
            //c.rgb=clamp((AddBRDF*_LightColor*s.Albedo)+((BRDF)*s.Albedo*_MainColor),0,1);
            //c.rgb=clamp(lerp(((BRDFLight)*s.Albedo*_MainColor),s.Alpha,(AddBRDF*_LightColor)),0,1);
            c.rgb=lightcomp;

            return c;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {

            float3 main = clamp(tex2D (_MainTex, IN.uv_MainTex)+.2,0,1);
            float4 detail = tex2D (_DetailAlbedoMap, IN.uv2_DetailAlbedoMap);
            float4 detail2 = tex2D (_DetailAlbedoMap2, IN.uv2_DetailAlbedoMap2);

            float3 colorcomp = (main)*detail;
            colorcomp.rgb *= (1-detail2.a);

            o.Albedo =clamp(colorcomp,0,1);
            //o.Alpha = main;
        }

        ENDCG

    } 

    Fallback "Legacy Shaders/VertexLit"

}
