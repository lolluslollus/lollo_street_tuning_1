-- local stringUtils = require('lollo_street_tuning/lolloStringUtils')
local debugger = require('debugger')
local edgeUtils = require('lollo_street_tuning.edgeHelper')

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

local function _myErrorHandler(err)
    print('lollo street splitter ERROR: ', err)
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

	local proposal = api.type.SimpleProposal.new()
	proposal.streetProposal.edgesToRemove[1] = oldEdge.id

	local baseEdge = api.engine.getComponent(oldEdge.id, api.type.ComponentType.BASE_EDGE)
	local baseEdgeStreet = api.engine.getComponent(oldEdge.id, api.type.ComponentType.BASE_EDGE_STREET)

	local newEdge = api.type.SegmentAndEntity.new()
	newEdge.entity = -1
	newEdge.type = 0
	newEdge.comp = baseEdge
	newEdge.streetEdge = baseEdgeStreet
	-- eo.streetEdge.streetType = api.res.streetTypeRep.find(streetEdgeEntity.streetType)

    proposal.streetProposal.edgesToAdd[1] = newEdge
    print('LOLLO eo = ')
    debugPrint(newEdge)
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
        print('LOLLO res = ')
		debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print('LOLLO success = ')
		debugPrint(success)
	end

	local cmd = api.cmd.make.buildProposal(proposal, nil, false)
	api.cmd.sendCommand(cmd, callback)
end

local function _splitEdgeBak(wholeEdge, nodeMid)
    -- LOLLO NOTE this thing destroys all buildings along the edges that it replaces. This defies the very purpose of this mod!
    local proposal = api.type.SimpleProposal.new()

    local edge0 = api.type.SegmentAndEntity.new()
    edge0.entity = -1
    edge0.comp.node0 = wholeEdge.node0
    edge0.comp.node1 = -3
    edge0.comp.tangent0 = api.type.Vec3f.new(wholeEdge.node0tangent[1], wholeEdge.node0tangent[2], wholeEdge.node0tangent[3])
    edge0.comp.tangent1 = api.type.Vec3f.new(nodeMid.tangent[1], nodeMid.tangent[2], nodeMid.tangent[3])
    edge0.comp.type = 0
    edge0.comp.typeIndex = 0
    -- edge0.comp.objects = {{ -1, 1 }} --
    edge0.type = 0
    edge0.streetEdge = api.type.BaseEdgeStreet.new()
    edge0.streetEdge.streetType = api.res.streetTypeRep.find(wholeEdge.streetType)

    local edge1 = api.type.SegmentAndEntity.new()
    edge1.entity = -2
    edge1.comp.node0 = -3
    edge1.comp.node1 = wholeEdge.node1
    edge1.comp.tangent0 = api.type.Vec3f.new(nodeMid.tangent[1], nodeMid.tangent[2], nodeMid.tangent[3])
    edge1.comp.tangent1 = api.type.Vec3f.new(wholeEdge.node1tangent[1], wholeEdge.node1tangent[2], wholeEdge.node1tangent[3])
    edge1.comp.type = 0
    edge1.comp.typeIndex = 0
    --edge1.comp.objects = {{ -1, 1 }}
    edge1.type = 0
    edge1.streetEdge = api.type.BaseEdgeStreet.new()
    edge1.streetEdge.streetType = api.res.streetTypeRep.find(wholeEdge.streetType)

    proposal.streetProposal.edgesToAdd[1] = edge0
    proposal.streetProposal.edgesToAdd[2] = edge1
    proposal.streetProposal.edgesToRemove[1] = wholeEdge.id

    -- eo = api.type.SimpleStreetProposal.EdgeObject.new()
    -- eo.left = true
    -- eo.model = "street/signal_waypoint.mdl"
    -- eo.playerEntity = game.interface.getPlayer()
    -- eo.oneWay = false
    -- eo.param = 0.5
    -- eo.edgeEntity = -1
    -- eo.name = "MY Beautiful Signal"

    -- proposal.streetProposal.edgeObjectsToAdd[1] = eo

    local node1 = api.type.NodeAndEntity.new()
    node1.entity = -3
    node1.comp.position = api.type.Vec3f.new(nodeMid.position[1], nodeMid.position[2], nodeMid.position[3]) --api.type.Vec3f.new(40.0, 0.0, 0.0)

    proposal.streetProposal.nodesToAdd[1] = node1


    local context = api.type.Context:new()
    context.checkTerrainAlignment = false
    context.cleanupStreetGraph = true -- default is false, it seems to do nothing
    context.gatherBuildings = false -- buildings are destroyed anyway
    context.gatherFields = true
    context.player = api.engine.util.getPlayer() -- buildings are destroyed anyway

    local callback = function(res, success)
        print('LOLLO street splitter callback returned res = ')
        debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print(success)
    end

    local cmd = api.cmd.make.buildProposal(proposal, context, true) -- true means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
    api.cmd.sendCommand(cmd, callback)
end

local function _splitEdge(wholeEdge, nodeMid)
    -- LOLLO NOTE this thing destroys all buildings along the edges that it replaces. This defies the very purpose of this mod!
    local proposal = api.type.SimpleProposal.new()

    local baseEdgeStreet = api.engine.getComponent(wholeEdge.id, api.type.ComponentType.BASE_EDGE_STREET)
    local edge0 = api.type.SegmentAndEntity.new()
    edge0.entity = -1
    edge0.type = 0
    edge0.comp.node0 = wholeEdge.node0
    edge0.comp.node1 = -3
    edge0.comp.tangent0 = api.type.Vec3f.new(wholeEdge.node0tangent[1], wholeEdge.node0tangent[2], wholeEdge.node0tangent[3])
    edge0.comp.tangent1 = api.type.Vec3f.new(nodeMid.tangent[1], nodeMid.tangent[2], nodeMid.tangent[3])
    edge0.comp.type = 0
    -- edge0.comp.typeIndex = 0
    -- edge0.comp.objects = {{ -1, 1 }} --
    edge0.streetEdge = baseEdgeStreet

    local edge1 = api.type.SegmentAndEntity.new()
    edge1.entity = -2
    edge1.type = 0
    edge1.comp.node0 = -3
    edge1.comp.node1 = wholeEdge.node1
    edge1.comp.tangent0 = api.type.Vec3f.new(nodeMid.tangent[1], nodeMid.tangent[2], nodeMid.tangent[3])
    edge1.comp.tangent1 = api.type.Vec3f.new(wholeEdge.node1tangent[1], wholeEdge.node1tangent[2], wholeEdge.node1tangent[3])
    edge1.comp.type = 0
    -- edge1.comp.typeIndex = 0
    --edge1.comp.objects = {{ -1, 1 }}
    edge1.streetEdge = baseEdgeStreet

    proposal.streetProposal.edgesToAdd[1] = edge0
    proposal.streetProposal.edgesToAdd[2] = edge1
    proposal.streetProposal.edgesToRemove[1] = wholeEdge.id

    -- eo = api.type.SimpleStreetProposal.EdgeObject.new()
    -- eo.left = true
    -- eo.model = "street/signal_waypoint.mdl"
    -- eo.playerEntity = game.interface.getPlayer()
    -- eo.oneWay = false
    -- eo.param = 0.5
    -- eo.edgeEntity = -1
    -- eo.name = "MY Beautiful Signal"

    -- proposal.streetProposal.edgeObjectsToAdd[1] = eo

    local node1 = api.type.NodeAndEntity.new()
    node1.entity = -3
    node1.comp.position = api.type.Vec3f.new(nodeMid.position[1], nodeMid.position[2], nodeMid.position[3]) --api.type.Vec3f.new(40.0, 0.0, 0.0)

    proposal.streetProposal.nodesToAdd[1] = node1


    local context = api.type.Context:new()
    context.checkTerrainAlignment = false
    context.cleanupStreetGraph = true -- default is false, it seems to do nothing
    context.gatherBuildings = false -- buildings are destroyed anyway
    context.gatherFields = true
    context.player = api.engine.util.getPlayer() -- buildings are destroyed anyway

    local callback = function(res, success)
        print('LOLLO street splitter callback returned res = ')
        debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print(success)
    end

    local cmd = api.cmd.make.buildProposal(proposal, context, true) -- true means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
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
                        local nodeMid = edgeUtils.getNodeBetween(
                            {
                                nearbyEdges[1]['node0pos'],
                                nearbyEdges[1]['node0tangent'],
                            },
                            {
                                nearbyEdges[1]['node1pos'],
                                nearbyEdges[1]['node1tangent'],
                            }
                        )
                        print('LOLLO edgeMid = ')
                        debugPrint(nodeMid)
                        print('LOLLO nearbyEdges[1] = ')
                        debugPrint(nearbyEdges[1])

                        _splitEdge(nearbyEdges[1], nodeMid)
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
            elseif name == 'streetGetInfoBuilt' then
                local getInfoConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(getInfoConstruction) == 'table' and type(getInfoConstruction.transf) == 'table' then
                    local nearbyEntities = edgeUtils.getNearbyEntities(getInfoConstruction.transf)
                    print('LOLLO nearbyEntities = ')
                    debugPrint(nearbyEntities)
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
