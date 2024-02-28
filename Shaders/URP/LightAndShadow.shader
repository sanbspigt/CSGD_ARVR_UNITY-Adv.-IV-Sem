Shader "Custom/URP_LightAndShadow"
{
    // Define shader properties (textures and colors)
    Properties
    {
        [Header(Base Color)]
        [MainTexture] _BaseMap("_BaseMap (Albedo)", 2D) = "white" {} // Base color map
       // [HDR][MainColor]_BaseColor("_BaseColor", Color) = (1,1,1,1) // Base color
        [Header(Normal)]
        [MainTexture]_NormalMap("_NormalMap", 2D) = "white" {} // Normal map
    }

        // Define a SubShader
        SubShader
    {
        // Specify the rendering pipeline and other tags
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
        }

        // Define a Pass within the SubShader
        Pass
        {
            Name "ForwardLit" // Name of the pass
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Begin HLSL program block
        HLSLPROGRAM

        // Compile directives for lighting features
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _SHADOWS_SOFT

        // Specify vertex and fragment shader functions
        #pragma vertex vert
        #pragma fragment frag

        // Include URP shader libraries for core and lighting functions
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        // Define the structure for shader attributes
        struct Attributes
        {
            float3 positionOS   : POSITION; // Object space position
            half3 normalOS      : NORMAL;   // Object space normal
            half4 tangentOS     : TANGENT;  // Object space tangent
            float2 uv           : TEXCOORD0; // Texture coordinates
        };

    // Define the structure for varying data passed from vertex to fragment shader
    struct Varyings
    {
        float2 uv                       : TEXCOORD0; // Texture coordinates
        float4 positionWSAndFogFactor   : TEXCOORD1; // World space position and fog factor
        half3 normalWS                  : TEXCOORD2; // World space normal
        float4 positionCS               : SV_POSITION; // Clip space position
        float3 lightTS                  : TEXCOORD3; // Light direction in tangent space
    };

    // Texture samplers
    sampler2D _BaseMap;
    sampler2D _NormalMap;

    // Constant buffers for texture scaling and translation
    CBUFFER_START(UnityPerMaterial)
    float4  _BaseMap_ST;
    float4  _NormalMap_ST;
    CBUFFER_END

        // Vertex shader function
        Varyings vert(Attributes input)
        {
            Varyings output;

            // Convert object space to world space
            VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
            VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

            output.uv = TRANSFORM_TEX(input.uv, _BaseMap); // Transform texture coordinates
            output.positionCS = TransformWorldToHClip(vertexInput.positionWS); // Convert world space to clip space

            // Calculate light direction in tangent space
            float3x3 tangentMat = float3x3(vertexNormalInput.tangentWS, vertexNormalInput.bitangentWS, vertexNormalInput.normalWS);
            output.lightTS = mul(tangentMat, GetMainLight().direction);

            return output;
        }

    // Fragment shader function
    half4 frag(Varyings input) : SV_Target
    {
        half4 col = tex2D(_BaseMap, input.uv); // Sample base map color
        float3 normal = UnpackNormal(tex2D(_NormalMap, input.uv)); // Unpack normal map
        float diff = saturate(dot(input.lightTS, normal)); // Calculate diffuse lighting

        col *= diff; // Apply lighting to color
        return col;
    }
    ENDHLSL
}
    }
}
