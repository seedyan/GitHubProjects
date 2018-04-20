Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space" {
	Properties {
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2d)="white"{}
		//对于法线纹理，这里用bump作为它的默认值，bump是unity内置的法线纹理，当没有提供任何法线纹理的时候，bump就对应了模型自带的法线信息。
		_BumpMap("Normal Map",2D)="bump"{}
		//用于控制凹凸程度
		_BumpScale("Bump Scale",float)=1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) =20
	}
	SubShader {
		Pass{
			//Lightmode 是pas标签的一种，用于定义该pass在unity的光照流水中的角色
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				//tangent 存储定点的切线方向,切线和法线不一样，这里的float4,使用tangent.w分量来决定切线空间中的第三个坐标轴--->副切线的方向性
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				//定点坐标从模型空间->其次裁剪坐标下
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				//使用了两张纹理，uv是float4 用来存储两个纹理坐标，xy分量存储了_mainTex的纹理坐标，zw分量存储了_bumpMap的纹理坐标。
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				//计算副切线，法线和切线叉乘，*w是确定方向
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
				//把模型空间下的切线方向 副切线方向和法线方向按行排列来得到从模型空间到切线空间的变换矩阵rotation
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);

				//ObjSpaceLightDir 得到模型空间下的光照方向
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				//ObjSpaceLightDir 得到模型空间下的视角方向
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				//o.lightDir = mul(TANGENT_SPACE_ROTATION,ObjSpaceLightDir(v.vertex)).xyz;

				//o.viewDir = mul(TANGENT_SPACE_ROTATION,ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				//用tex2d对法线纹理_BumpMap进行采样，法线纹理中存储的是吧法线经过映射之后得到的像素值[0,1]
				//如果我们没有在unity中把该纹理的类型设置成Normal map ,则需要我们手动进行反映射。
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal;

				//tangentNormal = (packedNormal.xy * 2 - 1) * _BumpScale;
				//tangentNormal.z = sqrt(1.0 - saturate(doa(tangentNormal.xy,tangentNormal.xy)));

				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss);

				return fixed4(ambient+diffuse+specular,1.0);

			}


			ENDCG
		}
	}
	FallBack "Diffuse"
}
