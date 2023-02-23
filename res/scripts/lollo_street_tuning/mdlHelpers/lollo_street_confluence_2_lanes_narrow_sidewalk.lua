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
                    -- -- close the incoming thinner roads
                    -- {
                    --     materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                    --     mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                    --     name = "pltfrm_r_top",
                    --     transf = { 0, .40, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, -7.5, 0, 0, 1, },
                    -- },
                    -- bevel the pavement outside
                    -- left
                    {
                        materials = {
                            'street/new_medium_sidewalk_border_inner.mtl',
                            'street/new_medium_sidewalk.mtl',
                            'street/new_medium_sidewalk_border_inner.mtl',
                        },
                        mesh = 'lollo_street_tuning/merge/straight_spcl_r_5_lod0.msh',
                        name = 'straight_spcl2_l',
                        transf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2.5, 10, 0, 1}
                    },
                    -- right
                    {
                        materials = {
                            'street/new_medium_sidewalk_border_inner.mtl',
                            'street/new_medium_sidewalk.mtl',
                            'street/new_medium_sidewalk_border_inner.mtl',
                        },
                        mesh = 'lollo_street_tuning/merge/straight_spcl_r_5_lod0.msh',
                        name = 'straight_spcl2_l',
                        transf = {1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, -2.5, -10, 0, 1}
                    },
                    -- ground
                    {
                        materials = { 'street/merge/country_new_medium_paving_low_prio.mtl'},
                        mesh = 'lollo_street_tuning/merge/square_16x5.msh',
                        transf = {1, 0, 0, 0,  0, 0.625, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1}
                    },
                    -- -- bevel the pavement inside
                    -- {
                    --     --materials = {'station/road/streetstation/streetstation_perron_border.mtl', 'station/road/streetstation/streetstation_perron_base_new.mtl'},
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_spcl2_r_lod0.msh',
                    --     -- mesh = "station/road/streetstation/pedestrian_era_c/corner_out_lod0.msh",
                    --     name = 'straight_spcl2_l',
                    --     transf = {-0.4, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 1, 0, -1.6, -4, 0, 1}
                    -- },
                    -- {
                    --     --materials = {'station/road/streetstation/streetstation_perron_border.mtl', 'station/road/streetstation/streetstation_perron_base_new.mtl'},
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_spcl2_r_lod0.msh',
                    --     -- mesh = "station/road/streetstation/pedestrian_era_c/corner_out_lod0.msh",
                    --     name = 'straight_spcl2_l',
                    --     transf = {-0.4, 0, 0, 0, 0, -0.4, 0, 0, 0, 0, 1, 0, -1.6, 4, 0, 1}
                    -- },
                },
                transf = {.8, 0, 0, 0, 0, .8, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000
        }
    }
end

results.getCountryRoadLods = function()
    return {
        {
            node = {
                children = {
                    -- ground
                    {
                        materials = { 'street/merge/country_new_medium_paving_low_prio.mtl'},
                        mesh = 'lollo_street_tuning/merge/square_16x5.msh',
                        transf = {1, 0, 0, 0,  0, 0.625, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1}
                    },
                },
                transf = {.8, 0, 0, 0, 0, .8, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
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
                            {{-2, -2, 0}, {-1.8, -2, 0}}
                        },
                        ['right_lane_two'] = {
                            {{1.8, -2, 0}, {2, -2, 0}}
                        },
                        ['left_lane_one'] = {
                            {{-2, 2, 0}, {-1.8, 2, 0}}
                        },
                        ['left_lane_two'] = {
                            {{1.8, 2, 0}, {2, 2, 0}}
                        }
                    }
                },
                {'BUS', 'CAR', 'ELECTRIC_TRAM', 'TRAM', 'TRUCK'},
                100,
                3,
                false --linkable
            ) or laneutil.createLanes(
                {
                    curves = {
                        ['right_lane_one'] = {
                            {{-2, -2, 0}, {-1.8, -2, 0}}
                        },
                        ['right_lane_two'] = {
                            {{1.8, -2, 0}, {2, -2, 0}}
                        },
                        ['left_lane_one'] = {
                            {{-1.8, 2, 0}, {-2, 2, 0}}
                        },
                        ['left_lane_two'] = {
                            {{2, 2, 0}, {1.8, 2, 0}}
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
                        ['shorter_right_lane'] = {
                            {{2.00000, -6.00000, sidewalkHeight}, {-2.00000, -3.60000, sidewalkHeight}}
                        },
                        ['shorter_left_lane'] = {
                            {{2.00000, 6.00000, sidewalkHeight}, {-2.00000, 3.60000, sidewalkHeight}}
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
