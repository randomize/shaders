// vim: ft=cg
Shader "Cardboard/UnlitWithLUT"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
        _LutTextureA ("Lut Texture A", 2D) = "white" { }
        _LutTextureB ("Lut Texture B", 2D) = "white" { }
        _LutLerp ("LUT Lerp", Range(0,1)) = 0.0
    }
CGINCLUDE
#include "UnityShaderVariables.cginc"
#include "UnityCG.cginc"

struct appdata 
{
    float4 vertex : POSITION;
    half4 color : COLOR;
    float2 uv : TEXCOORD0;
};

struct v2f 
{
    fixed4 color : COLOR0;
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
};

uniform sampler2D _MainTex;
uniform sampler2D _LutTextureA;
uniform sampler2D _LutTextureB;
uniform float _LutLerp;



v2f vert(appdata v) 
{
    v2f o;
    o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
    o.uv = v.uv;
    o.color = saturate(v.color);
    return o;
}


// Pass lut texture and color, returns interpolated color
fixed3 Lut(sampler2D _LUT, fixed3 c)
{

    // TODO: use fixed/halfes where possible

    float b = c.b * 63.0;

    float2 q1, q2, t1, t2;

    q1.y = floor(floor(b) / 8.0);
    q1.x = floor(b) - (q1.y * 8.0);

    q2.y = floor(ceil(b) / 8.0);
    q2.x = ceil(b) - (q2.y * 8.0);

    t1.x = (q1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * c.r);
    t1.y = (q1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * c.g);

    t2.x = (q2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * c.r);
    t2.y = (q2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * c.g);

    // perform 2 lookups
    fixed3 col1 = tex2D(_LUT, t1).rgb;
    fixed3 col2 = tex2D(_LUT, t2).rgb;

    return lerp(col1, col2, b - floor(b));
}

//----------------------------------------------------------------------
//--Pass through--------------------------------------------------------

// Just pass throught VR output, no LUT.
fixed4 frag_without_lut(v2f i) : SV_Target 
{
    fixed4 c = tex2D(_MainTex, i.uv);
    return c * i.color;
}

//----------------------------------------------------------------------
//--1 LUT---------------------------------------------------------------

// VR putput + LUT in gamma space.
fixed4 frag_with_one_lut_gamma(v2f i) : SV_Target 
{
    fixed4 c = tex2D(_MainTex, i.uv);
    c.rgb = Lut(_LutTextureA, c.rgb);
    return c * i.color;
}

// VR putput + LUT in linear space.
fixed4 frag_with_one_lut_linear(v2f i) : SV_Target 
{
    fixed4 c = tex2D(_MainTex, i.uv);

    c.rgb = sqrt(c.rgb);

    c.rgb = Lut(_LutTextureA, c.rgb);

    c.rgb = c.rgb * c.rgb;

    return c * i.color;
}

//----------------------------------------------------------------------
//--2 LUT---------------------------------------------------------------

fixed4 frag_with_two_lut_gamma(v2f i) : SV_Target 
{
    fixed4 c = tex2D(_MainTex, i.uv);

    fixed3 a = Lut(_LutTextureA, c.rgb);
    fixed3 b = Lut(_LutTextureB, c.rgb);
    c.rgb = lerp(a, b, _LutLerp);

    return c * i.color;
}

fixed4 frag_with_two_lut_linear(v2f i) : SV_Target 
{
    fixed4 c = tex2D(_MainTex, i.uv);

    c.rgb = sqrt(c.rgb);

    fixed3 a = Lut(_LutTextureA, c.rgb);
    fixed3 b = Lut(_LutTextureB, c.rgb);
    c.rgb = lerp(a, b, _LutLerp);

    c.rgb = c.rgb * c.rgb;

    return c * i.color;
}

ENDCG


SubShader { 
    Tags { "RenderType"="Opaque" }

    Pass // WITHOUT LUT
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        CGPROGRAM
#pragma vertex vert
#pragma fragment frag_without_lut
#pragma target 3.0
        ENDCG
    }
    //----------------------------------------------------------------------

    Pass // ONE LUT GAMMA SPACE
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        CGPROGRAM
#pragma vertex vert
#pragma fragment frag_with_one_lut_gamma
#pragma target 3.0
        ENDCG
    }

    Pass // ONE LUT LINEAR SPACE
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        CGPROGRAM
#pragma vertex vert
#pragma fragment frag_with_one_lut_linear
#pragma target 3.0
        ENDCG
    }
    //----------------------------------------------------------------------

    Pass // TWO LUT GAMMA SPACE
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        CGPROGRAM
#pragma vertex vert
#pragma fragment frag_with_two_lut_gamma
#pragma target 3.0
        ENDCG
    }

    Pass // TWO LUT LINEAR SPACE
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        CGPROGRAM
#pragma vertex vert
#pragma fragment frag_with_two_lut_linear
#pragma target 3.0
        ENDCG
    }
}

Fallback off
}

