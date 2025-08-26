-- for cycle stuff

CMDIA.lib = {
    _buffer = {cycles = {}, values = {}, def_values = {}},
    jkr = {
        recycler_jkrs = {}
    }
}

CMDIA.lib.addCycle = function(id, values, func)
    CMDIA.lib._buffer.cycles[id] = func
    CMDIA.lib._buffer.values[id] = values
    CMDIA.lib._buffer.def_values[id] = values
end

oldResetAncientCard = reset_ancient_card
function reset_ancient_card()
    oldResetAncientCard()
    for k, func in pairs(CMDIA.lib._buffer.cycles) do
        for sk in pairs(CMDIA.lib._buffer.values[k]) do
            CMDIA.lib._buffer.values[k][sk] = nil
        end        
        G.GAME.current_round[k .. "_card"] = CMDIA.lib._buffer.values[k]
        func(G.GAME.current_round[k .. "_card"])
        for sk in pairs(CMDIA.lib._buffer.values[k]) do
            if CMDIA.lib._buffer.values[k][sk] == nil then
                CMDIA.lib._buffer.values[k][sk] = CMDIA.lib._buffer.def_values[k][sk]
            end
        end
    end
end

-- for recycler (joker)

CMDIA.lib.recycler_insert = function(id, scalingVals)
    if not id then
        error("Recycle Inserting for [NIL]: ID is Nil")
    end
    if (not scalingVals) then
        error("Recycle Inserting for " .. id .. ": scalingVals is nil")
    end
    if type(scalingVals) ~= "table" and type(scalingVals) ~= "number" then
        error("Recycle Inserting for " .. id .. ": Wrong type of scalingVals, Current type: " .. tostring(type(scalingVals)))
    end
    CMDIA.lib.jkr.recycler_jkrs[id] = {
        scalingVals = scalingVals
    }
end