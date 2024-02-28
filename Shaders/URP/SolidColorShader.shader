// Custom shader for applying a solid color to a mesh without considering lighting, in the Universal Render Pipeline
Shader "Custom/URPUnlitShaderColor"
{
    // Define shader properties that are accessible in the Unity Inspector
    Properties
    {
        // Define a color property for users to modify the base color of the material
        _BaseColor("Base Color", Color) = (1, 1, 1, 1) // Default value is white
    }

        // Define the subshader block
        SubShader
    {
        // Metadata tags for how the shader should be categorized and rendered by Unity
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Transparent"}

        // Define a single pass within the shader
        Pass
        {
            // Begin HLSL shader programming block
            HLSLPROGRAM
            // Specify the vertex and fragment shader entry points
            #pragma vertex vert
            #pragma fragment frag

            // Include necessary URP shader libraries for common functionality
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            

            // Define input structure for vertex shader with position attribute
            struct Attributes
            {
                float4 positionOS   : POSITION; // Object space position
            };

    // Define output structure of vertex shader (input to fragment shader)
    struct Varyings
    {
        float4 positionHCS  : SV_POSITION; // Position in clip space
    };

    // Declare a constant buffer for material-specific properties
    // This makes the shader compatible with Unity's SRP Batcher for improved performance
    CBUFFER_START(UnityPerMaterial)
        half4 _BaseColor; // The base color selected by the user in the Material Inspector
    CBUFFER_END

        // Vertex shader function
        Varyings vert(Attributes IN)
        {
            Varyings OUT;
            // Transform vertex position from object space to clip space
            OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
            return OUT; // Return the transformed vertex data
        }

    // Fragment shader function
    half4 frag() : SV_Target
    {
        // Return the base color as the output color of the pixel
        return _BaseColor;
    }
    ENDHLSL
}
    }
}
