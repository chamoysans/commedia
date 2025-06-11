
local testDeck = true

local modPrefix = "cmdia"

function HEX(hex) -- needed for colors
    if #hex <= 6 then hex = hex.."FF" end
    local _,_,r,g,b,a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    local color = {tonumber(r,16)/255,tonumber(g,16)/255,tonumber(b,16)/255,tonumber(a,16)/255 or 255}
    return color
end

SMODS.Atlas{
    key = 'cmdia_jokers',
    path = 'spritesheet.png',
    px = 71,
    py = 95,
    prefix_config = { key = false }
}

local jokers = {
    ['fourleaf_clover'] = {
        config = {
            extra = {
                triggers = 4,
                temp = nil,
            }
        },
        pos = { x = 0, y = 0 },
        rarity = 2,
        cost = 5,
        unlocked = true,
        discovered = true,
        blueprint_compat = true,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "u/DerpVN112", colours = { G.C.WHITE, HEX("77d96a") }}}
            return { vars = {card.ability.extra.triggers, (card.ability.extra.triggers == 1) and "y" or "ies"} }
        end,
        calculate = function(self, card, context)

            if context.cmdia_clover and card.ability and card.ability.extra then

                card.ability.extra.temp = math.random() * (math.random() * 100)

                local clovers = SMODS.find_card("j_cmdia_fourleaf_clover")

                if clovers[G.CMDIA_clover_triggering_index].ability.extra.temp ~= card.ability.extra.temp then return end

                card.ability.extra.triggers = card.ability.extra.triggers - 1
                
                if card.ability.extra.triggers <= 0 then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            card.T.r = -0.2
                            card:juice_up(0.3, 0.4)
                            card.states.drag.is = true
                            card.children.center.pinch.x = true
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                delay = 0.3,
                                blockable = false,
                                func = function()
                                    G.jokers:remove_card(card)
                                    card:remove()
                                    card = nil
                                    return true;
                                end
                            }))
                            return true
                        end
                    }))
                    G.CMDIA_clover_triggering_index = G.CMDIA_clover_triggering_index + 1
                    clovers[G.CMDIA_clover_triggering_index].ability.extra.temp = card.ability.extra.temp
                    return {
                        message = G.localization.misc.dictionary.cmdia_plucked
                    }
                else
                    return {
                        message = tostring(card.ability.extra.triggers)
                    }
                end
            end
        end,
    }
}

-- four leaf clover stuff --

local orig_evaluate_play = G.FUNCS.evaluate_play

G.FUNCS.evaluate_play = function(e)

    G.CMDIA_clover_triggering = true

    G.CMDIA_clover_triggering_index = 1

    orig_evaluate_play(e)

    G.CMDIA_clover_triggering = false
end

local orig_pseudorandom = pseudorandom

function pseudorandom(seed, min, max)
    local result = orig_pseudorandom(seed, min, max)

    local clovers = SMODS.find_card("j_cmdia_fourleaf_clover")

    if next(SMODS.find_card("j_cmdia_fourleaf_clover")) and G.CMDIA_clover_triggering then

        -- clovers[1].ability.extra.

        SMODS.calculate_context({cmdia_clover = true, card = clovers[1]}) -- line thats crashing
        result = 0
    end

    return result
end

-- joker registry --

for k, v in pairs(jokers) do
    v.key = k
    v.name = k
    SMODS.Joker(v)

    if testDeck then

        local deck = {
            key = v.key,
            pos = v.pos,
            name = v.name,   
            loc_txt = {
                name = v.name,
                text = {
                    v.name
                }
            },
            config = {},
            apply = function(self)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        add_joker("j_" .. modPrefix .. "_" .. k, nil, false, false)
                        return true
                    end
                }))
            end,
            atlas = v.atlas
        }

        SMODS.Back(deck)

    end
end

-- end --