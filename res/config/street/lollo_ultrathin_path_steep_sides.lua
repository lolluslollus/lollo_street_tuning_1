function data()
    return {
        numLanes = 2,
        -- transportModesStreet = {'PERSON'}, -- dumps
        sidewalkWidth = 0.2,
        sidewalkHeight = .0,
        streetWidth = 0.1,
        yearFrom = game.config.busLaneYearFrom,
        yearTo = 0,
        upgrade = false,
        country = false,
        speed = 20.0,
        type = 'lollo_ultrathin_path',
        name = _("Ultrathin path with steep enbankment"),
        desc = _("Ultrathin path with a speed limit of %2%, give it a bus lane to pedestrianise it."),
        categories = { 'paths' },
        order = 3,
        busAndTramRight = true,
        -- slopeBuildSteps = 1,
        transportModesStreet = {'TRUCK'}, -- it dumps with an empty array or with {'PERSON'}
        embankmentSlopeLow  = 0.0,
        embankmentSlopeHigh  = 9.9,
        materials = {
            streetPaving = {
                name = 'street/country_new_medium_paving.mtl',
                size = {1.0, 1.0}
            },
        },
        assets = {},
        cost = 1.0
    }
end
