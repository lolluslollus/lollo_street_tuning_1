local idTransf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
local laneutil = require('laneutil')
local results = {}

results.getBoundingInfo = function()
    return {
        bbMax = {2, 8.0, 0.3},
        bbMin = {-2, -8.0, 0}
    }
end

results.getCollider = function()
    return {
        params = {
            halfExtents = {2, 8.0, 0.15}
        },
        transf = idTransf,
        type = 'BOX'
    }
end

results.getStreetLods = function()
    return {
        {
            node = {
                children = {
                    -- close the incoming thinner roads
                    -- {
                    --     --materials = {'station/road/streetstation/streetstation_perron_border.mtl', 'station/road/streetstation/streetstation_perron_base_new.mtl'},
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_spcl2_r_lod0.msh',
                    --     name = 'straight_spcl2_l',
                    --     transf = {0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, -2.5, 0, 1}
                    -- },
                    -- {
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_spcl2_r_lod0.msh',
                    --     name = 'straight_spcl2_r',
                    --     transf = {0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 2.5, 0, 1}
                    -- },
                    {
                        materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                        mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                        name = "pltfrm_r_top",
                        transf = { 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, -7.5, 0, 0, 1, },
                    },
                    -- straight bits
                    {
                        materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -7.5, 0, 1}
                    },
                    {
                        materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 7.5, 0, 1}
                    },
                    -- ground
                    -- {
                    --     materials = {'street/country_new_medium_paving.mtl'},
                    --     mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                    --     transf = {.26, 0, 0, 0, 0, .99, 0, 0, 0, 0, 1, 0, 0.0, 9.8, -.795, 1}
                    -- },
                    -- {
                    --     materials = {'street/country_new_medium_paving.mtl'},
                    --     mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                    --     transf = {.26, 0, 0, 0, 0, .99, 0, 0, 0, 0, 1, 0, 0.0, 4.9, -.795, 1}
                    -- },
                    -- {
                    --     materials = {'street/country_new_medium_paving.mtl'},
                    --     mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                    --     transf = {.26, 0, 0, 0, 0, .99, 0, 0, 0, 0, 1, 0, 0.0, 0, -.795, 1}
                    -- },
                    -- {
                    --     materials = {'street/country_new_medium_paving.mtl'},
                    --     mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                    --     transf = {.26, 0, 0, 0, 0, .99, 0, 0, 0, 0, 1, 0, 0.0, -4.9, -.795, 1}
                    -- },
                },
                transf = {.8, 0, 0, 0, 0, .8, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
                -- transf = idTransf
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000
        }
    }
end

results.getTransportNetworkProvider = function(isSidewalkRaised)
    local sidewalkHeight = isSidewalkRaised and 0.3 or 0.0
    return {
        laneLists = {
            -- vehicles
            laneutil.createLanes(
                {
                    curves = {
                        -- ['right_lane'] = {
                        --     -- right with | | below and || above
                        --     {{-2.00000, -4.00000, 0.00000}, {-1.00000, -3.900000, 0.00000}, {1.00000, -2.10000, 0.00000}, {2.00000, -2.00000, 0.00000}}
                        -- },
                        -- ['left_lane'] = {
                        --     -- left with | | below and || above
                        --     {{-2.00000, 4.00000, 0.00000}, {-1.00000, 3.900000, 0.00000}, {1.00000, 2.10000, 0.00000}, {2.00000, 2.00000, 0.00000}}
                        -- }
                        ['right_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, -4, 0.00000}, {-1.8, -4, 0.00000}}
                        },
                        ['right_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, -3, 0.00000}, {2, -3, 0.00000}}
                        },
                        ['left_lane_one'] = {
                            -- left with | | below and || above
                            {{-2, 4, 0.00000}, {-1.8, 4.00000, 0.00000}}
                        },
                        ['left_lane_two'] = {
                            -- left with | | below and || above
                            {{1.8, 3, 0.00000}, {2, 3.00000, 0.00000}}
                        }
                    }
                },
                {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'},
                100,
                3,
                false --linkable
            ),
            -- pedestrians
            laneutil.createLanes(
                {
                    curves = {
                        -- ['right_lane'] = {
                        --     -- right with | | below and || above
                        --     {{10.00000, -6.00000, sidewalkHeight}, {2.00000, -6.00000, sidewalkHeight}, {-2.00000, -7.00000, sidewalkHeight}, {-6.00000, -7.00000, sidewalkHeight}}
                        -- },
                        ['shorter_right_lane'] = {
                            -- right with | | below and || above
                            {{6.00000, -7.00000, sidewalkHeight}, {2.00000, -7.00000, sidewalkHeight}, {-2.00000, -7.00000, sidewalkHeight}}
                        },
                        -- ['left_lane'] = { -- left with | | below and || above
                        --     {{10.00000, 6.00000, sidewalkHeight}, {2.00000, 6.00000, sidewalkHeight}, {-2.00000, 7.00000, sidewalkHeight}, {-6.00000, 7.00000, sidewalkHeight}}
                        -- }
                        ['shorter_left_lane'] = {
                            -- left with | | below and || above
                            {{6.00000, 7.00000, sidewalkHeight}, {2.00000, 7.00000, sidewalkHeight}, {-2.00000, 7.00000, sidewalkHeight}}
                        }
                    }
                },
                {'PERSON'},
                20,
                3,
                true --linkable
            )
        },
        runways = {},
        terminals = {}
    }
end

return results
