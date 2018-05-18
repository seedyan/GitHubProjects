// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "zwTech/Fx/Blur/Box Blur"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        _MaxResolution("Max Resolution", Int) = 720
        _Downsample("Downsample", Range(1, 100)) = 32
        _BlurSize("Blur Size", Range(0, 1)) = .5
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
        }

        Cull Off
        Lighting Off
        ZTest Always    
        ZWrite Off
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex: POSITION;
                float4 color: COLOR;
                float2 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex: SV_POSITION;
                half2 texcoord: TEXCOORD0;
                half2 taps[4] : TEXCOORD1;
            };

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            half4 _BlurOffsets;

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = mul(UNITY_MATRIX_MVP,IN.vertex);
                OUT.texcoord = IN.texcoord - _BlurOffsets.xy * _MainTex_TexelSize.xy;
                OUT.taps[0] = OUT.texcoord + _MainTex_TexelSize * _BlurOffsets.xy;
                OUT.taps[1] = OUT.texcoord - _MainTex_TexelSize * _BlurOffsets.xy;
                OUT.taps[2] = OUT.texcoord + _MainTex_TexelSize * _BlurOffsets.xy * half2(1, -1);
                OUT.taps[3] = OUT.texcoord - _MainTex_TexelSize * _BlurOffsets.xy * half2(1, -1);

                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = tex2D(_MainTex, IN.taps[0]);
                color += tex2D(_MainTex, IN.taps[1]);
                color += tex2D(_MainTex, IN.taps[2]);
                color += tex2D(_MainTex, IN.taps[3]);
                color = color * 0.25;
                color.a = 1;
                return color;
            }
            ENDCG
        }
    }

    Fallback off
}
