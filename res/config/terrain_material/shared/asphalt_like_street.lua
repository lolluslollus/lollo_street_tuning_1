function data()
    return {
        name = _('Asphalt like street'),
        detailColorTexture = 'terrain/new_medium_paving_albedo_bc1a.dds',
        detailMetalGlossAoHTexture = 'terrain/new_medium_paving_metall_gloss_ao_bc3.dds',
        detailNormalTexture = 'terrain/new_medium_paving_normal_bc5.dds',
        overlayTexture = 'terrain/overlay_0.dds', -- dirt
        detailSize = 1 / 24, --.025, --1 / 15, -- the smaller the detail size, the larger the tiles will look. 1 / 15 is too small, 1/32 is too large
        overlaySize = 0.08, --0.05, -- the larger, the thicker the dirt
        overlayStrength = 0.2, -- 0.125, -- the larger, the stronger the overlay
        --hOffset = 0.3,
        order = -62,
        priority = 1000000
    }
end
