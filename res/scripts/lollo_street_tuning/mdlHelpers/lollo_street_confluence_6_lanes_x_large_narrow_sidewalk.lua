local idTransf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
local laneutil = require('laneutil')
local results = {}

results.getBoundingInfo = function()
    return {
        bbMax = {2, 16.0, 0.3},
        bbMin = {-2, -16.0, 0}
    }
end

results.getCollider = function()
    return {
        params = {
            halfExtents = {2, 16.0, 0.15}
        },
        transf = idTransf,
        type = 'BOX'
    }
end

results.getCountryRoadLods = function()
    return {
        {
            node = {
                children = {},
                transf = idTransf
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000
        }
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
                    --     transf = { 0, 0.32, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0, -6.2, -8, 0, 1, },
                    -- },
                    -- {
                    --     materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                    --     mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                    --     name = "pltfrm_r_top",
                    --     transf = { 0, 0.32, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0, -6.2, -4, 0, 1, },
                    -- },
                    -- {
                    --     materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                    --     mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                    --     name = "pltfrm_r_top",
                    --     transf = { 0, 0.32, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0, -6.2, 0, 0, 1, },
                    -- },
                    -- {
                    --     materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                    --     mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                    --     name = "pltfrm_r_top",
                    --     transf = { 0, 0.32, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0, -6.2, 4, 0, 1, },
                    -- },
                    -- {
                    --     materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                    --     mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                    --     name = "pltfrm_r_top",
                    --     transf = { 0, 0.32, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0, -6.2, 8, 0, 1, },
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
                        transf = {0.8, 0, 0, 0, 0, 0.8, 0, 0, 0, 0, 1, 0, -2.0, 16, 0, 1}
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
                        transf = {0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 1, 0, -2.0, -16, 0, 1}
                    },
                    -- ground
                    {
                        materials = { 'street/merge/country_new_medium_paving_low_prio.mtl'},
                        mesh = 'lollo_street_tuning/merge/square_16x5.msh',
                        transf = {1, 0, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1}
                    },
                    -- -- bevel the pavement inside
                    -- {
                    --     --materials = {'station/road/streetstation/streetstation_perron_border.mtl', 'station/road/streetstation/streetstation_perron_base_new.mtl'},
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_spcl2_r_lod0.msh',
                    --     -- mesh = "station/road/streetstation/pedestrian_era_c/corner_out_lod0.msh",
                    --     name = 'straight_spcl2_l',
                    --     transf = {-0.32, 0, 0, 0, 0, 0.32, 0, 0, 0, 0, 1, 0, -1.2, -11.2, 0, 1}
                    -- },
                    -- {
                    --     --materials = {'station/road/streetstation/streetstation_perron_border.mtl', 'station/road/streetstation/streetstation_perron_base_new.mtl'},
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_spcl2_r_lod0.msh',
                    --     -- mesh = "station/road/streetstation/pedestrian_era_c/corner_out_lod0.msh",
                    --     name = 'straight_spcl2_l',
                    --     transf = {-0.32, 0, 0, 0, 0, -0.32, 0, 0, 0, 0, 1, 0, -1.2, 11.2, 0, 1}
                    -- },
                },
                transf = idTransf
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
                        ['right_lane_one'] = {
                            {{-2, -10, 0.00000}, {-1.8, -10, 0.00000}}
                        },
                        ['right_lane_two'] = {
                            {{1.8, -10, 0.00000}, {2, -10, 0.00000}}
                        },
                        ['centre_right_lane_one'] = {
                            {{-2, -6, 0.00000}, {-1.8, -6, 0.00000}}
                        },
                        ['centre_right_lane_two'] = {
                            {{1.8, -6, 0.00000}, {2, -6, 0.00000}}
                        },
                        ['inner_centre_right_lane_one'] = {
                            {{-2.0, -2, 0.00000}, {-1.8, -2, 0.00000}}
                        },
                        ['inner_centre_right_lane_two'] = {
                            {{1.8, -2.0, 0.00000}, {2, -2, 0.00000}}
                        },
                        ['inner_centre_left_lane_one'] = {
                            {{-1.8, 2, 0.00000}, {-2, 2, 0.00000}}
                        },
                        ['inner_centre_left_lane_two'] = {
                            {{2, 2.0, 0.00000}, {1.8, 2, 0.00000}}
                        },
                        ['centre_left_lane_one'] = {
                            {{-1.8, 6, 0.00000}, {-2, 6, 0.00000}}
                        },
                        ['centre_left_lane_two'] = {
                            {{2, 6, 0.00000}, {1.8, 6, 0.00000}}
                        },
                        ['left_lane_one'] = {
                            {{-1.8, 10, 0.00000}, {-2, 10, 0.00000}}
                        },
                        ['left_lane_two'] = {
                            {{2, 10, 0.00000}, {1.8, 10, 0.00000}}
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
                            {{2.00000, -14.00000, sidewalkHeight}, {-2.00000, -14.00000, sidewalkHeight}}
                        },
                        ['shorter_left_lane'] = {
                            -- left with | | below and || above
                            {{2.00000, 14.00000, sidewalkHeight}, {-2.00000, 14.00000, sidewalkHeight}}
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
