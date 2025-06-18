
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
        ["c_emperor"] = true,
        ["c_high_priestess"] = true,
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
                if pseudorandom('wheel_of_fortune') < G.GAME.probabilities.normal/used_tarot.ability.extra then
                    local temp_pool =   used_tarot.eligible_strength_jokers
                    local over = false
                    local eligible_card = pseudorandom_element(temp_pool, pseudoseed('wheel_of_fortune'))
                    local edition = nil
                    edition = poll_edition('wheel_of_fortune', nil, true, true)
                    eligible_card:set_edition(edition, true)
                    check_for_unlock({type = 'have_edition'})
                    used_tarot:juice_up(0.3, 0.5)
                else
                    attention_text({
                        text = localize('k_nope_ex'),
                        scale = 1.3, 
                        hold = 1.4,
                        major = used_tarot,
                        backdrop_colour = G.C.SECONDARY_SET.Tarot,
                        align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and 'tm' or 'cm',
                        offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and -0.2 or 0},
                        silent = true
                        })
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                        play_sound('tarot2', 0.76, 0.4);return true end}))
                    play_sound('tarot2', 1, 0.4)
                    used_tarot:juice_up(0.3, 0.5)
                end
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
        ["c_emperor"] = function(used_tarot)
            for i = 1, math.min((used_tarot.ability.consumeable.tarots or used_tarot.ability.consumeable.planets), G.consumeables.config.card_limit - #G.consumeables.cards) do
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        play_sound('timpani')
                        local card = create_card((used_tarot.ability.name == 'The Emperor' and 'Tarot') or (used_tarot.ability.name == 'The High Priestess' and 'Planet'), G.consumeables, nil, nil, nil, nil, nil, (used_tarot.ability.name == 'The Emperor' and 'emp') or (used_tarot.ability.name == 'The High Priestess' and 'pri'))
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        used_tarot:juice_up(0.3, 0.5)
                    end
                    return true end }))
            end
            delay(0.6)
        end
    }
}

CMDIA.dramatist_tarots.tarot_usage.c_high_priestess = CMDIA.dramatist_tarots.tarot_usage.c_emperor

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
        blueprint_compat = false,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "u/DerpVN112", colours = { G.C.WHITE, HEX("77d96a") }}}
            info_queue[#info_queue+1] = {key = 'cmdia_credit_art', set = 'Other', vars = { "u/DerpVN112", colours = { G.C.WHITE, HEX("77d96a") }}}
            return { vars = {card.ability.extra.triggers, (card.ability.extra.triggers == 1) and "y" or "ies"} }
        end,
        calculate = function(self, card, context)

            if context.cmdia_clover and card.ability and card.ability.extra then

                
                if not card.ability.extra.temp_perm then card.ability.extra.temp = math.random() * math.random() end

                local clovers = SMODS.find_card("j_cmdia_fourleaf_clover")

                if context.cmdia_clovercard.ability.extra.temp ~= card.ability.extra.temp then print("NUH UH | CMDIA "); return end

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
                    
                    if #clovers > G.CMDIA_clover_triggering_index then
                        G.CMDIA_clover_triggering_index = G.CMDIA_clover_triggering_index + 1
                        context.cmdia_clovercard.ability.extra.temp = card.ability.extra.temp
                        context.cmdia_clovercard.ability.extra.temp_perm = true
                    else
                        G.CMDIA_clover_triggering = false
                    end
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
        cost = 9,
        unlocked = true,
        discovered = true,
        blueprint_compat = true,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "u/someonenoonenever", colours = { G.C.FILTER, G.C.WHITE }}}
            info_queue[#info_queue+1] = {key = 'cmdia_credit_art', set = 'Other', vars = { "u/someonenoonenever", colours = { G.C.FILTER, G.C.WHITE }}}
            return { vars = {} }
        end,
        calculate = function(self, card, context)
            if context.using_consumeable then

                -- planet cards
                if context.consumeable.ability.set == 'Planet' and context.consumeable.ability.consumeable.hand_type and (not context.CMDIA_dramatist) then

                    SMODS.calculate_effect({message = localize("k_again_ex")}, context.blueprint_card or card)

                    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(context.consumeable.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].chips, mult = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].mult, level=G.GAME.hands[context.consumeable.ability.consumeable.hand_type].level})
                    level_up_hand(context.blueprint_card or card, context.consumeable.ability.consumeable.hand_type)
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

                        SMODS.calculate_effect({message = localize("k_again_ex")}, context.blueprint_card or card)

                        CMDIA.dramatist_tarots.tarot_usage[context.consumeable.config.center.key](context.consumeable)
                    end
                end
            end
        end,
    },
    ['bank_account'] = {
        config = {
            extra = {
                
            }
        },
        pos = { x = 2, y = 0 },
        rarity = 2,
        cost = 5,
        unlocked = true,
        discovered = true,
        blueprint_compat = false,
        mod_incompats = {
            "Talisman"
        },
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "Friazes", colours = { G.C.FILTER, G.C.WHITE }}}
            return { vars = {} }
        end,
        calculate = function(self, card, context)
        end,
    },
    ['kintsugi'] = {
        config = {
            extra = {
            }
        },
        pos = { x = 3, y = 0 },
        rarity = 3,
        cost = 6,
        unlocked = true,
        discovered = true,
        blueprint_compat = false,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "pie-en-argent", colours = { G.C.FILTER, G.C.WHITE }}}
            return { vars = {} }
        end,
        calculate = function(self, card, context)
        end,
    },
    ['theseus'] = {
        config = {
            extra = {
                slots = 1
            }
        },
        pos = { x = 4, y = 0 },
        rarity = 1,
        cost = 1,
        unlocked = false,
        discovered = false,
        blueprint_compat = false,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "Pusheenunderscore", colours = { G.C.FILTER, G.C.WHITE }}}
            return { vars = {card.ability.extra.slots} }
        end,
        add_to_deck = function(self, card, from_debuff)
            G.jokers.config.card_limit = lenient_bignum(
                G.jokers.config.card_limit + to_big(card.ability.extra.slots)
            )
        end,
        remove_from_deck = function(self, card, from_debuff)
            G.jokers.config.card_limit = lenient_bignum(
                G.jokers.config.card_limit - to_big(card.ability.extra.slots)
            )
        end,
        check_for_unlock = function(self, args)
            if args.type == 'win_custom' then
                if G.GAME.max_jokers <= G.jokers.config.card_limit - 1 then
                    unlock_card(self)
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

    local clovers = SMODS.find_card("j_cmdia_fourleaf_clover")

    for i, v in ipairs(clovers) do
        v.ability.extra.temp_perm = false
    end

    G.CMDIA_clover_triggering = false
end

local orig_pseudorandom = pseudorandom

function pseudorandom(seed, min, max)
    local result = orig_pseudorandom(seed, min, max)

    local clovers = SMODS.find_card("j_cmdia_fourleaf_clover")

    local safeIndex = 1

    for i, v in ipairs(clovers) do
        if v.ability.extra.triggers ~= 0 then
            safeIndex = i
            break
        end
    end

    if next(SMODS.find_card("j_cmdia_fourleaf_clover")) and G.CMDIA_clover_triggering then

        SMODS.calculate_context({cmdia_clover = true, cmdia_clovercard = clovers[safeIndex]}) -- line thats crashing
        result = 0
    end

    return result
end

-- joker registry --

for k, v in pairs(jokers) do
    v.key = k
    v.name = k
    local mod_incompats = v.mod_incompats or {}
    v.mod_incompats = nil

    local shouldAdd = true

    for i, v in ipairs(mod_incompats) do
        if (SMODS.Mods[v] or {}).can_load then
            shouldAdd = false
        end
    end

    if shouldAdd then SMODS.Joker(v) end    

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