﻿function data()
    return {
        --numLanes = 4,
        laneConfig = {
            {forward = true},
            {forward = true},
            --		{forward = true },
            --		{forward = true, },
            {forward = true},
            {forward = false}
        },
        transportModesStreet = {'CAR', 'BUS', 'ELECTRIC_TRAM', 'TRAM'}, -- with this, tram tracks appear on all lanes, not only on the right one
        --transportModesSidewalk = { "PERSON", "TRUCK" }, --crashes
        --transportModesSidewalk = { "PERSON" }, --crashes
        skipCollision = true,
        skipCollisionCheck = true,
        streetWidth = 8.0,
        sidewalkWidth = 4.0, -- was 4.0; 2 * sidewalkWidth + streetWidth must be 16
        sidewalkHeight = .00,
        yearFrom = 1925,
        yearTo = 0,
        upgrade = false,
        country = true,
        speed = 80.0,
        type = 'lollo_medium_1_way_2_lane_2_tram_tracks_country_road.lua',
        name = _('Medium 1-way country road with 2 lanes and 2 tram tracks'),
        desc = _('Medium 1-way country road with 2 lanes, each with a tram track. Speed limit is %2%.'),
        categories = {'one-way', 'country'},
        borderGroundTex = 'street_border.lua',
        materials = {
            streetPaving = {
                name = 'street/country_new_medium_paving.mtl',
                size = {8.0, 8.0}
            },
            streetBorder = {
                name = 'street/country_new_large_border.mtl',
                size = {24, 0.459}
            },
            junctionBorder = {
                name = 'street/country_new_large_border.mtl',
                size = {24, 0.459}
            },
            streetLane = {
                name = 'street/new_medium_lane.mtl',
                size = {4.0, 4.0}
            },
            streetArrow = {
                name = 'street/default_arrows.mtl',
                size = {6.0, 3.0}
            },
            streetStripe = {
                name = 'street/country_new_medium_stripes.mtl',
                size = {32.0, .5}
            },
            streetStripeMedian = {
                name = 'street/country_new_large_median.mtl',
                size = {4.0, .5}
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
                size = {12, 2.7}
            },
            crossingLane = {
                name = 'street/new_medium_lane.mtl',
                size = {4.0, 4.0}
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
            sidewalkLane = {},
            sidewalkBorderInner = {}
        },
        assets = {},
        sidewalkFillGroundTex = 'country_sidewalk.lua',
        cost = 50.0
    }
end
