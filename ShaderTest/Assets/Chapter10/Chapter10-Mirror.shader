Shader "Unity Shaders Book/chapter10/Mirror"
{
	properties
	{
		_MainTex("Main Tex",2D) = "while"{}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			sampler2D _MainTex;
			float4 _MainTex_ST;
			struct a2v
			{
				float4 vertex : POSITION;
				float3 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				//o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv =v.texcoord;
				o.uv.x = 1-o.uv.x;
				return o;
			}

			fixed4 frag(v2f i) : SV_target
			{
				return tex2D(_MainTex,i.uv);
			}
			ENDCG
		}
	}
}