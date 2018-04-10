﻿Shader "Unlit/Chapter_5_Sample_Shader"
{
	Properties
	{
		_Color ("Color",Color) = (1.0,1.0,1.0,1.0)
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			fixed4 _Color;

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				fixed3 color : COLOR0;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.color = v.normal * 0.5f + fixed3(0.5,0.5,0.5);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				fixed3 c = i.color;
				//使用_Color属性来控制输出颜色
				c *= _Color.rgb;
				return fixed4(c,1);
			}

			ENDCG
		}
	}
}
