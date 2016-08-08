// vim: ft=cg
Shader "Hidden/DepthShader2"
{
   Properties
   {
      _MainTex ("Texture", 2D) = "white" {}
      _DepthLevel ("Depth Level", Range(1, 3)) = 2
   }
   SubShader
   {
      // No culling or depth
      Cull Off ZWrite Off ZTest Always

      Pass
      {
         CGPROGRAM
         #pragma vertex vert
         #pragma fragment frag
         
         #include "UnityCG.cginc"

         struct appdata
         {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
         };

         struct v2f
         {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
         };

         v2f vert (appdata v)
         {
            v2f o;
            o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
            o.uv = v.uv;
            return o;
         }
         
         uniform sampler2D _MainTex;
         uniform sampler2D_float _CameraDepthTexture;
         uniform float _DepthLevel;

         fixed4 frag (v2f i) : SV_Target
         {
            fixed4 col = tex2D(_MainTex, i.uv);

            float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
            depth = pow(Linear01Depth(depth), _DepthLevel);
            return depth;

         }
         ENDCG
      }
   }
}
