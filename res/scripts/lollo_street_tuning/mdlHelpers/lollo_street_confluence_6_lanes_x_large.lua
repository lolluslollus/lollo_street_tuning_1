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
                children = {
                    -- LOLLO TODO maybe make some new dds with the white stripe
                    -- -- close the incoming thinner roads
                    -- {
                    --     materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                    --     mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                    --     name = "pltfrm_r_top",
                    --     transf = { 0, 0.8, 0, 0, 0.8, 0, 0, 0, 0, 0, 0.1, 0, -6, -2, 0, 1, },
                    -- },
                    -- {
                    --     materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                    --     mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                    --     name = "pltfrm_r_top",
                    --     transf = { 0, 0.8, 0, 0, 0.8, 0, 0, 0, 0, 0, 0.1, 0, -6, 2, 0, 1, },
                    -- },
                    -- -- straight bits
                    -- {
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                    --     transf = {0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 0.1, 0, 0, -16, 0, 1}
                    -- },
                    -- {
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                    --     transf = {0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 0.1, 0, 0, -14, 0, 1}
                    -- },
                    -- {
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                    --     transf = {0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 0.1, 0, 0, 12, 0, 1}
                    -- },
                    -- {
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                    --     transf = {0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 0.1, 0, 0, 14, 0, 1}
                    -- },
                    -- ground
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, 11.9, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, 10.0, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, 5.0, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, 0, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, -5, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, -6.9, -.795, 1}
                    },
                },
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
                    -- close the incoming thinner roads
                    {
                        materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                        mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                        name = "pltfrm_r_top",
                        transf = { 0, 0.8, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0, -6, -2, 0, 1, },
                    },
                    {
                        materials = { "street/new_medium_sidewalk_border_inner.mtl", "street/new_medium_sidewalk.mtl", },
                        mesh = "station/road/streetstation/era_c/pltfrm_r_top_lod0.msh",
                        name = "pltfrm_r_top",
                        transf = { 0, 0.8, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0, -6, 2, 0, 1, },
                    },
                    -- -- join
                    -- {
                    --     -- materials = { "station/road/streetstation/streetstation_perron_border.mtl", "station/road/streetstation/streetstation_perron_base_new.mtl", },
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = "station/road/streetstation/era_c/pltfrm_l_top_spcl_lod0.msh",
                    --     name = "pltfrm_l_top_spcl",
                    --     transf = { 0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 7.5, -17.5, 0, 1, },
                    -- },
                    -- {
                    --     -- materials = { "station/road/streetstation/streetstation_perron_border.mtl", "station/road/streetstation/streetstation_perron_base_new.mtl", },
                    --     materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                    --     mesh = "station/road/streetstation/era_c/pltfrm_l_top_spcl_lod0.msh",
                    --     name = "pltfrm_l_top_spcl",
                    --     transf = { 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 7.5, 17.5, 0, 1, },
                    -- },
                    -- straight bits
                    {
                        materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 1, 0, 0, -16, 0, 1}
                    },
                    {
                        materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 1, 0, 0, -14, 0, 1}
                    },
                    {
                        materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 1, 0, 0, 12, 0, 1}
                    },
                    {
                        materials = {'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl'},
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 1, 0, 0, 14, 0, 1}
                    },
                    -- ground
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, 16, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, 15.0, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, 10.0, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, 5.0, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, 0, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, -5, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, -10, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, -11, -.795, 1}
                    },
                    -- straight tram tracks to plaster the gaps
                    -- {
                    --     materials = { "station/station_tram_small_new_track_1.mtl", },
                    --     mesh = "station/road/streetstation/lod_0_tram_rail_extend_left.msh",
                    --     transf = { .1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1.8, 5, 0, 1, },
                    -- },
                    -- {
                    --     materials = { "station/station_tram_small_new_track_1.mtl", },
                    --     mesh = "station/road/streetstation/lod_0_tram_rail_extend_left.msh",
                    --     transf = { .1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1.8, 0, 0, 1, },
                    -- },
                    -- {
                    --     materials = { "station/station_tram_small_new_track_1.mtl", },
                    --     mesh = "station/road/streetstation/lod_0_tram_rail_extend_left.msh",
                    --     transf = { .05, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -3, 7.5, 0, 1, },
                    -- },
                    -- {
                    --     materials = { "station/station_tram_small_new_track_1.mtl", },
                    --     mesh = "station/road/streetstation/lod_0_tram_rail_extend_left.msh",
                    --     transf = { .05, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -3, -2.5, 0, 1, },
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

results.getTransportNetworkProvider = function()
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
                            {{-2, -10, 0.00000}, {-1.8, -10, 0.00000}}
                        },
                        ['right_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, -10, 0.00000}, {2, -10, 0.00000}}
                        },
                        ['centre_right_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, -6, 0.00000}, {-1.8, -6, 0.00000}}
                        },
                        ['centre_right_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, -6, 0.00000}, {2, -6, 0.00000}}
                        },
                        ['inner_centre_right_lane'] = {
                            -- right with | | below and || above
                            {{-2.0, -6.0, 0.00000}, {-1.8, -5.95, 0.00000}, {1.8, -2.05, 0.00000}, {2.0, -2.0, 0.00000}}
                        },
                        ['inner_centre_left_lane'] = {
                            -- right with | | below and || above
                            {{-2.0, 6.0, 0.00000}, {-1.8, 5.95, 0.00000}, {1.8, 2.05, 0.00000}, {2.0, 2.0, 0.00000}}
                        },
                        ['centre_left_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, 6, 0.00000}, {-1.8, 6, 0.00000}}
                        },
                        ['centre_left_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, 6, 0.00000}, {2, 6, 0.00000}}
                        },
                        ['left_lane_one'] = {
                            -- left with | | below and || above
                            {{-2, 10, 0.00000}, {-1.8, 10.00000, 0.00000}}
                        },
                        ['left_lane_two'] = {
                            -- left with | | below and || above
                            {{1.8, 10, 0.00000}, {2, 10, 0.00000}}
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
                        -- ['right_lane'] = {
                        --     -- right with | | below and || above
                        --     {{10.00000, -6.00000, 0.30000}, {2.00000, -6.00000, 0.30000}, {-2.00000, -7.00000, 0.30000}, {-6.00000, -7.00000, 0.30000}}
                        -- },
                        ['shorter_right_lane'] = {
                            -- right with | | below and || above
                            {{2.00000, -14.00000, 0.30000}, {-2.00000, -14.00000, 0.30000}}
                        },
                        -- ['left_lane'] = { -- left with | | below and || above
                        --     {{10.00000, 6.00000, 0.30000}, {2.00000, 6.00000, 0.30000}, {-2.00000, 7.00000, 0.30000}, {-6.00000, 7.00000, 0.30000}}
                        -- }
                        ['shorter_left_lane'] = {
                            -- left with | | below and || above
                            {{2.00000, 14.00000, 0.30000}, {-2.00000, 14.00000, 0.30000}}
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

results.getTransportNetworkProvider_AllowReversal = function()
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
                        ['reversal_inner'] = {
                            -- right with | | below and || above
                            {{-2, -6, 0.00000}, {6, 0, 0.00000}, {-2, 6, 0.00000}}
                        },
                        ['right_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, -10, 0.00000}, {-1.8, -10, 0.00000}}
                        },
                        ['right_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, -10, 0.00000}, {2, -10, 0.00000}}
                        },
                        ['centre_right_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, -6, 0.00000}, {-1.8, -6, 0.00000}}
                        },
                        ['centre_right_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, -6, 0.00000}, {2, -6, 0.00000}}
                        },
                        ['inner_centre_right_lane'] = {
                            -- right with | | below and || above
                            {{-2.0, -6.0, 0.00000}, {-1.8, -5.95, 0.00000}, {1.8, -2.05, 0.00000}, {2.0, -2.0, 0.00000}}
                        },
                        ['inner_centre_left_lane'] = {
                            -- right with | | below and || above
                            {{-2.0, 6.0, 0.00000}, {-1.8, 5.95, 0.00000}, {1.8, 2.05, 0.00000}, {2.0, 2.0, 0.00000}}
                        },
                        ['centre_left_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, 6, 0.00000}, {-1.8, 6, 0.00000}}
                        },
                        ['centre_left_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, 6, 0.00000}, {2, 6, 0.00000}}
                        },
                        ['left_lane_one'] = {
                            -- left with | | below and || above
                            {{-2, 10, 0.00000}, {-1.8, 10.00000, 0.00000}}
                        },
                        ['left_lane_two'] = {
                            -- left with | | below and || above
                            {{1.8, 10, 0.00000}, {2, 10, 0.00000}}
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
                        -- ['right_lane'] = {
                        --     -- right with | | below and || above
                        --     {{10.00000, -6.00000, 0.30000}, {2.00000, -6.00000, 0.30000}, {-2.00000, -7.00000, 0.30000}, {-6.00000, -7.00000, 0.30000}}
                        -- },
                        ['shorter_right_lane'] = {
                            -- right with | | below and || above
                            {{2.00000, -14.00000, 0.30000}, {-2.00000, -14.00000, 0.30000}}
                        },
                        -- ['left_lane'] = { -- left with | | below and || above
                        --     {{10.00000, 6.00000, 0.30000}, {2.00000, 6.00000, 0.30000}, {-2.00000, 7.00000, 0.30000}, {-6.00000, 7.00000, 0.30000}}
                        -- }
                        ['shorter_left_lane'] = {
                            -- left with | | below and || above
                            {{2.00000, 14.00000, 0.30000}, {-2.00000, 14.00000, 0.30000}}
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