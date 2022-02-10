local bridgeutilUG = require 'bridgeutil'

local _lod0_skinMaterials_era_c_rep = {
	'lollo_street_tuning/asphalt_low_prio_skinned.mtl',
	'lollo_street_tuning/asphalt_low_prio_skinned.mtl',
}
local _lod0_skinMaterials_era_c_side = {
	'lollo_street_tuning/asphalt_low_prio_skinned.mtl',
	'lollo_street_tuning/asphalt_low_prio_skinned.mtl',
	'lollo_street_tuning/asphalt_low_prio_skinned.mtl',
}
local _lod0_skinMaterials_era_c_side_no_railing = {
	'lollo_street_tuning/asphalt_low_prio_skinned.mtl',
	'lollo_street_tuning/asphalt_low_prio_skinned.mtl',
}
local _lod1_materials_era_c = {
	'lollo_street_tuning/asphalt_low_prio.mtl',
}

local function getDynamicProps()
	local _lod0_skinMaterials_rep = {}
	local _lod0_skinMaterials_side = {}
	local _lod0_skinMaterials_side_no_railing = {}
	local _lod1_materials = {}
	_lod0_skinMaterials_rep = _lod0_skinMaterials_era_c_rep
	_lod0_skinMaterials_side = _lod0_skinMaterials_era_c_side
	_lod0_skinMaterials_side_no_railing = _lod0_skinMaterials_era_c_side_no_railing
	_lod1_materials = _lod1_materials_era_c

	return _lod0_skinMaterials_rep, _lod0_skinMaterials_side, _lod0_skinMaterials_side_no_railing, _lod1_materials
end

local funcs = {
	getData4Basic = function()
		local _pillarLength = 1

		local pillarDir = 'bridge/lollo_street_tuning/cement_pillars/'
		local railingDir = 'bridge/lollo_street_tuning/pedestrian_basic/era_c_'
		local stockDir = 'bridge/cement/'

		-- LOLLO NOTE bridgeutil receives a list of models of bridge parts, each with its bounding box,
		-- and a list of lanes and offsets,
		-- then places them together depending on this information.
		-- The bounding boxes explain why bridges have a less flexible file structure.

		-- One problem is, platform-tracks < 5 m don't work well on stock bridges.
		-- Either we rewrite the whole thing, or we adjust something and use the automatisms
		-- => number two.
		-- My dedicated *_rep_* models have a mesh and bounding box 0.5 m wide instead of 4.
		-- This applies to railing and pillars.
		-- bridgeutil uses more instances if required, stacked sideways;
		-- otherwise, only one, and it is narrow enough for anything.
		-- This allows for bridges under 2.5 m platform-tracks and narrow paths;
		-- Sadly, any sorts of sides won't work with 2.5 m platforms
		-- coz bridgeutil assumes tracks are 5 m wide (UG TODO the lane data is manky).

		-- Skins and bones help bridges look better, they look segmented without them.
		-- Blender 2.79 has them and they work with the old converter; they are done with vertex groups.
		-- Use the weight painting, then the gradient tool on every vertex group.
		-- Don't forget to clean each vertex group after editing, like with meshes.

		-- This particular bridge is for 1 metre roads, which are very bendy.
		-- See the notes below.

		local railing = {
			railingDir .. 'railing_rep_side_no_side.mdl',
			railingDir .. 'railing_rep_side_no_side.mdl',
			railingDir .. 'railing_rep_side_no_side.mdl',
			railingDir .. 'railing_rep_rep.mdl',
			railingDir .. 'railing_rep_rep.mdl',
			-- these are useful to avoid funny dark textures on one side, but we use the two-sided material instead
			-- railingDir .. 'railing_rep_side2_no_side.mdl',
			-- railingDir .. 'railing_rep_side2_no_side.mdl',
			-- railingDir .. 'railing_rep_side2_no_side.mdl',
		}

		local config = {
			pillarBase = { stockDir .. 'pillar_btm_side.mdl', pillarDir .. 'pillar_btm_rep.mdl', stockDir .. 'pillar_btm_side2.mdl' },
			pillarRepeat = { stockDir .. 'pillar_rep_side.mdl', pillarDir .. 'pillar_rep_rep.mdl', stockDir .. 'pillar_rep_side2.mdl' },
			pillarTop = { stockDir .. 'pillar_top_side.mdl', pillarDir .. 'pillar_top_rep.mdl', stockDir .. 'pillar_top_side2.mdl' },
			railingBegin = railing,
			railingRepeat = railing,
			railingEnd = railing,
		}

		local updateFn = bridgeutilUG.makeDefaultUpdateFn(config)
		local newUpdateFn = function(params)
			-- print('newUpdateFn starting with params =') debugPrint(arrayUtils.cloneOmittingFields(params, {'state'}))
			-- UG TODO
			-- LOLLO NOTE
			-- when making a sharp bend, railingWidth is 10 instead of 0.5 and the lanes are screwed:
			-- this draws pointless artifacts on the sides. When it happens, pillarLength is different from the set value.
			-- the reason is, the C routine giving us the params assumes that the road is at least 5 m wide.
			-- this stupid C routine does not say how wide the road is, so we specialise the bridge on 1 metre wide roads.

			-- params.pillarHeights = {}

			if params.pillarLength ~= _pillarLength then
				params.pillarLength = _pillarLength
				params.pillarWidth = 0.5

				for _, railingInterval in pairs(params.railingIntervals) do
					-- railingInterval.hasPillar = { -1, -1, }
					for _, lane in pairs(railingInterval.lanes) do
						lane.offset = -0.5 -- goodish, it is minus the road width * 0.5
						-- lane.type = 0
					end
				end
				-- params.railingWidth = 0.5
				params.railingWidth = 1 -- goodish, it is the road width
				-- print('newUpdateFn tweaked params =') debugPrint(arrayUtils.cloneOmittingFields(params, {'state'}))
			end

			local results = updateFn(params)
			-- print('newUpdateFn returning =') debugPrint(results)
			return results
		end

		return {
			name = _('InternalBridgeNoPillarsNoSides'),
			yearFrom = -1, -- invisible
			yearTo = -1, -- invisible
			carriers = { 'ROAD' },
			speedLimit = 320.0 / 3.6,
			pillarLen = _pillarLength,
			pillarMinDist = 65535,
			pillarMaxDist = 65535,
			pillarTargetDist = 65535,
			-- pillarWidth = 2,
			cost = 0.0,
			-- LOLLO NOTE
			-- Sharp bends draw the street tangent to the bridge, outside,
			-- because the game expects 6m long street segments, while this bridge has 2m long segments.
			-- We can make street materials transparent, so sharp bends will look better.
			-- However, this will give junctions a hole in the middle.
			-- All in all, we choose junctions with no holes
			-- and put up with segments in stupidly narrow bends.
			materialsToReplace = {
				-- streetPaving = {
				--     name = 'lollo_street_tuning/totally_transparent.mtl'
				-- },
				-- streetLane = { -- this is the most conspicuous
				--     name = 'lollo_street_tuning/totally_transparent.mtl'
				-- },
				-- crossingLane = {
				--     name = 'lollo_street_tuning/totally_transparent.mtl'
				-- },
				-- sidewalkPaving = { -- this fills small gaps at junctions but also draws tangent stripes outside sharp bends
				--     -- name = 'lollo_street_tuning/totally_transparent.mtl'
				--     -- name = 'lollo_street_tuning/icon/green.mtl'
				--     -- name = 'lollo_street_tuning/asphalt_low_prio.mtl'
				--     name = 'street/country_new_medium_paving.mtl',
				--     size = { 2, 2 },
				-- },
				-- sidewalkCurb = { -- useless
				--     -- size = { 3, 0.6 },
				--     -- name = 'lollo_street_tuning/totally_transparent.mtl'
				--     name = 'lollo_street_tuning/icon/yellow.mtl'
				-- },
				-- sidewalkBorderInner = {
				--     size = { 2, 0.8 },
				--     -- name = 'lollo_street_tuning/totally_transparent.mtl'
				--     name = 'lollo_street_tuning/icon/blue.mtl'
				-- },
				-- sidewalkLane = {
				--     size = { 2, 0.8 },
				--     -- name = 'lollo_street_tuning/totally_transparent.mtl'
				--     name = 'lollo_street_tuning/icon/red.mtl'
				-- },
			},
			noParallelStripSubdivision = true,
			-- updateFn = updateFn,
			updateFn = newUpdateFn,
		}
	end,
	getModel4Basic_rep_side = function()
		local _lod0_skinMaterials_rep, _lod0_skinMaterials_side, _lod0_skinMaterials_side_no_railing, _lod1_materials = getDynamicProps()

		return {
			boundingInfo = {
				bbMax = { 2, 0, 0, },
				bbMin = { 0, -0.6, -0.5, },
			},
			collider = {
				params = {
					halfExtents = { 1, 0.3, 0.25, },
				},
				transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, -0.3, -0.25, 1, },
				type = 'BOX',
			},
			lods = {
				{
					node = {
						children = {
							{
								children = {
									{
										name = 'cement_bridge_bone_2m_start_side1',
										transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0.66667, 0, 1, },
									},
									{
										name = 'cement_bridge_bone_2m_end_side1',
										transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, 0.66667, 0, 1, },
									},
								},
								name = 'container_2m_side1',
								skin = 'lollo_street_tuning/bridge/pedestrian_cement/railing_rep_side_skin/cement_low_bottom_railing_rep_side_no_side_lod0.msh',
								skinMaterials = _lod0_skinMaterials_side_no_railing,
							},
						},
						-- transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -0.5, 0, 1, },
						transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -0.25, 0, 1, },
					},
					static = false,
					visibleFrom = 0,
					visibleTo = 200,
				},
				{
					node = {
						children = {
							{
								mesh = 'lollo_street_tuning/bridge/pedestrian_cement/railing_rep_side_skin/cement_low_bottom_railing_rep_side_no_side_lod1.msh',
								materials = _lod1_materials,
							},
						},
						-- transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -0.5, 0, 1, },
						transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -0.25, 0, 1, },
					},
					static = false,
					visibleFrom = 200,
					visibleTo = 1100,
				},
			},
			metadata = { },
			version = 1,
		}
	end,
	getModel4Basic_rep_rep = function()
		local _lod0_skinMaterials_rep, _lod0_skinMaterials_side, _lod0_skinMaterials_side_no_railing, _lod1_materials = getDynamicProps()

		return {
			boundingInfo = {
				bbMax = { 2, 0.5, 0, },
				bbMin = { 0, 0, -0.5, },
			},
			collider = {
				params = {
					halfExtents = { 1, 0.25, 0.25, },
				},
				transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, -0.25, 1, },
				type = 'BOX',
			},
			lods = {
				{
					node = {
						children = {
							{
								children = {
									{
										name = 'cement_bridge_bone_2m_start',
										transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0.66667, 0, 1, },
									},
									{
										name = 'cement_bridge_bone_2m_end',
										transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, 0.66667, 0, 1, },
									},
								},
								name = 'container_2m',
								skin = 'lollo_street_tuning/bridge/pedestrian_cement/railing_rep_rep_skin/cement_low_bottom_railing_rep_rep_lod0.msh',
								skinMaterials = _lod0_skinMaterials_rep,
							},
						},
						-- transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -0.25, 0, 1, },
						transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
					},
					static = false,
					visibleFrom = 0,
					visibleTo = 200,
				},
				{
					node = {
						children = {
							{
								mesh = 'lollo_street_tuning/bridge/pedestrian_cement/railing_rep_rep_skin/cement_low_bottom_railing_rep_rep_lod1.msh',
								materials = _lod1_materials,
							},
						},
						-- transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -0.25, 0, 1, },
						transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
					},
					static = false,
					visibleFrom = 200,
					visibleTo = 1100,
				},
			},
			metadata = { },
			version = 1,
		}
	end,
}

return funcs
