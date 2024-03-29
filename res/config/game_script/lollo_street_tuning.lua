local arrayUtils = require('lollo_street_tuning.arrayUtils')
local comparisonUtils = require('lollo_street_tuning.comparisonUtils')
local constants = require('lollo_street_tuning.constants')
local edgeUtils = require('lollo_street_tuning.edgeUtils')
local logger = require('lollo_street_tuning.logger')
local streetUtils = require('lollo_street_tuning.streetUtils')
local stringUtils = require('lollo_street_tuning.stringUtils')
local transfUtils = require('lollo_street_tuning.transfUtils')
local transfUtilUG = require('transf')

-- LOLLO BUG when you split a road near a modded street station, whose mod was removed,
-- and then apply a modifier, such as add / remove bus lane or change the street type,
-- the game crashes.
-- This happens with single as well as double-sided stations.
-- You can tell those stations because the game shows a placeholder at their location.
-- This seems to be a UG problem.
-- To solve the issue, replace those stations with some others available in your game.

local _eventId = '__lolloStreetTuningEvent__'
local _eventProperties = {
    lollo_street_changer = { conName = 'lollo_street_changer.con', eventName = 'streetChangerBuilt' },
    lollo_street_chunks = { conName = 'lollo_street_chunks_2.con', eventName = 'streetChunksBuilt' },
    lollo_street_cleaver = { conName = 'lollo_street_cleaver.con', eventName = 'streetCleaverBuilt' },
    lollo_street_get_info = { conName = 'lollo_street_get_info.con', eventName = 'streetGetInfoBuilt' },
    lollo_street_hairpin = { conName = 'lollo_street_hairpin_2.con', eventName = 'streetHairpinBuilt' },
    lollo_street_merge = { conName = 'lollo_street_merge_2.con', eventName = 'streetMergeBuilt' },
    lollo_street_remover = { conName = 'lollo_street_remover.con', eventName = 'streetRemoverBuilt' },
    lollo_street_remover_waypoint = { conName = '', eventName = 'streetRemoverWaypointBuilt' },
    lollo_street_splitter = { conName = 'lollo_street_splitter.con', eventName = 'streetSplitterBuilt' },
    lollo_street_splitter_w_api = { conName = 'lollo_street_splitter_w_api.con', eventName = 'streetSplitterWithApiBuilt' },
    lollo_toggle_all_tram_tracks = { conName = 'lollo_toggle_all_tram_tracks.con', eventName = 'toggleAllTracksBuilt' },
    noTramRightRoadBuilt = { conName = '', eventName = 'noTramRightRoadBuilt' },
    pathBuilt = { conName = '', eventName = 'pathBuilt' },
}
local _guiWaypoints = {
    streetEdgeRemover = {
        modelId = nil,
        fileName = 'lollo_street_tuning/street/remove_street_edge_waypoint.mdl',
    },
    trackEdgeRemover = {
        modelId = nil,
        fileName = 'lollo_street_tuning/railroad/remove_track_edge_waypoint.mdl',
    }
}

local function _isBuildingConstructionWithFileName(args, fileName)
    local toAdd =
        type(args) == 'table' and type(args.proposal) == 'userdata' and type(args.proposal.toAdd) == 'userdata' and
        args.proposal.toAdd

    if toAdd and #toAdd > 0 then
        for i = 1, #toAdd do
            if toAdd[i].fileName == fileName then
                return true
            end
        end
    end

    return false
end

local function _isBuildingStreetChanger(args)
    return _isBuildingConstructionWithFileName(args, _eventProperties.lollo_street_changer.conName)
end

local function _isBuildingStreetChunks(args)
    return _isBuildingConstructionWithFileName(args, _eventProperties.lollo_street_chunks.conName)
end

local function _isBuildingStreetCleaver(args)
    return _isBuildingConstructionWithFileName(args, _eventProperties.lollo_street_cleaver.conName)
end

local function _isBuildingStreetGetInfo(args)
    return _isBuildingConstructionWithFileName(args, _eventProperties.lollo_street_get_info.conName)
end

local function _isBuildingStreetHairpin(args)
    return _isBuildingConstructionWithFileName(args, _eventProperties.lollo_street_hairpin.conName)
end

local function _isBuildingStreetMerge(args)
    return _isBuildingConstructionWithFileName(args, _eventProperties.lollo_street_merge.conName)
end

local function _isBuildingStreetRemover(args)
    return _isBuildingConstructionWithFileName(args, _eventProperties.lollo_street_remover.conName)
end

local function _isBuildingStreetSplitter(args)
    return _isBuildingConstructionWithFileName(args, _eventProperties.lollo_street_splitter.conName)
end

local function _isBuildingStreetSplitterWithApi(args)
    return _isBuildingConstructionWithFileName(args, _eventProperties.lollo_street_splitter_w_api.conName)
end

local function _isBuildingToggleAllTracks(args)
    return _isBuildingConstructionWithFileName(args, _eventProperties.lollo_toggle_all_tram_tracks.conName)
end

local _guiUtils = {
    sendCommandWithArgs = function(eventName, args)
        api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
            string.sub(debug.getinfo(1, 'S').source, 1),
            _eventId,
            eventName,
            args
        ))
    end,
    sendCommandWithConId = function(eventName, args)
        api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
            string.sub(debug.getinfo(1, 'S').source, 1),
            _eventId,
            eventName,
            {
                conId = args.result[1]
            }
        ))
    end,
}

local _utils = {
    getAverageZ = function(edgeId)
        if not(edgeUtils.isValidAndExistingId(edgeId)) then return nil end

        local baseEdge = api.engine.getComponent(edgeId, api.type.ComponentType.BASE_EDGE)
        if baseEdge == nil then return nil end

        local baseNode0 = api.engine.getComponent(baseEdge.node0, api.type.ComponentType.BASE_NODE)
        local baseNode1 = api.engine.getComponent(baseEdge.node1, api.type.ComponentType.BASE_NODE)
        if baseNode0 == nil
        or baseNode1 == nil
        or baseNode0.position == nil
        or baseNode1.position == nil
        or type(baseNode0.position.z) ~= 'number'
        or type(baseNode1.position.z) ~= 'number'
        then
            return nil
        end

        return (baseNode0.position.z + baseNode1.position.z) / 2
    end,
    getConTransf = function(conId)
        if not(edgeUtils.isValidAndExistingId(conId)) then return nil end

        local conTransf = api.engine.getComponent(conId, api.type.ComponentType.CONSTRUCTION).transf
        return transfUtilUG.new(conTransf:cols(0), conTransf:cols(1), conTransf:cols(2), conTransf:cols(3))
    end,
    getToggledAllTramTracksStreetTypeFileName = function(streetFileName)
        logger.print('getToggledAllTramTracksStreetTypeFileName starting, streetFileName =') logger.debugPrint(streetFileName)
        if type(streetFileName) ~= 'string' or streetFileName == '' then return nil end

        local allStreetsData = streetUtils.getGlobalStreetData({streetUtils.getStreetDataFilters().STOCK_AND_RESERVED_LANES})
        logger.print('allStreetsData has', #allStreetsData, 'records')
        local oldStreetData = nil
        for _, value in pairs(allStreetsData) do
            logger.print('checking', value.fileName or 'NIL')
            if stringUtils.stringEndsWith(streetFileName, value.fileName) then
                oldStreetData = value
                break
            end
        end
        if not(oldStreetData) then return nil end

        local sameSizeStreetsData = {}
        for _, value in pairs(allStreetsData) do
            if value.fileName ~= streetFileName
            and value.isAllTramTracks ~= oldStreetData.isAllTramTracks
            and value.laneCount == oldStreetData.laneCount
            and value.sidewalkWidth == oldStreetData.sidewalkWidth
            and value.streetWidth == oldStreetData.streetWidth then
                sameSizeStreetsData[#sameSizeStreetsData+1] = value
            end
        end
        if #sameSizeStreetsData == 0 then return nil end

        logger.print('sameSizeStreetsData =') logger.debugPrint(sameSizeStreetsData)

        local _getConcatCategories = function(arr)
            local result = ''
            for i = 1, #arr do
                result = result .. tostring(arr[i]):lower()
            end
            return result
        end

        local oldStreetCategoriesStr = _getConcatCategories(oldStreetData.categories)
        logger.print('oldStreetCategoriesStr =') logger.debugPrint(oldStreetCategoriesStr)
        for i = 1, #sameSizeStreetsData do
            -- LOLLO TODO this estimator may be a little weak.
            -- we need a new property in streetUtils._getStreetTypesWithApi
            -- to identify similar streets with different tarmac.
            -- For the moment, we can probably toggle multiple times: this is a loop after all.
            if _getConcatCategories(sameSizeStreetsData[i].categories) == oldStreetCategoriesStr then
                return sameSizeStreetsData[i].fileName
            end
        end

        return nil
    end,

    getWhichEdgeGetsEdgeObjectAfterSplit = function(edgeObjPosition, node0pos, node1pos, nodeBetween)
        local result = {
            assignToSide = nil,
        }
        -- print('LOLLO attempting to place edge object with position =')
        -- debugPrint(edgeObjPosition)
        -- print('wholeEdge.node0pos =')
        -- debugPrint(node0pos)
        -- print('nodeBetween.position =')
        -- debugPrint(nodeBetween.position)
        -- print('nodeBetween.tangent =')
        -- debugPrint(nodeBetween.tangent)
        -- print('wholeEdge.node1pos =')
        -- debugPrint(node1pos)

        local edgeObjPosition_assignTo = nil
        local node0_assignTo = nil
        local node1_assignTo = nil
        -- at nodeBetween, I can draw the normal to the road:
        -- y = a + bx
        -- the angle is alpha = atan2(nodeBetween.tangent.y, nodeBetween.tangent.x) + PI / 2
        -- so b = math.tan(alpha)
        -- a = y - bx
        -- so a = nodeBetween.position.y - b * nodeBetween.position.x
        -- points under this line will go one way, the others the other way
        local alpha = math.atan2(nodeBetween.tangent.y, nodeBetween.tangent.x) + math.pi * 0.5
        local b = math.tan(alpha)
        if math.abs(b) < 1e+06 then
            local a = nodeBetween.position.y - b * nodeBetween.position.x
            if a + b * edgeObjPosition[1] > edgeObjPosition[2] then -- edgeObj is below the line
                edgeObjPosition_assignTo = 0
            else
                edgeObjPosition_assignTo = 1
            end
            if a + b * node0pos[1] > node0pos[2] then -- wholeEdge.node0pos is below the line
                node0_assignTo = 0
            else
                node0_assignTo = 1
            end
            if a + b * node1pos[1] > node1pos[2] then -- wholeEdge.node1pos is below the line
                node1_assignTo = 0
            else
                node1_assignTo = 1
            end
        -- if b grows too much, I lose precision, so I approximate it with the y axis
        else
            -- print('alpha =', alpha, 'b =', b)
            if edgeObjPosition[1] > nodeBetween.position.x then
                edgeObjPosition_assignTo = 0
            else
                edgeObjPosition_assignTo = 1
            end
            if node0pos[1] > nodeBetween.position.x then
                node0_assignTo = 0
            else
                node0_assignTo = 1
            end
            if node1pos[1] > nodeBetween.position.x then
                node1_assignTo = 0
            else
                node1_assignTo = 1
            end
        end

        if edgeObjPosition_assignTo == node0_assignTo then
            result.assignToSide = 0
        elseif edgeObjPosition_assignTo == node1_assignTo then
            result.assignToSide = 1
        end

        -- print('LOLLO assignment =')
        -- debugPrint(result)
        return result
    end,
}

local _actions = {
    bulldozeConstruction = function(conId)
        -- print('conId =', conId)
        if not(edgeUtils.isValidAndExistingId(conId)) then return end

        local oldConstruction = api.engine.getComponent(conId, api.type.ComponentType.CONSTRUCTION)
        -- print('oldConstruction =')
        -- debugPrint(oldConstruction)
        if not(oldConstruction) or not(oldConstruction.params) then return end

        local proposal = api.type.SimpleProposal.new()
        -- LOLLO NOTE there are asymmetries how different tables are handled.
        -- This one requires this system, UG says they will document it or amend it.
        proposal.constructionsToRemove = { conId }
        -- proposal.constructionsToRemove[1] = conId -- fails to add
        -- proposal.constructionsToRemove:add(conId) -- fails to add

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(proposal, nil, true), -- the 3rd param is "ignore errors"; wrong proposals will be discarded anyway
            function(res, success)
                -- print('LOLLO _bulldozeConstruction res = ')
                -- debugPrint(res)
                --for _, v in pairs(res.entities) do print(v) end
                -- print('LOLLO _bulldozeConstruction success = ')
                -- debugPrint(success)
            end
        )
    end,

    cleaveEdge = function(oldEdgeId)
        -- replaces an edge with many edges, one each lane
        if not(edgeUtils.isValidAndExistingId(oldEdgeId)) or edgeUtils.isEdgeFrozen(oldEdgeId) then return end

        local oldBaseEdge = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE)
        local oldBaseEdgeStreet = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
        -- save a crash when a modded road underwent a breaking change, so it has no oldEdgeStreet
        if oldBaseEdge == nil or oldBaseEdgeStreet == nil or type(oldBaseEdgeStreet.streetType) ~= 'number' or oldBaseEdgeStreet.streetType < 0 then return end
        -- print('oldBaseEdge =') debugPrint(oldBaseEdge)

        -- local oldEdgeStreetType = api.res.streetTypeRep.get(oldBaseEdgeStreet.streetType)
        -- if not(oldEdgeStreetType) or not(oldEdgeStreetType.laneConfigs) then return end
        -- local isOneWay = streetUtils.isStreetOneWay(oldEdgeStreetType.laneConfigs)
        -- print('isOneWay =', isOneWay or 'false')

        local tn = api.engine.getComponent(oldEdgeId, api.type.ComponentType.TRANSPORT_NETWORK)
        if not(tn) or not(tn.edges) then return end

        local _map = api.engine.system.streetSystem.getNode2SegmentMap()
        local oldNode0 = api.engine.getComponent(oldBaseEdge.node0, api.type.ComponentType.BASE_NODE)
        local oldNode1 = api.engine.getComponent(oldBaseEdge.node1, api.type.ComponentType.BASE_NODE)
        -- these are to double-check, they work
        -- local nodeIdsIn0 = edgeUtils.getNearbyObjectIds(transfUtils.position2Transf(oldNode0.position), 0.05, api.type.ComponentType.BASE_NODE)
        -- print('nodeIdsIn0 =') debugPrint(nodeIdsIn0)
        -- local nodeIdsIn1 = edgeUtils.getNearbyObjectIds(transfUtils.position2Transf(oldNode1.position), 0.05, api.type.ComponentType.BASE_NODE)
        -- print('nodeIdsIn1 =') debugPrint(nodeIdsIn1)

        local playerOwned = api.engine.getComponent(oldEdgeId, api.type.ComponentType.PLAYER_OWNED)
        local newStreetTypeId = api.res.streetTypeRep.find('lollo_internal_1_way_1_lane_street_no_sidewalk.lua')
        -- local newStreetTypeId = api.res.streetTypeRep.find('lollo_medium_1_way_1_lane_street_narrow_sidewalk.lua')

        print('#tn.edges =', #tn.edges or 'NIL')
        -- print('tn.edges =') debugPrint(tn.edges) -- they always have the same structure, even when they look like arcs
        local newEdges = {}
        local newNodes = {}
        -- LOLLO NOTE in any case, this looks so ugly that we want nothing to do with it.
        -- The road ends do not match optically, it looks like a mess.
        -- We must only cleave roads without pavement and maybe materials low z priority for half-decent looks.
        -- I could leave the old edge in place and add something invisible: that would look OK
        -- However, the bigger problem is: even tho I calculated the nodes well,
        -- they never connect up with the neighbouring streets.
        -- Two-way roads look good coz they show green dots overlaying my red dots, but it's an illusion.
        -- One-way show the problem at once.
        -- The red dots are where they should be, but they just won't connect to their neighbours.
        -- One way out would be: freeze the old chunk left and the old chunk right in a construction.
        -- That means, destroy some of the buildings around. So, no.

        local posTanX2 = {
            {
                {oldNode0.position.x, oldNode0.position.y, oldNode0.position.z},
                {oldBaseEdge.tangent0.x, oldBaseEdge.tangent0.y, oldBaseEdge.tangent0.z}
            },
            {
                {oldNode1.position.x, oldNode1.position.y, oldNode1.position.z},
                {oldBaseEdge.tangent1.x, oldBaseEdge.tangent1.y, oldBaseEdge.tangent1.z}
            }
        }

        for i = 2, (#tn.edges - 1), 1 do -- loop over the lanes neglecting the outer lanes, which are always pavements
            local edge = tn.edges[i]
            print('edge.geometry =') debugPrint(edge.geometry)
            if edge and edge.geometry and edge.geometry.params then
                -- take the direction into account
                local isSwap = edge.conns[1].entity == oldBaseEdge.node1
                print('isSwap =', isSwap or 'false')
                local offset = edge.geometry.params.offset or 0
                print('offset = ', offset)

                local newPosTanX2 = isSwap
                    and transfUtils.getParallelSidewaysWithRotZ(transfUtils.getPosTanX2Reversed(posTanX2), offset)
                    or transfUtils.getParallelSidewaysWithRotZ(posTanX2, offset)
                print('newPosTanX2 =') debugPrint(newPosTanX2)
                if isSwap then
                    print('distance = ') debugPrint(transfUtils.getPositionsDistance(newPosTanX2[1][1], posTanX2[2][1]))
                else
                    print('distance = ') debugPrint(transfUtils.getPositionsDistance(newPosTanX2[1][1], posTanX2[1][1]))
                end

                local getNode0Entity = function()
                    local node0Entity
                    -- this finds nothing with the old edge. It is useful to join sliced bits together tho.
                    local nodeIdsAlreadyIn0 = edgeUtils.getNearbyObjectIds(transfUtils.position2Transf(newPosTanX2[1][1]), 0.1, api.type.ComponentType.BASE_NODE)
                    print('nodeIdsAlreadyIn0 =') debugPrint(nodeIdsAlreadyIn0)
                    if #nodeIdsAlreadyIn0 == 0 then
                        local newNode0 = api.type.NodeAndEntity.new()
                        newNode0.entity = -(#newNodes + 1 + #newEdges)
                        newNode0.comp.position = api.type.Vec3f.new(newPosTanX2[1][1][1], newPosTanX2[1][1][2], newPosTanX2[1][1][3])
                        newNodes[#newNodes+1] = newNode0
                        node0Entity = newNode0.entity
                    else
                        node0Entity = nodeIdsAlreadyIn0[1]
                    end

                    return node0Entity
                end
                local node0Entity = getNode0Entity()

                local getNode1Entity = function()
                    local node1Entity
                    -- this finds nothing with the old edge. It is useful to join sliced bits together tho.
                    local nodeIdsAlreadyIn1 = edgeUtils.getNearbyObjectIds(transfUtils.position2Transf(newPosTanX2[2][1]), 0.1, api.type.ComponentType.BASE_NODE)
                    print('nodeIdsAlreadyIn1 =') debugPrint(nodeIdsAlreadyIn1)
                    if #nodeIdsAlreadyIn1 == 0 then
                        local newNode1 = api.type.NodeAndEntity.new()
                        newNode1.entity = -(#newNodes + 1 + #newEdges)
                        newNode1.comp.position = api.type.Vec3f.new(newPosTanX2[2][1][1], newPosTanX2[2][1][2], newPosTanX2[2][1][3])
                        newNodes[#newNodes+1] = newNode1
                        node1Entity = newNode1.entity
                    else
                        node1Entity = nodeIdsAlreadyIn1[1]
                    end

                    return node1Entity
                end
                local node1Entity = getNode1Entity()

                local newEdge = api.type.SegmentAndEntity.new()
                newEdge.comp.node0 = node0Entity
                newEdge.comp.tangent0 = api.type.Vec3f.new(
                    newPosTanX2[1][2][1],
                    newPosTanX2[1][2][2],
                    newPosTanX2[1][2][3]
                )

                newEdge.comp.node1 = node1Entity
                newEdge.comp.tangent1 = api.type.Vec3f.new(
                    newPosTanX2[2][2][1],
                    newPosTanX2[2][2][2],
                    newPosTanX2[2][2][3]
                )

                newEdge.entity = -(#newNodes + 1 + #newEdges)
                newEdge.type = 0 -- ROAD
                newEdge.comp.type = oldBaseEdge.type -- bridge, tunnel or none
                newEdge.comp.typeIndex = oldBaseEdge.typeIndex -- bridge or tunnel file or none
                -- newEdge.comp.objects = 
                newEdge.playerOwned = playerOwned
                newEdge.streetEdge = oldBaseEdgeStreet
                newEdge.streetEdge.streetType = newStreetTypeId
                -- useless
                -- newEdge.streetEdge.precedenceNode0 = 5 -- -5 -- 4 -- 3 -- -1 -- 0 --1 --2
                -- newEdge.streetEdge.precedenceNode1 = 6 -- -6 -- 4 -- 3 -- -1 -- 0 -- 1 --2

                newEdges[#newEdges+1] = newEdge
            end
        end

        print('newEdges =') debugPrint(newEdges)
        print('newNodes =') debugPrint(newNodes)
        local proposal = api.type.SimpleProposal.new()
        for index, newEdge in ipairs(newEdges) do
            proposal.streetProposal.edgesToAdd[index] = newEdge
        end

        for index, newNode in ipairs(newNodes) do
            proposal.streetProposal.nodesToAdd[index] = newNode
        end

        local function removeOld()
            -- remove the old edge
            proposal.streetProposal.edgesToRemove[1] = oldEdgeId
            -- remove the old nodes if orphan
            local nNodesToRemove = 0
            if #_map[oldBaseEdge.node0] == 1 then
                proposal.streetProposal.nodesToRemove[nNodesToRemove + 1] = oldBaseEdge.node0
                nNodesToRemove = nNodesToRemove + 1
            end
            if #_map[oldBaseEdge.node1] == 1 then
                proposal.streetProposal.nodesToRemove[nNodesToRemove + 1] = oldBaseEdge.node1
                nNodesToRemove = nNodesToRemove + 1
            end
        end
        removeOld()

        print('streetTuning.cleaveEdge is about to make the proposal = ') debugPrint(proposal)

        -- add and remove edge objects
        -- preserve buildings

        local context = api.type.Context:new()
        -- context.checkTerrainAlignment = true -- default is false, true gives smoother Z
        context.cleanupStreetGraph = true -- default is false, seems useless
        -- context.gatherBuildings = true  -- default is false
        -- context.gatherFields = true -- default is true
        -- context.player = api.engine.util.getPlayer() -- default is -1

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(proposal, context, true), -- the 3rd param is "ignore errors"; wrong proposals will be discarded anyway
            function(result, success)
                if not(success) then
                    print('Warning: streetTuning.cleaveEdge failed')
                    print('result =') debugPrint(result)
                else
                    print('streetTuning.cleaveEdge succeeded')
                end
            end
        )
    end,

    removeEdge = function(oldEdgeId)
        logger.print('removeEdge starting')
        -- removes an edge even if it has a street type, which has changed or disappeared
        if not(edgeUtils.isValidAndExistingId(oldEdgeId)) then return end

        local proposal = api.type.SimpleProposal.new()

        local conId = api.engine.system.streetConnectorSystem.getConstructionEntityForEdge(oldEdgeId)
        if edgeUtils.isValidAndExistingId(conId) then
            local conData = api.engine.getComponent(conId, api.type.ComponentType.CONSTRUCTION)
            if conData ~= nil
            -- and conData.frozenEdges ~= nil
            then
                proposal.constructionsToRemove = { conId }
                logger.print('conIdToBeRemoved =') logger.debugPrint(conId)
            end
        elseif not(edgeUtils.isEdgeFrozen(oldEdgeId)) then
            local oldBaseEdge = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE)
            logger.print('oldEdge =') logger.debugPrint(oldBaseEdge)
            local oldEdgeStreet = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
            logger.print('oldEdgeStreet =') logger.debugPrint(oldEdgeStreet)
            local oldEdgeTrack = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_TRACK)
            logger.print('oldEdgeTrack =') logger.debugPrint(oldEdgeTrack)
            -- save a crash when a modded road underwent a breaking change, so it has no oldEdgeStreet
            if oldBaseEdge == nil or (oldEdgeStreet == nil and oldEdgeTrack == nil) then return end

            local orphanNodeIds = {}
            local _map = api.engine.system.streetSystem.getNode2SegmentMap()
            if #_map[oldBaseEdge.node0] == 1 then
                orphanNodeIds[#orphanNodeIds+1] = oldBaseEdge.node0
            end
            if #_map[oldBaseEdge.node1] == 1 then
                orphanNodeIds[#orphanNodeIds+1] = oldBaseEdge.node1
            end

            proposal.streetProposal.edgesToRemove[1] = oldEdgeId
            for i = 1, #orphanNodeIds, 1 do
                proposal.streetProposal.nodesToRemove[i] = orphanNodeIds[i]
            end

            if oldBaseEdge.objects then
                for o = 1, #oldBaseEdge.objects do
                    proposal.streetProposal.edgeObjectsToRemove[#proposal.streetProposal.edgeObjectsToRemove+1] = oldBaseEdge.objects[o][1]
                end
            end
        end

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(proposal, nil, true),
            function(res, success)
                -- print('LOLLO res = ') -- debugPrint(res)
                -- print('LOLLO removeEdge success = ') -- debugPrint(success)
                if not(success) then
                    -- this fails if there are more than one contiguous invalid segments.
                    -- the message is
                    -- can't connect edge at position (-2170.3 / -2674.84 / 35.4797)
                    -- to get past this, we should navigate everywhere, checking for the street types
                    -- that can be either gone missing, or have been changed.
                    -- Then we should replace them with their own new version (streetTypeId = oldEdgeStreet.streetType),
                    -- or remove them
                    logger.warn('streetTuning.removeEdge failed, proposal = ') logger.warningDebugPrint(proposal)
                end
            end
        )
    end,

    replaceConWithSnappyCopy = function(oldConId)
        -- We don't use this anymore, check out the NOTE below.

        -- rebuild the con with the same but snappy, to prevent pointless internal conflicts
        -- that will prevent using the construction mover
        logger.print('replaceConWithSnappyCopy starting, oldConId =', oldConId or 'NIL')
        if not(edgeUtils.isValidAndExistingId(oldConId)) then return end

        local oldConstruction = api.engine.getComponent(oldConId, api.type.ComponentType.CONSTRUCTION)
        logger.print('oldConstruction =') logger.debugPrint(oldConstruction)
        if not(oldConstruction)
        or not(oldConstruction.params)
        or oldConstruction.params.snapNodes_ == 3 -- leave if nothing is going to change
        then return end

        local newConstruction = api.type.SimpleProposal.ConstructionEntity.new()
        newConstruction.fileName = oldConstruction.fileName

        local newParams = arrayUtils.cloneDeepOmittingFields(oldConstruction.params, nil, true)
        newParams.seed = oldConstruction.params.seed + 1
        newParams.snapNodes_ = 3 -- this is what this is all about
        logger.print('newParams =') logger.debugPrint(newParams)
        local paramsBak = arrayUtils.cloneDeepOmittingFields(newParams, {'seed'})
        newConstruction.params = newParams

        newConstruction.transf = oldConstruction.transf
        newConstruction.playerEntity = api.engine.util.getPlayer()

        local proposal = api.type.SimpleProposal.new()
        proposal.constructionsToAdd[1] = newConstruction
        -- LOLLO NOTE different tables are handled differently.
        -- This one requires this system, UG says they will document it or amend it.
        proposal.constructionsToRemove = { oldConId }
        -- proposal.constructionsToRemove[1] = oldConId -- fails to add
        -- proposal.constructionsToRemove:add(oldConId) -- fails to add
        -- proposal.old2new = { -- expected number, received table
        --     { oldConId, 1 }
        -- }
        -- proposal.old2new = {
        --     oldConId, 1
        -- }
        -- proposal.old2new = {
        --     oldConId,
        -- }

--[[
        local context = api.type.Context:new()
        context.checkTerrainAlignment = true -- true gives smoother z, default is false
        -- context.cleanupStreetGraph = false -- default is false
        -- context.gatherBuildings = true -- default is false
        -- context.gatherFields = true -- default is true
        context.player = api.engine.util.getPlayer()

        -- local cmd = api.cmd.make.buildProposal(proposal, context, true) -- the 3rd param is "ignore errors"
]]

        local cmd = api.cmd.make.buildProposal(proposal, nil, false) -- the 3rd param is "ignore errors"
        api.cmd.sendCommand(cmd, function(result, success)
            -- logger.print('LOLLO replaceConWithSnappyCopy result = ') logger.debugPrint(result)
            logger.print('LOLLO replaceConWithSnappyCopy success = ') logger.debugPrint(success)
            if success then
                xpcall(
                    function()
                        if result
                        and result.resultProposalData
                        and result.resultProposalData.errorState
                        and not(result.resultProposalData.errorState.critical)
                        and result.resultEntities
                        and result.resultEntities[1] ~= nil
                        and result.resultEntities[1] > 0
                        then
                            -- UG TODO there is no such thing in the new api,
                            -- nor an upgrade event, both would be useful
                            logger.print('oldConId =') logger.debugPrint(oldConId)
                            logger.print('result.resultEntities[1] =') logger.debugPrint(result.resultEntities[1])
                            logger.print('oldConstruction.fileName =') logger.debugPrint(oldConstruction.fileName)
                            local upgradedConId = game.interface.upgradeConstruction(
                                result.resultEntities[1],
                                oldConstruction.fileName,
                                paramsBak
                            )
                            logger.print('upgradeConstruction succeeded') logger.debugPrint(upgradedConId)
                        else
                            logger.warn('cannot upgrade construction')
                        end
                    end,
                    function(error)
                        logger.warn(error)
                    end
                )
            end
        end)
    end,
    replaceEdgeWithSame = function(oldEdgeId)
        -- only for testing
        -- replaces a street segment with an identical one, without destroying the buildings
        if not(edgeUtils.isValidAndExistingId(oldEdgeId)) then return end

        local oldEdge = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE)
        local oldEdgeStreet = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
        -- save a crash when a modded road underwent a breaking change, so it has no oldEdgeStreet
        if oldEdge == nil or oldEdgeStreet == nil then return end

        local playerOwned = api.engine.getComponent(oldEdgeId, api.type.ComponentType.PLAYER_OWNED)

        local newEdge = api.type.SegmentAndEntity.new()
        newEdge.entity = -1
        newEdge.type = 0
        newEdge.comp = oldEdge
        -- newEdge.playerOwned = {player = api.engine.util.getPlayer()}
        newEdge.playerOwned = playerOwned
        newEdge.streetEdge = oldEdgeStreet
        -- eo.streetEdge.streetType = api.res.streetTypeRep.find(streetEdgeEntity.streetType)

        local simpleProposal = api.type.SimpleProposal.new()
        simpleProposal.streetProposal.edgesToRemove[1] = oldEdgeId
        simpleProposal.streetProposal.edgesToAdd[1] = newEdge
        logger.print('simple proposal =') logger.debugPrint(simpleProposal)

        local context = api.type.Context:new()
        -- context.checkTerrainAlignment = true -- default is false, true gives smoother Z
        -- context.cleanupStreetGraph = true -- default is false
        -- context.gatherBuildings = true  -- default is false
        -- context.gatherFields = true -- default is true
        -- context.player = api.engine.util.getPlayer() -- default is -1
        local proposalData = api.engine.util.proposal.makeProposalData(simpleProposal, context)
        logger.print('proposalData =') logger.debugPrint(proposalData)

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(simpleProposal, nil, true),
            function(result, success)
                -- print('LOLLO res = ')
                -- debugPrint(res)
                --for _, v in pairs(res.entities) do print(v) end
                -- print('LOLLO success = ')
                -- debugPrint(success)
                if not(success) then
                    logger.warn('Warning: streetTuning.replaceEdgeWithSame failed, proposal = ') logger.warningDebugPrint(simpleProposal)
                else
                    logger.print('LOLLO street changer succeeded, result =') logger.debugPrint(result)
                    local proposal2 = result.proposal
                end
            end
        )
    end,

    replaceEdgeWithStreetType = function(oldEdgeId, newStreetTypeId)
        logger.print('replaceEdgeWithStreetType starting')
        -- replaces the street without destroying the buildings
        if not(edgeUtils.isValidAndExistingId(oldEdgeId)) or edgeUtils.isEdgeFrozen(oldEdgeId) or not(edgeUtils.isValidId(newStreetTypeId)) then return end

        local oldEdge = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE)
        if oldEdge == nil then return end

        local oldEdgeStreet = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
        -- save a crash when a modded road underwent a breaking change, so it has no oldEdgeStreet
        if oldEdgeStreet == nil then return end

        local newEdge = api.type.SegmentAndEntity.new()
        newEdge.entity = -1
        newEdge.type = 0 -- 0 is api.type.enum.Carrier.ROAD, 1 is api.type.enum.Carrier.RAIL
        newEdge.comp = oldEdge
        -- newEdge.playerOwned = {player = api.engine.util.getPlayer()}
        newEdge.playerOwned = api.engine.getComponent(oldEdgeId, api.type.ComponentType.PLAYER_OWNED)
        newEdge.streetEdge = oldEdgeStreet
        newEdge.streetEdge.streetType = newStreetTypeId

        -- add / remove tram tracks upgrade if the new street type explicitly wants so
        if streetUtils.isTramRightBarred(newStreetTypeId) then
            logger.print('tram barred in right lane')
            newEdge.streetEdge.tramTrackType = 0
        elseif streetUtils.isStreetAllTramTracks((api.res.streetTypeRep.get(newStreetTypeId) or {}).laneConfigs) then
            logger.print('the new street type is for trams in all lanes')
            newEdge.streetEdge.tramTrackType = 2
        end

        -- add bus lane and bar tram if the new street type wants so (paths)
        if streetUtils.hasCategory(newStreetTypeId, 'paths') then
            newEdge.streetEdge.hasBus = true
            newEdge.streetEdge.tramTrackType = 0
        end

        -- leave if nothing changed
        if newEdge.streetEdge.streetType == oldEdgeStreet.streetType
        and newEdge.streetEdge.tramTrackType == oldEdgeStreet.tramTrackType
        and newEdge.streetEdge.hasBus == oldEdgeStreet.hasBus
        then
            logger.print('nothing changed, leaving')
            return
        end

        local proposal = api.type.SimpleProposal.new()
        proposal.streetProposal.edgesToRemove[1] = oldEdgeId
        proposal.streetProposal.edgesToAdd[1] = newEdge

        logger.print('oldEdge =') logger.debugPrint(oldEdge)
        logger.print('oldEdgeStreet =') logger.debugPrint(oldEdgeStreet)
        logger.print('newEdge =') logger.debugPrint(newEdge)

        -- UG TODO this is useless coz it does not catch errors that happen later, caused by the proposal.
        -- local proposalData = api.engine.util.proposal.makeProposalData(proposal, context)
        -- local proposalData = api.engine.util.proposal.makeProposalData(proposal)
        -- logger.print('proposalData =') logger.debugPrint(proposalData)
        -- if proposalData.errorState.critical then
        --     logger.print('proposalData.errorState.critical')
        --     return
        -- end

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(proposal, nil, true),
            function(res, success)
                -- print('LOLLO res = ') -- debugPrint(res)
                -- print('LOLLO _replaceEdgeWithStreetType success = ') -- debugPrint(success)
                if not(success) then
                    logger.warn('replaceEdgeWithStreetType failed, proposal = ') logger.warningDebugPrint(proposal)
                end
            end
        )
    end,

    splitEdge = function(wholeEdgeId, nodeBetween)
        if not(edgeUtils.isValidAndExistingId(wholeEdgeId)) or edgeUtils.isEdgeFrozen(wholeEdgeId) or type(nodeBetween) ~= 'table' then return end

        local oldBaseEdge = api.engine.getComponent(wholeEdgeId, api.type.ComponentType.BASE_EDGE)
        local oldBaseEdgeStreet = api.engine.getComponent(wholeEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
        -- save a crash when a modded road underwent a breaking change, so it has no oldEdgeStreet
        if oldBaseEdge == nil or oldBaseEdgeStreet == nil then return end

        local node0 = api.engine.getComponent(oldBaseEdge.node0, api.type.ComponentType.BASE_NODE)
        local node1 = api.engine.getComponent(oldBaseEdge.node1, api.type.ComponentType.BASE_NODE)
        if node0 == nil or node1 == nil then return end

        if not(comparisonUtils.isXYZsSame(nodeBetween.refPosition0, node0.position)) and not(comparisonUtils.isXYZsSame(nodeBetween.refPosition0, node1.position)) then
            logger.warn('splitEdge cannot find the nodes')
            return
        end

        if comparisonUtils.isXYZsSame(nodeBetween.refPosition0, node0.position) then
            logger.print('nodeBetween is orientated like my edge')
        else
            logger.print('nodeBetween is not orientated like my edge')
            nodeBetween.refDistance0, nodeBetween.refDistance1 = nodeBetween.refDistance1, nodeBetween.refDistance0
            nodeBetween.refPosition0, nodeBetween.refPosition1 = nodeBetween.refPosition1, nodeBetween.refPosition0
            nodeBetween.refTangent0, nodeBetween.refTangent1 = nodeBetween.refTangent1, nodeBetween.refTangent0
            nodeBetween.tangent = transfUtils.getVectorMultiplied(nodeBetween.tangent, -1)
        end
        local distance0 = nodeBetween.refDistance0
        local distance1 = nodeBetween.refDistance1

        local oldTan0Length = transfUtils.getVectorLength(oldBaseEdge.tangent0)
        local oldTan1Length = transfUtils.getVectorLength(oldBaseEdge.tangent1)

        local playerOwned = api.type.PlayerOwned.new()
        playerOwned.player = api.engine.util.getPlayer()

        local newNodeBetween = api.type.NodeAndEntity.new()
        newNodeBetween.entity = -3
        newNodeBetween.comp.position = api.type.Vec3f.new(nodeBetween.position.x, nodeBetween.position.y, nodeBetween.position.z)

        local newEdge0 = api.type.SegmentAndEntity.new()
        newEdge0.entity = -1
        newEdge0.type = 0 -- 0 is api.type.enum.Carrier.ROAD, 1 is api.type.enum.Carrier.RAIL
        newEdge0.comp.node0 = oldBaseEdge.node0
        newEdge0.comp.node1 = -3
        newEdge0.comp.tangent0 = api.type.Vec3f.new(
            oldBaseEdge.tangent0.x * distance0 / oldTan0Length,
            oldBaseEdge.tangent0.y * distance0 / oldTan0Length,
            oldBaseEdge.tangent0.z * distance0 / oldTan0Length
        )
        newEdge0.comp.tangent1 = api.type.Vec3f.new(
            nodeBetween.tangent.x * distance0,
            nodeBetween.tangent.y * distance0,
            nodeBetween.tangent.z * distance0
        )
        newEdge0.comp.type = oldBaseEdge.type -- respect bridge or tunnel
        newEdge0.comp.typeIndex = oldBaseEdge.typeIndex -- respect bridge or tunnel type
        newEdge0.playerOwned = playerOwned
        newEdge0.streetEdge = oldBaseEdgeStreet

        local newEdge1 = api.type.SegmentAndEntity.new()
        newEdge1.entity = -2
        newEdge1.type = 0 -- 0 is api.type.enum.Carrier.ROAD, 1 is api.type.enum.Carrier.RAIL
        newEdge1.comp.node0 = -3
        newEdge1.comp.node1 = oldBaseEdge.node1
        newEdge1.comp.tangent0 = api.type.Vec3f.new(
            nodeBetween.tangent.x * distance1,
            nodeBetween.tangent.y * distance1,
            nodeBetween.tangent.z * distance1
        )
        newEdge1.comp.tangent1 = api.type.Vec3f.new(
            oldBaseEdge.tangent1.x * distance1 / oldTan1Length,
            oldBaseEdge.tangent1.y * distance1 / oldTan1Length,
            oldBaseEdge.tangent1.z * distance1 / oldTan1Length
        )
        newEdge1.comp.type = oldBaseEdge.type
        newEdge1.comp.typeIndex = oldBaseEdge.typeIndex
        newEdge1.playerOwned = playerOwned
        newEdge1.streetEdge = oldBaseEdgeStreet

        if type(oldBaseEdge.objects) == 'table' then
            -- local edge0StationGroups = {}
            -- local edge1StationGroups = {}
            local edge0Objects = {}
            local edge1Objects = {}
            for _, edgeObj in pairs(oldBaseEdge.objects) do
                local edgeObjPosition = edgeUtils.getObjectPosition(edgeObj[1])
                -- print('edge object position =') debugPrint(edgeObjPosition)
                if type(edgeObjPosition) ~= 'table' then return end -- change nothing and leave
                local assignment = _utils.getWhichEdgeGetsEdgeObjectAfterSplit(
                    edgeObjPosition,
                    {node0.position.x, node0.position.y, node0.position.z},
                    {node1.position.x, node1.position.y, node1.position.z},
                    nodeBetween
                )
                if assignment.assignToSide == 0 then
                    -- LOLLO NOTE if we skip this check,
                    -- one can split a road between left and right terminals of a streetside staion
                    -- and add more terminals on the new segments.
                    -- local stationGroupId = api.engine.system.stationGroupSystem.getStationGroup(edgeObj[1])
                    -- if arrayUtils.arrayHasValue(edge1StationGroups, stationGroupId) then return end -- don't split station groups
                    -- if edgeUtils.isValidId(stationGroupId) then table.insert(edge0StationGroups, stationGroupId) end
                    table.insert(edge0Objects, { edgeObj[1], edgeObj[2] })
                elseif assignment.assignToSide == 1 then
                    -- local stationGroupId = api.engine.system.stationGroupSystem.getStationGroup(edgeObj[1])
                    -- if arrayUtils.arrayHasValue(edge0StationGroups, stationGroupId) then return end -- don't split station groups
                    -- if edgeUtils.isValidId(stationGroupId) then table.insert(edge1StationGroups, stationGroupId) end
                    table.insert(edge1Objects, { edgeObj[1], edgeObj[2] })
                else
                    -- print('don\'t change anything and leave')
                    -- print('LOLLO error, assignment.assignToSide =', assignment.assignToSide)
                    return -- change nothing and leave
                end
            end
            newEdge0.comp.objects = edge0Objects -- LOLLO NOTE cannot insert directly into edge0.comp.objects. Different tables are handled differently...
            newEdge1.comp.objects = edge1Objects
        end

        local proposal = api.type.SimpleProposal.new()
        proposal.streetProposal.edgesToAdd[1] = newEdge0
        proposal.streetProposal.edgesToAdd[2] = newEdge1
        proposal.streetProposal.edgesToRemove[1] = wholeEdgeId
        proposal.streetProposal.nodesToAdd[1] = newNodeBetween

        local context = api.type.Context:new()
        context.checkTerrainAlignment = true -- default is false, true gives smoother Z
        -- context.cleanupStreetGraph = true -- default is false
        -- context.gatherBuildings = true  -- default is false
        -- context.gatherFields = true -- default is true
        context.player = api.engine.util.getPlayer() -- default is -1

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(proposal, context, true), -- the 3rd param is "ignore errors"; wrong proposals will be discarded anyway
            function(result, success)
                -- print('LOLLO street splitter callback returned result = ')
                -- debugPrint(result)
                -- print('LOLLO street splitter callback returned success = ', success)
                if not(success) then
                    print('Warning: streetTuning.splitEdge failed, result = ') debugPrint(result)
                end
            end
        )
    end,
}

function data()
    return {
        guiInit = function()
            -- make param window resizable coz our parameters are massive
			for _, id in pairs({
				'menu.construction.road.settingsWindow',
				-- 'menu.construction.rail.settingsWindow',
				-- 'menu.construction.water.settingsWindow',
				-- 'menu.construction.air.settingsWindow',
				-- 'menu.construction.terrain.settingsWindow',
				-- 'menu.construction.town.settingsWindow',
				-- 'menu.construction.industry.settingsWindow',
				'menu.modules.settingsWindow',
			}) do
				local iLayoutItem = api.gui.util.getById(id)
				if iLayoutItem ~= nil then
					iLayoutItem:setResizable(true)
                    iLayoutItem:setMaximumSize(api.gui.util.Size.new(800,1200))
					iLayoutItem:setIcon('ui/hammer19.tga')
				end
			end
            -- read variables
            _guiWaypoints.streetEdgeRemover.modelId = api.res.modelRep.find(_guiWaypoints.streetEdgeRemover.fileName)
            _guiWaypoints.trackEdgeRemover.modelId = api.res.modelRep.find(_guiWaypoints.trackEdgeRemover.fileName)
		end,
        handleEvent = function(src, id, name, args)
            if (id ~= _eventId) then return end
            if type(args) ~= 'table' then return end

            xpcall(
                function()
                    logger.print('handleEvent firing, src =', src, 'id =', id, 'name =', name, 'args =') logger.debugPrint(args)
--[[
                    if name == _eventProperties.lollo_street_chunks.eventName
                    or name == _eventProperties.lollo_street_hairpin.eventName
                    or name == _eventProperties.lollo_street_merge.eventName
                    then
                        -- if edgeUtils.isValidAndExistingId(args.conId) then
                        -- LOLLO NOTE as of build 35050 (or the one before),
                        -- transforming unsnapping edge nodes into snapping ones might break the connection
                        -- and game.interface.upgradeConstruction often fails to restore it.
                        -- This breaks wysiwyg, so we don't do it anymore.
                        -- _actions.replaceConWithSnappyCopy(args.conId)
                        -- return here or it will be bulldozed, all following cons get bulldozed
                        -- end
                    elseif name == _eventProperties.lollo_street_splitter.eventName then
]]
                    if name == _eventProperties.lollo_street_splitter.eventName then
                        -- do nothing
                        _actions.bulldozeConstruction(args.conId)
                    elseif name == _eventProperties.lollo_street_cleaver.eventName then
                        local conTransf = _utils.getConTransf(args.conId)
                        if conTransf ~= nil then
                            local nearestEdgeId = edgeUtils.street.getNearestEdgeId(conTransf, conTransf[15])
                            _actions.cleaveEdge(nearestEdgeId)
                        end
                        _actions.bulldozeConstruction(args.conId)
                    elseif name == _eventProperties.lollo_street_remover.eventName then
                        local conTransf = _utils.getConTransf(args.conId)
                        if conTransf ~= nil then
                            local nearestEdgeId = edgeUtils.street.getNearestEdgeId(conTransf, conTransf[15])
                            _actions.removeEdge(nearestEdgeId)
                        end
                        _actions.bulldozeConstruction(args.conId)
                    elseif name == _eventProperties.lollo_street_remover_waypoint.eventName then
                        _actions.removeEdge(args.edgeId)
                    elseif name == _eventProperties.lollo_street_splitter_w_api.eventName then
                        local conTransf = _utils.getConTransf(args.conId)
                        if conTransf ~= nil then
                            local nearestEdgeId = edgeUtils.street.getNearestEdgeId(
                                conTransf,
                                conTransf[15] + constants.splitterZShift - constants.splitterZToleranceM,
                                conTransf[15] + constants.splitterZShift + constants.splitterZToleranceM
                            )
                            logger.print('street splitter got nearestEdge =', nearestEdgeId or 'NIL')
                            if edgeUtils.isValidAndExistingId(nearestEdgeId) and not(edgeUtils.isEdgeFrozen(nearestEdgeId)) then
                                local averageZ = _utils.getAverageZ(nearestEdgeId)
                                logger.print('averageZ =', averageZ or 'NIL')
                                if type(averageZ) == 'number' then
                                    local nodeBetween = edgeUtils.getNodeBetweenByPosition(
                                        nearestEdgeId,
                                        -- LOLLO NOTE position and transf are always very similar
                                        {
                                            x = conTransf[13],
                                            y = conTransf[14],
                                            z = averageZ,
                                        },
                                        true
                                    )
                                    logger.print('nodeBetween =') logger.debugPrint(nodeBetween)
                                    _actions.splitEdge(nearestEdgeId, nodeBetween)
                                end
                                -- this is a little more accurate, but it's also harder to use with tunnels and bridges.
                                -- a user error can throw it out of whack more than the averageZ does.
                                -- local nodeBetween = edgeUtils.getNodeBetweenByPosition(
                                --     nearestEdgeId,
                                --     -- LOLLO NOTE position and transf are always very similar
                                --     {
                                --         x = conTransf[13],
                                --         y = conTransf[14],
                                --         z = conTransf[15] + constants.splitterZShift,
                                --     },
                                --     true,
                                --     logger.isExtendedLog()
                                -- )
                                -- logger.print('nodeBetween =') logger.debugPrint(nodeBetween)
                                -- _actions.splitEdge(nearestEdgeId, nodeBetween)
                            end
                        end
                        _actions.bulldozeConstruction(args.conId)
                    elseif name == _eventProperties.lollo_street_changer.eventName then
                        local conTransf = _utils.getConTransf(args.conId)
                        if conTransf ~= nil then
                            local nearestEdgeId = edgeUtils.street.getNearestEdgeId(conTransf, conTransf[15])
                            _actions.replaceEdgeWithSame(nearestEdgeId)
                        end
                        _actions.bulldozeConstruction(args.conId)
                    elseif name == _eventProperties.lollo_toggle_all_tram_tracks.eventName then
                        local conTransf = _utils.getConTransf(args.conId)
                        if conTransf ~= nil then
                            local nearestEdgeId = edgeUtils.street.getNearestEdgeId(conTransf, conTransf[15])
                            logger.print('toggle all tram tracks got nearestEdgeId =', nearestEdgeId or 'NIL')
                            if edgeUtils.isValidAndExistingId(nearestEdgeId) and not(edgeUtils.isEdgeFrozen(nearestEdgeId)) then
                                local oldEdgeStreet = api.engine.getComponent(nearestEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
                                if oldEdgeStreet ~= nil and oldEdgeStreet.streetType ~= nil then
                                    local newStreetTypeFileName = _utils.getToggledAllTramTracksStreetTypeFileName(
                                        api.res.streetTypeRep.getFileName(oldEdgeStreet.streetType)
                                    )
                                    -- logger.print('newStreetTypeFileName =', newStreetTypeFileName or 'NIL')
                                    if type(newStreetTypeFileName) == 'string' then
                                        _actions.replaceEdgeWithStreetType(
                                            nearestEdgeId,
                                            api.res.streetTypeRep.find(newStreetTypeFileName)
                                        )
                                    end
                                end
                            end
                        end
                        _actions.bulldozeConstruction(args.conId)
                    elseif name == _eventProperties.lollo_street_get_info.eventName then
                        local conTransf = _utils.getConTransf(args.conId)
                        if conTransf ~= nil then
                            local nearbyEdges = edgeUtils.getNearbyObjects(conTransf, 0.5, api.type.ComponentType.BASE_EDGE)
                            -- local nearbyConstructions = edgeUtils.getNearbyObjects(conTransf, 0.5, api.type.ComponentType.CONSTRUCTION)
                            print('nearby edges = <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
                            for edgeId, props in pairs(nearbyEdges) do
                                if edgeUtils.isValidId(edgeId) then
                                    print('<<<<<<<< edge id =', edgeId)
                                    debugPrint(props)

                                    print('node0 props =')
                                    if edgeUtils.isValidId(props.node0) then
                                        debugPrint(api.engine.getComponent(props.node0, api.type.ComponentType.BASE_NODE))
                                    end
                                    print('node1 props =')
                                    if edgeUtils.isValidId(props.node1) then
                                        debugPrint(api.engine.getComponent(props.node1, api.type.ComponentType.BASE_NODE))
                                    end

                                    print('lengths =')
                                    debugPrint(edgeUtils.getEdgeLength(edgeId, true))

                                    print('street edge props =')
                                    local streetEdgeProps = api.engine.getComponent(edgeId, api.type.ComponentType.BASE_EDGE_STREET)
                                    debugPrint(streetEdgeProps)

                                    if streetEdgeProps ~= nil and type(streetEdgeProps.streetType) == 'number' and streetEdgeProps.streetType > -1 then
                                        print('streetTypeFileName =')
                                        debugPrint(api.res.streetTypeRep.getFileName(streetEdgeProps.streetType))
                                    end
                                    print('track edge props =')
                                    local trackEdgeProps = api.engine.getComponent(edgeId, api.type.ComponentType.BASE_EDGE_TRACK)
                                    debugPrint(trackEdgeProps)
                                    if trackEdgeProps ~= nil and type(trackEdgeProps.trackType) == 'number' and trackEdgeProps.trackType > -1 then
                                        print('trackTypeFileName =')
                                        debugPrint(api.res.trackTypeRep.getFileName(trackEdgeProps.trackType))
                                    end
                                    print('>>>>>>>>')
                                end
                            end
                            --[[
                                -- put the following in the console:
                                fileName = 'construction_name.con'
                                position = {0, 0, 0}
                                searchRadius = 99999
                                cons = game.interface.getEntities({pos = position, radius = searchRadius}, {type = 'CONSTRUCTION', includeData = false, fileName = fileName})
                            ]]
                            print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
                            -- The following can freeze the game when pointed at a freestyle station
                            -- print('nearby constructions = <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
                            -- for conId, props in pairs(nearbyConstructions) do
                            --     if edgeUtils.isValidId(conId) then
                            --         print('construction id =', conId)
                            --         debugPrint(props)
                            --     end
                            -- end
                            -- print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
                        end
                        _actions.bulldozeConstruction(args.conId)
                    elseif name == _eventProperties.noTramRightRoadBuilt.eventName then
                        _actions.replaceEdgeWithStreetType(args.edgeId, args.streetTypeId)
                    elseif name == _eventProperties.pathBuilt.eventName then
                        _actions.replaceEdgeWithStreetType(args.edgeId, args.streetTypeId)
                    end
                end,
                logger.xpErrorHandler
            )
        end,
        guiHandleEvent = function(id, name, args)
            -- LOLLO NOTE args can have different types, even boolean, depending on the event id and name
            if id == 'constructionBuilder' and name == 'builder.apply' then
                -- if name == 'builder.proposalCreate' then return end
                logger.print('guiHandleEvent caught id = constructionBuilder and name = builder.apply')
                xpcall(
                    function()
                        if not args or not args.result or not args.result[1] then return end
                        if args.data.errorState and args.data.errorState.critical then logger.warn('cannot build or rebuild because of a critical error') return end

                        if _isBuildingStreetCleaver(args) then
                            _guiUtils.sendCommandWithConId(_eventProperties.lollo_street_cleaver.eventName, args)
                        elseif _isBuildingStreetSplitter(args) then
                            _guiUtils.sendCommandWithConId(_eventProperties.lollo_street_splitter.eventName, args)
                        elseif _isBuildingStreetSplitterWithApi(args) then
                            _guiUtils.sendCommandWithConId(_eventProperties.lollo_street_splitter_w_api.eventName, args)
                        elseif _isBuildingStreetGetInfo(args) then
                            _guiUtils.sendCommandWithConId(_eventProperties.lollo_street_get_info.eventName, args)
                        elseif _isBuildingStreetChanger(args) then
                            _guiUtils.sendCommandWithConId(_eventProperties.lollo_street_changer.eventName, args)
                        -- we don't do this anymore, see the NOTE above
                        -- elseif _isBuildingStreetChunks(args) then
                        --     logger.print('chunks built')
                        --     _guiUtils.sendCommand(_eventProperties.lollo_street_chunks.eventName, args)
                        -- elseif _isBuildingStreetHairpin(args) then
                        --     logger.print('hairpin built')
                        --     _guiUtils.sendCommand(_eventProperties.lollo_street_hairpin.eventName, args)
                        -- elseif _isBuildingStreetMerge(args) then
                        --     logger.print('merge built')
                        --     _guiUtils.sendCommand(_eventProperties.lollo_street_merge.eventName, args)
                        elseif _isBuildingStreetRemover(args) then
                            _guiUtils.sendCommandWithConId(_eventProperties.lollo_street_remover.eventName, args)
                        elseif _isBuildingToggleAllTracks(args) then
                            _guiUtils.sendCommandWithConId(_eventProperties.lollo_toggle_all_tram_tracks.eventName, args)
                        end
                    end,
                    logger.xpErrorHandler
                )
            elseif (id == 'streetBuilder' or id == 'streetTrackModifier') and name == 'builder.apply' then
                -- I get here in 3 cases:
                -- 1) a new street is built (id = streetBuilder)
                -- 2) an existing street is changed to a different type (id = streetTrackModifier)
                -- 3) an existing street is changed with the upgrade tool (ie bus lane or tram tracks are added or removed)
                -- (id = streetTrackModifier)
                -- I want to override cases 1 and 2, and maybe 3: if a street with no trams in the rightmost lane is built,
                -- I need to downgrade it to "no tram tracks",
                -- otherwise trams will still try to ride in the rightmost lane.
                -- It can be done by hand but this is handier.
                -- logger.print('guiHandleEvent caught id =', id, 'and name = builder.apply')
                -- local function _getRemovedSegment(removedSegments, addedSegment)
                --     if not(removedSegments) or not(addedSegment) or not(addedSegment.comp) then return nil end

                --     for i = 1, #removedSegments do
                --         if removedSegments[i] and removedSegments[i].comp then
                --             -- LOLLO TODO this estimator may not be good enough
                --             if removedSegments[i].comp.node0 == addedSegment.comp.node0
                --             and removedSegments[i].comp.node1 == addedSegment.comp.node1
                --             -- these won't necessarily work, the tangents might get optimised
                --             -- and removedSegments[i].comp.tangent0 == addedSegment.comp.tangent0
                --             -- and removedSegments[i].comp.tangent1 == addedSegment.comp.tangent1
                --             then
                --                 return removedSegments[i]
                --             end
                --         end
                --     end
                --     return nil
                -- end
                -- local function _getRemovedSegmentSimple(removedSegments, i)
                --     -- this is simple but it might just work
                --     if not(removedSegments) then
                --         return nil
                --     else
                --         return removedSegments[i]
                --     end
                -- end
                xpcall(
                    function()
                        -- logger.print('guiHandleEvent caught id =', id, 'name =', name, 'args =') logger.debugPrint(args)
                        if not(args) or not(args.proposal) or not(args.proposal.proposal)
                        or not(args.proposal.proposal.addedSegments)
                        or not(args.data) or not(args.data.entity2tn) then return end

                        if (not(args.data.errorState) or not(args.data.errorState.critical))
                        then
                            local addedSegments = args.proposal.proposal.addedSegments

                            -- remove right lane tram tracks if forbidden for current road
                            local removeTramTrackEventParams = {}
                            for _, addedSegment in pairs(addedSegments) do
                                if addedSegment
                                and addedSegment.streetEdge
                                and addedSegment.streetEdge.streetType ~= nil
                                and addedSegment.streetEdge.tramTrackType ~= 0
                                and edgeUtils.isValidAndExistingId(addedSegment.entity)
                                then
                                    if streetUtils.isTramRightBarred(addedSegment.streetEdge.streetType) then
                                        local conId = api.engine.system.streetConnectorSystem.getConstructionEntityForEdge(addedSegment.entity)
                                        if not(edgeUtils.isValidId(conId)) then -- do not touch frozen segments
                                            removeTramTrackEventParams[#removeTramTrackEventParams+1] = {
                                                edgeId = addedSegment.entity,
                                                streetTypeId = addedSegment.streetEdge.streetType
                                            }
                                        end
                                    end
                                end
                            end
                            for i = 1, #removeTramTrackEventParams do
                                api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                                    string.sub(debug.getinfo(1, 'S').source, 1),
                                    _eventId,
                                    _eventProperties.noTramRightRoadBuilt.eventName,
                                    removeTramTrackEventParams[i]
                                ))
                            end

                            -- add bus lane right if required for current road
                            -- LOLLO NOTE
                            -- this used to cause crashes with build 35050 and the paths that turn into bridges from the freestyle station.
                            local pathBuiltEventParams = {}
                            for _, addedSegment in pairs(addedSegments) do
                                if addedSegment
                                and addedSegment.streetEdge
                                and addedSegment.streetEdge.streetType ~= nil
                                and (not(addedSegment.streetEdge.hasBus) or addedSegment.tramTrackType ~= 0)
                                and edgeUtils.isValidAndExistingId(addedSegment.entity)
                                then
                                    if streetUtils.hasCategory(addedSegment.streetEdge.streetType, 'paths') then
                                        -- print('addedSegment =') debugPrint(addedSegment)
                                        local conId = api.engine.system.streetConnectorSystem.getConstructionEntityForEdge(addedSegment.entity)
                                        if not(edgeUtils.isValidId(conId)) then -- do not touch frozen segments
                                            pathBuiltEventParams[#pathBuiltEventParams+1] = {
                                                edgeId = addedSegment.entity,
                                                streetTypeId = addedSegment.streetEdge.streetType
                                            }
                                        end
                                    end
                                end
                            end
                            for i = 1, #pathBuiltEventParams do
                                api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                                    string.sub(debug.getinfo(1, 'S').source, 1),
                                    _eventId,
                                    _eventProperties.pathBuilt.eventName,
                                    pathBuiltEventParams[i]
                                ))
                            end
                        end

                        -- we don't change any more stuff, the rest is ok as it is
                    end,
                    logger.xpErrorHandler
                )
            elseif (name == 'builder.apply' and id == 'streetTerminalBuilder') then
                xpcall(
                    function()
                        -- logger.print('guiHandleEvent caught id =', id, 'name =', name, 'args =')
                        -- waypoint, traffic light, my own waypoints built
                        if args and args.proposal and args.proposal.proposal
                        and args.proposal.proposal.edgeObjectsToAdd
                        and args.proposal.proposal.edgeObjectsToAdd[1]
                        and args.proposal.proposal.edgeObjectsToAdd[1].modelInstance
                        then
                            -- LOLLO NOTE as I added an edge object, I have NOT split the edge
                            local modelId = args.proposal.proposal.edgeObjectsToAdd[1].modelInstance.modelId
                            if modelId == _guiWaypoints.streetEdgeRemover.modelId or modelId == _guiWaypoints.trackEdgeRemover.modelId then
                                logger.print('args.proposal.proposal.edgeObjectsToAdd[1] =') logger.debugPrint(args.proposal.proposal.edgeObjectsToAdd[1])
                                _guiUtils.sendCommandWithArgs(
                                    _eventProperties.lollo_street_remover_waypoint.eventName,
                                    {
                                        edgeId = args.proposal.proposal.edgeObjectsToAdd[1].segmentEntity,
                                    }
                                )
                            end
                        end
                    end,
                    logger.xpErrorHandler
                )
            end
        end,
        -- update = function()
        -- end,
        -- guiUpdate = function()
        -- end,
    }
end
