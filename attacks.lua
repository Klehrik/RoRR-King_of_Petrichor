-- Attacks

require("./kop_helper")
require("./move")
require("./projectiles")
require("./attack_sprites")


-- Swift Slash
function swift_slash_1()
    -- At the beginning of the swing, increase attack speed
    -- Also freeze movement
    boss.attack_speed = 1.5     -- Apparently vanilla Provi's shield gives him attack speed, and it is set directly, so I
                                -- have to also set it directly instead of adding/subtracting or else things have a chance to break
    boss.pHspeed = 0.0
    Move.add("Swift Slash 2", Attacks.swing, 7, swift_slash_2)
    Move.remove("Swift Slash Speed 1")
    return true
end

function swift_slash_2()
    -- On frame 7 of the swing, create hit markers
    for i = 1, 8 do spawn_hit_marker(boss, boss.x + (32.0 * i * boss.image_xscale), boss.y) end
    Move.add("Swift Slash 3", Attacks.swing, 13, swift_slash_3)
    return true
end

function swift_slash_3()
    -- At the end of the swing, reset attack speed
    boss.attack_speed = 1.0
    return true
end

function swift_slash_speed_1()
    -- Check for next walk after downslam
    Move.add("Swift Slash Speed 2", Attacks.walk, 0, swift_slash_speed_2)
    return true
end

function swift_slash_speed_2()
    -- At the start of the walk, increase movement speed
    boss.pHmax = boss.pHmax + 6.0
    boss.friction = boss.friction + 6.0
    Move.add("Swift Slash Speed 3", "constant", 0, swift_slash_speed_3)
    return true
end

function swift_slash_speed_3()
    -- Reset movement speed after walk end
    if boss.sprite_index ~= Attacks.idle
    and boss.sprite_index ~= Attacks.walk then
        boss.pHmax = boss.pHmax - 6.0
        boss.friction = boss.friction - 6.0
        return true
    end
    return false
end


-- Faster Firing
function faster_firing_1()
    -- At the start of firing, increase attack speed
    boss.attack_speed = 2.0
    Move.add("Faster Firing 2", "constant", 0, faster_firing_2)
    Move.add("Faster Firing Extra", "constant", 0, faster_firing_extra)
    return true
end

function faster_firing_2()
    -- Reset attack speed after the attack is done
    if boss.sprite_index ~= Attacks.hit_markers then
        boss.attack_speed = 1.0
        return true
    end
    return false
end

function faster_firing_extra()
    -- Fire extra hits ahead of the target when under <50% HP
    if hp_below_threshold(0.5) and frame % 30 == 0 then
        local target = boss.target.parent
        if target then
            local offset_x = gm.random_range(0, 32)
            local offset_y = gm.random_range(-32, 32)
            spawn_hit_marker(boss, target.x + offset_x + (target.pHspeed * 120), target.y + offset_y)
        end
    end

    if boss.sprite_index ~= Attacks.hit_markers then return true end
    return false
end


-- Countershield
function countershield()
    -- Create heavily damaging big hit markers in an area
    local count = 3
    for n = 1, count do spawn_big_hit_marker(boss.x, boss.y) end
    for i = 0, 5 do
        local angle = i * 60.0
        local dist = 128
        for n = 1, count do spawn_big_hit_marker(boss.x + (gm.dcos(angle) * dist), boss.y + (gm.dsin(angle) * dist)) end
    end
    return true
end


-- Downslam Projectiles
function downslam_projectiles()
    -- Create grounded projectiles in both directions
    local the_floor = 20
    for i = 0, 1 do
        local m = spawn_wurm_missile(boss, boss.x, boss.y + the_floor, boss.x, boss.y + the_floor, 180 * i, -4, 0.4, 0.5)
        m.color = 8437759
        m.image_blend = 8437759
        m.image_alpha = 0.75
    end
    return true
end


-- Combo+
function combo_1()
    for i = 1, 12 do
        spawn_death_marker(boss.x - (128.0 * boss.image_xscale) + (32.0 * i * boss.image_xscale), boss.y)
    end
    Move.add("Combo 2a", Attacks.combo_2, 7, combo_2a)
    return true
end

function combo_2a()
    local markers = 6
    local offset = 16 - (markers * 16)
    for i = 1, markers do
        spawn_death_marker(boss.x + offset, boss.y + offset)
        offset = offset + 32
    end
    Move.add("Combo 2b", Attacks.combo_2, 9, combo_2b)
    return true
end

function combo_2b()
    local markers = 6
    local offset = 16 - (markers * 16)
    for i = 1, markers do
        spawn_death_marker(boss.x - offset, boss.y + offset)
        offset = offset + 32
    end
    return true
end


-- Scatterbomb
function scatterbomb()
    -- Scatter many hit markers around the arena
    -- Approx. arena coords: (8730, 2160) to (10360, 2850)
    local count = 50
    if hp_below_threshold(0.66) then count = 65 end     -- First shield threshold
    if hp_below_threshold(0.33) then count = 80 end     -- Second shield threshold
    for i = 1, count do
        spawn_hit_marker(boss, gm.random_range(8730, 10360), gm.random_range(2160, 2850))
    end
    return true
end