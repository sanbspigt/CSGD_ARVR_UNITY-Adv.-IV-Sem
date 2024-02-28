// Custom shader for applying vertex manipulation to achieve a wave effect
Shader "Custom/URPVertexManipulation"
{
    // Define properties that can be adjusted in the Unity Editor
    Properties
    {
        _MainTex("Texture", 2D) = "white" {} // Main texture map
        _WaveAmplitude("Wave Amplitude", Float) = 1.0 // Amplitude of the wave effect
        _WaveFrequency("Wave Frequency", Float) = 1.0 // Frequency of the wave effect
    }

        // Define the subshader
            SubShader
        {
            // Specify how this shader should be rendered in the rendering pipeline
            Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Transparent" }

            // Define a single pass within the shader
            Pass
            {
                // Indicate the start of the HLSL shader program
                HLSLPROGRAM
                // Specify the vertex and fragment shader entry points
                #pragma vertex vert
                #pragma fragment frag

                // Include core shader libraries provided by URP for common functionality
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                // Define the structure for input vertex attributes
                struct Attributes
                {
                    float4 positionOS : POSITION; // Object space position
                    float3 normalOS   : NORMAL;   // Object space normal
                    float2 uv         : TEXCOORD0; // Texture coordinates
                };

        // Define the structure for varying data passed from vertex to fragment shader
        struct Varyings
        {
            float4 positionHCS : SV_POSITION; // Position in homogeneous clip space
            float2 uv          : TEXCOORD0; // Texture coordinates
        };

        // Declare the main texture and its sampler
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);

        // Declare properties for the wave effect
        float _WaveAmplitude;
        float _WaveFrequency;

        // Constant buffer for any per-material properties (empty in this case)
        CBUFFER_START(UnityPerMaterial)
        CBUFFER_END

            // Vertex shader function
            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                // Calculate the wave effect based on the vertex position and normal
                float wave = sin(_Time.y * _WaveFrequency + IN.positionOS.x + IN.positionOS.y + IN.positionOS.z) * _WaveAmplitude;
                float3 displacedPosition = IN.positionOS.xyz + IN.normalOS * wave; // Displace vertex along its normal

                // Transform the displaced position to clip space and pass through the UV coordinates
                OUT.positionHCS = TransformObjectToHClip(displacedPosition);
                OUT.uv = IN.uv;
                return OUT; // Return the modified vertex data
            }

        // Fragment shader function
        half4 frag(Varyings IN) : SV_Target
        {
            // Sample the texture using the passed UV coordinates
            half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
            return texColor; // Return the texture color
        }
        ENDHLSL
    }
        }
}
