Shader "Bully!/Ramp Lit/Diffuse"
{
	Properties 
	{
		_MainTex("_MainTex", 2D) = "black" {}
		_Ramp("Gradient Map", 2D) = "black" {}
	}

	SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 200
	Cull Back
	
	CGPROGRAM
	#pragma surface surf LambertRamp exclude_path:prepass halfasview approxview novertexlights noambient nolightmap
	
	sampler2D _MainTex;
	sampler2D _Ramp;
	
	inline fixed4 LightingLambertRamp (SurfaceOutput s, half3 lightDir, fixed atten)
	{
		fixed diff = max (0, dot (s.Normal, lightDir));
		
		fixed3 ramp = tex2D(_Ramp,float2(atten,.5)).rgb;
		fixed4 c;
		c.rgb = s.Albedo * _LightColor0.rgb * (diff *(atten*2) );// * ramp;
		c.rgb = ((c.rgb*2)*2)+c.rgb;
		c.rgb*=ramp;
		
		//c.rgb = s.Albedo*(diff*(atten*2)*(ramp))*_LightColor0.a;
		c.a = 0;//s.Alpha;
		
		return c;
	}	
	
	struct Input {
		float2 uv_MainTex : TEXCOORD;
	};

	void surf (Input IN, inout SurfaceOutput o)
	{
		fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
		o.Albedo = tex.rgb;
		o.Emission = tex.rgb * (tex.a + .4);
		
	}
	
ENDCG
} 
FallBack "Self-Illumin/VertexLit"
}