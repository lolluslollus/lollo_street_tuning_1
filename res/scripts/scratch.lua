package.path = package.path .. ';res/scripts/?.lua'
local arrayUtils = require('lollo_street_tuning.lolloArrayUtils')
local luadump = require('lollo_street_tuning.luadump')
local matrixUtils = require('lollo_street_tuning.matrix')
local streetUtils = require('lollo_street_tuning.lolloStreetUtils')
local transfUtils = require('lollo_street_tuning.transfUtils')
local edgeUtils = require('lollo_street_tuning.edgeHelper')
if debugPrint == nil then 
    debugPrint = function(sth)
        luadump(true)(sth)
    end
end
-- actboy lua debugger
-- actboy extension path
-- sumneko lua assist

local node0 = {
    {0, 1000, 50},
    {0, 1000, 100}
}
local node1 = {
    {1000, 0, 100},
    {1000, 0, 0}
}
local betweenPosition = {500, 500, 55}
local nodeBetween1 = edgeUtils.getNodeBetween(node0, node1, betweenPosition)
local nodeBetween2 = edgeUtils.getNodeBetween(node0, node1)
local dummy = 'AAA'

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
local dummy = 'AAA'