package.path = package.path .. ';res/scripts/?.lua'

local dump = require('res/scripts/luadump')
local fileUtils = require('res/scripts/fileUtils')
local stringUtils = require('res/scripts/stringUtils')


local str0 = 'C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/scripts/something.lua'
local str1 = string.reverse(str0)
local searchString = '[^/]*/'
local str2 = string.reverse(string.gsub(str1, searchString, '', 1))

local dirName = fileUtils.getDirFromFile(str0)
local files = fileUtils.getFilesInDirWithExtension(dirName, 'lua')

local searchString = '.*/ser/'
local newDir = string.reverse(string.gsub(string.reverse(dirName), searchString, 'ser/'))

local currPath = fileUtils.getCurrentPath()
local resDir = fileUtils.getResDirFromPath(currPath)
local aaa = 'LOLLO'



