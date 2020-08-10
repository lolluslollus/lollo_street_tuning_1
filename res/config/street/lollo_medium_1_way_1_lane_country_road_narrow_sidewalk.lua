function data()
    return {
        laneConfig = {
            {forward = true},
            {forward = true},
            {forward = true}
        },
        streetWidth = 2.4, -- was 3
        sidewalkWidth = 0.8, -- was 0.5; 2 * sidewalkWidth + streetWidth must be 4
        sidewalkHeight = .0,
        yearFrom = 1925,
        yearTo = 0,
        upgrade = false,
        country = true,
        speed = 80.0,
        type = 'lollo_medium_1_way_1_lane_country_road_narrow_sidewalk.lua',
        name = _('Narrow one-way road - 1 lane - .8 m shoulder'),
        desc = _('Narrow one-way road with 1 lane and extra narrow shoulder. Speed limit is %2%.'),
        categories = {'highway'},
        borderGroundTex = 'street_border.lua',
        materials = {
            streetPaving = {
                name = "street/country_new_medium_paving.mtl",
                size = { 8.0, 8.0 }
            },		
            streetBorder = {
                name = "street/country_new_small_street_border.mtl",		
                size = { 9.0, 0.56 }		
            },			
            streetLane = {
                name = "street/country_new_medium_lane.mtl",
                size = { 2.5, 2.5 }
            },
            streetStripe = {
    
            },
            streetStripeMedian = {
    
            },
            streetBus = {
            
            },
            streetTram = {
                name = "street/new_medium_tram_paving.mtl",
                size = { 2.0, 2.0 }
            },
            streetTramTrack = {
                name = "street/new_medium_tram_track.mtl",
                size = { 2.0, 2.0 }
            },
            junctionBorder = {
                name = "street/country_new_small_street_border.mtl",		
                size = { 9.0, 0.56 }		
            },
            crossingLane = {
                name = "street/country_new_medium_lane.mtl",
                size = { 2.5, 2.5 }
            },
            crossingBus = {
                name = ""		
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
            },
            sidewalkBorderOuter = {
            },
            sidewalkCurb = {
            },
            sidewalkWall = {
            }	
        },
        assets = {},
        signalAssetName = 'asset/ampel.mdl',
        cost = 25.0
    }
end
