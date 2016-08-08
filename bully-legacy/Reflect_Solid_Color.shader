  Shader "Bully!/CarPaint/Reflect Solid Color" {
    Properties {
      _RefPower ("Reflection", Range(0,10))= .45
      _Color ("Main Color", Color) = (1,1,1,1)
      _LightTint ("LightTint", Color) = (1,1,1)
      _BumpMap ("Bumpmap", 2D) = "bump" {}
      _Cube ("Cubemap", CUBE) = "" {}
    }
    SubShader {
      Tags { "RenderType" = "Opaque" "IgnoreProjector" = "True" }
      Cull Back
      Lighting Off
      CGPROGRAM
      #pragma target 2.0
      #pragma surface surf UnlitReflect halfAsView approxview noforwardadd novertexlights noambient

      half4 LightingUnlitReflect (SurfaceOutput s, half3 lightDir, half3 viewDir)
      {
          half4 c;
          c.rgb = s.Albedo;
          c.a = s.Alpha;
          return c;
      }
      
      struct Input {
          float2 uv_BumpMap;
          float3 worldRefl;
          INTERNAL_DATA
      };
      
      float4 _Color;
      sampler2D _BumpMap;
      float3 _LightTint;
      float _RefPower;
      samplerCUBE _Cube;
      
      void surf (Input IN, inout SurfaceOutput o) {
               
         o.Albedo = 0;
         
         o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
         fixed4 _cube = texCUBE (_Cube, WorldReflectionVector (IN, o.Normal));
          
         o.Emission = _Color.rgb + (_cube.rgb * _RefPower);
      }
      ENDCG
    } 
    Fallback "Constant Color"
  }