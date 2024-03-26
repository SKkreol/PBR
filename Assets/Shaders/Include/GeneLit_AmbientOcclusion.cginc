#ifndef GENELIT_AO_INCLUDED
    #define GENELIT_AO_INCLUDED

    //------------------------------------------------------------------------------
    // Ambient occlusion configuration
    //------------------------------------------------------------------------------

    // Diffuse BRDFs
    #define SPECULAR_AO_OFF             0
    #define SPECULAR_AO_SIMPLE          1
    #define SPECULAR_AO_BENT_NORMALS    2

    #define SPECULAR_AMBIENT_OCCLUSION SPECULAR_AO_SIMPLE
    #define MULTI_BOUNCE_AMBIENT_OCCLUSION 1

    //------------------------------------------------------------------------------
    // Ambient occlusion helpers
    //------------------------------------------------------------------------------

    half SpecularAO_Lagarde(half NoV, half visibility, half roughness)
    {
        // Lagarde and de Rousiers 2014, "Moving Frostbite to PBR"
        return saturate(pow(NoV + visibility, exp2(-half(16.0) * roughness - half(1.0))) - half(1.0) + visibility);
    }

    half sphericalCapsIntersection(half cosCap1, half cosCap2, half cosDistance)
    {
        // Oat and Sander 2007, "Ambient Aperture Lighting"
        // Approximation mentioned by Jimenez et al. 2016
        half r1 = acosFastPositive(cosCap1);
        half r2 = acosFastPositive(cosCap2);
        half d  = acosFast(cosDistance);

        // We work with cosine angles, replace the original paper's use of
        // cos(min(r1, r2)) with max(cosCap1, cosCap2)
        // We also remove a multiplication by 2 * PI to simplify the computation
        // since we divide by 2 * PI in computeBentSpecularAO()

        if (min(r1, r2) <= max(r1, r2) - d) return 1.0 - max(cosCap1, cosCap2);
        else if (r1 + r2 <= d) return 0.0;

        half delta = abs(r1 - r2);
        half x = 1.0 - saturate((d - delta) / max(r1 + r2 - delta, 1e-4));
        // simplified smoothstep()
        half area = sq(x) * (-2.0 * x + 3.0);
        return area * (1.0 - max(cosCap1, cosCap2));
    }

    // This function could (should?) be implemented as a 3D LUT instead, but we need to save samplers
    half SpecularAO_Cones(half3 bentNormal, half visibility, half roughness, half3 refl)
    {
        // Jimenez et al. 2016, "Practical Realtime Strategies for Accurate Indirect Occlusion"

        // aperture from ambient occlusion
        half cosAv = sqrt(1.0 - visibility);
        // aperture from roughness, log(10) / log(2) = 3.321928
        half cosAs = exp2(-3.321928 * sq(roughness));
        // angle betwen bent normal and reflection direction
        half cosB  = dot(bentNormal, refl);

        // Remove the 2 * PI term from the denominator, it cancels out the same term from
        // sphericalCapsIntersection()
        half ao = sphericalCapsIntersection(cosAv, cosAs, cosB) / (1.0 - cosAs);
        // Smoothly kill specular AO when entering the perceptual roughness range [0.1..0.3]
        // Without this, specular AO can remove all reflections, which looks bad on metals
        return lerp(1.0, ao, smoothstep(0.01, 0.09, roughness));
    }

    half specularAO(half NoV, half visibility, half roughness, half3 normal, half3 refl)
    {
        half specularAO = 1.0;

        // SSAO is not applied when blending is enabled
        #if !defined(_ALPHABLEND_ON) && !defined(_ALPHAPREMULTIPLY_ON)

            #if SPECULAR_AMBIENT_OCCLUSION == SPECULAR_AO_SIMPLE
                // TODO: Should we even bother computing this when screen space bent normals are enabled?
                specularAO = SpecularAO_Lagarde(NoV, visibility, roughness);
            #elif SPECULAR_AMBIENT_OCCLUSION == SPECULAR_AO_BENT_NORMALS
                specularAO = SpecularAO_Cones(normal, visibility, roughness, refl);
            #endif

        #endif

        return specularAO;
    }

    #if MULTI_BOUNCE_AMBIENT_OCCLUSION == 1
        /**
        * Returns a color ambient occlusion based on a pre-computed visibility term.
        * The albedo term is meant to be the diffuse color or f0 for the diffuse and
        * specular terms respectively.
        */
        half3 gtaoMultiBounce(half visibility, const half3 albedo)
        {
            // Jimenez et al. 2016, "Practical Realtime Strategies for Accurate Indirect Occlusion"
            half3 a =  half(2.0404) * albedo - half(0.3324);
            half3 b = -half(4.7951) * albedo + half(0.6417);
            half3 c =  half(2.7552) * albedo + half(0.6903);

            return max(visibility, ((visibility * a + b) * visibility + c) * visibility);
        }
    #endif

    void multiBounceAO(half visibility, const half3 albedo, inout half3 color)
    {
        #if MULTI_BOUNCE_AMBIENT_OCCLUSION == 1
            color *= gtaoMultiBounce(visibility, albedo);
        #endif
    }

    void multiBounceSpecularAO(half visibility, const half3 albedo, inout half3 color)
    {
        #if MULTI_BOUNCE_AMBIENT_OCCLUSION == 1 && SPECULAR_AMBIENT_OCCLUSION != SPECULAR_AO_OFF
            color *= gtaoMultiBounce(visibility, albedo);
        #endif
    }

    half singleBounceAO(half visibility)
    {
        #if MULTI_BOUNCE_AMBIENT_OCCLUSION == 1
            return half(1.0);
        #else
            return visibility;
        #endif
    }
#endif
