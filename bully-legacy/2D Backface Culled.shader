Shader "QuadUI/2DBackfaceCulled"
{
	Properties 
	{
		_Color("Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("Texture (RGB[A])", 2D) = "white" {}
	}
	
	Category
	{
		Lighting Off		
		Cull Back
		ZWrite Off
		Alphatest Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		Fog
		{
			Mode Off
		}
		
		BindChannels 
		{
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}
		
		SubShader 
		{
			Tags
			{
				"Queue"="Transparent"
				"IgnoreProjector"="True"
				"RenderType"="Transparent"
			}
			
			Pass 
			{
				SetTexture [_MainTex] 
				{
					combine texture * primary, texture * primary
				}
				
				SetTexture [_MainTex] 
				{
					constantcolor [_Color]
					combine previous * constant, previous * constant
				}
			}
		}
	}
	
	Fallback "Diffuse"
}