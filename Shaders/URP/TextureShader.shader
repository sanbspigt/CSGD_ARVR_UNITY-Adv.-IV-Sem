// Custom shader for applying a texture to a mesh without lighting (unlit) in the Universal Render Pipeline
Shader "Custom/URPUnlitTextureShader"
{
    // Define shader properties accessible in the Unity Inspector
    Properties
    {
        _MainTex("Texture", 2D) = "white" {} // Main texture to be applied
       // _MainTex_ST("Tiling/Offset", Vector) = (1, 1, 0, 0) // Uncomment for default tiling and offset
    }

        // SubShader block defines how the shader will be rendered by the URP
        SubShader
    {
        // Metadata tags for how the shader should be categorized and rendered by Unity
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Geometry" }

        // A single Pass block for rendering operations
        Pass
        {
            // Indicate the start of HLSL shader programming block
            HLSLPROGRAM
            // Define vertex and fragment shader entry points
            #pragma vertex vert
            #pragma fragment frag

            // Include necessary URP shader libraries for common functionality
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Define input structure for vertex shader with position and UV coordinates
            struct Attributes
            {
                float4 positionOS : POSITION; // Object space position
                float2 uv         : TEXCOORD0; // Texture UV coordinates
            };

    // Define output structure of vertex shader (input to fragment shader)
    struct Varyings
    {
        float4 positionHCS : SV_POSITION; // Position in clip space
        float2 uv          : TEXCOORD0; // Texture UV coordinates
    };

    // Declare the texture and its sampler
    TEXTURE2D(_MainTex); // The texture to be sampled
    SAMPLER(sampler_MainTex); // Sampler for the texture

    // Add a vector to hold tiling and offset for the texture
    float4 _MainTex_ST;

    // Define a constant buffer for per-material properties if needed (empty here)
    CBUFFER_START(UnityPerMaterial)
    CBUFFER_END

        // Vertex shader function
        Varyings vert(Attributes IN)
        {
            Varyings OUT;
            // Transform vertex position from object space to clip space
            OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
            // Apply texture tiling and offset
            OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
            return OUT; // Output the transformed vertex data
        }

    // Fragment shader function
    half4 frag(Varyings IN) : SV_Target
    {
        // Sample the texture using the UV coordinates processed by the vertex shader
        half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
        return texColor; // Return the color sampled from the texture
    }
    ENDHLSL
}
    }
}
