-- local dump = require('lollo_street_tuning/luadump')
-- local inspect = require('inspect')
-- local vec3 = require 'vec3'
-- local transf = require 'transf'
local edgeUtils = require('lollo_street_tuning/edgeHelpers')
local pitchUtil = require('lollo_street_tuning/lolloPitchHelpers')
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
