-- Move

Move = {
    moves = {}
}

function Move.add(id, attack, frame, func)
    for _, m in ipairs(Move.moves) do
        if m.id == id then return end
    end

    local m = {
        id = id,
        attack = attack,
        frame = frame,
        func = func
    }

    table.insert(Move.moves, m)
    return m
end

function Move.remove(id)
    for _, m in ipairs(Move.moves) do
        if m.id == id then
            table.remove(Move.moves, _)
            return
        end
    end
end

function Move.check(boss)
    if not boss then return end
    
    for _, m in ipairs(Move.moves) do
        if m.attack == "constant" or (boss.sprite_index == m.attack and boss.image_index >= m.frame) then
            if m.func() then table.remove(Move.moves, _) end
        end
    end
end