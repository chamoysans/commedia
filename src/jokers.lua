
local testDeck = false -- for some reason test decks are broken

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

CMDIA.dramatist_tarots = {
    tarot_supported = {
        ["c_hermit"] = true,
        ["c_wheel_of_fortune"] = true,
        ["c_temperance"] = true,
        ["c_judgement"] = true,
    },
    tarot_usage = {
        ["c_hermit"] = function(used_tarot)
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                used_tarot:juice_up(0.3, 0.5)
                ease_dollars(math.max(0,math.min(G.GAME.dollars, used_tarot.ability.extra)), true)
                return true end }))
            delay(0.6)
        end,
        ["c_wheel_of_fortune"] = function(used_tarot)
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                local over = false
                local eligible_card = pseudorandom_element(temp_pool, pseudoseed('wheel_of_fortune'))
                local edition = nil
                edition = poll_edition('wheel_of_fortune', nil, true, true)
                eligible_card:set_edition(edition, true)
                check_for_unlock({type = 'have_edition'})
                used_tarot:juice_up(0.3, 0.5)
            return true end }))
        end,
        ["c_temperance"] = function(used_tarot)
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                used_tarot:juice_up(0.3, 0.5)
                ease_dollars(used_tarot.ability.money, true)
                return true end }))
            delay(0.6)
        end,
        ["c_judgement"] = function(used_tarot)
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                local card = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'jud')
                card:add_to_deck()
                G.jokers:emplace(card)
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            delay(0.6)
        end,
    }
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
    },
    ['dramatist'] = {
        config = {
            extra = {
                
            }
        },
        pos = { x = 1, y = 0 },
        rarity = 3,
        cost = 7,
        unlocked = true,
        discovered = true,
        blueprint_compat = true,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "u/someonenoonenever", colours = { G.C.FILTER, G.C.WHITE }}}
            return { vars = {} }
        end,
        calculate = function(self, card, context)
            if context.using_consumeable then

                -- planet cards
                if context.consumeable.ability.set == 'Planet' and context.consumeable.ability.consumeable.hand_type and (not context.CMDIA_dramatist) then

                    SMODS.calculate_effect({message = localize("k_again_ex")}, card)

                    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(context.consumeable.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].chips, mult = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].mult, level=G.GAME.hands[context.consumeable.ability.consumeable.hand_type].level})
                    level_up_hand(card, context.consumeable.ability.consumeable.hand_type)
                    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})

                    SMODS.calculate_context({using_consumeable = true, consumeable = context.consumeable, area = context.area, CMDIA_dramatist = true})

                    return({
                        message = localize('k_upgrade_ex'),
                        colour = G.C.SECONDARY_SET.Planet
                    })
                end

                -- tarot cards
                if context.consumeable.ability.set == 'Tarot' then
                    if CMDIA.dramatist_tarots.tarot_supported[context.consumeable.config.center.key] then

                        SMODS.calculate_effect({message = localize("k_again_ex")}, card)

                        CMDIA.dramatist_tarots.tarot_usage[context.consumeable.config.center.key](context.consumeable)
                    end
                end
            end
        end,
    },
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