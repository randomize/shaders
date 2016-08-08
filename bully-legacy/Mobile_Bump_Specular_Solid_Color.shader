// Simplified Bumped Specular shader. Differences from regular Bumped Specular one:
// - no Main Color nor Specular Color
// - specular lighting directions are approximated per vertex
// - writes zero to alpha channel
// - Normalmap uses Tiling/Offset of the Base texture
// - no Deferred Lighting support
// - no Lightmap support
// - fully supports only 1 directional light. Other lights can affect it, but it will be per-vertex/SH.

Shader "Bully!/Mobile/Bumped Specularrr" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecularColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)	
	_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
	_BumpMap ("Normalmap", 2D) = "bump" {}
}
SubShader { 
	Tags { "RenderType"="Opaque" }
	LOD 250
	Lighting Off
	
CGPROGRAM
#pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd halfasview noambient

fixed4 _Color;
fixed4 _SpecularColor;
sampler2D _BumpMap;
half _Shininess;

inline fixed4 LightingMobileBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
{
	fixed diff = max (0, dot (s.Normal, halfDir));
	fixed nh = max (0, dot (s.Normal, halfDir));
	fixed spec = pow (nh, s.Specular*128) * s.Gloss;
	
	fixed4 c;
	c.rgb = (s.Albedo * 1 * diff + 1 * spec * _SpecularColor.rgb) * (atten*2);
	c.a = 0.0;
	return c;
}

struct Input {
	float2 uv_BumpMap;
};

void surf (Input IN, inout SurfaceOutput o) {
	//fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	o.Albedo = _Color;//tex.rgb;
	o.Gloss = 1;//tex.a;
	o.Alpha = 1;//tex.a;
	o.Specular = _Shininess;
	o.Normal = UnpackNormal (tex2D(_BumpMap, IN.uv_BumpMap));
}
ENDCG
}

FallBack "Mobile/VertexLit"
}
