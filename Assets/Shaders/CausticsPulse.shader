Shader "Pandora/CausticsPulse"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _ColorC1 ("Caustic 1 Tint", Color) = (1,1,1,1)
        _ColorC2 ("Caustic 2 Tint", Color) = (1,1,1,1)
        _MainTex ("Caustic1", 2D) = "white" {}
        _Normal ("Normal (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        [Header(Caustics)]
        _CausticsTex("Caustics (RGB)", 2D) = "white" {}
        //Tiling xY and offsets xY
        _Caustics_ST("Caustics ST", Vector) = (1,1,0,0)
        _Normal_ST("_Normal_ST", Vector) = (1,1,0,0)
        _CausticsSpeed("AnimationSpeed", Range(0,1)) = 0.3
        _Bloom("Oversaturation Coefficient1", Range(0, 1)) = 0.5
        _Bloom_Additive("Oversaturation Coefficient2 offset", Range(0, 5)) = 0.5
        _Blend("Caustics Blending", Range(0, 1)) = 0
        _SmoothstepPeriod("Smoothstep period", Range(0.01, 3)) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _CausticsTex;
        sampler2D _Normal;
        
        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float4 _Caustics_ST;
        float4 _Normal_ST;
        float _CausticsSpeed;
        float _Bloom;
        float _Blend;
        float3 _ColorC1;
        float3 _ColorC2;
        float _SmoothstepPeriod;
        float _Bloom_Additive;
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = _Color;
            o.Albedo.rgb = c.rgb;
             
            //Caustics Sampling 
            fixed2 uv = IN.uv_MainTex * _Caustics_ST.xy + _Caustics_ST.zw;
            uv += _CausticsSpeed * _Time.y;
            float3 caustics = tex2D(_CausticsTex,uv).rgb * _ColorC2;
            float3 main = tex2D (_MainTex, uv).rgb * _ColorC1;
            
            
            caustics = abs(caustics * (smoothstep(0, 1, abs(sin(_Time.y * _SmoothstepPeriod))) * _Bloom * 2+ 3) );
            main = abs(main * (_Bloom * _Bloom_Additive) );
            o.Emission = saturate(caustics);
            
            caustics  = lerp(caustics, main, _Blend);
            
            
            o.Albedo.rgb += caustics;
            o.Normal = UnpackNormal (tex2D (_Normal, IN.uv_MainTex * _Normal_ST));
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
