Shader "Unity Shader Book/Chapter 6/Duffuse Piexl-Level"
{
	Properties {
		//声明一个Color类型的属性，默认为白色
		_Diffuse ("Diffuse",Color) = (1,1,1,1)
	}

	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			//为了使用Properties中声明的属性，定义一个和该属性类型相匹配的变量
			fixed4 _Diffuse;

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;

				//把顶点位置从模型空间转换到裁减空间
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldNormal = mul(v.normal,_World2Object);
				return o;
			}

			fixed4 frag(v2f i) :SV_TARGET
			{
				//内置变量得到环境光部分
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//把在模型空间的法线 通过模型空间到世界空间的变换矩阵的逆_World2Object，通过改变在mul中的位置，得到和转置矩阵相同的矩阵乘法。
				//法线需要原变化矩阵的（逆转置）矩阵来变化法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//归一化   _WorldSpaceLightPos0 光源方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				//_LightColor0是该pass处理的光源的颜色和强度信息
				//公式： 入射光线的颜色和强度 * 漫反射系数 * max（表面法线 · 入射光方向）
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

				fixed3 color = ambient + diffuse;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}
}