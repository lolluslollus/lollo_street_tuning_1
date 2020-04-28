package.path = package.path .. ';res/scripts/?.lua'

local dump = require('res/scripts/luadump')
local arrayUtils = require('res/scripts/arrayUtils')
local fileUtils = require('res/scripts/fileUtils')
local stringUtils = require('res/scripts/stringUtils')

local streetDir = 'C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/config/street'
local streetFiles = fileUtils.getFilesInDirWithExtension(streetDir, 'lua')

local mapped = arrayUtils.map({1, 2, 3}, function(num) return num + 1 end)
local lollo = 'LOLLO'
function getStreetDataFromFiles()
    local fileDatas = {}
    local currPath = fileUtils.getCurrentPath()
    print('LOLLO currPath is')
    dump(true)(currPath)
    if not stringUtils.isNullOrEmptyString(currPath) then
        local resDir = fileUtils.getResDirFromPath(currPath)
        print('LOLLO resDir is')
        dump(true)(resDir)
        if not stringUtils.isNullOrEmptyString(resDir) then
            local streetDir = resDir .. '/config/street'
            print('LOLLO streetDir is')
            dump(true)(streetDir)
            --streetDir = "C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/config/street"

            if not stringUtils.isNullOrEmptyString(streetDir) then
                local streetFiles = fileUtils.getFilesInDirWithExtension(streetDir, 'lua')
                print('LOLLO streetfiles are')
                dump(true)(streetFiles)
                if type(streetFiles) == 'table' then
                    for i = 1, #streetFiles do
                        local isOk, fileData = fileUtils.readGameDataFile(streetFiles[i])
                        if isOk then
                            table.insert(
                                fileDatas,
                                #fileDatas + 1,
                                {
                                    type = fileData.type,
                                    streetWidth = fileData.streetWidth,
                                    sidewalkWidth = fileData.sidewalkWidth
                                }
                            )
                        end
                    end
                    for i = 1, #fileDatas do
                        dump(true)(fileDatas[i])
                    end
                end
            end
        end
    end
end

local aaa = 'AAA'
