function data()
    return {
        numLanes = 2,
        sidewalkWidth = 0.0,
        sidewalkHeight = .0,
        streetWidth = 0.1,
        yearFrom = 65535, -- LOLLO NOTE this bars the street from the street menu
        yearTo = 0,
        upgrade = false,
        country = false,
        speed = 100.0,
        type = 'lollo_ultrathin_street',
        --name = _("Lollo ultrathin street"),
        --desc = _("Ultrathin street with a speed limit of %2%."),
        --categories = { "urban" },
        categories = {},
        borderGroundTex = 'street_border.lua',
        materials = {
            streetPaving = {
                name = 'street/country_new_medium_paving.mtl',
                size = {8.0, 8.0}
            },
            streetBorder = {
                -- name = 'street/new_medium_border.mtl',
                -- size = {2.0, .3}
            },
            streetLane = {
                -- name = 'street/new_medium_lane.mtl',
                -- size = {4.0, 4.0}
            },
            streetStripe = {},
            streetStripeMedian = {
                -- name = 'street/new_medium_stripes.mtl',
                -- size = {8.0, .5}
            },
            streetTram = {
                -- name = 'street/new_medium_tram_paving.mtl',
                -- size = {2.0, 2.0}
            },
            streetTramTrack = {
                -- name = 'street/new_medium_tram_track.mtl',
                -- size = {2.0, 2.0}
            },
            streetBus = {
                -- name = 'street/new_medium_bus.mtl',
                -- size = {12, 2.7}
            },
            crossingLane = {
                -- name = 'street/new_medium_lane.mtl',
                -- size = {4.0, 4.0}
            },
            crossingBus = {
                -- name = ''
            },
            crossingTram = {
                -- name = 'street/new_medium_tram_paving.mtl',
                -- size = {2.0, 2.0}
            },
            crossingTramTrack = {
                -- name = 'street/new_medium_tram_track.mtl',
                -- size = {2.0, 2.0}
            },
            crossingCrosswalk = {
                -- name = 'street/new_medium_crosswalk.mtl',
                -- size = {3.0, 2.5}
            },
            crossingStopline = {
                -- name = 'street/new_medium_stopline.mtl',
                -- size = {6.0, .5}
            },
            sidewalkPaving = {
                -- name = 'street/new_medium_sidewalk.mtl',
                -- size = {4.0, 4.0}
            },
            sidewalkLane = {},
            sidewalkBorderInner = {
                -- name = 'street/new_medium_sidewalk_border_inner.mtl',
                -- size = {3, 0.6}
            },
            sidewalkBorderOuter = {
                -- name = 'street/new_medium_sidewalk_border_outer.mtl',
                -- size = {8.0, 0.41602}
            },
            sidewalkCurb = {
                -- name = 'street/new_medium_sidewalk_curb.mtl',
                -- size = {3, .35}
            },
            sidewalkWall = {
                -- name = 'street/new_medium_sidewalk_wall.mtl',
                -- size = {8.0, 0.41602}
            }
        },
        materials = {},
        assets = {},
        cost = 0.0
    }
end
