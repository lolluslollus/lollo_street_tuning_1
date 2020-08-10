local idTransf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
local laneutil = require('laneutil')
local results = {}

results.getBoundingInfo = function()
    return {
        bbMax = {2, 12.0, 0.3},
        bbMin = {-2, -12.0, 0}
    }
end

results.getCollider = function()
    return {
        params = {
            halfExtents = {2, 12.0, 0.15}
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
                    -- ground
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, 7.9, -.795, 1}
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
                        transf = {.22, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1, 0, 0, -2.9, -.795, 1}
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

results.getTransportNetworkProvider = function()
    return {
        laneLists = {
            -- vehicles
            laneutil.createLanes(
                {
                    curves = {
                        ['right_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, -6, 0.00000}, {-1.8, -6, 0.00000}}
                        },
                        ['right_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, -6, 0.00000}, {2, -6, 0.00000}}
                        },
                        ['centre_right_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, -2, 0.00000}, {-1.8, -2, 0.00000}}
                        },
                        ['centre_right_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, -2, 0.00000}, {2, -2, 0.00000}}
                        },
                        ['centre_left_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, 2, 0.00000}, {-1.8, 2, 0.00000}}
                        },
                        ['centre_left_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, 2, 0.00000}, {2, 2, 0.00000}}
                        },
                        ['left_lane_one'] = {
                            -- left with | | below and || above
                            {{-2, 6, 0.00000}, {-1.8, 6.00000, 0.00000}}
                        },
                        ['left_lane_two'] = {
                            -- left with | | below and || above
                            {{1.8, 6, 0.00000}, {2, 6, 0.00000}}
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
                            {{2.00000, -10.00000, 0.30000}, {-2.00000, -10.00000, 0.30000}}
                        },
                        ['shorter_left_lane'] = {
                            -- left with | | below and || above
                            {{2.00000, 10.00000, 0.30000}, {-2.00000, 10.00000, 0.30000}}
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
                        -- ['reversal_inner'] = {
                        --     -- right with | | below and || above
                        --     {{-2, -6, 0.00000}, {6, 0, 0.00000}, {-2, 6, 0.00000}}
                        -- },
                        ['right_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, -6, 0.00000}, {-1.8, -6, 0.00000}}
                        },
                        ['right_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, -6, 0.00000}, {2, -6, 0.00000}}
                        },
                        ['centre_right_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, -2, 0.00000}, {-1.8, -2, 0.00000}}
                        },
                        ['centre_right_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, -2, 0.00000}, {2, -2, 0.00000}}
                        },
                        ['centre_left_lane_one'] = {
                            -- right with | | below and || above
                            {{-2, 2, 0.00000}, {-1.8, 2, 0.00000}}
                        },
                        ['centre_left_lane_two'] = {
                            -- right with | | below and || above
                            {{1.8, 2, 0.00000}, {2, 2, 0.00000}}
                        },
                        ['left_lane_one'] = {
                            -- left with | | below and || above
                            {{-2, 6, 0.00000}, {-1.8, 6.00000, 0.00000}}
                        },
                        ['left_lane_two'] = {
                            -- left with | | below and || above
                            {{1.8, 6, 0.00000}, {2, 6, 0.00000}}
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
                            {{2.00000, -10.00000, 0.30000}, {-2.00000, -10.00000, 0.30000}}
                        },
                        ['shorter_left_lane'] = {
                            -- left with | | below and || above
                            {{2.00000, 10.00000, 0.30000}, {-2.00000, 10.00000, 0.30000}}
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
