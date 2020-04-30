--local dump = require 'luadump'
--local inspect = require('inspect')
local dbg = require('debugger')
local stringUtils = require('lollo_street_tuning/lolloStringUtils')

local fileUtils = {}
fileUtils.fileExists = function(filePath)
    local file = io.open(filePath, 'r')
    if file then
        file:close()
        return true
    end
    return false
end

fileUtils.readGameDataFile = function(filePath)
    local file = io.open(filePath, 'r')
    if file == nil then
        -- print('LOLLO file not found')
        return false
    end

    -- this works, but it returns a file that returns nothing, coz street files are structured this way
    -- local file, err = loadfile(<full path>)
    -- print('LOLLO err = ', err)
    -- print(inspect(file)) -- a function
    -- print(inspect(file())) -- nil. Note that street files do not return anything.

    -- file has type userdata
    -- print('LOLLO start reading the file')
    local fileContents = file:read('*a') -- this works! it reads the file contents! However, it adds a funny character at the beginning.
    -- print('LOLLO closing the file')
    file:close()

    -- We need to remove the funny character at the beginning
    -- and the function name, or load() will fail. Consider the following:
    --    local ee = return function(a,b) return a+b end -- works
    --    local ee = return function data(a,b) return a+b end -- fails
    local searchStr = '[%W]*function[%s]+data[%s]*%('
    local howManyMatches = 0
    fileContents, howManyMatches = string.gsub(fileContents, searchStr, 'return function(', 1)

    -- print('LOLLO adjusted file contents = ')
    -- dump(true)(fileContents)
    -- print('LOLLO howManyMatches = ')
    -- dump(true)(howManyMatches)

    if howManyMatches == 0 then
        return false
    end

    --local myFileFunc = loadstring(fileContents) -- it fails coz loadstring is not available anymore
    -- local func, err = load('return function(a,b) return a+b end')
    -- if func then
    --     local ok, add = pcall(func)
    --     if ok then
    --         print('LOLLO test 4 load', add(2, 3))
    --     else
    --         print('Execution error:', add)
    --     end
    -- else
    --     print('Compilation error:', err)
    -- end

    local func, err = load(fileContents)
    if func then
        local ok, fc = pcall(func)
        if ok then
            -- print('LOLLO test 4 load -----------------------------------')
            -- dump(true)(fc()) -- fc now contains my street data!
            return true, fc()
        else
            print('lollo file utils - Execution error:', fc)
        end
    else
        print('lollo file utils - Compilation error:', err)
    end

    return false
end

fileUtils.getCurrentPath = function()
    local currPath = string.sub(debug.getinfo(1, 'S').source, 2)
    return string.gsub(currPath, '\\', '/')
    --    return string.sub(debug.getinfo(1, 'S').source, 2)

    -- returns something like
    -- "@<full path>"
    -- so we take out the first character, which is no control character by the way, so we cannot use gsub with %c

    -- local info
    -- local i = 1
    -- repeat
    --     info = debug.getinfo(i, 'S')
    --     i = i + 1
    --     print('LOLLO info = ')
    --     require('luadump')(true)(info)
    -- until info == nil
    -- info = debug.getinfo(i - 2, 'S')

    -- return info

    -- it will find stuff like
    -- {
    --     lastlinedefined = 91,
    --     linedefined = 75,
    --     short_src = "...ing_area/lollo_street_tuning_1/res/scripts/fileUtils.lua",
    --     source = "@<full path>",
    --     what = "Lua"
    -- }
    -- and then
    -- {
    --     lastlinedefined = 75,
    --     linedefined = 9,
    --     short_src = "[string "C:/Program Files (x86)/Steam/userdata/7159018..."]",
    --     source = ".../res/construction/lollo_street_chunks.con",
    --     what = "Lua"
    -- }
    -- and then
    -- {
    --     lastlinedefined = 235,
    --     linedefined = 7,
    --     short_src = "[string "C:/Program Files (x86)/Steam/userdata/7159018..."]",
    --     source = ".../res/construction/lollo_street_chunks.con",
    --     what = "Lua"
    -- }
    -- and then
    -- {
    --     lastlinedefined = 235,
    --     linedefined = 7,
    --     short_src = "[string "C:/Program Files (x86)/Steam/userdata/7159018..."]",
    --     source = ".../res/construction/lollo_street_chunks.con",
    --     what = "Lua"
    -- }
end

fileUtils.getFileNameFromPath = function(path)
    if stringUtils.stringEndsWith(path, '/') then
        path = string.sub(path, 1, string.len(path) - 1)
    end

    local splits = stringUtils.stringSplit(path, '/')
    return splits[#splits] or ''
end

fileUtils.getParentDirFromPath = function(path)
    local searchString = '[^/]*/'
    return string.reverse(string.gsub(string.reverse(path), searchString, '', 1))
end

fileUtils.getResDirFromPath = function(path)
    local searchString = '.*/ser/'
    return string.reverse(string.gsub(string.reverse(path), searchString, 'ser/'))
end

fileUtils.getFilesInDir = function(dirPath, filterFn)
    local dirPathWithEndingSlash = stringUtils.stringEndsWith(dirPath, '/') and dirPath or (dirPath .. '/')
    filterFn = type(filterFn) == 'function' and filterFn or function(fileName)
            return true
        end
    local result = {}
    local f = io.popen(string.format([[dir "%s" /b /a-d]], dirPathWithEndingSlash))
    --local f = io.popen(string.format([[dir "%s" /b /ad]], dirPathWithEndingSlash))
    if f then
        for s in f:lines() do
            if ((string.len(s) > 0) and filterFn(s)) then
                result[#result + 1] = string.format([[%s%s]], dirPathWithEndingSlash, s)
            --result[#result + 1] = string.format([[%s%s/]], dirPathWithEndingSlash, s)
            end
        end
        f:close()
    end

    return result
end

fileUtils.getFilesInDirWithExtension = function(dirPath, ext)
    if ext == nil then
        return {}
    end

    local extWithoutDot = string.sub(ext, 1, 1) == '.' and string.sub(ext, 2, 1) or ext
    return fileUtils.getFilesInDir(
        dirPath,
        function(fileName)
            return stringUtils.stringEndsWith(fileName, '.' .. extWithoutDot)
        end
    )
end

fileUtils.getGamePath = function()
    dbg()
    local cpaths = fileUtils.getPackageCpaths()
    if type(cpaths) ~= 'table' or #cpaths < 1 then
        return ''
    end

    local cpath = ''
    local i = 1
    while stringUtils.isNullOrEmptyString(cpath) and i <= #cpaths do
        if stringUtils.stringContains(cpaths[i], 'Transport Fever 2') then
            cpath = cpaths[i]
        end
        i = i + 1
    end

    dbg()
    if stringUtils.isNullOrEmptyString(cpath) then
        return ''
    end

    local reversedPath = string.reverse(cpath)
    local one, two = string.find(reversedPath, '/2 reveF tropsnarT/')
    if one == nil then
        return ''
    end

    return string.reverse(string.sub(reversedPath, one)) or ''
end

fileUtils.getPackageCpaths = function()
    -- returns something like
    -- {
    --     "C:\Program Files (x86)\Steam\steamapps\common\Transport Fever 2\?.dll",
    --     "C:\Program Files (x86)\Steam\steamapps\common\Transport Fever 2\loadall.dll",
    --     ".\?.dll"
    -- }

    return stringUtils.stringSplit(string.gsub(package.cpath, '\\', '/'), ';')
end
fileUtils.getPackagePaths = function()
    -- returns something like
    -- {
    --     "C:/Program Files (x86)/Steam/userdata/<steam user id>/1066780/local/staging_area/lollo_street_tuning_1/res/scripts/?.lua",
    --     "res/scripts/?.lua"
    -- }

    return stringUtils.stringSplit(string.gsub(package.path, '\\', '/'), ';')
end

return fileUtils
