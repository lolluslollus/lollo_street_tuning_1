package.path = package.path .. ';res/scripts/?.lua'

local dump = require('res/scripts/luadump')
local arrayUtils = require('res/scripts/arrayUtils')
local fileUtils = require('res/scripts/fileUtils')
local stringUtils = require('res/scripts/stringUtils')

local path = "C:/Program Files (x86)/Steam/steamapps/common/Transport Fever 2/?.dll"

local reversedPath = string.reverse(path)
local one, two = string.find(reversedPath, '/2 reveF tropsnarT/')
--local one, two = string.find(string.reverse(path), '/2 reveF tropsnarZZZ/')
if one ~= nil then
    local prunedPath = string.reverse(string.sub(reversedPath, one))
    local aaa = 'AAA'

end

local table1 = {
    {
        a = 1,
        b = 2,
    },
    {
        a = 10,
        b = 20,
    }
}

local table2 = {
    {
        a = 1,
        b = 2,
    },
    {
        a = 10,
        b = 20,
    },
    {
        a = 100,
        b = 200,
    }
}

arrayUtils.concatValues(table1, table2)

local aaa = 'AAA'
