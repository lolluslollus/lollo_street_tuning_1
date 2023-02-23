local idTransf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
local laneutil = require('laneutil')
local results = {}

results.getBoundingInfo = function()
    return {
        bbMax = {2, 8.0, 0.3},
        bbMin = {-6, -8.0, 0}
    }
end

results.getCollider = function()
    return {
        params = {
            halfExtents = {4, 8.0, 0.15}
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
                    -- -- close the incoming thinner roads
                    -- {
                    --     materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                    --     mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                    --     name = "pltfrm_r_top",
                    --     transf = { 0, 0.4, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, -12.6, -5, 0, 1, },
                    -- },
                    -- {
                    --     materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                    --     mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                    --     name = "pltfrm_r_top",
                    --     transf = { 0, 0.4, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, -12.6, 0, 0, 1, },
                    -- },
                    -- {
                    --     materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                    --     mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                    --     name = "pltfrm_r_top",
                    --     transf = { 0, 0.4, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, -12.6, 5, 0, 1, },
                    -- },
                    -- -- straight bits
                    -- -- right
                    -- {
                    --     --materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                    --     transf = {1.6, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 1, 0, -3.75, -9, 0, 1}
                    -- },
                    -- -- left
                    -- {
                    --     --materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                    --     transf = {1.6, 0, 0, 0, 0, -0.4, 0, 0, 0, 0, 1, 0, -3.75, 9, 0, 1}
                    -- },
                    -- bevel the pavement outside
                    {
                        --materials = {'station/road/streetstation/streetstation_perron_border.mtl', 'station/road/streetstation/streetstation_perron_base_new.mtl'},
                        materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_spcl2_r_lod0.msh',
                        name = 'straight_spcl2_l',
                        transf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -7.5, 0, 1}
                    },
                    {
                        --materials = {'station/road/streetstation/streetstation_perron_border.mtl', 'station/road/streetstation/streetstation_perron_base_new.mtl'},
                        materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_spcl2_l_lod0.msh',
                        name = 'straight_spcl2_l',
                        transf = {-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 7.5, 0, 1}
                    },
                    -- ground
                    {
                        materials = { 'street/merge/country_new_medium_paving_low_prio.mtl'},
                        mesh = 'lollo_street_tuning/merge/square_16x5.msh',
                        transf = {1, 0, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1}
                    },
                },
                transf = {.8, 0, 0, 0, 0, .8, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
                -- transf = idTransf
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000
        }
    }
end

results.getTransportNetworkProvider = function(isOneWay, isSidewalkRaised)
    local sidewalkHeight = isSidewalkRaised and 0.3 or 0.0
    return {
        laneLists = {
            -- vehicles
            isOneWay and laneutil.createLanes(
                {
                    curves = {
                        ['right_lane_one'] = {
                            {{-6, -6, 0}, {-5.8, -6, 0}}
                        },
                        ['right_lane_two'] = {
                            {{1.8, -4.5, 0}, {2, -4.5, 0}}
                        },
                        ['centre_right_lane_one'] = {
                            {{-6, -2, 0}, {-5.8, -2, 0}}
                        },
                        ['centre_right_lane_two'] = {
                            {{1.8, -1.5, 0}, {2, -1.5, 0}}
                        },

                        ['centre_left_lane_one'] = {
                            {{1.8, 1.5, 0}, {2, 1.5, 0}}
                        },
                        ['centre_left_lane_two'] = {
                            {{-6, 2, 0}, {-5.8, 2, 0}}
                        },
                        ['left_lane_one'] = {
                            {{1.8, 4.5, 0}, {2, 4.5, 0}}
                        },
                        ['left_lane_two'] = {
                            {{-6, 6, 0}, {-5.8, 6, 0}}
                        }
                    }
                },
                {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'},
                100,
                3.0,
                false --linkable
            ) or laneutil.createLanes(
                {
                    curves = {
                        -- ['reversal_inner'] = {
                        --     {{-6, -2, 0}, {1, 0, 0}, {-6, 2, 0}}
                        -- },
                        -- ['reversal_outer'] = {
                        --     {{-6, -6, 0}, {6, 0, 0}, {-6, 6, 0}}
                        -- },
                        ['right_lane_one'] = {
                            {{-6, -6, 0}, {-5.8, -6, 0}}
                        },
                        ['right_lane_two'] = {
                            {{1.8, -4.5, 0}, {2, -4.5, 0}}
                        },
                        ['centre_right_lane_one'] = {
                            {{-6, -2, 0}, {-5.8, -2, 0}}
                        },
                        ['centre_right_lane_two'] = {
                            {{1.8, -1.5, 0}, {2, -1.5, 0}}
                        },

                        ['centre_left_lane_one'] = {
                            {{2, 1.5, 0}, {1.8, 1.5, 0}}
                        },
                        ['centre_left_lane_two'] = {
                            {{-5.8, 2, 0}, {-6, 2, 0}}
                        },
                        ['left_lane_one'] = {
                            {{2, 4.5, 0}, {1.8, 4.5, 0}}
                        },
                        ['left_lane_two'] = {
                            {{-5.8, 6, 0}, {-6, 6, 0}}
                        }
                    }
                },
                {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'},
                100,
                3.0,
                false --linkable
            ),
            -- pedestrians
            laneutil.createLanes(
                {
                    curves = {
                        ['shorter_right_lane'] = {
                            -- right with | | below and || above
                            {{6.00000, -7.00000, sidewalkHeight}, {2.00000, -7.00000, sidewalkHeight}, {-6.00000, -7.60000, sidewalkHeight}}
                        },
                        ['shorter_left_lane'] = {
                            -- left with | | below and || above
                            {{6.00000, 7.00000, sidewalkHeight}, {2.00000, 7.00000, sidewalkHeight}, {-6.00000, 7.60000, sidewalkHeight}}
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
