function data()
    return {
        --numLanes = 6,
        laneConfig = {
            {forward = false},
            {forward = false},
            {forward = false},
            {forward = false},
            {forward = true},
            {forward = true},
            {forward = true},
            {forward = true},
        },
        --transportModesStreet = {'CAR', 'BUS', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'}, -- with this, tram tracks appear on all lanes, not only on the right one
        --transportModesSidewalk = { "PERSON", "TRUCK" }, --crashes
        --transportModesSidewalk = { "PERSON" }, --crashes
        streetWidth = 20.0,
        sidewalkWidth = 2.0, -- 2 * sidewalkWidth + streetWidth must be 24
        sidewalkHeight = .3,
        yearFrom = 1925,
        yearTo = 0,
        aiLock = true,
        visibility = true,
        country = false,
        speed = 60.0,
        -- priority = this crashes 7, -- LOLLO NOTE this is copied from airports, it should give priority to this street
        type = 'lollo_large_6_lane_street.lua',
        name = _('Large street - 6 lanes'),
        desc = _('Large street with 6 lanes crammed in. Speed limit is %2%.'),
        categories = {'urban'},
        borderGroundTex = 'street_border.lua',
        materials = {
            streetPaving = {
                name = 'street/country_new_medium_paving.mtl',
                size = {8.0, 8.0}
            },
            streetBorder = {
                name = 'street/new_large_border.mtl',
                size = {6.0, .5}
            },
            streetLane = {
                name = 'street/new_medium_lane.mtl',
                size = {3.33, 3.33}
            },
            streetArrow = {
                name = 'street/default_arrows.mtl',
                size = {9.0, 3.0}
            },
            streetStripe = {
                name = 'street/new_medium_stripes.mtl',
                size = {8.0, .5}
            },
            streetStripeMedian = {
                name = 'street/new_large_median.mtl',
                size = {4.0, 1}
            },
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
                size = {12, 2.5}
            },
            crossingLane = {
                name = 'street/new_medium_lane.mtl',
                size = {3.33, 3.33}
            },
            crossingBus = {
                name = ''
            },
            crossingTram = {
                name = 'street/new_medium_tram_paving.mtl',
                size = {2.0, 2.0}
            },
            crossingTramTrack = {
                name = 'street/new_medium_tram_track.mtl',
                size = {2.0, 2.0}
            },
            crossingCrosswalk = {
                name = 'street/new_medium_crosswalk.mtl',
                size = {3.0, 2.5}
            },
            sidewalkPaving = {
                name = 'street/new_medium_sidewalk.mtl',
                size = {4.0, 4.0}
            },
            sidewalkLane = {},
            sidewalkBorderInner = {
                name = 'street/new_medium_sidewalk_border_inner.mtl',
                size = {3, 0.6}
            },
            sidewalkBorderOuter = {
                name = 'street/new_medium_sidewalk_border_outer.mtl',
                size = {8.0, 0.41602}
            },
            sidewalkCurb = {
                name = 'street/new_medium_sidewalk_curb.mtl',
                size = {3, .35}
            },
            sidewalkWall = {
                name = 'street/new_medium_sidewalk_wall.mtl',
                size = {8.0, 0.41602}
            }
        },
        assets = {
            {
                name = 'street/street_light_eu_c.mdl',
                offset = 8.0,
                distance = 16.0,
                prob = 1.0,
                offsetOrth = 3.4,
                randRot = false,
                oneSideOnly = false,
                alignToElevation = false,
                avoidFaceEdges = false,
                placeOnBridge = true
            },
            {
                name = 'street/street_asset_mix/fireplug_eu_c.mdl',
                offset = 10.0,
                distance = 49.0,
                prob = 0.5,
                offsetOrth = 0.5,
                randRot = false,
                oneSideOnly = false,
                alignToElevation = true,
                avoidFaceEdges = false
            },
            {
                name = 'street/street_asset_mix/mailbox_eu_c.mdl',
                offset = 9,
                distance = 39.0,
                prob = 0.3,
                offsetOrth = 0.4,
                randRot = false,
                oneSideOnly = false,
                alignToElevation = false,
                avoidFaceEdges = false
            },
            {
                name = 'street/street_asset_mix/trash_standing_c.mdl',
                offset = 20,
                distance = 50.0,
                prob = 0.5,
                offsetOrth = 0.5, -- was 3.0,
                randRot = false,
                oneSideOnly = false,
                alignToElevation = true,
                avoidFaceEdges = false
            },
            {
                name = 'asset/tree_bed_new.mdl',
                offset = 13.0,
                distance = 23.0,
                prob = 1.0,
                offsetOrth = 1, -- was 2.89,
                randRot = false,
                oneSideOnly = false,
                alignToElevation = true,
                avoidFaceEdges = true
            },
            {
                name = 'tree/lombardy_poplar.mdl',
                offset = 13.0,
                distance = 23.0,
                prob = 1.0,
                offsetOrth = 0.91, -- was 2.8,
                randRot = true,
                oneSideOnly = false,
                alignToElevation = false,
                avoidFaceEdges = true
            }
        },
        signalAssetName = 'asset/ampel.mdl',
        cost = 60.0
    }
end
