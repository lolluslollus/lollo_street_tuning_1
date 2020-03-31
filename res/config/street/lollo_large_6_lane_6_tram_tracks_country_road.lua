function data()
    return {
        --numLanes = 6,
        laneConfig = {
            {
                forward = false,
                transportModesLane = {'BUS', 'ELECTRIC_TRAM', 'PERSON', 'TRAM'},
                transportModes = {'BUS', 'ELECTRIC_TRAM', 'PERSON', 'TRAM'}
            },
            {
                forward = false,
                transportModesLane = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM'},
                transportModes = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM'}
            },
            {
                forward = false,
                transportModesLane = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM'},
                transportModes = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM'}
            },
            {
                forward = false,
                transportModesLane = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'},
                transportModes = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'}
            },
            {
                forward = true,
                transportModesLane = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'},
                transportModes = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'}
            },
            {
                forward = true,
                transportModesLane = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM'},
                transportModes = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM'}
            },
            {
                forward = true,
                transportModesLane = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM'},
                transportModes = {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM'}
            },
            {
                forward = true,
                transportModesLane = {'BUS', 'ELECTRIC_TRAM', 'PERSON', 'TRAM'},
                transportModes = {'BUS', 'ELECTRIC_TRAM', 'PERSON', 'TRAM'}
            }
        },
        transportModesStreet = {'CAR', 'BUS', 'ELECTRIC_TRAM', 'TRAM'}, -- with this, tram tracks appear on all lanes, not only on the right one
        skipCollision = true,
        skipCollisionCheck = true,
        streetWidth = 20.0,
        sidewalkWidth = 2.0, -- 2 * sidewalkWidth + streetWidth must be 24
        sidewalkHeight = .02,
        yearFrom = 1925,
        yearTo = 0,
        upgrade = false,
        country = true,
        speed = 100.0,
        priority = 7, -- LOLLO NOTE this is copied from airports, it should give priority to this street
        type = 'lollo_large_6_lane_6_tram_tracks_country_road',
        name = _('Large country road with 6 lanes and 6 tram tracks'),
        desc = _('Large country road with 6 lanes crammed in, each with a tram track. Speed limit is %2%.'),
        categories = {'country'},
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
                size = {3.33, 3.33}
            },
            streetArrow = {
                name = 'street/default_arrows.mtl',
                size = {9.0, 3.0}
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
            sidewalkLane = {},
            sidewalkBorderInner = {
                name = 'street/country_new_large_sidewalk_border_inner.mtl',
                size = {9, 3.6}
            },
        },
        assets = {},
        borderGroundTex = 'street_border.lua',
        sidewalkFillGroundTex = 'country_sidewalk.lua',
        cost = 75.0
    }
end
