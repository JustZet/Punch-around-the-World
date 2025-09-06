return {
    pairsForLoop = function(func, data) 
        for key, value in pairs(data) do
            func(key, value)
        end
    end
}