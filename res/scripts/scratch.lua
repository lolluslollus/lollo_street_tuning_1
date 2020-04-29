package.path = package.path .. ';res/scripts/?.lua'

local dump = require('res/scripts/luadump')
local arrayUtils = require('res/scripts/lolloArrayUtils')
local fileUtils = require('res/scripts/lolloFileUtils')
local stringUtils = require('res/scripts/lolloStringUtils')

local path = "C:/Program Files (x86)/Steam/steamapps/common/Transport Fever 2/?.dll/"

local reversedPath = string.reverse(path)
local one, two = string.find(reversedPath, '/2 reveF tropsnarT/')
--local one, two = string.find(string.reverse(path), '/2 reveF tropsnarZZZ/')
if one ~= nil then
    local prunedPath = string.reverse(string.sub(reversedPath, one))
    local aaa = 'AAA'

end

if stringUtils.stringEndsWith(path, '/') then 
    path = string.sub(path, 1, string.len(path) - 1)
end

local splits = stringUtils.stringSplit(path, '/')
local fileName = splits[#splits]

local aaa = 'AAA'
