// vim: ft=cg
Shader "Custom/CamFlipShader"
{
    Properties
    {
        _MainTex ( "Main Texture", 2D ) = "white" {}

         _StencilComp ("Stencil Comparison", Float) = 8
         _Stencil ("Stencil ID", Float) = 0
         _StencilOp ("Stencil Operation", Float) = 0
         _StencilWriteMask ("Stencil Write Mask", Float) = 255
         _StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15
    }
   
    SubShader
    {      

		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

        Pass
        {
            
            Cull Off

            CGPROGRAM
           
            #pragma vertex vert
            #pragma fragment frag
           
            uniform sampler2D _MainTex;
            uniform float4x4 _UVRotate;
           
            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 color    : COLOR;
                float4 texcoord : TEXCOORD0;
            };
           
            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                fixed4 color    : COLOR;
                half2 uv : TEXCOORD0;
            };
           
            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;

                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = mul(_UVRotate, v.texcoord);
                o.color = v.color;

                return o;
            }
           
            float4 frag(vertexOutput i) : COLOR
            {
                /*i.ux.x = i.ux.x % 1.0f;
                i.ux.y = i.ux.y % 1.0f;    */
                fixed4 x = tex2D( _MainTex, frac(i.uv) );
                return x * i.color;

            }
           
            ENDCG
        }
    }
    Fallback "Diffuse"
}
