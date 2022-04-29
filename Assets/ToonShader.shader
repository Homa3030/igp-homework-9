Shader "Custom/Toon Shader"
{
    Properties
    {
        [MainTexture]
        _BaseMap("Texture", 2D) = "white" {} 
        _Color("Color", Color) = (1, 1, 1, 1)
        _ShadowColor("Shadow Color", Color) = (0, 0, 0, 1)
        _ShadowSmoothness("Shadow Smoothness", Range(0, 2)) = 1
        _ShadowThreshold("Shadow Threshold", Range(-1, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal_ws : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _Color;
            float4 _ShadowColor;
            float _ShadowSmoothness;
            float _ShadowThreshold;
            
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normal_ws = TransformObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _Color;

                Light light = GetMainLight();
                float n_dot_l = smoothstep(_ShadowThreshold, _ShadowThreshold + _ShadowSmoothness, dot(i.normal_ws, light.direction));
                
                return lerp(_ShadowColor, _Color, n_dot_l);
            }
            ENDHLSL
        }
    }
}