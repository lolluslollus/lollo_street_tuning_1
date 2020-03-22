-- local dump = require('luadump')
-- local stringUtils = require('stringUtils')

local function isBuildingStreetSplitter(param)
    local toAdd =
        type(param) == 'table' and type(param.proposal) == 'userdata' and type(param.proposal.toAdd) == 'userdata' and
        param.proposal.toAdd

    if toAdd and #toAdd > 0 then
        for i = 1, #toAdd do
            if toAdd[i].fileName == [[lollo_street_splitter.con]] then
                return true
            end
        end
    end

    return false
end

function data()
    return {
        ini = function()
        end,
        handleEvent = function(src, id, name, param)
            if (id ~= '__splitterEvent__') then
                return
            end

            -- print('__splitterEvent__ caught')
            -- print('src = ', src)
            -- print('id = ', id)
            -- print('name = ', name)
            -- print('param = ')
            -- dump(true)(param)
            -- print('type(param) = ', type(param))
            -- print('type(param.constructionEntityId) = ', type(param.constructionEntityId))
            if
                type(param) ~= 'table' or
                    (type(param.constructionEntityId) ~= 'string' and type(param.constructionEntityId) ~= 'number')
             then
                return
            end
            -- print('about to bulldoze ', param.constructionEntityId)
            -- dump(true)(game.interface.getEntity(param.constructionEntityId))

            game.interface.bulldoze(param.constructionEntityId)

            --gui = {
            --    buttoncallbacks = {  },
            --    windowcallbacks = {  }  absoluteLayout_get = (id),
            --    boxLayout_create = (id, orientation),
            --    boxLayout_get = (id, orientation),
            --    button_create = (id, content),
            --    button_get = (id, content),
            --    component_create = (id, name),
            --    component_get = (id),
            --    imageView_create = (id, path),
            --    imageView_get = (id, path),
            --    textView_create = (id, text, width),
            --    textView_get = (id),
            --    window_create = (id, title, child),
            --    window_get = (id)
            --}

            --            game.interface = {
            --     addPlayer = (),
            --     book = (),
            --     buildConstruction = (),
            --     bulldoze = (),
            --     clearJournal = (),
            --     findPath = (),
            --     getBuildingType = (),
            --     getBuildingTypes = (),
            --     getCargoType = (),
            --     getCargoTypes = (),
            --     getCompanyScore = (),
            --     getConstructionEntity = (),
            --     getDateFromNowPlusOffsetDays = (),
            --     getDepots = (),
            --     getDestinationDataPerson = (),
            --     getEntities = (),
            --     getEntity = (),
            --     getGameDifficulty = (),
            --     getGameSpeed = (),
            --     getGameTime = (),
            --     getHeight = (),
            --     getIndustryProduction = (),
            --     getIndustryProductionLimit = (),
            --     getIndustryShipping = (),
            --     getIndustryTransportRating = (),
            --     getLines = (),
            --     getLog = (),
            --     getMillisPerDay = (),
            --     getName = (),
            --     getPlayer = (),
            --     getPlayerJournal = (),
            --     getStationTransportSamples = (),
            --     getStations = (),
            --     getTownCapacities = (),
            --     getTownCargoSupplyAndLimit = (),
            --     getTownEmission = (),
            --     getTownReachability = (),
            --     getTownTrafficRating = (),
            --     getTownTransportSamples = (),
            --     getTowns = (),
            --     getVehicles = (),
            --     getWorld = (),
            --     replaceVehicle = (),
            --     setBuildInPauseModeAllowed = (),
            --     setBulldozeable = (),
            --     setDate = (),
            --     setGameSpeed = (),
            --     setMarker = (),
            --     setMaximumLoan = (),
            --     setMillisPerDay = (),
            --     setMinimumLoan = (),
            --     setMissionState = (),
            --     setName = (),
            --     setPlayer = (),
            --     setTownCapacities = (),
            --     setTownDevelopmentActive = (),
            --     setZone = (),
            --     spawnAnimal = (),
            --     startEvent = (),
            --     upgradeConstruction = ()
            --   }

            --  game.gui = nil or empty

            -- game.res = {
            --     gameScript = {
            --       ["arrivaltracker.lua_handleEvent"] = (src, id, name, param),
            --       ["arrivaltracker.lua_load"] = (loadedstate),
            --       ["arrivaltracker.lua_save"] = (),
            --       ["base.lua_init"] = (),
            --       ["base.lua_update"] = (),
            --       ["contexthelper.lua_guiHandleEvent"] = (id, name, param),
            --       ["contexthelper.lua_guiUpdate"] = (),
            --       ["contexthelper.lua_init"] = (),
            --       ["contexthelper.lua_load"] = (state),
            --       ["contexthelper.lua_save"] = (),
            --       ["contexthelper.lua_update"] = (),
            --       ["entry.lua_guiHandleEvent"] = (id, name, param),
            --       ["entry.lua_guiUpdate"] = (),
            --       ["entry.lua_handleEvent"] = (src, id, name, param),
            --       ["entry.lua_load"] = (data),
            --       ["entry.lua_save"] = (),
            --       ["gameinfo.lua_guiInit"] = (),
            --       ["gameinfo.lua_guiUpdate"] = (),
            --       ["gameinfo.lua_init"] = (),
            --       ["gameinfo.lua_load"] = (state),
            --       ["gameinfo.lua_save"] = (),
            --       ["gui.lua_guiHandleEvent"] = (id, name, param),
            --       ["guidesystem.lua_guiHandleEvent"] = (id, name, param),
            --       ["guidesystem.lua_guiUpdate"] = (),
            --       ["guidesystem.lua_handleEvent"] = (src, id, name, param),
            --       ["guidesystem.lua_load"] = (state, reset),
            --       ["guidesystem.lua_save"] = (),
            --       ["guidesystem.lua_update"] = (),
            --       ["mn_upgrader_gs.lua_guiUpdate"] = (),
            --       ["mn_upgrader_gs.lua_handleEvent"] = (src, id, name, param),
            --       ["modname.lua_guiHandleEvent"] = (id, name, param),
            --       ["modname.lua_guiUpdate"] = (),
            --       ["modname.lua_handleEvent"] = (src, id, name, param),
            --       ["modname.lua_load"] = (allState),
            --       ["modname.lua_save"] = (),
            --       ["modname.lua_update"] = (),
            --       ["mus.lua_guiHandleEvent"] = (id, name, param),
            --       ["selectortooltip.lua_guiHandleEvent"] = (id, name, param),
            --       ["selectortooltip.lua_guiUpdate"] = (),
            --       ["selectortooltip.lua_load"] = (state),
            --       ["selectortooltip.lua_save"] = (),
            --       ["snowball_coordinates_callbacks.lua_guiUpdate"] = (),
            --       ["snowball_fences_callback.lua_guiHandleEvent"] = (id, name, param),
            --       ["snowball_fences_callback.lua_handleEvent"] = (src, id, name, param)
            --     }
            --   }
        end,
        guiHandleEvent = function(id, name, param)
            if id ~= 'constructionBuilder' then
                return
            end
            if name ~= 'builder.apply' then
                return
            end
            -- if name == "builder.proposalCreate" then return end

            -- print('{\n-- guiHandleEvent --')
            -- print('\n - id = ', id)
            -- print('\n - name = ', name)

            if not (isBuildingStreetSplitter(param)) then
                return
            end

            --             print("-- global variables = ")
            --             for key, value in pairs(_G) do
            --                 print(key, value)
            --             end
            --             print("-- sol = ")
            --             dump(true)(sol)
            --             print("-- ug = ")
            --             dump(true)(ug)
            --             print("-- package = ")
            --             dump(true)(package) --this hangs
            --             print("-- getmetatable = ")
            --             dump(true)(getmetatable(""))
            --             print("-- io = ")
            --             dump(true)(io)

            -- LOLLO NOTE param can have different types, even boolean. If so, param.data below will fail!
            -- if param then print("type(param) = ", type(param)) end
            -- if param.data then print("type(param.data) = ", type(param.data)) end
            -- if param and param.data and param.data.entity2tn then print("type(param.data.entity2tn) = ", type(param.data.entity2tn)) end
            --[[ 
            if param and type(param) == 'table' and param.data and type(param.data) == 'userdata' and
                    param.data.entity2tn and
                    type(param.data.entity2tn) == 'userdata'
             then
                for k, v in pairs(param.data.entity2tn) do
                    print('entity id = ', k)
                    dump(true)(game.interface.getEntity(k))
                end
            end
 ]]
            if
                not (type(param) == 'table' and type(param.data) == 'userdata' and
                    type(param.data.entity2tn) == 'userdata')
             then
                return
            end

            -- print('-- start working out entities near construction')
            local constructionEntity = nil
            for k, _ in pairs(param.data.entity2tn) do
                local entity = game.interface.getEntity(k)
                if type(entity) == 'table' and type(entity.type) == 'string' and entity.type == 'CONSTRUCTION' then
                    -- print('construction found')
                    constructionEntity = entity
                    break
                end
            end

            if type(constructionEntity) ~= 'table' or not (constructionEntity.position) or not (constructionEntity.id) then
                return
            end
            -- _G.lollo = true
            --[[ print('nearby entities within 99= ')
                    local baseEdges =
                        game.interface.getEntities(
                        {pos = constructionEntity.position, radius = 99},
                        {type = 'BASE_EDGE', includeData = true}
                    )
                    local baseNodes =
                        game.interface.getEntities(
                        {pos = constructionEntity.position, radius = 99},
                        {type = 'BASE_NODE', includeData = true}
                    )
                    dump(true)(baseEdges)
                    dump(true)(baseNodes)
                    print('nearby entities within 9= ')
                    dump(true)(
                        game.interface.getEntities(
                            {pos = constructionEntity.position, radius = 9},
                            {type = 'BASE_EDGE', includeData = true}
                        )
                    )
                    dump(true)(
                        game.interface.getEntities(
                            {pos = constructionEntity.position, radius = 9},
                            {type = 'BASE_NODE', includeData = true}
                        )
                    ) ]]
            --[[             print('nearby entities within 1= ') -- within 0 only returns the base node of the construction itself
            local baseEdges =
                game.interface.getEntities(
                {pos = constructionEntity.position, radius = 1},
                {type = 'BASE_EDGE', includeData = true}
            )
            dump(true)(baseEdges)
            local baseNodes =
                game.interface.getEntities(
                {pos = constructionEntity.position, radius = 1},
                {type = 'BASE_NODE', includeData = true}
            )
            dump(true)(baseNodes)
 ]]
            -- game.interface.bulldoze(constructionEntity.id) -- cannot call it from this thread
            game.interface.sendScriptEvent(
                '__splitterEvent__',
                'built',
                {
                    constructionEntityId = constructionEntity.id
                    -- constructionEntity = constructionEntity,
                    -- baseEdges = baseEdges,
                    -- baseNodes = baseNodes
                }
            )
            --_G.lollo = false
            -- end
            -- end
            -- return
            -- end

            -- game.gui.stopAction() -- does not stop
            --[[ if param then
                print("--- entity = ")
                local entity = game.interface.getEntity(param)
                dump(true)(entity)
            end ]]

            --[[ game.gui = {
                absoluteLayout_addItem = (),
                absoluteLayout_deleteAll = (),
                absoluteLayout_setPosition = (),
                addTask = (),
                boxLayout_addItem = (),
                boxLayout_create = (),
                button_create = (),
                calcMinimumSize = (),
                component_create = (),
                component_setLayout = (),
                component_setStyleClassList = (),
                component_setToolTip = (),
                component_setTransparent = (),
                getCamera = (),
                getContentRect = (),
                getMousePos = (),
                getTerrainPos = (),
                imageView_create = (),
                imageView_setImage = (),
                isEditor = (),
                isGuideSystemActive = (),
                openWindow = (),
                playCutscene = (),
                playSoundEffect = (),
                playTrack = (),
                setAutoCamera = (),
                setCamera = (),
                setConstructionAngle = (),
                setEnabled = (),
                setHighlighted = (),
                setMedalsCompletion = (),
                setMissionComplete = (),
                setTaskProgress = (),
                setVisible = (),
                showTask = (),
                stopAction = (),
                textView_create = (),
                textView_setText = (),
                window_close = (),
                window_create = (),
                window_setIcon = (),
                window_setPosition = (),
                window_setTitle = ()
              }, ]]

            --[[ game.interface = {
                findPath = (),
                getBuildingType = (),
                getBuildingTypes = (),
                getCargoType = (),
                getCargoTypes = (),
                getCompanyScore = (),
                getDateFromNowPlusOffsetDays = (),
                getDepots = (),
                getDestinationDataPerson = (),
                getEntities = (),
                getEntity = (),
                getGameDifficulty = (),
                getGameSpeed = (),
                getGameTime = (),
                getHeight = (),
                getIndustryProduction = (),
                getIndustryProductionLimit = (),
                getIndustryShipping = (),
                getIndustryTransportRating = (),
                getLines = (),
                getLog = (),
                getMillisPerDay = (),
                getName = (),
                getPlayer = (),
                getPlayerJournal = (),
                getStationTransportSamples = (),
                getStations = (),
                getTownCapacities = (),
                getTownCargoSupplyAndLimit = (),
                getTownEmission = (),
                getTownReachability = (),
                getTownTrafficRating = (),
                getTownTransportSamples = (),
                getTowns = (),
                getVehicles = (),
                getWorld = (),
                sendScriptEvent = (),
                setBuildInPauseModeAllowed = (),
                setDate = (),
                setMarker = (),
                setTownCapacities = (),
                setZone = ()
              }, ]]
        end,
        update = function()
        end,
        guiUpdate = function()
        end,
        save = function()
            return allState
        end,
        load = function(allState)
        end
    }
end
