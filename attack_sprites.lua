-- Attack Sprites

Attacks = {
    -- Phase 1+                                                                                                 Max frame (indexed from 0)
    idle                = gm.constants.sBoss1Idle,          -- Usually occurs for a bit between attacks             8
    walk                = gm.constants.sBoss1Walk,          -- Usually occurs for a bit between attacks             7
    swing               = gm.constants.sBoss1ShootZ1,       --                                                      15
    downslam            = gm.constants.sBoss1ShootZ2,       --                                                      25
    shockwave           = gm.constants.sBoss1ShootX1,       --                                                      27
    hit_markers_intro   = gm.constants.sBoss1ShootC1_1,     -- Holds out his hand                                   12
    hit_markers         = gm.constants.sBoss1ShootC1_2,     -- Main attack                                          6

    -- Phase 3+
    support_projs       = gm.constants.sBoss3ShootC1_fast,  -- Fires out 2 "oWurmMissile"s                          10
    downslam_clones     = gm.constants.sBoss3ShootZ2,       -- Used for both 3 and 6 clones                         27

    -- Phase 4
    idle_4              = gm.constants.sBoss4Idle,          --                                                      7
    walk_4              = gm.constants.sBoss4Walk,          --                                                      7
    rest                = gm.constants.sBoss4Rest,          --                                                      26
    pizza               = gm.constants.sBoss4Spawn,         -- Starts on frame 40 on subsequent uses                77
    hit_markers_4_intro = gm.constants.sBoss3ShootC1_1,     -- Holds out his hand (phase 4 version)                 12
    hit_markers_4       = gm.constants.sBoss4ShootC1_2,     -- Faster version of hit_markers in phase 4             7
    support_projs_4     = gm.constants.sBoss4ShootC1_fast,  -- Fires out 4 "oWurmMissile"s                          10
    hori_pillar         = gm.constants.sBoss4ShootC1,       --                                                      22
    vert_pillar         = gm.constants.sBoss4ShootC2,       --                                                      25
    combo_intro         = gm.constants.sBoss4ShootZ2_1,     -- Initial teleport (not a slash)                       10
    combo_1             = gm.constants.sBoss4ShootZ2_2,     --                                                      14
    combo_2             = gm.constants.sBoss4ShootZ2_3,     --                                                      15
    combo_3             = gm.constants.sBoss4ShootZ2_4      --                                                      18
}
