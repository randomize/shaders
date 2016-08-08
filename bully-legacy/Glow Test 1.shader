Shader "Bully!/FX/Volumetric Glow" {

Properties 
{
	_RimColor("Glow Color", Color) = (0,0.1188812,1,1)
	_RimPower("Glow Power", Range(0.1,1) ) = 1
}

SubShader {

	Tags
	{
		"Queue"="Transparent"
		"IgnoreProjector"="True"
		"RenderType"="Transparent"
	}
	
		


Pass {

		//ZWrite Off
		//ZTest LEqual
		Blend SrcAlpha One
		Cull Front
CGPROGRAM
#pragma fragment frag
#pragma vertex vert
#include "UnityCG.cginc"

float4 _RimColor;
float _RimPower;

struct v2f {
    float4 pos : SV_POSITION;
    float3 normal : TEXCOORD0;
    float3 viewT : TEXCOORD1;
};

v2f vert (appdata_base v)
{
    v2f o;
    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
    o.normal = normalize(v.normal);
    o.viewT = normalize(ObjSpaceViewDir(v.vertex));
    return o;
}

fixed4 frag(v2f i) : COLOR
{
	fixed4 c;
	
	fixed4 Fresnel = (1.0 - dot( normalize(i.viewT), normalize( i.normal ) )).xxxx;
	fixed4 Pow = pow(Fresnel, _RimPower.xxxx);
	//fixed4 Invert = abs((Pow*.007) - 1);
	//Invert = abs(Invert - 1);														
	
	//Invert*= .07;
	c.rgb = _RimColor.rgb;
	c.a = clamp(abs(clamp((Pow.r*1.5)-2,0,1)),0,1)*(1+_RimColor.a);
	
	return c;
}

ENDCG
}
} 
}
