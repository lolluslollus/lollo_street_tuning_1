local arrayUtils = {}

arrayUtils.arrayHasValue = function(tab, val)
    for i, v in ipairs(tab) do
        if v == val then
            return true
        end
    end

    return false
end
arrayUtils.map = function(arr, func)
    local results = {}
    for i = 1, #arr do
        table.insert(results, #results + 1, func(arr[i]))
    end
    return results
end

arrayUtils.concatValues = function(table1, table2)
    if type(table1) ~= 'table' or type(table2) ~= 'table' then
        return
    end

    for _, v in pairs(table2) do
        table.insert(table1, #table1 + 1, v)
    end
end

arrayUtils.concatKeysValues = function(table1, table2)
    if type(table1) ~= 'table' or type(table2) ~= 'table' then
        return
    end

    for k, v in pairs(table2) do
        table1[k] = v
    end
end

return arrayUtils
