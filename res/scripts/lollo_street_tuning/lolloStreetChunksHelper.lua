-- local dump = require('lollo_street_tuning/luadump')
-- local inspect = require('inspect')
-- local vec3 = require 'vec3'
-- local transf = require 'transf'
local arrayUtils = require('lollo_street_tuning/lolloArrayUtils')
local edgeUtils = require('lollo_street_tuning/edgeHelpers')
local pitchUtil = require('lollo_street_tuning/lolloPitchHelpers')
local streetUtils = require('lollo_street_tuning/lolloStreetUtils')
local debugger = require('debugger')
local helper = {}

-- --------------- parameters ------------------------
local _distances = {}
for i = 0, 12 do -- watch out, the parameters have base 0
    table.insert(_distances, i)
end

helper.getDistances = function()
    return _distances
end

local _lengthMultiplier = 10
local _lengths = {}
for i = 0, 12 do -- watch out, the parameters have base 0
    table.insert(_lengths, i * _lengthMultiplier)
end

helper.getLengthMultiplier = function()
    return _lengthMultiplier
end

helper.getLengths = function()
    return _lengths
end

-- --------------- utils -----------------------------------
helper.makeEdges = function(direction, pitch, node0, node1, isRightOfIsland, tan0, tan1)
    -- return params.direction == 0 and
    --     {
    --         {pitchUtil.getXYZPitched(pitch, {-6, -3, .0}), {1, .0, .0}}, -- node 0
    --         {pitchUtil.getXYZPitched(pitch, {-2, -3, .0}), {1, .0, .0}} -- node 1
    --     } or
    --     {
    --         {pitchUtil.getXYZPitched(pitch, {-2, -3, .0}), {-1, .0, .0}}, -- node 0
    --         {pitchUtil.getXYZPitched(pitch, {-6, -3, .0}), {-1, .0, .0}} -- node 1
    --     }
    if tan0 == nil or tan1 == nil then
        local edgeLength = edgeUtils.getVectorLength({node1[1] - node0[1], node1[2] - node0[2], node1[3] - node0[3]})
        if tan0 == nil then tan0 = {edgeLength, 0, 0} end
        if tan1 == nil then tan1 = {edgeLength, 0, 0} end
    end

    if direction == 0 or (direction == 2 and isRightOfIsland) then return
        {
            {pitchUtil.getXYZPitched(pitch, node0), tan0}, -- node 0
            {pitchUtil.getXYZPitched(pitch, node1), tan1} -- node 1
        }
    else return
        {
            {pitchUtil.getXYZPitched(pitch, node1), {-tan1[1], -tan1[2], -tan1[3]}}, -- node 0
            {pitchUtil.getXYZPitched(pitch, node0), {-tan0[1], -tan0[2], -tan0[3]}} -- node 1
        }
    end
end

helper.getFreeNodesLowX = function(params, isRightOfIsland)
    if params.lockLayoutCentre == 1 then
        if params.direction == 2 and isRightOfIsland then
            return params.direction == 0 and {1} or {0}
        else
            return params.direction == 0 and {0} or {1}
        end
    else
        return {0, 1}
    end
end

helper.getFreeNodesCentre = function(params, isRightOfIsland)
    if params.lockLayoutCentre == 1 then
        return {}
    else
        return {0, 1}
    end
end

helper.getFreeNodesHighX = function(params, isRightOfIsland)
    if params.lockLayoutCentre == 1 then
        if params.direction == 2 and isRightOfIsland then
            return params.direction == 0 and {0} or {1}
        else
            return params.direction == 0 and {1} or {0}
        end
    else
        return {0, 1}
    end
end

helper.getParams = function()
    local defaultStreetTypeIndex = arrayUtils.findIndex(streetUtils.getGlobalStreetData(), 'fileName', 'lollo_medium_1_way_1_lane_street.lua') - 1
    if defaultStreetTypeIndex < 0 then defaultStreetTypeIndex = 0 end
print('LOLLO getting params for street chunk')
    return {
        {
            key = 'streetType_',
            name = _('Street type'),
            values = arrayUtils.map(
                streetUtils.getGlobalStreetData(),
                function(str)
                    return str.name
                end
            ),
            uiType = 'COMBOBOX',
            defaultIndex = defaultStreetTypeIndex
            -- yearFrom = 1925,
            -- yearTo = 0
        },
        {
            key = 'howManyStreetsBase0',
            name = _('Number of roads'),
            values = {_('1'), _('2'), _('3'), _('4'), _('5'), _('6')},
            defaultIndex = 1
            -- yearFrom = 1925,
            -- yearTo = 0
        },
        {
            key = 'snapNodes',
            name = _('Snap to neighbours'),
            values = {
                _('No'),
                _('Yes')
            },
            defaultIndex = 0
        },
        {
            key = 'lockLayoutCentre',
            name = _('Lock chunks'),
            tooltip = _('Lock chunks to keep their shape pretty and prevent other roads merging in. Unlock them to treat them like ordinary roads. You cannot relock an unlocked chunk.'),
            values = {
                _('No'),
                _('Yes')
            },
            defaultIndex = 0
        },
        {
            key = 'distance',
            name = _('Distance'),
            -- values = {_('0m'), _('1m'), _('2m'), _('3m'), _('4m')},
            values = arrayUtils.map(
                helper.getDistances(),
                function(dis)
                    return tostring(dis) .. 'm'
                end
            ),
            defaultIndex = 0
        },
        {
            key = 'islandWidth',
            name = _('Island Width'),
            values = arrayUtils.map(
                helper.getDistances(),
                function(dis)
                    return tostring(dis) .. 'm'
                end
            ),
            defaultIndex = 0
        },
        {
            key = 'extraLength',
            name = _('Extra Length'),
            -- values = {_('0m'), _('1m'), _('2m'), _('3m'), _('4m')},
            values = arrayUtils.map(
                helper.getLengths(),
                function(length)
                    return tostring(length) .. 'm'
                end
            ),
            defaultIndex = 0
        },
        -- {
        --     key = "terrainAlignment",
        --     name = _("Terrain alignment"),
        --     values = { _("Yes"), _("No") },
        --     defaultIndex = 1
        -- },
        {
            key = 'direction',
            name = _('Direction'),
            values = {
                _('↑'),
                _('↓'),
                _('↓↑'),
            },
            defaultIndex = 0
        },
        {
            key = 'tramTrack',
            name = _('Tram track type'),
            values = {
                -- must be in this sequence
                _('NO'),
                _('YES'),
                _('ELECTRIC')
            },
            defaultIndex = 2
        },
        {
            key = 'pitch',
            name = _('Pitch (adjust it with O and P while building)'),
            values = pitchUtil.getPitchParamValues(),
            defaultIndex = pitchUtil.getDefaultPitchParamValue(),
            uiType = 'SLIDER'
        }
    }
end

helper.getSnapEdgeLists = function(params, pitchAdjusted, streetData, tramTrackType)
    local streetHalfWidth = streetData.sidewalkWidth + streetData.streetWidth * 0.5
    local streetFullWidth = streetData.sidewalkWidth + streetData.sidewalkWidth + streetData.streetWidth

    local distance = params.distance or 0.0
    local halfDistance = distance * 0.5
    local halfExtraLength = (params.extraLength or 0.0) * 0.5 * helper.getLengthMultiplier()
    local halfIslandWidth = (params.islandWidth or 0.0) * 0.5

    -- LOLLO TODO check this, it might need extending
    -- local x0 = - math.max(7.0, streetHalfWidth + 1.0) - streetHalfWidth - halfExtraLength -- this dumps
    -- local x0 = - math.max(9.0, streetHalfWidth + 1.0) - streetHalfWidth - halfExtraLength
    local x0 = - math.max(8.0, streetHalfWidth + 1.0) - streetHalfWidth - halfExtraLength -- this is the fruit of trial and error: if x1 - x0 is too little, snapping will dump
    local x1 = - streetHalfWidth - halfExtraLength
    local x2 = - x1
    local x3 = - x0

    -- print('LOLLO streetHalfWidth = ', streetHalfWidth)
    -- print('LOLLO 2.0 * streetHalfWidth = ', 2.0 * streetHalfWidth)
    -- print('LOLLO streetFullWidth = ', streetFullWidth)
    -- print('LOLLO halfDistance = ', halfDistance)
    -- print('LOLLO halfIslandWidth = ', halfIslandWidth)
    local edgeParams = {
        skipCollision = true,
        type = streetData.fileName,
        tramTrackType = tramTrackType
    }
    local edgeLists
    if params.howManyStreetsBase0 == 0 then -- 1 street
        edgeLists = {
            -- low x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, 0, 0},
                    {x1, 0, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
                --					snapNodes = { 0, 1 },  -- node 0 and 1 are allowed to snap to other edges of the same type --crashes
                --					tag2nodes = {},
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, 0, 0},
                    {x2, 0, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, 0, 0},
                    {x3, 0, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            }
        }
    elseif params.howManyStreetsBase0 == 1 then -- 2 streets
        edgeLists = {
            -- low x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesLowX(params, true),
                snapNodes = helper.getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesCentre(params, true),
                snapNodes = helper.getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x3, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesHighX(params, true),
                snapNodes = helper.getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x3, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            }
        }
    elseif params.howManyStreetsBase0 == 2 then -- 3 streets
        edgeLists = {
            -- low x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesLowX(params, true),
                snapNodes = helper.getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, halfIslandWidth, 0},
                    {x1, halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, streetFullWidth + distance + halfIslandWidth, 0},
                    {x1, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesCentre(params, true),
                snapNodes = helper.getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, halfIslandWidth, 0},
                    {x2, halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, streetFullWidth + distance + halfIslandWidth, 0},
                    {x2, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x3, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesHighX(params, true),
                snapNodes = helper.getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, halfIslandWidth, 0},
                    {x3, halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, streetFullWidth + distance + halfIslandWidth, 0},
                    {x3, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            }
        }
    elseif params.howManyStreetsBase0 == 3 then -- 4 streets
        edgeLists = {
            -- low x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {- streetHalfWidth, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesLowX(params, true),
                snapNodes = helper.getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesLowX(params, true),
                snapNodes = helper.getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x2, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesCentre(params, true),
                snapNodes = helper.getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesCentre(params, true),
                snapNodes = helper.getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x3, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesHighX(params, true),
                snapNodes = helper.getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x3, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesHighX(params, true),
                snapNodes = helper.getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x3, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x3, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            }
        }
    elseif params.howManyStreetsBase0 == 4 then -- 5 streets
        edgeLists = {
            -- low x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    {x1, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesLowX(params, true),
                snapNodes = helper.getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesLowX(params, true),
                snapNodes = helper.getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, halfIslandWidth, 0},
                    {x1, halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, streetFullWidth + distance + halfIslandWidth, 0},
                    {x1, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0},
                    {x1, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    {x2, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesCentre(params, true),
                snapNodes = helper.getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesCentre(params, true),
                snapNodes = helper.getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, halfIslandWidth, 0},
                    {x2, halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, streetFullWidth + distance + halfIslandWidth, 0},
                    {x2, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0},
                    {x2, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    {x3, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesHighX(params, true),
                snapNodes = helper.getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x3, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesHighX(params, true),
                snapNodes = helper.getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, halfIslandWidth, 0},
                    {x3, halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, streetFullWidth + distance + halfIslandWidth, 0},
                    {x3, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0},
                    {x3, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            }
        }
    else -- if params.howManyStreetsBase0 == 5 then -- 6 streets -- fallback
        edgeLists = {
            -- low x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    {x1, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesLowX(params, true),
                snapNodes = helper.getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x1, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesLowX(params, true),
                snapNodes = helper.getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesLowX(params, true),
                snapNodes = helper.getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x0, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0},
                    {x1, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesLowX(params),
                snapNodes = helper.getSnapNodesLowX(params)
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    {x2, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesCentre(params, true),
                snapNodes = helper.getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x2, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesCentre(params, true),
                snapNodes = helper.getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesCentre(params, true),
                snapNodes = helper.getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x1, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0},
                    {x2, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesCentre(params),
                snapNodes = helper.getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    {x3, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesHighX(params, true),
                snapNodes = helper.getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x3, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesHighX(params, true),
                snapNodes = helper.getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x3, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = helper.getFreeNodesHighX(params, true),
                snapNodes = helper.getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x3, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x3, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = helper.makeEdges(
                    params.direction,
                    pitchAdjusted,
                    {x2, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0},
                    {x3, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = helper.getFreeNodesHighX(params),
                snapNodes = helper.getSnapNodesHighX(params)
            }
        }
    end
    return edgeLists
end

helper.getSnapNodesLowX = function(params, isRightOfIsland)
    if params.snapNodes == 1 then
        if params.direction == 2 and isRightOfIsland then
            return params.direction == 0 and {1} or {0}
        else
            return params.direction == 0 and {0} or {1}
        end
    else
        return {}
    end
end

helper.getSnapNodesCentre = function(params, isRightOfIsland)
    return {}
end

helper.getSnapNodesHighX = function(params, isRightOfIsland)
    if params.snapNodes == 1 then
        if params.direction == 2 and isRightOfIsland then
            return params.direction == 0 and {0} or {1}
        else
            return params.direction == 0 and {1} or {0}
        end
    else
        return {}
    end
end

return helper
