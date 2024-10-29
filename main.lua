-- King of Petrichor
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

require("./kop_helper")
require("./move")
require("./projectiles")
require("./attack_sprites")
require("./attacks")

local diff_icon = gm.sprite_add(_ENV["!plugins_mod_folder_path"].."/practice.png", 5, false, false, 12, 9)
local diff_icon2x = gm.sprite_add(_ENV["!plugins_mod_folder_path"].."/practice2x.png", 4, false, false, 25, 19)
local diff_sfx = gm.audio_create_stream(_ENV["!plugins_mod_folder_path"].."/practice.ogg")

local diff_id = -2
local init_diff = false
local warp = false
local init_stats = false

-- DEBUG
-- local stored = -1



-- ========== Main ==========

gm.pre_script_hook(gm.constants.__input_system_tick, function(self, other, result, args)

    -- Initialize "difficulty"
    if not init_diff then
        init_diff = true

        diff_id = gm.difficulty_create("klehrik", "kop")   -- Namespace, Identifier
        local class_diff = gm.variable_global_get("class_difficulty")[diff_id + 1]
        local values = {
            "Practice Fight",   -- Name
            "Practice against the final boss.",  -- Description
            diff_icon,      -- Sprite ID
            diff_icon2x,    -- Sprite Loadout ID
            5595306,        -- Primary Color
            diff_sfx,       -- Sound ID
            0.0,            -- diff_scale
            0.0,            -- general_scale
            0.0,            -- point_scale
            false,          -- is_monsoon_or_higher
            false           -- allow_blight_spawns
        }
        for i = 2, 12 do gm.array_set(class_diff, i, values[i - 1]) end
    end

    -- Difficulty manager
    if gm._mod_game_getDifficulty() == diff_id then
        if gm.variable_global_get("stage_id") ~= 9.0 then
            gm.stage_goto(9.0)
            warp = true
            init_stats = true
        else
            local player = Helper.get_client_player()
            if player then
                -- Warp to arena
                if warp then
                    warp = false
                    local cmd = Helper.find_active_instance(gm.constants.oCommand)
                    if cmd then player.x, player.y = cmd.x, cmd.y - 12 end
                end
                
                -- Give player items
                if init_stats then
                    init_stats = false
                    gm.item_give(player, gm.item_find("ror-paulsGoatHoof"), 1)
                    gm.item_give(player, gm.item_find("ror-sproutingEgg"), 1)
                    gm.item_give(player, gm.item_find("ror-barbedWire"), 3)
                end

                -- Keep level at 4
                local director = Helper.find_active_instance(gm.constants.oDirectorControl)
                if director then
                    director.player_level = 4.0
                    director.player_exp = 0.0
                end
            end
        end
    end


    -- Providence
    if Helper.instance_exists(boss) then

        -- Set title
        local title = "King of Petrichor"
        boss.name2 = title
        local hud = Helper.find_active_instance(gm.constants.oHUD)
        if hud then hud.boss_party_active.text2 = title end

        
        -- Swift Slash
        -- Boosts the first swing after a shockwave and downslam
        if boss.sprite_index == Attacks.shockwave then
            Move.add("Swift Slash 1", Attacks.swing, 0, swift_slash_1)
            Move.add("Swift Slash Speed 1", Attacks.downslam, 0, swift_slash_speed_1)
            Move.remove("Swift Slash 2")
            Move.remove("Swift Slash 3")
            Move.remove("Swift Slash Speed 2")
            Move.remove("Swift Slash Speed 3")
        end

        -- Faster Firing
        -- Shoots hit markers faster, and also shoots more ahead at <50% HP
        if boss.sprite_index == Attacks.hit_markers_intro then
            Move.add("Faster Firing 1", Attacks.hit_markers, 0, faster_firing_1)
            Move.remove("Faster Firing 2")
            Move.remove("Faster Firing Extra")
        end

        -- Countershield
        -- Creates a heavily damaging area of big hit markers whenever shield goes up (phase 3+)
        if boss.armor >= 900000.0 and current_phase() >= 2 and not boss.countershield and hp_below_threshold(0.9) then
            boss.countershield = true
            Move.add("Countershield", "constant", 0, countershield)
        end
        if boss.armor < 900000.0 and boss.countershield then boss.countershield = nil end

        -- Downslam Projectiles
        -- Creates grounded projectiles on downslam that must be jumped over/i-framed through (phase 3+)
        if boss.sprite_index ~= Attacks.downslam_clones then
            Move.add("Downslam Projectiles", Attacks.downslam_clones, 25, downslam_projectiles)
        end

        -- Combo+
        -- Adds death hit markers to the first two attacks (phase 4)
        if boss.sprite_index == Attacks.combo_intro then
            Move.add("Combo 1", Attacks.combo_1, 8, combo_1)
            Move.remove("Combo 2")
            Move.remove("Combo 3")
        end

        -- Scatterbomb
        -- Scatter many hit markers around the arena during pizza
        if boss.sprite_index ~= Attacks.pizza then
            Move.add("Scatterbomb", Attacks.pizza, 64, scatterbomb)
        end


        -- Attack listener
        Move.check(boss)

    else if Helper.instance_exists(gm.constants.oDirectorControl) then Move.moves = {} end
    end


    -- Wurms
    -- Passively fire slower projectiles; fire rate speeds up as health decreases
    local wurms, exist = Helper.find_active_instance_all(gm.constants.oWurmHead)
    if exist then
        for _, wurm in ipairs(wurms) do

            local scale = wurm.hp / wurm.maxhp
            if frame % math.max(math.floor(120 * scale), 40) == 0 then
                if wurm.target ~= -4.0 then
                    local target = wurm.target.parent
                    if target then
                        local m = spawn_wurm_missile(wurm, wurm.x, wurm.y, target.x, target.y,
                        wurm.image_angle + gm.choose(gm.random_range(-80, -100), gm.random_range(80, 100)),
                        target, 0.6, 0.33)
                        m.color = 8437759
                        m.image_blend = 8437759
                        m.image_alpha = 0.75
                    end
                end
            end

        end
    end


    -- Wurm Missile speed reduction
    local ms = Helper.find_active_instance_all(gm.constants.oWurmMissile)
    for _, m in ipairs(ms) do
        if m.speed_scale and m.state > 0.0 then m.speed = m.speed - (0.5 - (m.speed_scale * 0.5)) end
        
        if m.lifetime then
            m.lifetime = m.lifetime - 1
            if m.lifetime <= 0 then gm.instance_destroy(m) end
        end
    end



    -- DEBUG
    -- if boss then
    --     if stored ~= boss.sprite_index then
    --         stored = boss.sprite_index
    --         log.info(gm.sprite_get_name(boss.sprite_index))
    --         log.info("spr index:     "..boss.sprite_index)
    --         log.info("image count:   "..gm.sprite_get_number(boss.sprite_index))
    --         log.info("current image: "..boss.image_index)
    --         log.info("")
    --     end
    -- end
end)


gm.pre_code_execute("gml_Object_oDirectorControl_Alarm_1", function(self, other)
    -- Prevent enemies from spawning in practice
    if gm._mod_game_getDifficulty() == diff_id then
        self:alarm_set(1, 60)
        return false
    end
end)


-- gui.add_imgui(function()
--     if ImGui.Begin("KoP") then

--         if ImGui.Button("Log all states") then
--             -- log.info("")
--             -- log.info("[delta]")
--             -- for k, v in pairs(delta) do
--             --     log.info(k..": "..v)
--             -- end

--             -- log.info("")
--             -- log.info("[swift_slash]")
--             -- for k, v in pairs(swift_slash) do
--             --     log.info(k..": "..v)
--             -- end

--             -- log.info("")
--             -- log.info("[faster_firing]")
--             -- for k, v in pairs(faster_firing) do
--             --     log.info(k..": "..v)
--             -- end

--             -- log.info("")
--             -- log.info("[downslam]")
--             -- for k, v in pairs(downslam) do
--             --     log.info(k..": "..v)
--             -- end

--             if Helper.instance_exists(boss) then
--                 boss.attack_speed = 100.0
--             end

--         elseif ImGui.Button("Test") then
--             local p = Helper.get_client_player()

--             log.info(#Move.moves)

--             for _, m in ipairs(Move.moves) do
--                 log.info(m.id)
--             end

--             -- gm.instance_create_depth(p.x, p.y, 0, gm.constants.oBossSkill2)
--             -- local tracer = gm.instance_create_depth(p.x, p.y, 0, gm.constants.oEfBossShadowTracer)
--             -- tracer.sX, tracer.sY = p.x, p.y
--             -- tracer.tX, tracer.tY = p.x, p.y
--             -- tracer.image_alpha = 0.33

--             --spawn_hit_marker(p.x, p.y)

--             -- local proj = gm.instance_create_depth(p.x, p.y, 0, gm.constants.oBossSkill3)
--             -- proj.image_xscale = 3.0
--             -- proj.image_yscale = 3.0

--             -- local s = gm.instance_create_depth(p.x + 100, p.y - 100, 0, gm.constants.oWurmMissile)
--             -- s.direction = 90
--             -- s.targetX = p.x
--             -- s.targetY = p.y

--             --local proj = gm.instance_create_depth(p.x, p.y, 0, gm.constants.oBossSkill1)

--             -- local b = gm.instance_create_depth(p.x - 100, p.y, 0, gm.constants.oBoss1Bullet1)
--             -- b.image_xscale = -1.0
--             -- b.hspeed = -10.0
--             -- b.parent = p

--             -- local m = spawn_wurm_missile(p.x, p.y - 100, p.x, p.y, 0, p, -4)

--         elseif ImGui.Button("Sprite and image data") then
--             -- boss = Helper.find_active_instance(gm.constants.oBoss1)
--             -- if not boss then boss = Helper.find_active_instance(gm.constants.oBoss3) end
--             -- if not boss then boss = Helper.find_active_instance(gm.constants.oBoss4) end

--             if boss then
--                 log.info(gm.sprite_get_name(boss.sprite_index))
--                 log.info("spr index:     "..boss.sprite_index)
--                 log.info("image count:   "..gm.sprite_get_number(boss.sprite_index))
--                 log.info("current image: "..boss.image_index)
--                 log.info("")
--             end

--             --log.info(Helper.find_active_instance(gm.constants.oBoss1Bullet1).direction)

--         end

--     end

--     ImGui.End()
-- end)