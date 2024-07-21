-- KoP Helper

frame = 0
boss = nil



-- ========== Functions ==========

function hp_below_threshold(n)
    return boss.hp / boss.maxhp <= n
end

function current_phase()
    if boss.object_index == gm.constants.oBoss1 then return 1 end
    if boss.object_index == gm.constants.oBoss3 then return 2 end
    if boss.object_index == gm.constants.oBoss4 then return 3 end
end



-- ========== Main ==========

gm.pre_script_hook(gm.constants.__input_system_tick, function(self, other, result, args)
    frame = frame + 1

    -- Get boss
    boss = Helper.find_active_instance(gm.constants.oBoss1)
    if not boss then boss = Helper.find_active_instance(gm.constants.oBoss3) end
    if not boss then boss = Helper.find_active_instance(gm.constants.oBoss4) end
end)