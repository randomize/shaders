Shader "Bully!/Bumped Specular Solid Color" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
	_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
	_BumpMap ("Normalmap", 2D) = "bump" {}
}
SubShader { 
	Tags { "RenderType"="Opaque" }
	LOD 250
	Cull Back
	
CGPROGRAM
#pragma surface surf MobileBlinnPhong nolightmap halfasview 
//noforwardadd

inline fixed4 LightingMobileBlinnPhong (SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
{
	fixed diff = max (0, dot (s.Normal, lightDir));
	float nh = max (0, dot (s.Normal, viewDir));
	float spec = pow (nh, s.Specular*128.0);// * s.Gloss;
	
	fixed4 c;
	c.rgb = (s.Albedo * diff + _SpecColor.rgb * spec) * (atten * 2);
	return c;
}

sampler2D _BumpMap;
fixed4 _Color;
half _Shininess;

struct Input {
	float2 uv_BumpMap;
};

void surf (Input IN, inout SurfaceOutput o) {
	o.Albedo = _Color.rgb;
	o.Gloss = 1;//tex.a;
	o.Alpha = 1;//tex.a * _Color.a;
	o.Specular = _Shininess;
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
}
ENDCG
}

FallBack "Specular"
}
