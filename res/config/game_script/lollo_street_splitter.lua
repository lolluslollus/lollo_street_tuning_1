local arrayUtils = require('lollo_street_tuning.arrayUtils')
local edgeUtils = require('lollo_street_tuning.edgeHelper')
local streetUtils = require('lollo_street_tuning.streetUtils')
local stringUtils = require('lollo_street_tuning/stringUtils')

local function _isBuildingOneOfMine(param, fileName)
    local toAdd =
        type(param) == 'table' and type(param.proposal) == 'userdata' and type(param.proposal.toAdd) == 'userdata' and
        param.proposal.toAdd

    if toAdd and #toAdd > 0 then
        for i = 1, #toAdd do
            if toAdd[i].fileName == fileName then
                return true
            end
        end
    end

    return false
end

local function _isBuildingStreetChanger(param)
    return _isBuildingOneOfMine(param, 'lollo_street_changer.con')
end

local function _isBuildingStreetGetInfo(param)
    return _isBuildingOneOfMine(param, 'lollo_street_get_info.con')
end

local function _isBuildingStreetSplitter(param)
    return _isBuildingOneOfMine(param, 'lollo_street_splitter.con')
end

local function _isBuildingStreetSplitterWithApi(param)
    return _isBuildingOneOfMine(param, 'lollo_street_splitter_w_api.con')
end

local function _isBuildingToggleAllTracks(param)
    return _isBuildingOneOfMine(param, 'lollo_toggle_all_tram_tracks.con')
end

local function _myErrorHandler(err)
    print('lollo street splitter ERROR: ', err)
end

local function _getToggleAllTramTracksStreetTypeFileName(streetFileName)
    if type(streetFileName) ~= 'string' or streetFileName == '' then return nil end

    -- print('KKKKKKKKKKKKKKKK')
    -- debugPrint(streetUtils.getGlobalStreetData(streetUtils.getStreetDataFilters().STOCK))
    -- print('KKKKKKKKKKKKKKKK')
    local allStreetData = streetUtils.getGlobalStreetData(streetUtils.getStreetDataFilters().STOCK_AND_RESERVED_LANES)
    -- print('allStreetData has', #allStreetData, 'records')
    local oldStreetProperties = nil
    for _, value in pairs(allStreetData) do
        if value.fileName == streetFileName then
            oldStreetProperties = value
            break
        end
    end
    if not(oldStreetProperties) then return nil end

    local sameSizeStreetsProperties = {}
    for _, value in pairs(allStreetData) do
        if value.fileName ~= streetFileName
        and value.isAllTramTracks ~= oldStreetProperties.isAllTramTracks
        and value.laneCount == oldStreetProperties.laneCount
        and value.sidewalkWidth == oldStreetProperties.sidewalkWidth
        and value.streetWidth == oldStreetProperties.streetWidth then
            sameSizeStreetsProperties[#sameSizeStreetsProperties+1] = value
        end
    end
    if #sameSizeStreetsProperties == 0 then return nil end

    -- print('sameSizeStreetsProperties =')
    -- debugPrint(sameSizeStreetsProperties)

    local getConcatCategories = function(arr)
        local result = ''
        for i = 1, #arr do
            result = result .. tostring(arr[i]):lower()
        end
        return result
    end

    local oldStreetCategoriesStr = getConcatCategories(oldStreetProperties.categories)

    for i = 1, #sameSizeStreetsProperties do
        -- LOLLO TODO this estimator may be a little weak.
        -- we need a new property in streetUtils._getStreetTypesWithApi
        -- to identify similar streets with different tarmac.
        -- For the moment, we can probably toggle multiple times.
        if getConcatCategories(sameSizeStreetsProperties[i].categories) == oldStreetCategoriesStr then
            return sameSizeStreetsProperties[i].fileName
        end
    end

    return nil
end

local function _replaceEdgeDestroyingBuildings(oldEdge)
    -- LOLLO NOTE this thing destroys all buildings along the edges that it replaces.
    local proposal = api.type.SimpleProposal.new()

    local newEdge = api.type.SegmentAndEntity.new()
    newEdge.entity = -1
    newEdge.comp.node0 = oldEdge.node0
    newEdge.comp.node1 = oldEdge.node1
    newEdge.comp.tangent0 = api.type.Vec3f.new(oldEdge.node0tangent[1], oldEdge.node0tangent[2], oldEdge.node0tangent[3])
    newEdge.comp.tangent1 = api.type.Vec3f.new(oldEdge.node1tangent[1], oldEdge.node1tangent[2], oldEdge.node1tangent[3])
    newEdge.comp.type = 0
    newEdge.comp.typeIndex = 0
    -- edge0.comp.objects = {{ -1, 1 }} --
    newEdge.type = 0
    newEdge.streetEdge = api.type.BaseEdgeStreet.new()
    newEdge.streetEdge.streetType = api.res.streetTypeRep.find(oldEdge.streetType)

    proposal.streetProposal.edgesToAdd[1] = newEdge
    proposal.streetProposal.edgesToRemove[1] = oldEdge.id

    local context = api.type.Context:new()
    context.checkTerrainAlignment = false
    context.cleanupStreetGraph = true -- default is false, it seems to do nothing
    context.gatherBuildings = false -- buildings are destroyed anyway
    context.gatherFields = true
    context.player = api.engine.util.getPlayer() -- buildings are destroyed anyway

    local callback = function(res, success)
        print('LOLLO street changer callback returned res = ')
        debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print(success)
    end

    local cmd = api.cmd.make.buildProposal(proposal, context, true) -- true means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
    api.cmd.sendCommand(cmd, callback)
end

local function _replaceEdge(oldEdge)
    -- LOLLO NOTE this replaces the street without destroying the buildings
    if type(oldEdge) ~= 'table' then return end

	local baseEdge = api.engine.getComponent(oldEdge.id, api.type.ComponentType.BASE_EDGE)
	local baseEdgeStreet = api.engine.getComponent(oldEdge.id, api.type.ComponentType.BASE_EDGE_STREET)

	local newEdge = api.type.SegmentAndEntity.new()
	newEdge.entity = -1
	newEdge.type = 0
    newEdge.comp = baseEdge
    -- newEdge.playerOwned = {player = api.engine.util.getPlayer()}
    newEdge.playerOwned = oldEdge.playerOwned
	newEdge.streetEdge = baseEdgeStreet
	-- eo.streetEdge.streetType = api.res.streetTypeRep.find(streetEdgeEntity.streetType)

    local proposal = api.type.SimpleProposal.new()
	proposal.streetProposal.edgesToRemove[1] = oldEdge.id
    proposal.streetProposal.edgesToAdd[1] = newEdge
    --[[ local sampleNewEdge =
    {
      entity = -1,
      comp = {
        node0 = 13010,
        node1 = 18753,
        tangent0 = {
          x = -32.318000793457,
          y = 81.757850646973,
          z = 3.0953373908997,
        },
        tangent1 = {
          x = -34.457527160645,
          y = 80.931526184082,
          z = -1.0708819627762,
        },
        type = 0,
        typeIndex = -1,
        objects = { },
      },
      type = 0,
      params = {
        streetType = 23,
        hasBus = false,
        tramTrackType = 0,
        precedenceNode0 = 2,
        precedenceNode1 = 2,
      },
      playerOwned = nil,
      streetEdge = {
        streetType = 23,
        hasBus = false,
        tramTrackType = 0,
        precedenceNode0 = 2,
        precedenceNode1 = 2,
      },
      trackEdge = {
        trackType = -1,
        catenary = false,
      },
    } ]]

    local callback = function(res, success)
        -- print('LOLLO res = ')
		-- debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        -- print('LOLLO success = ')
		-- debugPrint(success)
	end

	local cmd = api.cmd.make.buildProposal(proposal, nil, false)
	api.cmd.sendCommand(cmd, callback)
end

local function _replaceEdgeWithStreetType(oldEdge, newStreetType)
    -- LOLLO NOTE this replaces the street without destroying the buildings
    if type(oldEdge) ~= 'table' or newStreetType < 0 then return end

	local baseEdge = api.engine.getComponent(oldEdge.id, api.type.ComponentType.BASE_EDGE)
	local baseEdgeStreet = api.engine.getComponent(oldEdge.id, api.type.ComponentType.BASE_EDGE_STREET)

	local newEdge = api.type.SegmentAndEntity.new()
	newEdge.entity = -1
	newEdge.type = 0
    newEdge.comp = baseEdge
    -- newEdge.playerOwned = {player = api.engine.util.getPlayer()}
    newEdge.playerOwned = oldEdge.playerOwned
    newEdge.streetEdge = baseEdgeStreet
    newEdge.streetEdge.streetType = newStreetType
    -- add tram tracks upgrade if the new street type wants so
    local _newStreetProperties = api.res.streetTypeRep.get(newStreetType)
    if not(_newStreetProperties) or not(_newStreetProperties.laneConfigs) then return end

    if streetUtils.getIsStreetAllTramTracks(_newStreetProperties.laneConfigs) then
        newEdge.streetEdge.tramTrackType = 2
    end
	-- eo.streetEdge.streetType = api.res.streetTypeRep.find(streetEdgeEntity.streetType)

    local proposal = api.type.SimpleProposal.new()
	proposal.streetProposal.edgesToRemove[1] = oldEdge.id
    proposal.streetProposal.edgesToAdd[1] = newEdge
    --[[ local sampleNewEdge =
    {
      entity = -1,
      comp = {
        node0 = 13010,
        node1 = 18753,
        tangent0 = {
          x = -32.318000793457,
          y = 81.757850646973,
          z = 3.0953373908997,
        },
        tangent1 = {
          x = -34.457527160645,
          y = 80.931526184082,
          z = -1.0708819627762,
        },
        type = 0,
        typeIndex = -1,
        objects = { },
      },
      type = 0,
      params = {
        streetType = 23,
        hasBus = false,
        tramTrackType = 0,
        precedenceNode0 = 2,
        precedenceNode1 = 2,
      },
      playerOwned = nil,
      streetEdge = {
        streetType = 23,
        hasBus = false,
        tramTrackType = 0,
        precedenceNode0 = 2,
        precedenceNode1 = 2,
      },
      trackEdge = {
        trackType = -1,
        catenary = false,
      },
    } ]]

    local callback = function(res, success)
        -- print('LOLLO res = ')
		-- debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        -- print('LOLLO success = ')
		-- debugPrint(success)
	end

	local cmd = api.cmd.make.buildProposal(proposal, nil, false)
	api.cmd.sendCommand(cmd, callback)
end

local function _spliceEdge(edge0, edge1)
    -- LOLLO NOTE untested function, difficult to use coz it requires two selected objects
    local proposal = api.type.SimpleProposal.new()

    local baseEdge0 = api.engine.getComponent(edge0.id, api.type.ComponentType.BASE_EDGE)
    local baseEdge1 = api.engine.getComponent(edge1.id, api.type.ComponentType.BASE_EDGE)
    local baseEdgeStreet = api.engine.getComponent(edge0.id, api.type.ComponentType.BASE_EDGE_STREET)

    local splicedEdge = api.type.SegmentAndEntity.new()
    splicedEdge.entity = -1
    splicedEdge.type = 0
    splicedEdge.comp.node0 = edge0.node0
    splicedEdge.comp.node1 = edge1.node1
    splicedEdge.comp.tangent0 = api.type.Vec3f.new(edge0.node0tangent[1], edge0.node0tangent[2], edge0.node0tangent[3])
    splicedEdge.comp.tangent1 = api.type.Vec3f.new(edge1.node1tangent[1], edge1.node1tangent[2], edge1.node1tangent[3])
    splicedEdge.comp.type = 0
    splicedEdge.comp.typeIndex = -1
    splicedEdge.playerOwned = {player = api.engine.util.getPlayer()}
    splicedEdge.streetEdge = baseEdgeStreet

    local splicedEdgeObjects = {}
    if type(baseEdge0.objects) == 'table' then
        for _, vv in pairs(baseEdge0.objects) do
            local entity = game.interface.getEntity(vv[1])
            if type(entity) == 'table' and type(entity.position) == 'table' then
                table.insert(splicedEdgeObjects, { vv[1], vv[2] })
            end
        end
    end
    if type(baseEdge1.objects) == 'table' then
        for _, vv in pairs(baseEdge1.objects) do
            local entity = game.interface.getEntity(vv[1])
            if type(entity) == 'table' and type(entity.position) == 'table' then
                table.insert(splicedEdgeObjects, { vv[1], vv[2] })
            end
        end
    end
    splicedEdge.comp.objects = splicedEdgeObjects -- LOLLO NOTE cannot insert directly into edge0.comp.objects

    proposal.streetProposal.edgesToAdd[1] = splicedEdge
    proposal.streetProposal.edgesToRemove[1] = edge0.id
    proposal.streetProposal.edgesToRemove[2] = edge1.id
    proposal.streetProposal.nodesToRemove[1] = edge1.node0.id

    local context = api.type.Context:new()
    -- context.checkTerrainAlignment = true -- default is false
    -- context.cleanupStreetGraph = true -- default is false, it seems to do nothing
    -- context.gatherBuildings = true  -- default is false
    -- context.gatherFields = true -- default is true
    context.player = api.engine.util.getPlayer() -- default is -1

    local callback = function(res, success)
        print('LOLLO street splicer callback returned res = ')
        debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print('LOLLO street splicer callback returned success = ')
        print(success)
    end

    local cmd = api.cmd.make.buildProposal(proposal, context, false) -- the third param means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
    api.cmd.sendCommand(cmd, callback)
end

local function _getWhichEdgeGetsEdgeObjectAfterSplit(edgeObjPosition, node0pos, node1pos, nodeBetween)
    local result = {
        assignToFirstEstimate = nil,
        assignToSecondEstimate = nil,
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
    -- first estimator
    local nodeBetween_Node0_Distance = edgeUtils.getVectorLength({
        nodeBetween.position[1] - node0pos[1],
        nodeBetween.position[2] - node0pos[2]
    })
    local nodeBetween_Node1_Distance = edgeUtils.getVectorLength({
        nodeBetween.position[1] - node1pos[1],
        nodeBetween.position[2] - node1pos[2]
    })
    local edgeObj_Node0_Distance = edgeUtils.getVectorLength({
        edgeObjPosition[1] - node0pos[1],
        edgeObjPosition[2] - node0pos[2]
    })
    local edgeObj_Node1_Distance = edgeUtils.getVectorLength({
        edgeObjPosition[1] - node1pos[1],
        edgeObjPosition[2] - node1pos[2]
    })
    if edgeObj_Node0_Distance < nodeBetween_Node0_Distance then
        result.assignToFirstEstimate = 0
        -- table.insert(edge0Objects, { edgeObj[1], edgeObj[2] })
    elseif edgeObj_Node1_Distance < nodeBetween_Node1_Distance then
        result.assignToFirstEstimate = 1
        -- table.insert(edge1Objects, { edgeObj[1], edgeObj[2] })
    end

    -- second estimator
    local edgeObjPosition_assignTo = nil
    local node0_assignTo = nil
    local node1_assignTo = nil
    -- at nodeBetween, I can draw the normal to the road:
    -- y = a + bx
    -- the angle is alpha = atan2(nodeBetween.tangent[2], nodeBetween.tangent[1]) + PI / 2
    -- so b = math.tan(alpha)
    -- a = y - bx
    -- so a = nodeBetween.position[2] - b * nodeBetween.position[1]
    -- points under this line will go one way, the others the other way
    local alpha = math.atan2(nodeBetween.tangent[2], nodeBetween.tangent[1]) + math.pi * 0.5
    local b = math.tan(alpha)
    if math.abs(b) < 1e+06 then
        local a = nodeBetween.position[2] - b * nodeBetween.position[1]
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
        if edgeObjPosition[1] > nodeBetween.position[1] then
            edgeObjPosition_assignTo = 0
        else
            edgeObjPosition_assignTo = 1
        end
        if node0pos[1] > nodeBetween.position[1] then
            node0_assignTo = 0
        else
            node0_assignTo = 1
        end
        if node1pos[1] > nodeBetween.position[1] then
            node1_assignTo = 0
        else
            node1_assignTo = 1
        end
    end

    if edgeObjPosition_assignTo == node0_assignTo then
        result.assignToSecondEstimate = 0
    elseif edgeObjPosition_assignTo == node1_assignTo then
        result.assignToSecondEstimate = 1
    end

    -- print('LOLLO assignment =')
    -- debugPrint(result)
    return result
end

local function _splitEdge(wholeEdge, nodeBetween)
    if type(wholeEdge) ~= 'table' or type(nodeBetween) ~= 'table' then return end

    local node0TangentLength = edgeUtils.getVectorLength({
        wholeEdge.node0tangent[1],
        wholeEdge.node0tangent[2],
        wholeEdge.node0tangent[3]
        -- 0
    })
    local node1TangentLength = edgeUtils.getVectorLength({
        wholeEdge.node1tangent[1],
        wholeEdge.node1tangent[2],
        wholeEdge.node1tangent[3]
        -- 0
    })
    local edge0Length = edgeUtils.getVectorLength({
        nodeBetween.position[1] - wholeEdge.node0pos[1],
        nodeBetween.position[2] - wholeEdge.node0pos[2],
        -- 0
        nodeBetween.position[3] - wholeEdge.node0pos[3]
    })
    local edge1Length = edgeUtils.getVectorLength({
        nodeBetween.position[1] - wholeEdge.node1pos[1],
        nodeBetween.position[2] - wholeEdge.node1pos[2],
        -- 0
        nodeBetween.position[3] - wholeEdge.node1pos[3]
    })

    local proposal = api.type.SimpleProposal.new()

    -- LOLLO NOTE api.engine.getComponent gets more properties than game.interface.getEntity()
    local baseEdge = api.engine.getComponent(wholeEdge.id, api.type.ComponentType.BASE_EDGE)
    local baseEdgeStreet = api.engine.getComponent(wholeEdge.id, api.type.ComponentType.BASE_EDGE_STREET)
    -- print('LOLLO baseEdge = ')
    -- debugPrint(baseEdge)
    -- print('LOLLO baseEdgeStreet = ')
    -- debugPrint(baseEdgeStreet)
    local playerOwned = api.type.PlayerOwned.new()
    playerOwned.player = api.engine.util.getPlayer()

    local newNodeBetween = api.type.NodeAndEntity.new()
    newNodeBetween.entity = -3
    newNodeBetween.comp.position = api.type.Vec3f.new(nodeBetween.position[1], nodeBetween.position[2], nodeBetween.position[3]) --api.type.Vec3f.new(40.0, 0.0, 0.0)

    local newEdge0 = api.type.SegmentAndEntity.new()
    newEdge0.entity = -1
    newEdge0.type = 0
    newEdge0.comp.node0 = wholeEdge.node0
    newEdge0.comp.node1 = -3
    newEdge0.comp.tangent0 = api.type.Vec3f.new(
        wholeEdge.node0tangent[1] * edge0Length / node0TangentLength,
        wholeEdge.node0tangent[2] * edge0Length / node0TangentLength,
        wholeEdge.node0tangent[3] * edge0Length / node0TangentLength
    )
    newEdge0.comp.tangent1 = api.type.Vec3f.new(
        nodeBetween.tangent[1] * edge0Length,
        nodeBetween.tangent[2] * edge0Length,
        nodeBetween.tangent[3] * edge0Length
    )
    newEdge0.comp.type = baseEdge.type -- 0 -- respect bridge or tunnel
    newEdge0.comp.typeIndex = baseEdge.typeIndex -- -1 -- respect bridge or tunnel
    newEdge0.playerOwned = playerOwned
    newEdge0.streetEdge = baseEdgeStreet

    local newEdge1 = api.type.SegmentAndEntity.new()
    newEdge1.entity = -2
    newEdge1.type = 0
    newEdge1.comp.node0 = -3
    newEdge1.comp.node1 = wholeEdge.node1
    newEdge1.comp.tangent0 = api.type.Vec3f.new(
        nodeBetween.tangent[1] * edge1Length,
        nodeBetween.tangent[2] * edge1Length,
        nodeBetween.tangent[3] * edge1Length
    )
    newEdge1.comp.tangent1 = api.type.Vec3f.new(
        wholeEdge.node1tangent[1] * edge1Length / node1TangentLength,
        wholeEdge.node1tangent[2] * edge1Length / node1TangentLength,
        wholeEdge.node1tangent[3] * edge1Length / node1TangentLength
    )
    newEdge1.comp.type = baseEdge.type -- 0
    newEdge1.comp.typeIndex = baseEdge.typeIndex -- -1
    newEdge1.playerOwned = playerOwned
    newEdge1.streetEdge = baseEdgeStreet

    if type(baseEdge.objects) == 'table' then
        local edge0Objects = {}
        local edge1Objects = {}
        for _, edgeObj in pairs(baseEdge.objects) do
            local edgeObjEntity = game.interface.getEntity(edgeObj[1])
            if type(edgeObjEntity) == 'table' and type(edgeObjEntity.position) == 'table' then
                local assignment = _getWhichEdgeGetsEdgeObjectAfterSplit(
                    edgeObjEntity.position,
                    wholeEdge.node0pos,
                    wholeEdge.node1pos,
                    nodeBetween
                )
                -- if assignment.assignToFirstEstimate == 0 then
                if assignment.assignToSecondEstimate == 0 then
                    table.insert(edge0Objects, { edgeObj[1], edgeObj[2] })
                -- elseif assignment.assignToFirstEstimate == 1 then
                elseif assignment.assignToSecondEstimate == 1 then
                    table.insert(edge1Objects, { edgeObj[1], edgeObj[2] })
                else
                    -- don't change anything and leave
                    -- print('LOLLO error, assignment.assignToFirstEstimate =', assignment.assignToFirstEstimate)
                    -- print('LOLLO error, assignment.assignToSecondEstimate =', assignment.assignToSecondEstimate)
                    return
                end
            end
        end
        newEdge0.comp.objects = edge0Objects -- LOLLO NOTE cannot insert directly into edge0.comp.objects
        newEdge1.comp.objects = edge1Objects
    end

    proposal.streetProposal.edgesToAdd[1] = newEdge0
    proposal.streetProposal.edgesToAdd[2] = newEdge1
    proposal.streetProposal.edgesToRemove[1] = wholeEdge.id
    proposal.streetProposal.nodesToAdd[1] = newNodeBetween

    local context = api.type.Context:new()
    context.checkTerrainAlignment = true -- default is false, true gives smoother Z
    -- context.cleanupStreetGraph = true -- default is false, it seems to do nothing
    -- context.gatherBuildings = true  -- default is false
    -- context.gatherFields = true -- default is true
    context.player = api.engine.util.getPlayer() -- default is -1

    local callback = function(res, success)
        -- print('LOLLO street splitter callback returned res = ')
        -- debugPrint(res)
        if success == true
        and res
        and res.resultProposalData
        and res.resultProposalData.tpNetLinkProposal
        and res.resultProposalData.tpNetLinkProposal.toAdd
        and #res.resultProposalData.tpNetLinkProposal.toAdd > 0 then
            print('LOLLO new tpNetLinkProposals', #res.resultProposalData.tpNetLinkProposal.toAdd)
            -- LOLLO TODO MAYBE undo
            -- _spliceEdge(edge0, edge1)
        end
        --for _, v in pairs(res.entities) do print(v) end
        -- print('LOLLO street splitter callback returned success = ')
        -- print(success)
    end

    local cmd = api.cmd.make.buildProposal(proposal, context, false) -- the third param means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
    api.cmd.sendCommand(cmd, callback)
end

function data()
    return {
        ini = function()
        end,
        handleEvent = function(src, id, name, param)
            if (id ~= '__lolloStreetSplitterEvent__') then return end
            if type(param) ~= 'table' or type(param.constructionEntityId) ~= 'number' then return end
            if name == 'streetSplitterBuilt' then
                -- do nothing
            elseif name == 'streetSplitterWithApiBuilt' then
                local splitterConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(splitterConstruction) == 'table' and type(splitterConstruction.transf) == 'table' then
                    local nearbyEdges = edgeUtils.getNearbyStreetEdges(splitterConstruction.transf)
                    if #nearbyEdges > 0 then
                        local nodeBetween = edgeUtils.getNodeBetween(
                            {
                                nearbyEdges[1]['node0pos'],
                                nearbyEdges[1]['node0tangent'],
                            },
                            {
                                nearbyEdges[1]['node1pos'],
                                nearbyEdges[1]['node1tangent'],
                            },
                            -- LOLLO NOTE position and transf are always very similar
                            -- {
                            --     splitterConstruction.transf[13],
                            --     splitterConstruction.transf[14],
                            --     splitterConstruction.transf[15],
                            -- },
                            splitterConstruction.position
                        )

                        _splitEdge(nearbyEdges[1], nodeBetween)
                    end
                end
            elseif name == 'streetChangerBuilt' then
                local changerConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(changerConstruction) == 'table' and type(changerConstruction.transf) == 'table' then
                    local nearbyEdges = edgeUtils.getNearbyStreetEdges(changerConstruction.transf)
                    if #nearbyEdges > 0 then
                        print('LOLLO nearbyEdges[1] = ')
                        debugPrint(nearbyEdges[1])

                        _replaceEdge(nearbyEdges[1])
                    end
                end
            elseif name == 'toggleAllTracksBuilt' then
                local myConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(myConstruction) == 'table' and type(myConstruction.transf) == 'table' then
                    -- LOLLO TODO sometimes, this selects an edge nearby: fix it
                    local nearbyEdges = edgeUtils.getNearbyStreetEdges(myConstruction.transf)
                    if #nearbyEdges > 0 then
                        local newStreetType = _getToggleAllTramTracksStreetTypeFileName(
                            nearbyEdges[1].streetType
                        )
                        if newStreetType then
                            _replaceEdgeWithStreetType(
                                nearbyEdges[1],
                                api.res.streetTypeRep.find(newStreetType)
                            )
                        end
                    end
                end
            elseif name == 'streetGetInfoBuilt' then
                local getInfoConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(getInfoConstruction) == 'table' and type(getInfoConstruction.transf) == 'table' then
                    local nearbyEntities = edgeUtils.getNearbyEntities(getInfoConstruction.transf)
                    if type(nearbyEntities) == 'table' then
                        print('LOLLO GET INFO found nearby entities = ')
                        for _, entity in pairs(nearbyEntities) do
                            debugPrint(entity)
                            if entity.type == 'BASE_EDGE' and not(stringUtils.isNullOrEmptyString(entity.streetType)) then
                                print('base edge component =')
                                debugPrint(api.engine.getComponent(entity.id, api.type.ComponentType.BASE_EDGE))
                                print('base edge street component =')
                                debugPrint(api.engine.getComponent(entity.id, api.type.ComponentType.BASE_EDGE_STREET))
                                print('street properties =')
                                debugPrint(api.res.streetTypeRep.get(api.res.streetTypeRep.find(entity.streetType)))
                            end
                            debugPrint('--------')
                        end
                    end
                end
            end

            game.interface.bulldoze(param.constructionEntityId)
        end,
        guiHandleEvent = function(id, name, param)
            -- LOLLO NOTE param can have different types, even boolean, depending on the event id and name
            if id ~= 'constructionBuilder' then return end
            if name ~= 'builder.apply' then return end
            -- if name == "builder.proposalCreate" then return end

            xpcall(
                function()
                    if not param.result or not param.result[1] then
                        return
                    end

                    -- game.interface.bulldoze(constructionEntity.id) -- cannot call it from this thread, so I raise and call it in the worker thread
                    if _isBuildingStreetSplitter(param) then
                        game.interface.sendScriptEvent(
                            '__lolloStreetSplitterEvent__',
                            'streetSplitterBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    elseif _isBuildingStreetSplitterWithApi(param) then
                        game.interface.sendScriptEvent(
                            '__lolloStreetSplitterEvent__',
                            'streetSplitterWithApiBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    elseif _isBuildingStreetGetInfo(param) then
                        game.interface.sendScriptEvent(
                            '__lolloStreetSplitterEvent__',
                            'streetGetInfoBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    elseif _isBuildingStreetChanger(param) then
                        game.interface.sendScriptEvent(
                            '__lolloStreetSplitterEvent__',
                            'streetChangerBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    elseif _isBuildingToggleAllTracks(param) then
                        game.interface.sendScriptEvent(
                            '__lolloStreetSplitterEvent__',
                            'toggleAllTracksBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    end
                end,
                _myErrorHandler
            )
        end,
        update = function()
        end,
        guiUpdate = function()
        end,
        -- save = function()
        --     return allState
        -- end,
        -- load = function(allState)
        -- end
    }
end
