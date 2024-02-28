// Custom shader for blending and transparency in URP
Shader "Custom/URPTransparentBlend"
{
    // Define the properties that can be set in the Material Inspector
    Properties
    {
        _MainTex("Texture", 2D) = "white" {} // The main texture
        _BlendMode("Blend Mode", Range(0, 4)) = 0 // Blend mode selector
        _Transparency("Transparency", Range(0.0, 1.0)) = 0.5 // Transparency level
    }

        SubShader
        {
            // Set the shader to render in the Transparent queue and specify it uses the URP
            Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Transparent" }
            LOD 100 // Level of detail

            // Set up blending and depth writing
            Blend SrcAlpha OneMinusSrcAlpha // Standard alpha blending
            ZWrite Off // Disable writing to the Z-buffer to ensure correct rendering order of transparent objects
            AlphaToMask Off // Disable alpha-to-coverage

            Pass
            {
                Name "FORWARD" // Name of this pass
                Tags { "LightMode" = "UniversalForward" } // Using forward rendering in URP

                // Start of the HLSL shader program
                HLSLPROGRAM
            // Declare vertex and fragment shader entry points
            #pragma vertex vert
            #pragma fragment frag

            // Include core shader library for URP
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Define the input structure for the vertex shader
            struct Attributes
            {
                float4 positionOS : POSITION; // Object space position
                float2 uv         : TEXCOORD0; // UV coordinates
            };

        // Define the output structure of the vertex shader (input to the fragment shader)
        struct Varyings
        {
            float4 positionHCS : SV_POSITION; // Homogeneous clip space position
            float2 uv          : TEXCOORD0; // UV coordinates passed through
        };

        // Declare the texture and its sampler
        TEXTURE2D(_MainTex); // The main texture
        SAMPLER(sampler_MainTex); // Sampler for the main texture

        // Transparency and blend mode variables
        float _Transparency; // Transparency value
        float _BlendMode; // Blend mode selector

        // Constant buffer for per-material properties (if needed)
        CBUFFER_START(UnityPerMaterial)
        CBUFFER_END

            // Vertex shader function
            Varyings vert(Attributes IN)
            {
                Varyings OUT; // Initialize output structure
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz); // Transform position to clip space
                OUT.uv = IN.uv; // Pass through UV coordinates
                return OUT; // Return the output
            }

        // Fragment shader function
        half4 frag(Varyings IN) : SV_Target
        {
            half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv); // Sample the texture
            texColor.a *= _Transparency; // Apply transparency to the alpha channel

            // Implement blending based on the selected mode
            int mode = int(_BlendMode); // Convert blend mode to integer
            switch (mode)
            {
                case 1: // Additive blending
                    texColor.rgb += (1.0 - texColor.a) * texColor.rgb;
                    break;
                case 2: // Multiply blending
                    texColor.rgb *= texColor.rgb;
                    break;
                case 3: // Soft Light blending
                    texColor.rgb = lerp(2.0 * texColor.rgb * texColor.rgb + texColor.rgb * texColor.rgb * (1.0 - 2.0 * texColor.rgb), sqrt(texColor.rgb) * (2.0 * texColor.rgb - texColor.rgb), texColor.a);
                    break;
                case 4: // Overlay blending
                    texColor.rgb = lerp(1.0 - 2.0 * (1.0 - texColor.rgb) * (1.0 - texColor.rgb), 2.0 * texColor.rgb * texColor.rgb, step(0.5, texColor.rgb));
                    break;
                default: // Normal (no additional blending)
                    break;
            }

            return texColor; // Return the final color
        }
        ENDHLSL
    }
        }
}
