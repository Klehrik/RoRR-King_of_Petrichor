-- Projectiles

function spawn_hit_marker(boss, x, y)
    if not boss then return end
    local proj = gm.instance_create_depth(x, y, -1, gm.constants.oBossSkill2)
    local tracer = gm.instance_create_depth(boss.x, boss.y, 0, gm.constants.oEfBossShadowTracer)
    tracer.sX, tracer.sY = boss.x, boss.y
    tracer.tX, tracer.tY = x, y
    tracer.image_alpha = 0.5
    return proj
end

function spawn_death_marker(x, y)
    return gm.instance_create_depth(x, y, -1, gm.constants.oBossSkill1)
end

function spawn_big_hit_marker(x, y)
    return gm.instance_create_depth(x, y, -1, gm.constants.oBossSkill3)
end

function spawn_shockwave(x, y)
    return gm.instance_create_depth(x, y, -1, gm.constants.oBossSkill3)
end

function spawn_wurm_missile(parent, x, y, tx, ty, direction, target, damage_scale, speed_scale)
    if not damage_scale then damage_scale = 1.0 end
    if not speed_scale then speed_scale = 1.0 end
    local m = gm.instance_create_depth(x, y, -1000.0, gm.constants.oWurmMissile)
    m.targetX = tx
    m.targetY = ty
    m.direction = direction
    m.parent = parent
    m.target = target
    m.damage = parent.damage * 0.9 * damage_scale
    m.speed_scale = speed_scale
    m.lifetime = 600
    return m
end