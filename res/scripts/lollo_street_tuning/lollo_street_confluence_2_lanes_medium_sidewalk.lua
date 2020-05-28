local idTransf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
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

results.getLods = function()
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
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.26, 0, 0, 0, 0, .99, 0, 0, 0, 0, 1, 0, 0.0, 9.8, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.26, 0, 0, 0, 0, .99, 0, 0, 0, 0, 1, 0, 0.0, 4.9, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.26, 0, 0, 0, 0, .99, 0, 0, 0, 0, 1, 0, 0.0, 0, -.795, 1}
                    },
                    {
                        materials = {'street/country_new_medium_paving.mtl'},
                        mesh = 'station/rail/era_c/station_1_main/station_1_main_perron_lod0.msh',
                        transf = {.26, 0, 0, 0, 0, .99, 0, 0, 0, 0, 1, 0, 0.0, -4.9, -.795, 1}
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
                transf = {.8, 0, 0, 0, 0, .8, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
                -- transf = idTransf
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000
        }
    }
end

return results
