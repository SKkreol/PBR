#ifndef Custom_INCLUDED
    #define Custom_INCLUDED

float3 DirectLightPart(PixelParams pixel,ShadingData shadingData, float occlusion)
{
    float NoL = saturate(dot(shadingData.normal, _WorldSpaceLightPos0.xyz));
    float ao = computeMicroShadowing(NoL, occlusion);
    float3 h = normalize(shadingData.view + _WorldSpaceLightPos0.xyz);
    float NoV = shadingData.NoV;
    float NoH = saturate(dot(shadingData.normal, h));
    float LoH = saturate(dot(_WorldSpaceLightPos0.xyz, h));
                
    float3 specularDirect = isotropicLobe(pixel, h, NoV, NoL, NoH, LoH);
    float3 diffuseDirect = diffuseLobe(pixel, NoV, NoL, LoH);

    // TODO: attenuate the diffuse lobe to avoid energy gain
    // The energy compensation term is used to counteract the darkening effect
    // at high roughness
    float3 color = diffuseDirect + specularDirect * pixel.energyCompensation;
    //return (color * _LightColor0.rgb) * (light.attenuation * NoL * occlusion);
    return (color * _LightColor0.rgb) * (NoL * ao);
}

float3 IndirectLightPart(PixelParams pixel, ShadingData shadingData, float occlusion)
{
    // specular layer
    float3 E = lerp(pixel.dfg.xxx, pixel.dfg.yyy, pixel.f0);
    float3 r = lerp(shadingData.reflected, shadingData.normal, pixel.roughness * pixel.roughness);
    float3 specularIndirect = E * prefilteredRadiance(r, pixel.perceptualRoughness, shadingData.position);

    float diffuseAO = occlusion;
    float specAO = SpecularAO_Lagarde(shadingData.NoV, diffuseAO, pixel.roughness);
    specularIndirect *= singleBounceAO(specAO) * pixel.energyCompensation;

    // diffuse layer
    float diffuseBRDF = singleBounceAO(diffuseAO); // Fd_Lambert() is baked in the SH below
    float3 diffuseNormal = shadingData.normal;
    float3 irradiance = ShadeSHPerPixel(diffuseNormal, shadingData.ambient, shadingData.position);
    float3 diffuseIndirect = pixel.diffuseColor * irradiance * saturate(1.0 - E) * diffuseBRDF;

    // extra ambient occlusion term for the base and subsurface layers
    multiBounceAO(diffuseAO, pixel.diffuseColor, diffuseIndirect);
    multiBounceSpecularAO(specAO, pixel.f0, specularIndirect);
    float3  color = diffuseIndirect + specularIndirect;
    return color;
}

float4 pbrLight(const MaterialInputs material, const ShadingData shadingData)
{
    PixelParams pixel = (PixelParams)0;
    
    float4 baseColor = material.baseColor;
    pixel.diffuseColor = baseColor.rgb * (1.0 - material.metallic);
    // Assumes an interface from air to an IOR of 1.5 for dielectrics
    float reflectance = computeDielectricF0(material.reflectance);
    pixel.f0 = computeF0(baseColor, material.metallic, reflectance);

    float perceptualRoughness = material.roughness;
    // This is used by the refraction code and must be saved before we apply specular AA
    pixel.perceptualRoughnessUnclamped = perceptualRoughness;
    
    #if defined(GEOMETRIC_SPECULAR_AA)
        perceptualRoughness = normalFiltering(perceptualRoughness, shadingData.normal);
    #endif
    
    // Clamp the roughness to a minimum value to avoid divisions by 0 during lighting
    pixel.perceptualRoughness = clamp(perceptualRoughness, MIN_PERCEPTUAL_ROUGHNESS, 1.0);
    // Remaps the roughness to a perceptually linear roughness (roughness^2)
    pixel.roughness = perceptualRoughnessToRoughness(pixel.perceptualRoughness);
    
    // Pre-filtered DFG term used for image-based lighting
    pixel.dfg = prefilteredDFG(pixel.perceptualRoughness, shadingData.NoV);
    // Energy compensation for multiple scattering in a microfacet model
    // See "Multiple-Scattering Microfacet BSDFs with the Smith Model"
    pixel.energyCompensation = 1.0 + pixel.f0 * (1.0 / pixel.dfg.y - 1.0);
    
    float occlusion = material.ambientOcclusion;
    pixel.pseudoAmbient = 1;

    float3 indirect = IndirectLightPart(pixel, shadingData, occlusion);
    float3 direct = DirectLightPart(pixel, shadingData, occlusion);
    
    return float4(direct + indirect, 1);
}


#endif
