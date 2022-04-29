Shader "Custom/Lambert Shader"
{
    Properties
    {
        [MainTexture]
        _BaseMap("Texture", 2D) = "white" {} 
        _Color("Color", Color) = (1, 1, 1, 1)
        _SpecularHardness("Specular Hardness", float) = 1
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
                float3 position_ws : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _Color;
            float _SpecularHardness;
            
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                //float3 position_os = v.vertex.xyz;
                //position_os.y += sin(_Time.z + position_os.x);
                
                //o.vertex = TransformObjectToHClip(position_os);
                const float3 position_ws = TransformObjectToWorld(v.vertex.xyz);
                o.vertex = TransformWorldToHClip(position_ws);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normal_ws = TransformObjectToWorldNormal(v.normal);
                o.position_ws = position_ws;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _Color;

                Light light = GetMainLight();
                i.normal_ws = normalize(i.normal_ws);
                float n_dot_l = dot(i.normal_ws, light.direction);

                float3 view_dir_ws = normalize(GetWorldSpaceViewDir(i.position_ws));;
                float3 h = normalize(light.direction + view_dir_ws);

                const float n_dot_h = dot(i.normal_ws, h);
                const float intensity = pow(saturate(n_dot_h), _SpecularHardness);
                float3 specular = intensity * light.color;
                return
                    saturate(n_dot_l * albedo * float4(light.color, 1) +
                    float4(specular, 1));
            }
            ENDHLSL
        }
    }
}