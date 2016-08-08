  Shader "Bully!/CarPaint/UnlitReflect" {
    Properties {
      _RefPower ("Reflection", Range(0,10))= .45
      _MainTex ("Texture", 2D) = "white" {}
      _LightTint ("LightTint", Color) = (1,1,1)
      _BumpMap ("Bumpmap", 2D) = "bump" {}
      _Cube ("Cubemap", CUBE) = "" {}
    }
    SubShader {
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
      #pragma target 2.0
      #pragma surface surf UnlitReflect halfAsView approxview noforwardadd novertexlights noambient

      half4 LightingUnlitReflect (SurfaceOutput s, half3 lightDir, half3 viewDir) {
		//half3 h = normalize (lightDir + viewDir);


          half4 c;
          c.rgb = s.Albedo;
          c.a = s.Alpha;
          return c;
      }
      
      struct Input {
          float2 uv_MainTex;
          float2 uv_BumpMap;
          float3 worldRefl;
          INTERNAL_DATA
      };
      
      sampler2D _MainTex;
      sampler2D _BumpMap;
      float3 _LightTint;
      float _RefPower;
      samplerCUBE _Cube;
      
      void surf (Input IN, inout SurfaceOutput o) {
         
         fixed4 tex = tex2D (_MainTex, IN.uv_MainTex);
         
         o.Albedo = 0;
         
         o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
         fixed4 _cube = texCUBE (_Cube, WorldReflectionVector (IN, o.Normal));
          
         //o.Emission = (tex.rgb * _LightTint) + (_cube.rgb * tex.a * _RefPower);
         o.Emission = tex.rgb + (_cube.rgb * tex.a * _RefPower);
      }
      ENDCG
    } 
    Fallback "Unlit/Texture"
  }