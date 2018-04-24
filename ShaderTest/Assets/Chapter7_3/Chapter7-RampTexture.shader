shader "Unity Shader Book/Chapter 7/Ramp Texture"
{
	Properties{
		_Color("Color Tint",Color) = (1,1,1,1)
		_RampTex("Ramp Tex",2D) = "white" {}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,256)) = 20
	}
	SubShader{
		Pass{
			Tags{"LightModel"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};


			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(_Object2World,v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord,_RampTex);
				//o.uv = v.texcoord * _RampTex_ST.xy + _RampTex_ST.zw;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float worldNormal = normalize(i.worldNormal);

				float worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//把法线方向和光照方向点积 *0.5+0.5 从[-1,1]->[0，1]
				fixed halfLambert = 0.5 * dot(worldNormal,worldLightDir) + 0.5;
				//使用halfLambert来构建纹理坐标，对_ramptex采样，
				fixed3 diffuseColor = tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb * _Color.rgb;

				fixed3 diffuse = _LightColor0.rgb * diffuseColor;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed3 halfDir = normalize(viewDir + worldLightDir);

				fixed3 specular = _LightColor0.rgb * _Specular * pow(max(0,dot(worldNormal,halfDir)),_Gloss);

				return fixed4(ambient+ diffuseColor + specular,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}