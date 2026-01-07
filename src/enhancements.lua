local modPrefix = "cmdia"

SMODS.Atlas {
    key = 'cmdia_enhancements',
    path = 'spritesheet_enh.png',
    px = 71,
    py = 95,
    prefix_config = { key = false }
}

local enhancements = {
    ["philosopher"] = {
        pos = { x = 0, y = 0 },
        atlas = "cmdia_enhancements",
        unlocked = true,
        discovered = true,
        no_rank = true,           -- for stone
        no_suit = true,           -- for stone
        -- shatters = true,          -- for glass (commented out because uhhh doesn't work with the hook lmao)
        replace_base_card = true, -- for stone
        always_scores = true,
        calculate = function(self, card, context)
            -- Counts as Stone, Glass, Steel, Lucky, and Gold cards.
            -- Can't be debuffed or destroyed.

            local vars = {}
            local cae = { stone = 50, glass = 2, steel = 1.5, gold = 3, chancesG = 4, chancesL_M = 5, chancesL_D = 15, c_mult = 20, c_money = 20 }

            if context.cardarea == G.play and context.main_scoring then
                vars.chips = cae.stone

                vars.x_mult_mod = cae.glass

                if CMDIA.roll("phil_lucky1", cae.chancesL_M) then vars.mult_mod = cae.c_mult end

                if CMDIA.roll("phil_lucky1", cae.chancesL_M) then vars.dollars = cae.c_money end

                return vars
            end

            if context.final_scoring_step and context.cardarea == G.hand then
                vars.x_mult_mod = cae.steel
                vars.dollars = cae.gold

                return vars
            end
        end
    }
}

-- hooks for philosopher
oSMODS_has_enhancement = SMODS.has_enhancement -- made global on purpose

function SMODS.has_enhancement(th, key)
    local phils = {
        m_steel = true,
        m_gold = true,
        m_lucky = true,
        m_glass = true,
        m_stone = true
    }

    if phils[key] and SMODS.find_card('j_cmdia_ritual') and oSMODS_has_enhancement(th, "m_cmdia_philosopher") then
        return true
    else
        return oSMODS_has_enhancement(th, key)
    end
end

local oCard_set_debuff = Card.set_debuff

function Card.set_debuff(th, should_debuff)
    if not oSMODS_has_enhancement(th, "m_cmdia_philosopher") then
        oCard_set_debuff(th, should_debuff)
    else
        th.debuff = false
    end
end

local oCard_start_dissolve = Card.start_dissolve

function Card.start_dissolve(th, dissolve_colours, silent, dissolve_time_fac, no_juice)
    if oSMODS_has_enhancement(th, "m_cmdia_philosopher") then
        SMODS.calculate_effect({ message = localize('cmdia_ritual_indestructable') }, th)
    else
        oCard_start_dissolve(th, dissolve_colours, silent, dissolve_time_fac, no_juice)
    end
end

local template = {
    ["enh"] = {
        atlas = "cmdia_enhancements",
        unlocked = true,
        discovered = true,
        pos = { x = 0, y = 0 },
        calculate = function(self, card, context)

        end
    }
}

for k, v in pairs(enhancements) do
    v.key = k
    v.name = k
    local mod_incompats = v.mod_incompats or {}
    v.mod_incompats = nil

    local shouldAdd = true

    for _, v in ipairs(mod_incompats) do
        if (SMODS.Mods[v] or {}).can_load then
            shouldAdd = false
        end
    end

    if shouldAdd then SMODS.Enhancement(v) end
end
