local edgeUtils = require('lollo_street_tuning.edgeHelper')
local streetUtils = require('lollo_street_tuning.streetUtils')
local stringUtils = require('lollo_street_tuning/stringUtils')
local transfUtilUG = require('transf')

local function _myErrorHandler(err)
    print('lollo street tuning error caught: ', err)
end

local _eventId = '__lolloStreetTuningEvent__'
local _eventProperties = {
    lollo_street_changer = { conName = 'lollo_street_changer.con', eventName = 'streetChangerBuilt' },
    lollo_street_get_info = { conName = 'lollo_street_get_info.con', eventName = 'streetGetInfoBuilt' },
    lollo_street_splitter = { conName = 'lollo_street_splitter.con', eventName = 'streetSplitterBuilt' },
    lollo_street_splitter_w_api = { conName = 'lollo_street_splitter_w_api.con', eventName = 'streetSplitterWithApiBuilt' },
    lollo_toggle_all_tram_tracks = { conName = 'lollo_toggle_all_tram_tracks.con', eventName = 'toggleAllTracksBuilt' },
    noTramRightRoadBuilt = { conName = '', eventName = 'noTramRightRoadBuilt' },
}

local function _isBuildingConstructionWithFileName(param, fileName)
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
    return _isBuildingConstructionWithFileName(param, _eventProperties.lollo_street_changer.conName)
end

local function _isBuildingStreetGetInfo(param)
    return _isBuildingConstructionWithFileName(param, _eventProperties.lollo_street_get_info.conName)
end

local function _isBuildingStreetSplitter(param)
    return _isBuildingConstructionWithFileName(param, _eventProperties.lollo_street_splitter.conName)
end

local function _isBuildingStreetSplitterWithApi(param)
    return _isBuildingConstructionWithFileName(param, _eventProperties.lollo_street_splitter_w_api.conName)
end

local function _isBuildingToggleAllTracks(param)
    return _isBuildingConstructionWithFileName(param, _eventProperties.lollo_toggle_all_tram_tracks.conName)
end

local _utils = {
    getEdgeId = function(entity2tn, addedSegment)
    -- these variables are all userdata but I can use pairs on entity2tn.
    -- the game does not populate result here, so I have to go through this.
        if not(entity2tn) or not(addedSegment) or not(addedSegment.comp) then return nil end

        for edgeId, segment in pairs(entity2tn) do
            -- the api calls them edges but they are actually lanes, and the segments are actually edges.
            -- print('segment =')
            -- debugPrint(segment)
            -- if segment.edges and segment.edges[1] and segment.edges[1].conns
            -- and segment.edges[1].conns[1] and segment.edges[1].conns[2] then
            if segment and segment.edges then
                for i = 1, #segment.edges do
                    local edge = segment.edges[i]
                    if edge and edge.conns and edge.conns[1] and edge.conns[2] then
                        local node0Id = edge.conns[1].entity
                        local node1Id = edge.conns[2].entity
                        -- print('node0Id =', node0Id)
                        -- print('node1Id =', node1Id)
                        if node0Id ~= node1Id then -- some edges are like that
                            if (node0Id == addedSegment.comp.node0 and node1Id == addedSegment.comp.node1)
                            or (node0Id == addedSegment.comp.node1 and node1Id == addedSegment.comp.node0) then
                                -- print('k =', k)
                                return edgeId
                            end
                        end
                    end
                end
            end
        end
        return nil
    end,

    getObjectPositionOld = function(objectId)
        if type(objectId) ~= 'number' or objectId < 0 then return nil end

        local edgeObjEntity = game.interface.getEntity(objectId)
        if type(edgeObjEntity) == 'table' then
            return edgeObjEntity.position
        end

        return nil
    end,

    getObjectPosition = function(objectId)
        if type(objectId) ~= 'number' or objectId < 0 then return nil end

        local modelInstanceList = api.engine.getComponent(objectId, api.type.ComponentType.MODEL_INSTANCE_LIST)
        if not(modelInstanceList) then return nil end

        local fatInstances = modelInstanceList.fatInstances
        if not(fatInstances) or not(fatInstances[1]) or not(fatInstances[1].transf) or not(fatInstances[1].transf.cols) then return nil end

        local objectTransf = transfUtilUG.new(
            fatInstances[1].transf:cols(0),
            fatInstances[1].transf:cols(1),
            fatInstances[1].transf:cols(2),
            fatInstances[1].transf:cols(3)
        )
        -- print('fatInstances[1]', fatInstances[1] and true)
        -- print('fatInstances[2]', fatInstances[2] and true) -- always nil
        -- print('fatInstances[3]', fatInstances[3] and true) -- always nil
        return {
            [1] = objectTransf[13],
            [2] = objectTransf[14],
            [3] = objectTransf[15]
        }
    end,

    getToggledAllTramTracksStreetTypeFileName = function(streetFileName)
        if type(streetFileName) ~= 'string' or streetFileName == '' then return nil end

        -- print('KKKKKKKKKKKKKKKK')
        -- debugPrint(streetUtils.getGlobalStreetData(streetUtils.getStreetDataFilters().STOCK))
        -- print('KKKKKKKKKKKKKKKK')
        local allStreetsData = streetUtils.getGlobalStreetData(streetUtils.getStreetDataFilters().STOCK_AND_RESERVED_LANES)
        -- print('allStreetsData has', #allStreetsData, 'records')
        local oldStreetData = nil
        for _, value in pairs(allStreetsData) do
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

        -- print('sameSizeStreetsProperties =')
        -- debugPrint(sameSizeStreetsProperties)

        local _getConcatCategories = function(arr)
            local result = ''
            for i = 1, #arr do
                result = result .. tostring(arr[i]):lower()
            end
            return result
        end

        local oldStreetCategoriesStr = _getConcatCategories(oldStreetData.categories)
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
            -- assignToFirstEstimate = nil,
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
        -- local nodeBetween_Node0_Distance = edgeUtils.getVectorLength({
        --     nodeBetween.position[1] - node0pos[1],
        --     nodeBetween.position[2] - node0pos[2]
        -- })
        -- local nodeBetween_Node1_Distance = edgeUtils.getVectorLength({
        --     nodeBetween.position[1] - node1pos[1],
        --     nodeBetween.position[2] - node1pos[2]
        -- })
        -- local edgeObj_Node0_Distance = edgeUtils.getVectorLength({
        --     edgeObjPosition[1] - node0pos[1],
        --     edgeObjPosition[2] - node0pos[2]
        -- })
        -- local edgeObj_Node1_Distance = edgeUtils.getVectorLength({
        --     edgeObjPosition[1] - node1pos[1],
        --     edgeObjPosition[2] - node1pos[2]
        -- })
        -- if edgeObj_Node0_Distance < nodeBetween_Node0_Distance then
        --     result.assignToFirstEstimate = 0
        -- elseif edgeObj_Node1_Distance < nodeBetween_Node1_Distance then
        --     result.assignToFirstEstimate = 1
        -- end

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
    end,
}

local _actions = {
    bulldozeConstruction = function(constructionId)
        -- print('constructionId =', constructionId)
        if type(constructionId) ~= 'number' or constructionId < 0 then return end

        local oldConstruction = api.engine.getComponent(constructionId, api.type.ComponentType.CONSTRUCTION)
        -- print('oldConstruction =')
        -- debugPrint(oldConstruction)
        if not(oldConstruction) or not(oldConstruction.params) then return end

        local proposal = api.type.SimpleProposal.new()
        -- LOLLO NOTE there are asymmetries how different tables are handled.
        -- This one requires this system, UG says they will document it or amend it.
        proposal.constructionsToRemove = { constructionId }
        -- proposal.constructionsToRemove[1] = constructionId -- fails to add
        -- proposal.constructionsToRemove:add(constructionId) -- fails to add

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(proposal, nil, false), -- the 3rd param is "ignore errors"; wrong proposals will be discarded anyway
            function(res, success)
                -- print('LOLLO _bulldozeConstruction res = ')
                -- debugPrint(res)
                --for _, v in pairs(res.entities) do print(v) end
                -- print('LOLLO _bulldozeConstruction success = ')
                -- debugPrint(success)
            end
        )
    end,

    replageEdgeWithSame = function(oldEdgeId)
        -- only for testing
        -- replaces a street segment with an identical one, without destroying the buildings
        if type(oldEdgeId) ~= 'number' or oldEdgeId < 0 then return end

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

        local proposal = api.type.SimpleProposal.new()
        proposal.streetProposal.edgesToRemove[1] = oldEdgeId
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

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(proposal, nil, false),
            function(res, success)
                -- print('LOLLO res = ')
                -- debugPrint(res)
                --for _, v in pairs(res.entities) do print(v) end
                -- print('LOLLO success = ')
                -- debugPrint(success)
            end
        )
    end,

    replaceEdgeWithStreetType = function(oldEdgeId, newStreetTypeId)
        -- replaces the street without destroying the buildings
        if type(oldEdgeId) ~= 'number' or oldEdgeId < 0
        or type(newStreetTypeId) ~= 'number' or newStreetTypeId < 0 then return end

        local oldEdge = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE)
        local oldEdgeStreet = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
        -- save a crash when a modded road underwent a breaking change, so it has no oldEdgeStreet
        if oldEdge == nil or oldEdgeStreet == nil then return end

        local newEdge = api.type.SegmentAndEntity.new()
        newEdge.entity = -1
        newEdge.type = 0
        newEdge.comp = oldEdge
        -- newEdge.playerOwned = {player = api.engine.util.getPlayer()}
        newEdge.playerOwned = api.engine.getComponent(oldEdgeId, api.type.ComponentType.PLAYER_OWNED)
        newEdge.streetEdge = oldEdgeStreet
        newEdge.streetEdge.streetType = newStreetTypeId
        -- add / remove tram tracks upgrade if the new street type explicitly wants so
        if streetUtils.transportModes.isTramRightBarred(newStreetTypeId) then
            newEdge.streetEdge.tramTrackType = 0
        elseif streetUtils.getIsStreetAllTramTracks((api.res.streetTypeRep.get(newStreetTypeId) or {}).laneConfigs) then
            newEdge.streetEdge.tramTrackType = 2
        end

        -- leave if nothing changed
        if newEdge.streetEdge.streetType == oldEdgeStreet.streetType
        and newEdge.streetEdge.tramTrackType == oldEdgeStreet.tramTrackType then return end

        local proposal = api.type.SimpleProposal.new()
        proposal.streetProposal.edgesToRemove[1] = oldEdgeId
        proposal.streetProposal.edgesToAdd[1] = newEdge

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(proposal, nil, false),
            function(res, success)
                -- print('LOLLO res = ')
                -- debugPrint(res)
                --for _, v in pairs(res.entities) do print(v) end
                -- print('LOLLO _replaceEdgeWithStreetType success = ')
                -- debugPrint(success)
            end
        )
    end,

    splitEdge = function(wholeEdgeId, position0, tangent0, position1, tangent1, nodeBetween)
        if type(wholeEdgeId) ~= 'number' or wholeEdgeId < 0 or type(nodeBetween) ~= 'table' then return end

        local node0TangentLength = edgeUtils.getVectorLength({
            tangent0.x,
            tangent0.y,
            tangent0.z
        })
        local node1TangentLength = edgeUtils.getVectorLength({
            tangent1.x,
            tangent1.y,
            tangent1.z
        })
        local edge0Length = edgeUtils.getVectorLength({
            nodeBetween.position[1] - position0.x,
            nodeBetween.position[2] - position0.y,
            nodeBetween.position[3] - position0.z
        })
        local edge1Length = edgeUtils.getVectorLength({
            nodeBetween.position[1] - position1.x,
            nodeBetween.position[2] - position1.y,
            nodeBetween.position[3] - position1.z
        })

        local oldEdge = api.engine.getComponent(wholeEdgeId, api.type.ComponentType.BASE_EDGE)
        local oldEdgeStreet = api.engine.getComponent(wholeEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
        -- save a crash when a modded road underwent a breaking change, so it has no oldEdgeStreet
        if oldEdge == nil or oldEdgeStreet == nil then return end

        local playerOwned = api.type.PlayerOwned.new()
        playerOwned.player = api.engine.util.getPlayer()

        local newNodeBetween = api.type.NodeAndEntity.new()
        newNodeBetween.entity = -3
        newNodeBetween.comp.position = api.type.Vec3f.new(nodeBetween.position[1], nodeBetween.position[2], nodeBetween.position[3])

        local newEdge0 = api.type.SegmentAndEntity.new()
        newEdge0.entity = -1
        newEdge0.type = 0
        newEdge0.comp.node0 = oldEdge.node0
        newEdge0.comp.node1 = -3
        newEdge0.comp.tangent0 = api.type.Vec3f.new(
            tangent0.x * edge0Length / node0TangentLength,
            tangent0.y * edge0Length / node0TangentLength,
            tangent0.z * edge0Length / node0TangentLength
        )
        newEdge0.comp.tangent1 = api.type.Vec3f.new(
            nodeBetween.tangent[1] * edge0Length,
            nodeBetween.tangent[2] * edge0Length,
            nodeBetween.tangent[3] * edge0Length
        )
        newEdge0.comp.type = oldEdge.type -- respect bridge or tunnel
        newEdge0.comp.typeIndex = oldEdge.typeIndex -- respect bridge or tunnel
        newEdge0.playerOwned = playerOwned
        newEdge0.streetEdge = oldEdgeStreet

        local newEdge1 = api.type.SegmentAndEntity.new()
        newEdge1.entity = -2
        newEdge1.type = 0
        newEdge1.comp.node0 = -3
        newEdge1.comp.node1 = oldEdge.node1
        newEdge1.comp.tangent0 = api.type.Vec3f.new(
            nodeBetween.tangent[1] * edge1Length,
            nodeBetween.tangent[2] * edge1Length,
            nodeBetween.tangent[3] * edge1Length
        )
        newEdge1.comp.tangent1 = api.type.Vec3f.new(
            tangent1.x * edge1Length / node1TangentLength,
            tangent1.y * edge1Length / node1TangentLength,
            tangent1.z * edge1Length / node1TangentLength
        )
        newEdge1.comp.type = oldEdge.type
        newEdge1.comp.typeIndex = oldEdge.typeIndex
        newEdge1.playerOwned = playerOwned
        newEdge1.streetEdge = oldEdgeStreet

        if type(oldEdge.objects) == 'table' then
            local edge0Objects = {}
            local edge1Objects = {}
            for _, edgeObj in pairs(oldEdge.objects) do
                -- print('edgeObjEntityId =', edgeObj[1])
                -- local edgeObjPositionOld = _utils.getObjectPositionOld(edgeObj[1])
                local edgeObjPosition = _utils.getObjectPosition(edgeObj[1])
                -- print('edge object position: old and new way')
                -- debugPrint(edgeObjPositionOld)
                -- debugPrint(edgeObjPosition)
                if type(edgeObjPosition) ~= 'table' then return end -- change nothing and leave
                local assignment = _utils.getWhichEdgeGetsEdgeObjectAfterSplit(
                    edgeObjPosition,
                    {position0.x, position0.y, position0.z},
                    {position1.x, position1.y, position1.z},
                    nodeBetween
                )
                -- if assignment.assignToFirstEstimate == 0 then
                if assignment.assignToSecondEstimate == 0 then
                    table.insert(edge0Objects, { edgeObj[1], edgeObj[2] })
                -- elseif assignment.assignToFirstEstimate == 1 then
                elseif assignment.assignToSecondEstimate == 1 then
                    table.insert(edge1Objects, { edgeObj[1], edgeObj[2] })
                else
                    -- print('don\'t change anything and leave')
                    -- print('LOLLO error, assignment.assignToFirstEstimate =', assignment.assignToFirstEstimate)
                    -- print('LOLLO error, assignment.assignToSecondEstimate =', assignment.assignToSecondEstimate)
                    return -- change nothing and leave
                end
            end
            newEdge0.comp.objects = edge0Objects -- LOLLO NOTE cannot insert directly into edge0.comp.objects
            newEdge1.comp.objects = edge1Objects
        end

        local proposal = api.type.SimpleProposal.new()
        proposal.streetProposal.edgesToAdd[1] = newEdge0
        proposal.streetProposal.edgesToAdd[2] = newEdge1
        proposal.streetProposal.edgesToRemove[1] = wholeEdgeId
        proposal.streetProposal.nodesToAdd[1] = newNodeBetween

        local context = api.type.Context:new()
        context.checkTerrainAlignment = true -- default is false, true gives smoother Z
        -- context.cleanupStreetGraph = true -- default is false, it seems to do nothing
        -- context.gatherBuildings = true  -- default is false
        -- context.gatherFields = true -- default is true
        context.player = api.engine.util.getPlayer() -- default is -1

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(proposal, context, false), -- the 3rd param is "ignore errors"; wrong proposals will be discarded anyway
            function(res, success)
                -- print('LOLLO street splitter callback returned res = ')
                -- debugPrint(res)
                --for _, v in pairs(res.entities) do print(v) end
                -- print('LOLLO street splitter callback returned success = ')
                -- print(success)
            end
        )
    end,
}

function data()
    return {
        ini = function()
        end,
        handleEvent = function(src, id, name, param)
            if (id ~= _eventId) then return end
            if type(param) ~= 'table' then return end
            if type(param.constructionEntityId) == 'number' and param.constructionEntityId >= 0 then
                -- print('param.constructionEntityId =', param.constructionEntityId or 'NIL')
                local constructionTransf = api.engine.getComponent(param.constructionEntityId, api.type.ComponentType.CONSTRUCTION).transf
                constructionTransf = transfUtilUG.new(constructionTransf:cols(0), constructionTransf:cols(1), constructionTransf:cols(2), constructionTransf:cols(3))
                -- print('type(constructionTransf) =', type(constructionTransf))
                -- debugPrint(constructionTransf)
                if name == _eventProperties.lollo_street_splitter.eventName then
                -- do nothing
                elseif name == _eventProperties.lollo_street_splitter_w_api.eventName then
                    local nearestEdgeId = edgeUtils.getNearestEdgeId(constructionTransf)
                    -- print('street splitter got nearestEdge =', nearestEdgeId or 'NIL')
                    if type(nearestEdgeId) == 'number' and nearestEdgeId >= 0 then
                        local oldEdge = api.engine.getComponent(nearestEdgeId, api.type.ComponentType.BASE_EDGE)
                        if oldEdge then
                            local node0 = api.engine.getComponent(oldEdge.node0, api.type.ComponentType.BASE_NODE)
                            local node1 = api.engine.getComponent(oldEdge.node1, api.type.ComponentType.BASE_NODE)
                            if node0 and node1 then
                                local nodeBetween = edgeUtils.getNodeBetween(
                                    node0.position,
                                    oldEdge.tangent0,
                                    node1.position,
                                    oldEdge.tangent1,
                                    -- LOLLO NOTE position and transf are always very similar
                                    {
                                        x = constructionTransf[13],
                                        y = constructionTransf[14],
                                        z = constructionTransf[15],
                                    }
                                )

                                -- print('node0 =')
                                -- debugPrint(node0)
                                -- print('oldEdge.tangent0 =')
                                -- debugPrint(oldEdge.tangent0)
                                -- print('node1 =')
                                -- debugPrint(node1)
                                -- print('oldEdge.tangent1 =')
                                -- debugPrint(oldEdge.tangent1)
                                -- print('splitterConstruction.transf =')
                                -- debugPrint(constructionTransf)
                                -- print('nodeBetween =')
                                -- debugPrint(nodeBetween)

                                _actions.splitEdge(
                                    nearestEdgeId,
                                    node0.position,
                                    oldEdge.tangent0,
                                    node1.position,
                                    oldEdge.tangent1,
                                    nodeBetween
                                )
                            end
                        end
                    end
                elseif name == _eventProperties.lollo_street_changer.eventName then
                    local nearestEdgeId = edgeUtils.getNearestEdgeId(
                        constructionTransf
                    )
                    -- print('nearestEdge =', nearestEdgeId or 'NIL')
                    if type(nearestEdgeId) == 'number' and nearestEdgeId >= 0 then
                        -- print('LOLLO nearestEdgeId = ', nearestEdgeId or 'NIL')
                        _actions.replageEdgeWithSame(nearestEdgeId)
                    end
                elseif name == _eventProperties.lollo_toggle_all_tram_tracks.eventName then
                    local nearestEdgeId = edgeUtils.getNearestEdgeId(
                        constructionTransf
                    )
                    -- print('nearestEdgeId =', nearestEdgeId or 'NIL')
                    if type(nearestEdgeId) == 'number' and nearestEdgeId >= 0 then
                        local oldEdgeStreet = api.engine.getComponent(nearestEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
                        if oldEdgeStreet and oldEdgeStreet.streetType then
                            local newStreetTypeFileName = _utils.getToggledAllTramTracksStreetTypeFileName(
                                api.res.streetTypeRep.getFileName(oldEdgeStreet.streetType)
                            )
                            -- print('newStreetTypeFileName =', newStreetTypeFileName or 'NIL')
                            if type(newStreetTypeFileName) == 'string' then
                                _actions.replaceEdgeWithStreetType(
                                    nearestEdgeId,
                                    api.res.streetTypeRep.find(newStreetTypeFileName)
                                )
                            end
                        end
                    end
                elseif name == _eventProperties.lollo_street_get_info.eventName then
                    local nearbyEntities = edgeUtils.getNearbyEntities(constructionTransf)
                    if type(nearbyEntities) == 'table' then
                        debugPrint('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
                        print('LOLLO GET INFO found nearby entities = ')
                        for _, entity in pairs(nearbyEntities) do
                            debugPrint('<<<<<<<<')
                            debugPrint(entity)
                            if entity.type == 'BASE_EDGE' and not(stringUtils.isNullOrEmptyString(entity.streetType)) then
                                print('base edge component =')
                                debugPrint(api.engine.getComponent(entity.id, api.type.ComponentType.BASE_EDGE))
                                print('base edge street component =')
                                debugPrint(api.engine.getComponent(entity.id, api.type.ComponentType.BASE_EDGE_STREET))
                                print('street properties =')
                                debugPrint(api.res.streetTypeRep.get(api.res.streetTypeRep.find(entity.streetType)))
                            end
                            debugPrint('>>>>>>>>')
                        end
                        debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
                    end
                end

                -- game.interface.bulldoze(param.constructionEntityId)
                _actions.bulldozeConstruction(param.constructionEntityId)
            elseif type(param.edgeId) == 'number' and param.edgeId >= 0 then
                -- print('param.edgeId =', param.edgeId or 'NIL')
                if name == _eventProperties.noTramRightRoadBuilt.eventName then
                    _actions.replaceEdgeWithStreetType(
                        param.edgeId,
                        param.streetTypeId
                    )
                end
            -- else
            --     print('id =', id or 'NIL', 'name =', name or 'NIL', 'param =')
            --     debugPrint(param)
            end
        end,
        guiHandleEvent = function(id, name, param)
            -- LOLLO NOTE param can have different types, even boolean, depending on the event id and name
            if id == 'constructionBuilder' and name == 'builder.apply' then
                -- if name == "builder.proposalCreate" then return end
                -- print('guiHandleEvent caught id = constructionBuilder and name = builder.apply')
                xpcall(
                    function()
                        if not param.result or not param.result[1] then return end

                        -- game.interface.bulldoze(constructionEntity.id) -- cannot call it from this thread, so I raise and call it in the worker thread
                        if _isBuildingStreetSplitter(param) then
                            game.interface.sendScriptEvent(
                                _eventId,
                                _eventProperties.lollo_street_splitter.eventName,
                                {
                                    constructionEntityId = param.result[1]
                                }
                            )
                        elseif _isBuildingStreetSplitterWithApi(param) then
                            game.interface.sendScriptEvent(
                                _eventId,
                                _eventProperties.lollo_street_splitter_w_api.eventName,
                                {
                                    constructionEntityId = param.result[1]
                                }
                            )
                        elseif _isBuildingStreetGetInfo(param) then
                            game.interface.sendScriptEvent(
                                _eventId,
                                _eventProperties.lollo_street_get_info.eventName,
                                {
                                    constructionEntityId = param.result[1]
                                }
                            )
                        elseif _isBuildingStreetChanger(param) then
                            game.interface.sendScriptEvent(
                                _eventId,
                                _eventProperties.lollo_street_changer.eventName,
                                {
                                    constructionEntityId = param.result[1]
                                }
                            )
                        elseif _isBuildingToggleAllTracks(param) then
                            game.interface.sendScriptEvent(
                                _eventId,
                                _eventProperties.lollo_toggle_all_tram_tracks.eventName,
                                {
                                    constructionEntityId = param.result[1]
                                }
                            )
                        end
                    end,
                    _myErrorHandler
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
                -- print('guiHandleEvent caught id = streetBuilder and name = builder.apply')
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
                        if not(param) or not(param.proposal) or not(param.proposal.proposal)
                        or not(param.proposal.proposal.addedSegments) or not(param.proposal.proposal.addedSegments[1])
                        or not(param.data) or not(param.data.entity2tn) then return end

                        local addedSegments = param.proposal.proposal.addedSegments
                        -- local removedSegments = param.proposal.proposal.removedSegments
                        for i = 1, #addedSegments do
                            local addedSegment = addedSegments[i]
                            if addedSegment and addedSegment.streetEdge
                            and addedSegment.streetEdge.tramTrackType ~= 0
                            and addedSegment.streetEdge.streetType then
                                -- ignore case 3) described above. Or maybe not.
                                -- local removedSegment = _getRemovedSegmentSimple(removedSegments, i)
                                -- local removedSegment = _getRemovedSegment(removedSegments, addedSegment)
                                -- if not(removedSegment) or not(removedSegment.streetEdge)
                                -- or removedSegment.streetEdge.streetType ~= addedSegment.streetEdge.streetType then
                                --     print('TEN')
                                if streetUtils.transportModes.isTramRightBarred(addedSegment.streetEdge.streetType) then
                                    -- print('sending script event, param =')
                                    -- debugPrint(param)
                                    game.interface.sendScriptEvent(
                                        _eventId,
                                        _eventProperties.noTramRightRoadBuilt.eventName,
                                        {
                                            edgeId = _utils.getEdgeId(param.data.entity2tn, addedSegment),
                                            streetTypeId = addedSegment.streetEdge.streetType
                                        }
                                    )
                                end
                                -- end
                            end
                        end
                    end,
                    _myErrorHandler
                )
            end
            -- if (name == "select") then -- clicking a street won't select it
            --     -- with this event, param is the selected item id
            --     local entity = game.interface.getEntity(param)
            --     print('selected entity =')
            --     debugPrint(entity)
            -- end
        end,
        update = function()
        end,
        guiUpdate = function()
        end,
    }
end
