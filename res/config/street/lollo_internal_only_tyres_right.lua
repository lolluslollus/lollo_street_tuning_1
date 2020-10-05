function data()
    return {
        --numLanes = 4,
        laneConfig = {
            {forward = true},
            {forward = true},
            {forward = true}
        },
        streetWidth = 2,
        sidewalkWidth = 1, -- 2 * sidewalkWidth + streetWidth must be 8
        sidewalkHeight = 0,
        yearFrom = 65535, -- LOLLO NOTE this bars the street from the street menu
        yearTo = 0,
        upgrade = true, -- do not display this street in the menu
        country = false,
        speed = 100.0, -- was 50.0,
        type = 'lollo_internal_only_tyres_right.lua',
        name = _('lollo_internal_only_tyres_right'),
        desc = _('lollo_internal_only_tyres_right'),
        --categories = {},
        materials = { },
        assets = {
            {
                name = 'lollo_assets/only_tyres.mdl',
                -- offset = 8.0,
                -- distance = 16.0,
                offset = 6.0,
                distance = 12.0,
                prob = 1.0,
                offsetOrth = 0.2,
                randRot = false,
                oneSideOnly = false,
                alignToElevation = true,
                avoidFaceEdges = false,
                placeOnBridge = true
            },
            -- {
            --	name = "asset/lamp_new.mdl",
            --	offset = 5.0,
            --	distance = 12.0,
            --	prob = 1.0,
            --	offsetOrth = 2.4,
            --	randRot = false,
            --	oneSideOnly = false,
            --	alignToElevation = false,
            --	avoidFaceEdges = true,
            --	placeOnBridge = true,
            --},
        },
        signalAssetName = 'asset/ampel.mdl',
        cost = 40.0
    }
end
