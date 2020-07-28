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
    {1000, 0, 50},
    {1, 0, 0}
}
local node1 = {
    {2000, 0, 50},
    {1, 0, 0}
}
local betweenPosition = {1500, 0, 50}
local nodeBetween = edgeUtils.getNodeBetween(node0, node1, betweenPosition)

local dummy = 'AAA'
