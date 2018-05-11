
Shader "Unity Shaders Book/Chapter 9/ShadowMap"
{
	Properties{
		//声明一个Color类型的属性，默认为白色
		_Diffuse ("Diffuse",Color) = (1,1,1,1)
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}

	SubShader{
		Tags { "RenderType"="Opaque" }
		//base pass
		Pass{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			//保证我们在Shader中使用光照衰减等光照变量可以被正确的赋值。
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				//声明一个用于对阴影纹理采样的坐标。这个宏的参数需要是下一个可用的插值寄存器的索引值。
				SHADOW_COORDS(2)
			};

			v2f vert(a2v v)
			{
				v2f o;
				//把定点位置从模型空间转换到裁剪空间
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				//转到法线从模型空间到世界空间。  转换法线需要逆转置矩阵，这里使用逆矩阵+改变mul的位置来实现
				o.worldNormal = mul(v.normal,_World2Object);
				o.worldPos = mul(_Object2World,v.vertex).xyz;
				//在顶点着色器中计算上一步声明的阴影纹理坐标
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) :SV_TARGET
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//光线的方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldNormal = normalize(i.worldNormal);
				//漫反射 光的颜色和强度 * 漫反射系数 * max（表面法线 · 入射光线）
				fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(worldNormal,worldLight));
				//视角方向 通过世界坐标下摄像机的坐标-顶点位置从模型空间变换成世界空间
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				//blinn 这里不是用反射的方向 而是用视角方向和光照方向相加在归一化
				//公式： 光的颜色和强度 * 高光系数 * max(反射方向 * 视角方向) ^ 光泽度
				fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(worldNormal,normalize(viewDir + worldLight))),_Gloss);
				//平行光没有衰减
				fixed atten = 1.0;
				fixed shadow = SHADOW_ATTENUATION(i);
				fixed3 color = ambient + (diffuse + specular) * atten * shadow;
				return fixed4(color,1.0);
			}

			ENDCG
		}

		//Additional Pass
		Pass{
			Tags { "LightMode" = "ForwardAdd" }
			Blend one one
			CGPROGRAM
			#pragma multi_compile_fwdadd

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				//把定点位置从模型空间转换到裁剪空间
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				//转到法线从模型空间到世界空间。  转换法线需要逆转置矩阵，这里使用逆矩阵+改变mul的位置来实现
				o.worldNormal = mul(v.normal,_World2Object);
				o.worldPos = mul(_Object2World,v.vertex).xyz;
				return o;
			}

			fixed4 frag(v2f i) :SV_TARGET
			{

				//光线的方向,如果是平行光，_WorldSpaceLightPos0.xyz就是光的方向
				//如果是点光源或者聚光灯的话，_WorldSpaceLightPos0.xyz表示光源的位置，用_WorldSpaceLightPos0.xyz - 顶点的世界坐标i.worldPos ，得到光源方向。
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif

				fixed3 worldNormal = normalize(i.worldNormal);
				//漫反射 光的颜色和强度 * 漫反射系数 * max（表面法线 · 入射光线）
				fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(worldNormal,worldLight));
				//视角方向 通过世界坐标下摄像机的坐标-顶点位置从模型空间变换成世界空间
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				//blinn 这里不是用反射的方向 而是用视角方向和光照方向相加在归一化
				//公式： 光的颜色和强度 * 高光系数 * max(反射方向 * 视角方向) ^ 光泽度
				fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(worldNormal,normalize(viewDir + worldLight))),_Gloss);
				#ifdef USING_DIRECTIONAL_LIGHT
					//平行光没有衰减
					fixed atten = 1.0;
				#else
					//得到光源空间下的坐标
					float3 lightCoord = mul(_LightMatrix0, float4(i.worldPos,1)).xyz;
					//使用该坐标对衰减纹理进行采样得到衰减值。
					fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#endif
				fixed3 color = (diffuse + specular) * atten;
				return fixed4(color,1.0);
			}

			ENDCG
		}
	}
		FallBack "Specular"
}