Shader "PBRURP"
{
    Properties
    {
        [SingleLine] _Color ("Color", Color) = (1,1,1,1)
        [SingleLineScaleOffset(_Color)] _MainTex ("Albedo", 2D) = "white" {}
        [SingleLine(, _MASKMAP)] _MaskMap ("Mask Map", 2D) = "white" {}
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _OcclusionStrength ("Occlusion", Range(0,1)) = 1.0
        _Reflectance ("Reflectance", Range(0.35, 1.0)) = 0.5

        [IfDef(_NORMALMAP)][SingleLine] _BumpScale ("Normal Scale", Range(1.0, 2.0)) = 1.0
        [SingleLine(_BumpScale, _NORMALMAP)][Normal] _BumpMap ("Normal Map", 2D) = "bump" {}
        
        [HideInInspector][NonModifiableTextureData] _DFG ("_DFG", 2D) = "black" {}
    }
    SubShader
    {
        Pass
        {
            Name "FORWARD"
            Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }

            Cull Back
            ZWrite On

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex vertForward
            #pragma fragment fragForward
            #pragma multi_compile_fwdbase
            #pragma shader_feature_local _MASKMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local REFRACTION_TYPE_NONE REFRACTION_TYPE_SOLID REFRACTION_TYPE_THIN
            #pragma shader_feature_local REFLECTION_SPACE_CUBE REFLECTION_SPACE_CYLINDER REFLECTION_SPACE_ADDITIONAL_BOX
            #pragma multi_compile _ULTRA_GRAPHICS _HIGH_GRAPHICS _MEDIUM_GRAPHICS _LOW_GRAPHICS
            #define UNITY_TWO_PI        6.28318530718f
            #define UNITY_FOUR_PI       12.56637061436f
            #define UNITY_INV_PI        0.31830988618f
            #define UNITY_INV_TWO_PI    0.15915494309f
            #define UNITY_INV_FOUR_PI   0.07957747155f
            #define UNITY_float_PI       1.57079632679f
            #define UNITY_INV_float_PI   0.636619772367f
            
            #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #define USE_METALLIC
            #define FILAMENT_QUALITY FILAMENT_QUALITY_HIGH
            #define GEOMETRIC_SPECULAR_AA
            #define FILAMENT_QUALITY_HIGH   2
            
            CBUFFER_START(UnityPerMaterial)
                half4 _MainTex_ST;
                half4 _MainTex_TexelSize;
                half4 _Color;
                half _Glossiness;
                half _Metallic;
                half _Reflectance;
                half _OcclusionStrength;
                half _BumpScale;
            CBUFFER_END

            TEXTURE2D(_MainTex);       SAMPLER(sampler_MainTex);
            TEXTURE2D(_MaskMap);       SAMPLER(sampler_MaskMap);
            TEXTURE2D(_DFG);       SAMPLER(sampler_DFG);
            #if defined(_NORMALMAP)
                TEXTURE2D(_BumpMap);       SAMPLER(sampler_BumpMap);
            #endif

             #include "Include/GeneLit_Brdf.cginc"
             #include "Include/GeneLit_AmbientOcclusion.cginc"

            half3 PrefilteredDFG_LUT(half lod, half NoV)
            {
                // coord = sqrt(linear_roughness), which is the mapping used by cmgen.
                return SAMPLE_TEXTURE2D(_DFG,sampler_DFG, half2(NoV, lod)).rgb;
            }

            half2 EnvBRDFApprox(half Roughness, half NoV)
            {
                // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
                half4 c0 = half4(-1, -0.0275, -0.572, 0.022);
                half4 c1 = half4(1, 0.0425, 1.04, -0.04);
                half4 r = Roughness * c0 + c1;
                half a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
                half2 AB = half2(-1.04, 1.04) * a004 + r.zw;
                return AB;
            }

            half3 prefilteredDFG(half perceptualRoughness, half NoV)
            {
                // PrefilteredDFG_LUT() takes a LOD, which is sqrt(roughness) = perceptualRoughness
                return PrefilteredDFG_LUT(perceptualRoughness, NoV);
            }
            
            inline half3 indirectSpecular(half3 r, half lod, half3 worldPos)
            {
                half3 specular;

                //#ifdef UNITY_SPECCUBE_BOX_PROJECTION
                    //half3 refDir = GENELIT_PROJECTED_DIRECTION(r, worldPos, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
                //#else
                    half3 refDir = r;
                //#endif

                #ifdef _GLOSSYREFLECTIONS_OFF
                    specular = unity_IndirectSpecColor.rgb;
                #else
                    half4 cubeSpec = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, refDir, lod);
                    half3 env0 =  DecodeHDREnvironment(cubeSpec, unity_SpecCube0_HDR);
                    //#ifdef UNITY_SPECCUBE_BLENDING
                        //const half kBlendFactor = 0.99999;
                        //half blendLerp = unity_SpecCube0_BoxMin.w;
                        //UNITY_BRANCH
                       //if (blendLerp < kBlendFactor)
                        //{
                           // #ifdef UNITY_SPECCUBE_BOX_PROJECTION
                                //refDir = BoxProjectedCubemapDirection(r, worldPos, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
                            //#else
                                //refDir = r;
                            //#endif

                            //half3 env1 = DecodeHDR(UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, refDir, lod), unity_SpecCube1_HDR);
                            //specular = lerp(env1, env0, blendLerp);
                        //}
                        //else
                        //{
                            specular = env0;
                        //}
                    //#else
                        //specular = env0;
                    //#endif
                #endif

                return specular;
            }

            inline half perceptualRoughnessToLod(half perceptualRoughness)
            {
                // The mapping below is a quadratic fit for log2(perceptualRoughness)+iblRoughnessOneLevel when
                // iblRoughnessOneLevel is 4. We found empirically that this mapping works very well for
                // a 256 cubemap with 5 levels used. But also scales well for other iblRoughnessOneLevel values.
                return half(UNITY_SPECCUBE_LOD_STEPS) * perceptualRoughness * (half(1.7) - half(0.7) * perceptualRoughness);
                //return UNITY_SPECCUBE_LOD_STEPS * perceptualRoughness * (2.0 - perceptualRoughness);
            }

            inline half3 prefilteredRadiance(const half3 r, half perceptualRoughness, half3 worldPos)
            {
                half lod = perceptualRoughnessToLod(perceptualRoughness);
                return indirectSpecular(r, lod, worldPos);
            }
            
            struct atr
            {
                half4 vertex : POSITION;
                half4 tangent : TANGENT;
                half3 normal : NORMAL;
                half4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                half4 pos : SV_POSITION;
                half4 uv : TEXCOORD0;
                half3 worldPos : TEXCOORD1;
                half3 NW : TEXCOORD2;
                half4 TW : TEXCOORD3;
                half3 BW : TEXCOORD5;
                half4 ambientOrLightmapUV : TEXCOORD4;
            };

            v2f vertForward(atr v)
            {
                v2f o = (v2f)0;
                half3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = mul(UNITY_MATRIX_VP, half4(worldPos, 1));
                o.uv.xy = v.texcoord.xy;

                half3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                half3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                
                #if defined(_ULTRA_GRAPHICS)
                    worldTangent = normalize(worldTangent - dot(worldTangent, worldNormal) * worldNormal);
                #endif
                
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                o.NW = worldNormal;
                o.TW.xyz = worldTangent;
                o.TW.w = tangentSign;
                o.BW = normalize(cross(o.NW, o.TW)*tangentSign);

                o.worldPos = worldPos;
                o.ambientOrLightmapUV = SampleSHVertex(worldNormal).rgbb;
                return o;
            }

            half specularAA(half perceptualRoughness, const half3 worldNormal)
            {
                // Kaplanyan 2016, "Stable specular highlights"
                // Tokuyoshi 2017, "Error Reduction and Simplification for Shading Anti-Aliasing"
                // Tokuyoshi and Kaplanyan 2019, "Improved Geometric Specular Antialiasing"

                // This implementation is meant for deferred rendering in the original paper but
                // we use it in forward rendering as well (as discussed in Tokuyoshi and Kaplanyan
                // 2019). The main reason is that the forward version requires an expensive transform
                // of the half vector by the tangent frame for every light. This is therefore an
                // approximation but it works well enough for our needs and provides an improvement
                // over our original implementation based on Vlachos 2015, "Advanced VR Rendering".

                half3 du = ddx(worldNormal);
                half3 dv = ddy(worldNormal);

                half variance = half(UNITY_INV_TWO_PI) * (dot(du, du) + dot(dv, dv));

                half roughness = perceptualRoughnessToRoughness(perceptualRoughness);
                half kernelRoughness = saturate(half(2.0) * variance);
                half squareRoughness = saturate(roughness * roughness + kernelRoughness);

                return roughnessToPerceptualRoughness(sqrt(squareRoughness));
            }

            half LerpOneTo2(half b, half t)
            {
                half oneMinusT = 1 - t;
                return oneMinusT + b * t;
            }

            half computeMicroShadowing2(half NoL, half visibility)
            {
                // Chan 2018, "Material Advances in Call of Duty: WWII"
                half aperture = rsqrt(half(1.001) - visibility);
                half microShadow = saturate(NoL * aperture);
                return microShadow * microShadow;
            }

            half diffuseDirect2(half roughness, half NoV, half NoL, half LoH)
            {
                #if defined(_ULTRA_GRAPHICS)
                    return Fd_Burley(roughness, NoV, NoL, LoH);
                #else
                    return 1.0f; // Fd_Lambert()
                #endif
            }

            half visibility2(half roughness, half NoV, half NoL) {
                 #if defined(_LOW_GRAPHICS)
                    return V_SmithGGXCorrelated_Fast(roughness, NoV, NoL);
                #else
                    return V_SmithGGXCorrelated(roughness, NoV, NoL);
                #endif
            }

            half ApplayMiscroShadow(half ao, half lambert)
            {
                half aperture = half(2)*ao*ao;
                return saturate(lambert + (aperture - half(1)));
            }
            // General light formula (DirectSpecular + DirectDiffuse) * NoL * LightColor + IndirectDiffuse + IndirectSpecular
            half4 fragForward(in v2f IN) : SV_Target
            {
                //IN.TW.xyz = normalize(IN.TW.xyz - dot(IN.TW.xyz, IN.NW) * IN.NW);
                // We use unnormalized post-interpolation values, assuming mikktspace tangents
                half3 BitW = normalize(cross(IN.NW, IN.TW.xyz) * IN.TW.w);
                half3x3 TBN =  half3x3(IN.TW.xyz, IN.BW, IN.NW);

                half3 V = normalize(_WorldSpaceCameraPos - IN.worldPos);
                half3 SH_Vertex = IN.ambientOrLightmapUV.rgb;
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv.xy) * _Color;
                half4 mods = 1;
                #if defined(_MASKMAP)
                    mods = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, IN.uv.xy);
                #endif

                half metallic = _Metallic * mods.r;

                half ambientOcclusion = LerpOneTo2(mods.g, _OcclusionStrength);
                half3 normal = half3(0.0, 0.0, 1.0);
                #if defined(_NORMALMAP)
                    half4 packNormals = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv.xy);
                    normal = UnpackNormalScale(packNormals, _BumpScale);
                #endif

                half3 N = normalize(mul(normal, TBN));

                half NoV = max(dot(N, V), half(MIN_N_DOT_V));
                half3 ReflectV = reflect(-V, N);
                
                half4 baseColor = color;
                half3 diffuseColor = baseColor.rgb * (half(1.0) - metallic);
                // Assumes an interface from air to an IOR of 1.5 for dielectrics
                half reflectance = computeDielectricF0(_Reflectance);
                half3 F0 = computeF0(baseColor, metallic, reflectance);

                half perceptualRoughness = half(1.0) - _Glossiness * mods.a;
                
                #if defined(_ULTRA_GRAPHICS)
                    perceptualRoughness = specularAA(perceptualRoughness, N);
                #endif
                
                // Clamp the roughness to a minimum value to avoid divisions by 0 during lighting
                perceptualRoughness = clamp(perceptualRoughness, MIN_PERCEPTUAL_ROUGHNESS, half(1.0));
                // Remaps the roughness to a perceptually linear roughness (roughness^2)
                half roughness = perceptualRoughness * perceptualRoughness;
                
                // Pre-filtered DFG term used for image-based lighting
                //#if defined(_LOW_GRAPHICS)
                    //half2 DFG = EnvBRDFApprox(perceptualRoughness, NoV).yx;
                //#else
                    half2 DFG = prefilteredDFG(perceptualRoughness, NoV);
                //#endif

                // Energy compensation for multiple scattering in a microfacet model
                // See "Multiple-Scattering Microfacet BSDFs with the Smith Model"
                half3 energyCompensation = half(1.0) + F0 * (half(1.0) / DFG.y - half(1.0));
               
                half occlusion = ambientOcclusion;

                //INDIRECT part --------------------------------------------------------
                // specular layer
                half3 E = lerp(DFG.xxx, DFG.yyy, F0);
                half3 r = lerp(ReflectV, N, roughness * roughness);
                half3 specularIndirect = E * prefilteredRadiance(r, perceptualRoughness, IN.worldPos);

                half diffuseAO = occlusion;
                half specAO = SpecularAO_Lagarde(NoV, diffuseAO, roughness);
                specularIndirect *= singleBounceAO(specAO) * energyCompensation;

                // diffuse layer
                half diffuseBRDF = singleBounceAO(diffuseAO); // Fd_Lambert() is baked in the SH below
                half3 diffuseNormal = N;
                half3 irradiance = SampleSHPixel(SH_Vertex, diffuseNormal);
                half3 diffuseIndirect = diffuseColor * irradiance * saturate(half(1.0) - E) * diffuseBRDF;

                // extra ambient occlusion term for the base and subsurface layers
                multiBounceAO(diffuseAO, diffuseColor, diffuseIndirect);
                multiBounceSpecularAO(specAO, F0, specularIndirect);
                half3 indirect = diffuseIndirect + specularIndirect;
                //INDIRECT part --------------------------------------------------------
                
                //DIRECT part --------------------------------------------------------
                half NoL = saturate(dot(N, _MainLightPosition.xyz));
                half ao = computeMicroShadowing2(NoL, occlusion);
                //return ApplayMiscroShadow(ao, NoL);

                half3 h = normalize(V + _MainLightPosition.xyz);
                half NoH = saturate(dot(N, h));
                half LoH = saturate(dot(_MainLightPosition.xyz, h));

                half D = distribution(roughness, NoH, h);
                half Vis = visibility2(roughness, NoV, NoL);
                half3 F = fresnel(F0, LoH);
                            
                half3 specularDirect = (D * Vis) * F;
                half3 diffuseDirect = diffuseColor * diffuseDirect2(roughness, NoV, NoL, LoH);

                // TODO: attenuate the diffuse lobe to avoid energy gain
                // The energy compensation term is used to counteract the darkening effect
                // at high roughness
                half3 directColor = diffuseDirect + specularDirect * energyCompensation;
                //return (color * _LightColor0.rgb) * (light.attenuation * NoL * occlusion);
                half3 direct = (directColor * _MainLightColor.rgb) * (NoL * ao);
                //DIRECT part --------------------------------------------------------
                
                // TO DO compute custom fog
                return  half4(direct + indirect, 1);
            }
            ENDHLSL
        }
    }
}