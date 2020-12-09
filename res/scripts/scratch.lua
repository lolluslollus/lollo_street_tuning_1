package.path = package.path .. ';res/scripts/?.lua'
local arrayUtils = require('lollo_street_tuning.arrayUtils')
local matrixUtils = require('lollo_street_tuning.matrix')
local streetUtils = require('lollo_street_tuning.streetUtils')
local transfUtils = require('lollo_street_tuning.transfUtils')
local edgeUtils = require('lollo_street_tuning.edgeUtils')
if debugPrint == nil then
    debugPrint = function(sth)
    end
end
-- actboy lua debugger
-- actboy extension path
-- sumneko lua assist
local aaa = false or true

local fileName = 'LOLLO.lua'
local targetLaneConfig = {0, 0, 0, 1}
local function _getConfigToString(config)
    local result = ''
    for key, value in pairs(config) do
        result = result .. tostring(value)
    end
    return result
end
local newFileName = string.sub(fileName, 1, string.len(fileName) - string.len('.lua')) .. '-' .. _getConfigToString(targetLaneConfig) .. '.lua'
local newFileName = string.gsub('aaa/bbb/ccc', '%/', '-')
local ddd = not(nil)
local dummy = 'AAA'