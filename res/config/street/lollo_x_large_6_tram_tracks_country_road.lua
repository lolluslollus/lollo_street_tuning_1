function data()
    return {
        numLanes = 6,
        transportModesStreet = {'CAR', 'BUS', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'}, -- with this, tram tracks appear on all lanes, not only on the right one
        streetWidth = 24.0,
        sidewalkWidth = 4.0,
        sidewalkHeight = .02,
        yearFrom = 1925,
        yearTo = 0,
        upgrade = true,
        country = true,
        speed = 100.0,
        type = "lollo_x_large_6_tram_tracks_country_road",
        name = _("Extra-large country road - 6 lanes - 6 tram tracks"),
        desc = _("Extra-large road with 6 lanes, each with a tram track. Speed limit is %2%."),
        categories = { "country" },
        materials = {
            streetPaving = {
                name = "street/country_new_medium_paving.mtl",
                size = { 8.0, 8.0 }
            },		
            streetBorder = {
                name = "street/country_new_large_border.mtl",
                size = { 24, 0.459 }		
            },			
            streetLane = {
                name = "street/new_medium_lane.mtl",
                size = { 3.0, 3.0 }
            },
            streetArrow = {
                name = "street/default_arrows.mtl",
                size = { 9.0, 3.0 }
            },
            streetStripe = {
                name = "street/country_new_medium_stripes.mtl",
                size = { 32.0, .5 }		
            },
            streetStripeMedian = {
                name = "street/country_new_large_median.mtl",
                size = { 4.0, .5 }		
            },
            streetTram = {
                name = "street/new_medium_tram_paving.mtl",
                size = { 2.0, 2.0 }
            },
            streetTramTrack = {
                name = "street/new_medium_tram_track.mtl",
                size = { 2.0, 2.0 }
            },
            streetBus = {
                name = "street/new_medium_bus.mtl",
                size = { 12, 2.7 }
            },
            crossingLane = {
                name = "street/new_medium_lane.mtl",
                size = { 3.0, 3.0 }
            },
            crossingBus = {
                name = "",
            },
            crossingTram = {
                name = "street/new_medium_tram_paving.mtl",
                size = { 2.0, 2.0 }
            },
            crossingTramTrack = {
                name = "street/new_medium_tram_track.mtl",
                size = { 2.0, 2.0 }
            },
            crossingCrosswalk = {
                name = ""		
            },
            sidewalkPaving = {
                name = ""		
            },
            sidewalkLane = {	
            },
            sidewalkBorderInner = {
                name = "street/country_new_large_sidewalk_border_inner.mtl",	
                size = { 9, 3.6 }
            },
            sidewalkBorderOuter = {
            },
            sidewalkCurb = {
            },
            sidewalkWall = {
            }	
        },
        assets = {	
        },
        borderGroundTex = "street_border.lua",
        sidewalkFillGroundTex = "country_sidewalk.lua",
        cost = 100.0,
    }
    end
    