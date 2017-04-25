Shader "Unlit/SH_KeyColor"
{
    Properties
    {
         _Color ("Color", Color) = (1,1,1,1)
         _TransparentColor ("Transparent Color", Color) = (1,1,1,1)
         _Threshold ("Threshhold", Range(0,1)) = 0.1
         _Threshold2 ("Threshhold2", Range(0,1)) = 0.1
         _ContrastA ("Contrast", Range(0,1)) = 0.1
         _ContrastB ("Contrast Trsh", Range(0,1)) = 0.1
        _MainTex ("Texture", 2D) = "white" {}
         _Res ("Res", Range(1,2048)) = 512
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define AA 4.0

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

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TransparentColor;
            fixed _Threshold;
            fixed _Threshold2;
            fixed _ContrastA;
            fixed _ContrastB;
            float4 _MainTex_ST;
            float _Res;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed bldist(fixed4 c)
            {
                float t = abs(_TransparentColor.g - c.g);

                return smoothstep(_Threshold - _Threshold2, _Threshold +
                _Threshold2, t);

            }

            fixed bldist2(fixed4 c)
            {
                float maskY = 0.2989 * _TransparentColor.r + 0.5866 * _TransparentColor.g + 0.1145 * _TransparentColor.b;
                float maskCr = 0.7132 * (_TransparentColor.r - maskY);
                float maskCb = 0.5647 * (_TransparentColor.b - maskY);

                float Y = 0.2989 * c.r + 0.5866 * c.g + 0.1145 * c.b;
                float Cr = 0.7132 * (c.r - Y);
                float Cb = 0.5647 * (c.b - Y);

                return smoothstep(_Threshold - _Threshold2, _Threshold + _Threshold2, distance(float2(Cr, Cb), float2(maskCr, maskCb)));

            }

            fixed4 sample (float2 uv, fixed4 cc)
            {
                // sample the texture
                fixed4 c = tex2D(_MainTex, uv);

                float blendValue = bldist2(c);

                // blendValue = smoothstep(_ContrastA - _ContrastB, _ContrastA + _ContrastB, blendValue);

                // float blendValueCC = bldist(cc);
                // blendValue *= bldist(cc);

                c.a = blendValue;
                c.rgb = c.rgb * blendValue;

                return c * _Color;
            }

            fixed4 frag(v2f IN) : SV_Target
            {

                float4 col = 0.;
                float2 uv = IN.uv;
                fixed4 cc = tex2D(_MainTex, uv);

                float e = 1. / _Res;
                for (float i = -AA; i < AA; ++i)
                {
                    for (float j = -AA; j < AA; ++j)
                    {
                        col += sample( uv + float2(i, j) * (e/AA), cc ) / (4.*AA*AA);
                    }
                }

                return col;
            }
            ENDCG
        }
    }
}
