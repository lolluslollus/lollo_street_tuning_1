function data()
    return {
        numLanes = 2,
        sidewalkWidth = 0, --0.11,
        sidewalkHeight = .0,
        streetWidth = 0.1,
        yearFrom = 65535, -- LOLLO NOTE this bars the street from the street menu -- this street is for the slicer only
        yearTo = 0,
        aiLock = true,
        visibility = false, -- do not display in the menu, this street is for the slicer only - unreliable
        country = false,
        speed = 100.0,
        type = 'lollo_ultrathin_street',
        --name = _("Lollo ultrathin street"),
        --desc = _("Ultrathin street with a speed limit of %2%."),
        --categories = { "urban" },
        categories = {},
        slopeBuildSteps = 1,
        borderGroundTex = 'street_border.lua',
        materials = {},
        assets = {},
        cost = 0.0
    }
end
