Shader "Pandora/CausticsPulseRotating"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _ColorCaustic ("Caustic Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Normal ("Normal (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        [Header(Caustics)]
        _CausticsTex("Caustics (RGB)", 2D) = "white" {}
        //Tiling xY and offsets xY
        _Caustics_ST("Caustics ST", Vector) = (1,1,0,0)
        _Normal_ST("_Normal_ST", Vector) = (1,1,0,0)
        _CausticsSpeed("AnimationSpeed", Range(0,1)) = 0.3
        _Bloom("Oversaturation coefficient", Range(0, 1)) = 0.5
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
        float3 _ColorCaustic;
        float _SmoothstepPeriod;
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
            float3 caustics = tex2D(_CausticsTex,uv).rgb * _ColorCaustic;
            //caustics.xy = 0;
            
            caustics = caustics * (sin(_Time.y * _SmoothstepPeriod) * _Bloom * 5) ;
            o.Emission = saturate(caustics);
            
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
