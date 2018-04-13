Shader "Unity Shader Book/Chapter 6/BlinnPhong"
{
	Properties{
		//声明一个Color类型的属性，默认为白色
		_Diffuse ("Diffuse",Color) = (1,1,1,1)
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}

	SubShader{
		Pass{
			Tags {"LightMode" = "ForWardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

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
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//光线的方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldNormal = normalize(i.worldNormal);
				//漫反射 光的颜色和强度 * 漫反射系数 * max（表面法线 · 入射光线）
				fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(worldNormal,worldLight));


				//视角方向 通过世界坐标下摄像机的坐标-顶点位置从模型空间变换成世界空间
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				//入射光线关于平面发现的反射方向，reflect第一个参数 光的方向是光源指向交点
				fixed3 reflectDir = normalize(reflect(-worldLight,worldNormal));
				//blinn 这里不是用反射的方向 而是用视角方向和光照方向相加在归一化
				//公式： 光的颜色和强度 * 高光系数 * max(反射方向 * 视角方向) ^ 光泽度
				fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(worldNormal,normalize(viewDir + worldLight))),_Gloss);
				fixed3 color = ambient + diffuse + specular;
				return fixed4(color,1.0);
			}

			ENDCG
		}
	}
}