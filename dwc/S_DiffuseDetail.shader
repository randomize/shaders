// vim: ft=cg

Shader "Bully!/Lit/DiffuseDetail" {
    Properties { 
        _MainTex ("Texture", 2D) = "white" {}
        _DetailAlbedoMap ("Detail", 2D) = "white" {} 
    }
    SubShader {
        Tags {"RenderType" = "opaque" }
        LOD 200
        
CGPROGRAM
#pragma surface surf Lambert noambient

sampler2D _MainTex;
sampler2D _DetailAlbedoMap; 

struct Input{
    float2 uv_MainTex;
    float2 uv2_DetailAlbedoMap;      
    };

void surf (Input IN, inout SurfaceOutput o){
            float4 main = clamp(tex2D (_MainTex, IN.uv_MainTex)*1.5,0,1);
            float4 detail = tex2D (_DetailAlbedoMap, IN.uv2_DetailAlbedoMap);
            float3 colorcomp = (main)*detail;

            o.Albedo =clamp(colorcomp,0,1);
            //o.Emission = .2;
        }

        ENDCG

    } 

    Fallback "Legacy Shaders/VertexLit"

}
