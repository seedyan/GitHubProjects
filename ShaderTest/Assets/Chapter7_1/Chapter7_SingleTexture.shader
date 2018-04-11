Shader "Unity Shaders Book/Chapter 7/Single Texture"
{
	Properties{
		_Color("Color",color) = (1,1,1,1)
		_MainTex ("Maintex",2D) = "white" {}
		_Specular ("Specular",color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

	SubShader{
		Pass{
		Tags{"LightModel" = "ForwardBase"}

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "Lighting.cginc"

		fixed4 _Color;
		sampler2D _MainTex;
		//纹理的缩放和平移值， _MainTex.zy -> 缩放值  _MainTex.zw -> 偏移值
		float4 _MainTex_ST;
		fixed4 _Specular;
		float _Gloss; 

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			//存储模型的第一组纹理坐标
			float4 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 pos:SV_POSITION;
			float3 worldNormal: TEXCOORD0;
			float3 worldPos : TEXCOORD1;
			//存储纹理坐标的变量
			float2 uv : TEXCOORD2;
		};

		v2f vert(a2v v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = mul(_Object2World,v.vertex).xyz;
			//使用纹理的属性值_MainTex_ST来对顶点纹理坐标进行变换，先对纹理坐标进行缩放，然后使用偏移量对结果进行偏移
			o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			//和上面的操作一致
			//o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
			return o;
		}

		fixed4 frag(v2f i) : SV_TARGET
		{
			//世界坐标下的的法线方向
			fixed3 worldNormal = normalize(i.worldNormal);
			//世界坐标下的光照方向
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
			//使用tex2d对纹理进行采样， 第一个参数是需要被采样的纹理，第二个参数是float2类型的纹理坐标，返回计算得到的纹素值，使用采样结果和颜色属性_Color的乘积来作为材质的反射率
			fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
			//把反射率和环境光相乘得到环境光部分
			fixed3 ambinet = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			//漫反射光照结果
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));
			//视角
			fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
			//视角和光线方向的中间方向
			fixed3 halfDir = normalize(worldLightDir + viewDir);
			//高光
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);
			return fixed4(ambinet + diffuse + specular,1.0);
		}
		ENDCG
		}
	}
	Fallback "Specular"
}