local arrayUtils = require('lollo_street_tuning.arrayUtils')
local edgeUtils = require('lollo_street_tuning.edgeUtils')
local streetUtils = require('lollo_street_tuning.streetUtils')
local stringUtils = require('lollo_street_tuning/stringUtils')
local transfUtilUG = require('transf')

-- LOLLO BUG when you split a road near a modded street station, whose mod was removed,
-- and then apply a modifier, such as add / remove bus lane or change the street type,
-- the game crashes.
-- This happens with single as well as double-sided stations.
-- You can tell those stations because the game shows a placeholder at their location.
-- This seems to be a UG problem.
-- To solve the issue, replace those stations with some others available in your game.

local function _myErrorHandler(err)
    print('lollo street tuning caught error: ', err)
end

local _eventId = '__lolloStreetTuningEvent__'
local _eventProperties = {
    lollo_street_changer = { conName = 'lollo_street_changer.con', eventName = 'streetChangerBuilt' },
    lollo_street_get_info = { conName = 'lollo_street_get_info.con', eventName = 'streetGetInfoBuilt' },
    lollo_street_splitter = { conName = 'lollo_street_splitter.con', eventName = 'streetSplitterBuilt' },
    lollo_street_splitter_w_api = { conName = 'lollo_street_splitter_w_api.con', eventName = 'streetSplitterWithApiBuilt' },
    lollo_toggle_all_tram_tracks = { conName = 'lollo_toggle_all_tram_tracks.con', eventName = 'toggleAllTracksBuilt' },
    noTramRightRoadBuilt = { conName = '', eventName = 'noTramRightRoadBuilt' },
    pathBuilt = { conName = '', eventName = 'pathBuilt' },
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

    replaceEdgeWithSame = function(oldEdgeId)
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
            api.cmd.make.buildProposal(proposal, nil, true),
            function(res, success)
                -- print('LOLLO res = ')
                -- debugPrint(res)
                --for _, v in pairs(res.entities) do print(v) end
                -- print('LOLLO success = ')
                -- debugPrint(success)
                if not(success) then
                    print('Warning: streetTuning.replaceEdgeWithSame failed, proposal = ') debugPrint(proposal)
                end
            end
        )
    end,

    replaceEdgeWithStreetType = function(oldEdgeId, newStreetTypeId)
        -- replaces the street without destroying the buildings
        if not(edgeUtils.isValidAndExistingId(oldEdgeId))
        or not(edgeUtils.isValidId(newStreetTypeId)) then return end

        local oldEdge = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE)
        local oldEdgeStreet = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
        -- save a crash when a modded road underwent a breaking change, so it has no oldEdgeStreet
        if oldEdge == nil or oldEdgeStreet == nil then return end

        local newEdge = api.type.SegmentAndEntity.new()
        newEdge.entity = -1
        newEdge.type = 0 -- 0 is ROAD, 1 is TRACK
        newEdge.comp = oldEdge
        -- newEdge.playerOwned = {player = api.engine.util.getPlayer()}
        newEdge.playerOwned = api.engine.getComponent(oldEdgeId, api.type.ComponentType.PLAYER_OWNED)
        newEdge.streetEdge = oldEdgeStreet
        newEdge.streetEdge.streetType = newStreetTypeId

        -- add / remove tram tracks upgrade if the new street type explicitly wants so
        if streetUtils.isTramRightBarred(newStreetTypeId) then
            newEdge.streetEdge.tramTrackType = 0
        elseif streetUtils.isStreetAllTramTracks((api.res.streetTypeRep.get(newStreetTypeId) or {}).laneConfigs) then
            newEdge.streetEdge.tramTrackType = 2
        end

        -- add bus lane if the new street type wants so
        if streetUtils.isPath(newStreetTypeId) then
            newEdge.streetEdge.hasBus = true
        end

        -- leave if nothing changed
        if newEdge.streetEdge.streetType == oldEdgeStreet.streetType
        and newEdge.streetEdge.tramTrackType == oldEdgeStreet.tramTrackType
        and newEdge.streetEdge.hasBus == oldEdgeStreet.hasBus
        then return end

        local proposal = api.type.SimpleProposal.new()
        proposal.streetProposal.edgesToRemove[1] = oldEdgeId
        proposal.streetProposal.edgesToAdd[1] = newEdge

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(proposal, nil, true),
            function(res, success)
                -- print('LOLLO res = ') -- debugPrint(res)
                -- print('LOLLO _replaceEdgeWithStreetType success = ') -- debugPrint(success)
                if not(success) then
                    print('Warning: streetTuning.replaceEdgeWithStreetType failed, proposal = ') debugPrint(proposal)
                end
            end
        )
    end,

    splitEdge = function(wholeEdgeId, nodeBetween)
        if not(edgeUtils.isValidAndExistingId(wholeEdgeId)) or type(nodeBetween) ~= 'table' then return end

        local oldBaseEdge = api.engine.getComponent(wholeEdgeId, api.type.ComponentType.BASE_EDGE)
        local oldBaseEdgeStreet = api.engine.getComponent(wholeEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
        -- save a crash when a modded road underwent a breaking change, so it has no oldEdgeStreet
        if oldBaseEdge == nil or oldBaseEdgeStreet == nil then return end

        local node0 = api.engine.getComponent(oldBaseEdge.node0, api.type.ComponentType.BASE_NODE)
        local node1 = api.engine.getComponent(oldBaseEdge.node1, api.type.ComponentType.BASE_NODE)
        if node0 == nil or node1 == nil then return end

        if not(edgeUtils.isXYZSame(nodeBetween.refPosition0, node0.position)) and not(edgeUtils.isXYZSame(nodeBetween.refPosition0, node1.position)) then
            print('WARNING: splitEdge cannot find the nodes')
        end
        local isNodeBetweenOrientatedLikeMyEdge = edgeUtils.isXYZSame(nodeBetween.refPosition0, node0.position)
        local distance0 = isNodeBetweenOrientatedLikeMyEdge and nodeBetween.refDistance0 or nodeBetween.refDistance1
        local distance1 = isNodeBetweenOrientatedLikeMyEdge and nodeBetween.refDistance1 or nodeBetween.refDistance0
        local tanSign = isNodeBetweenOrientatedLikeMyEdge and 1 or -1

        local oldTan0Length = edgeUtils.getVectorLength(oldBaseEdge.tangent0)
        local oldTan1Length = edgeUtils.getVectorLength(oldBaseEdge.tangent1)

        local playerOwned = api.type.PlayerOwned.new()
        playerOwned.player = api.engine.util.getPlayer()

        local newNodeBetween = api.type.NodeAndEntity.new()
        newNodeBetween.entity = -3
        newNodeBetween.comp.position = api.type.Vec3f.new(nodeBetween.position.x, nodeBetween.position.y, nodeBetween.position.z)

        local newEdge0 = api.type.SegmentAndEntity.new()
        newEdge0.entity = -1
        newEdge0.type = 0 -- ROAD
        newEdge0.comp.node0 = oldBaseEdge.node0
        newEdge0.comp.node1 = -3
        newEdge0.comp.tangent0 = api.type.Vec3f.new(
            oldBaseEdge.tangent0.x * distance0 / oldTan0Length,
            oldBaseEdge.tangent0.y * distance0 / oldTan0Length,
            oldBaseEdge.tangent0.z * distance0 / oldTan0Length
        )
        newEdge0.comp.tangent1 = api.type.Vec3f.new(
            nodeBetween.tangent.x * distance0 * tanSign,
            nodeBetween.tangent.y * distance0 * tanSign,
            nodeBetween.tangent.z * distance0 * tanSign
        )
        newEdge0.comp.type = oldBaseEdge.type -- respect bridge or tunnel
        newEdge0.comp.typeIndex = oldBaseEdge.typeIndex -- respect bridge or tunnel type
        newEdge0.playerOwned = playerOwned
        newEdge0.streetEdge = oldBaseEdgeStreet

        local newEdge1 = api.type.SegmentAndEntity.new()
        newEdge1.entity = -2
        newEdge1.type = 0 -- ROAD
        newEdge1.comp.node0 = -3
        newEdge1.comp.node1 = oldBaseEdge.node1
        newEdge1.comp.tangent0 = api.type.Vec3f.new(
            nodeBetween.tangent.x * distance1 * tanSign,
            nodeBetween.tangent.y * distance1 * tanSign,
            nodeBetween.tangent.z * distance1 * tanSign
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
                    print('Warning: streetTuning.splitEdge failed, proposal = ') debugPrint(proposal)
                end
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
            if edgeUtils.isValidAndExistingId(param.constructionEntityId) then
                -- print('param.constructionEntityId =', param.constructionEntityId or 'NIL')
                local constructionTransf = api.engine.getComponent(param.constructionEntityId, api.type.ComponentType.CONSTRUCTION).transf
                constructionTransf = transfUtilUG.new(constructionTransf:cols(0), constructionTransf:cols(1), constructionTransf:cols(2), constructionTransf:cols(3))
                -- print('type(constructionTransf) =', type(constructionTransf))
                -- debugPrint(constructionTransf)
                if name == _eventProperties.lollo_street_splitter.eventName then
                -- do nothing
                elseif name == _eventProperties.lollo_street_splitter_w_api.eventName then
                    local nearestEdgeId = edgeUtils.street.getNearestEdgeId(constructionTransf)
                    -- print('street splitter got nearestEdge =', nearestEdgeId or 'NIL')
                    if edgeUtils.isValidAndExistingId(nearestEdgeId) and not(edgeUtils.isEdgeFrozen(nearestEdgeId)) then
                        local nodeBetween = edgeUtils.getNodeBetweenByPosition(
                            nearestEdgeId,
                            -- LOLLO NOTE position and transf are always very similar
                            {
                                x = constructionTransf[13],
                                y = constructionTransf[14],
                                z = constructionTransf[15],
                            }
                        )
                        -- print('nodeBetween =') debugPrint(nodeBetween)
                        _actions.splitEdge(nearestEdgeId, nodeBetween)
                    end
                elseif name == _eventProperties.lollo_street_changer.eventName then
                    local nearestEdgeId = edgeUtils.street.getNearestEdgeId(
                        constructionTransf
                    )
                    -- print('nearestEdge =', nearestEdgeId or 'NIL')
                    if type(nearestEdgeId) == 'number' and nearestEdgeId >= 0 then
                        -- print('LOLLO nearestEdgeId = ', nearestEdgeId or 'NIL')
                        _actions.replaceEdgeWithSame(nearestEdgeId)
                    end
                elseif name == _eventProperties.lollo_toggle_all_tram_tracks.eventName then
                    local nearestEdgeId = edgeUtils.street.getNearestEdgeId(
                        constructionTransf
                    )
                    -- print('nearestEdgeId =', nearestEdgeId or 'NIL')
                    if edgeUtils.isValidAndExistingId(nearestEdgeId) then
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
                    xpcall( -- { 386681, 688570, 552461, }
                        function()
                            local nearbyEdges = edgeUtils.getNearbyObjects(constructionTransf, 0.5, api.type.ComponentType.BASE_EDGE)
                            local nearbyConstructions = edgeUtils.getNearbyObjects(constructionTransf, 0.5, api.type.ComponentType.CONSTRUCTION)
                            print('nearby edges = <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
                            for edgeId, props in pairs(nearbyEdges) do
                                if edgeUtils.isValidId(edgeId) then
                                    print('edge id =', edgeId)
                                    debugPrint(props)
                                    print('street edge props =')
                                    debugPrint(api.engine.getComponent(edgeId, api.type.ComponentType.BASE_EDGE_STREET))
                                    print('track edge props =')
                                    debugPrint(api.engine.getComponent(edgeId, api.type.ComponentType.BASE_EDGE_TRACK))
                                end
                            end
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
                        end,
                        _myErrorHandler
                    )
                end

                _actions.bulldozeConstruction(param.constructionEntityId)
            elseif edgeUtils.isValidAndExistingId(param.edgeId) and edgeUtils.isValidId(param.streetTypeId) then
                -- print('param.edgeId =', param.edgeId or 'NIL')
                if name == _eventProperties.noTramRightRoadBuilt.eventName then
                    _actions.replaceEdgeWithStreetType(
                        param.edgeId,
                        param.streetTypeId
                    )
                elseif name == _eventProperties.pathBuilt.eventName then
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

                        if _isBuildingStreetSplitter(param) then
                            api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                                string.sub(debug.getinfo(1, 'S').source, 1),
                                _eventId,
                                _eventProperties.lollo_street_splitter.eventName,
                                {
                                    constructionEntityId = param.result[1]
                                }
                            ))
                        elseif _isBuildingStreetSplitterWithApi(param) then
                            api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                                string.sub(debug.getinfo(1, 'S').source, 1),
                                _eventId,
                                _eventProperties.lollo_street_splitter_w_api.eventName,
                                {
                                    constructionEntityId = param.result[1]
                                }
                            ))
                        elseif _isBuildingStreetGetInfo(param) then
                            api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                                string.sub(debug.getinfo(1, 'S').source, 1),
                                _eventId,
                                _eventProperties.lollo_street_get_info.eventName,
                                {
                                    constructionEntityId = param.result[1]
                                }
                            ))
                        elseif _isBuildingStreetChanger(param) then
                            api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                                string.sub(debug.getinfo(1, 'S').source, 1),
                                _eventId,
                                _eventProperties.lollo_street_changer.eventName,
                                {
                                    constructionEntityId = param.result[1]
                                }
                            ))
                        elseif _isBuildingToggleAllTracks(param) then
                            api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                                string.sub(debug.getinfo(1, 'S').source, 1),
                                _eventId,
                                _eventProperties.lollo_toggle_all_tram_tracks.eventName,
                                {
                                    constructionEntityId = param.result[1]
                                }
                            ))
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

                        -- remove right lane tram tracks if forbidden for current road
                        local removeTramTrackEventParams = {}
                        for _, addedSegment in pairs(addedSegments) do
                            if addedSegment and addedSegment.streetEdge
                            and addedSegment.streetEdge.tramTrackType ~= 0
                            and addedSegment.streetEdge.streetType ~= nil then
                                if streetUtils.isTramRightBarred(addedSegment.streetEdge.streetType) then
                                    removeTramTrackEventParams[#removeTramTrackEventParams+1] = {
                                        edgeId = addedSegment.entity,
                                        streetTypeId = addedSegment.streetEdge.streetType
                                    }
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
                        local addBusLaneEventParams = {}
                        for _, addedSegment in pairs(addedSegments) do
                            if addedSegment and addedSegment.streetEdge
                            and not(addedSegment.streetEdge.hasBus)
                            and addedSegment.streetEdge.streetType ~= nil then
                                if streetUtils.isPath(addedSegment.streetEdge.streetType) then
                                    addBusLaneEventParams[#addBusLaneEventParams+1] = {
                                        edgeId = addedSegment.entity,
                                        streetTypeId = addedSegment.streetEdge.streetType
                                    }
                                end
                            end
                        end
                        for i = 1, #addBusLaneEventParams do
                            -- game.interface.sendScriptEvent(
                            --     _eventId,
                            --     _eventProperties.pathBuilt.eventName,
                            --     addBusLaneEventParams[i]
                            -- )
                            api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                                string.sub(debug.getinfo(1, 'S').source, 1),
                                _eventId,
                                _eventProperties.pathBuilt.eventName,
                                addBusLaneEventParams[i]
                            ))
                        end

                        -- we don't change any more stuff, the rest is ok as it is
                    end,
                    _myErrorHandler
                )
            end
        end,
        update = function()
        end,
        guiUpdate = function()
        end,
    }
end
