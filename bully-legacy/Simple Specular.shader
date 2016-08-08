Shader "Bully!/Simple Specular" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_Shininess ("Shininess", Range (0.01, 1)) = 0.078125
}

SubShader {
	Tags { "RenderType"="Opaque" }
	
	
CGPROGRAM
#pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd halfasview noambient

fixed4 _Color;
half _Shininess;

struct Input {
	float2 uv;
};

inline fixed4 LightingMobileBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
{
	fixed diff = max (0, dot (s.Normal, halfDir));
	fixed spec = pow (diff, s.Specular*128) * s.Gloss;
	
	fixed4 c;
	c.rgb = (s.Albedo * diff + .25 * spec) * (atten*2);
	c.a = 0.0;
	return c;
}

void surf (Input IN, inout SurfaceOutput o) {
	o.Albedo = _Color.rgb;
	o.Gloss = 1;
	o.Specular = _Shininess;
}
ENDCG
}

Fallback "VertexLit"
}
