Shader "Unity Shaders Book/Chapter 11/Billboard" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		//用于调整时固定法线，还是固定指向上的方向
		_VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1 
	}
	SubShader {
		// Need to disable batching because of the vertex animation
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}
		
		Pass { 
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _VerticalBillboarding;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert (a2v v) {
				v2f o;
				
				//选择模型的原点作为广告牌的锚点
				float3 center = float3(0, 0, 0);
				//模型空间下的视角位置
				float3 viewer = mul(_World2Object,float4(_WorldSpaceCameraPos, 1));
				//根据视角位置和锚点，来获得法线
				float3 normalDir = viewer - center;

				//_VerticalBillBoarding = 1 ,意味着法线方向固定为视角方向。_VerticalBillBoarding = 0,意味着向上方向固定为（0，1，0）
				normalDir.y =normalDir.y * _VerticalBillboarding;
				normalDir = normalize(normalDir);

				//防止法线方向和向上方向平行得到粗略的向上方向
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				//通过法线和粗略的向上方向得到向右方向。并且归一化。
				float3 rightDir = normalize(cross(upDir, normalDir));
				//此时的向上方向还是不准确的，通过法线和向右得到最后的向上方向
				upDir = normalize(cross(normalDir, rightDir));
				
				//根据原始的位置，相对于锚点的偏移量以及3个正交基矢量，得到新的顶点位置。
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
              
				o.pos = mul(UNITY_MATRIX_MVP, float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 c = tex2D (_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				
				return c;
			}
			
			ENDCG
		}
	} 
	FallBack "Transparent/VertexLit"
}
