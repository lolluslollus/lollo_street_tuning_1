﻿function data()
    return {
        --numLanes = 4,
        laneConfig = {
            {forward = true},
            {forward = true},
            {forward = true}
        },
        --transportModesStreet = {'CAR', 'BUS', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'}, -- with this, tram tracks appear on all lanes, not only on the right one
        --transportModesSidewalk = { "PERSON", "TRUCK" }, --crashes
        --transportModesSidewalk = { "PERSON" }, --crashes
        streetWidth = 2.4, -- was 0.2,
        sidewalkWidth = 0.1, -- was 4.0; 2 * sidewalkWidth + streetWidth must be 8
        sidewalkHeight = 0,
        yearFrom = 65535, -- LOLLO NOTE this bars the street from the street menu
        yearTo = 0,
        aiLock = true,
        visibility = false, -- do not display this street in the menu, unreliable
        country = false,
        speed = 100.0, -- was 50.0,
        -- priority = this crashes 4, -- LOLLO NOTE this is copied from airports, it should give priority to this street
        type = 'lollo_internal_1_way_1_lane_street_no_sidewalk.lua',
        name = _('Medium one-way street with 1 lane'),
        desc = _('Medium one-way street with 1 lane. Speed limit is %2%.'),
        --categories = {},
        --borderGroundTex = 'street_border.lua',
        materials = {
            -- streetPaving = {
            --     name = 'street/country_new_medium_paving.mtl',
            --     size = {8.0, 8.0}
            -- },
            -- streetBorder = {
            --     name = 'street/new_medium_border.mtl',
            --     size = {2.0, .3}
            -- },
            -- streetBorder = {
            --     name = 'street/country_new_large_border.mtl',
            --     size = {24, 0.459}
            -- },
            -- junctionBorder = {
            --     name = 'street/country_new_large_border.mtl',
            --     size = {24, 0.459}
            -- },
            streetLane = {
                name = 'street/new_medium_lane.mtl',
                size = {4.0, 4.0}
            },
            -- streetArrow = {
            --     name = 'street/default_arrows.mtl',
            --     size = {9.0, 3.0}
            -- },
            -- streetStripe = {
            --     name = 'street/new_medium_stripes.mtl',
            --     size = {8.0, .5}
            -- },
            -- streetStripeMedian = {
            --     name = 'street/new_large_median.mtl',
            --     size = {4.0, 1}
            -- },
            streetTram = {
                name = 'street/new_medium_tram_paving.mtl',
                size = {2.0, 2.0}
            },
            streetTramTrack = {
                name = 'street/new_medium_tram_track.mtl',
                size = {2.0, 2.0}
            },
            streetBus = {
                name = 'street/new_medium_bus.mtl',
                size = {12, 2.7}
            },
            -- crossingLane = {
            --     name = 'street/new_medium_lane.mtl',
            --     size = {4.0, 4.0}
            -- },
            -- crossingBus = {
            --     name = ''
            -- },
            -- crossingTram = {
            --     name = 'street/new_medium_tram_paving.mtl',
            --     size = {2.0, 2.0}
            -- },
            -- crossingTramTrack = {
            --     name = 'street/new_medium_tram_track.mtl',
            --     size = {2.0, 2.0}
            -- },
            -- crossingCrosswalk = {
            --     name = 'street/new_medium_crosswalk.mtl',
            --     size = {3.0, 2.5}
            --     -- size = { 2.5, 2.5 }
            -- },
            -- crossingStopline = {
            --     name = 'street/new_medium_stopline.mtl',
            --     size = {6.0, .5}
            -- },
            -- sidewalkPaving = {
            --     name = 'street/new_medium_sidewalk.mtl',
            --     size = {4.0, 4.0}
            -- },
            -- sidewalkLane = {},
            -- sidewalkBorderInner = {
            --     name = 'street/new_medium_sidewalk_border_inner.mtl',
            --     size = {3, 0.6}
            -- },
            -- sidewalkBorderOuter = {
            --     name = 'street/new_medium_sidewalk_border_outer.mtl',
            --     size = {8.0, 0.41602}
            -- },
            -- sidewalkCurb = {
            --     name = 'street/new_medium_sidewalk_curb.mtl',
            --     size = {3, .35}
            -- },
            -- sidewalkWall = {
            --     name = 'street/new_medium_sidewalk_wall.mtl',
            --     size = {8.0, 0.41602}
            -- }
        },
        catenary = {
            pole = { name = "lollo_assets/empty.mdl" },
            poleCrossbar = { name = "lollo_assets/empty.mdl" },
            poleDoubleCrossbar = { name = "lollo_assets/empty.mdl" },
            isolatorStraight = "lollo_assets/empty.mdl";
            isolatorCurve =  "lollo_assets/empty.mdl";
            junction = "asset/cable_junction.mdl";
        },
        assets = {
            -- {
            --     name = 'street/street_light_eu_c.mdl',
            --     offset = 8.0,
            --     distance = 16.0,
            --     prob = 1.0,
            --     offsetOrth = 3.4,
            --     randRot = false,
            --     oneSideOnly = true, -- was false,
            --     alignToElevation = false,
            --     avoidFaceEdges = false,
            --     placeOnBridge = true
            -- },
            -- {
            --     name = 'street/street_asset_mix/fireplug_eu_c.mdl',
            --     offset = 9.0,
            --     distance = 49.0,
            --     prob = 0.5,
            --     offsetOrth = 0.5,
            --     randRot = false,
            --     oneSideOnly = false,
            --     alignToElevation = true,
            --     avoidFaceEdges = false
            -- },
            -- {
            --     name = 'street/street_asset_mix/mailbox_eu_c.mdl',
            --     offset = 5, -- was 8,
            --     distance = 43, -- was 40.0,
            --     prob = 0.3,
            --     offsetOrth = 0.4,
            --     randRot = false,
            --     oneSideOnly = false,
            --     alignToElevation = false,
            --     avoidFaceEdges = false
            -- },
            -- {
            --     name = 'street/street_asset_mix/trash_standing_c.mdl',
            --     offset = 20,
            --     distance = 50.0,
            --     prob = 0.5,
            --     offsetOrth = 0.5, -- was 3.0,
            --     randRot = false,
            --     oneSideOnly = false,
            --     alignToElevation = true,
            --     avoidFaceEdges = false
            -- }
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
