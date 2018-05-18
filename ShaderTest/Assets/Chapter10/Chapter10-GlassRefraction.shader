Shader "Unity Shaders Book/Chapter 10/Glass Refraction"
{
	Properties
	{
		//玻璃的材质纹理
		_MainTex("Main Tex",2D) = "white"{}
		//玻璃的法线纹理
		_BumpMap("Bump Map",2D) = "bump"{}
		//模拟反射的环境纹理
		_CubeMap("Cube Map",cube) = "_Skybox"{}
		//用于控制模拟折射时图像的扭曲程度
		_Distortion ("Distortion", Range(0, 100)) = 10
		//0 只包含反射效果 1只包含折射效果
		_RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0
	}

	SubShader
	{
		///"Queue"="Transparent" 保证不透明的先渲染
		Tags { "Queue"="Transparent" "RenderType"="Opaque" }

		//抓取屏幕的pass
		GrabPass { "_RefractionTex" }
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			//_RefractionTex对应抓取屏幕的图像所存储的纹理
			sampler2D _RefractionTex;
			//可以得到纹理的纹素值
			float4 _RefractionTex_TexelSize;

						struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT; 
				float2 texcoord: TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;  
			    float4 TtoW1 : TEXCOORD3;  
			    float4 TtoW2 : TEXCOORD4; 
			};
			
			v2f vert (a2v v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				//得到对应被抓取的屏幕图像的采样坐标
				o.scrPos = ComputeGrabScreenPos(o.pos);
				//对_MainTex采样
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				//对_BumpMap采样
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				//由于需要在片元着色器中把法线方向从切线空间变换到世界空间下
				float3 worldPos = mul(_Object2World, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
				
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
				
				return o;
			}

			fixed4 frag (v2f i) : SV_Target {		
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				// 对法线纹理采样，得到切线空间下的法线。
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));	
				
				// Compute the offset in tangent space
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;
				
				// Convert the normal to world space
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				fixed3 reflDir = reflect(-worldViewDir, bump);
				fixed4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;
				
				fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
				
				return fixed4(finalColor, 1);
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}