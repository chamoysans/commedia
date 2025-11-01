
local testDeck = false -- for some reason test decks are broken

local modPrefix = "cmdia"

function HEX(hex) -- needed for colors
    if #hex <= 6 then hex = hex.."FF" end
    local _,_,r,g,b,a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    local color = {tonumber(r,16)/255,tonumber(g,16)/255,tonumber(b,16)/255,tonumber(a,16)/255 or 255}
    return color
end

function CMDIA.roll(seed, odds, norm) -- helper
    local prob = G.GAME.probabilities.normal
    return (pseudorandom(seed or 'DEFAULTSEEDCMDIA_123') < (prob or (norm or 1))/odds)
end

SMODS.Atlas{
    key = 'cmdia_jokers',
    path = 'spritesheet.png',
    px = 71,
    py = 95,
    prefix_config = { key = false }
}

SMODS.Atlas{
    key = 'cmdia_j_questmaster',
    path = 'questmaster.png',
    px = 71,
    py = 95,
    prefix_config = { key = false }
}

local debug = true

function cmdiaprint(str)
    if debug then print(str) end
end

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

local function tableAdd(t1, t2)
    for k, v2 in pairs(t2) do
        local v1 = t1[k]
        if type(v1) == "table" and type(v2) == "table" then
            tableAdd(v1, v2)
        elseif type(v1) == "number" and type(v2) == "number" then
            t1[k] = v1 + v2
        else
            t1[k] = v2
        end
    end
    return t1
end

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
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "u/DerpVN112", colours = { G.C.WHITE, HEX("77d96a") }}}
                info_queue[#info_queue+1] = {key = 'cmdia_credit_art', set = 'Other', vars = { "u/DerpVN112", colours = { G.C.WHITE, HEX("77d96a") }}}
            end
            return { vars = {card.ability.extra.triggers, (card.ability.extra.triggers == 1) and "y" or "ies"} }
        end,
        calculate = function(self, card, context)

            if context.cmdia_clover and card.ability and card.ability.extra and not context.blueprint then

                
                if not card.ability.extra.temp_perm then card.ability.extra.temp = math.random() * math.random() end

                local clovers = SMODS.find_card("j_cmdia_fourleaf_clover")

                if context.cmdia_clovercard.ability.extra.temp ~= card.ability.extra.temp then return end

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
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "u/someonenoonenever", colours = { G.C.FILTER, G.C.WHITE }}}
                info_queue[#info_queue+1] = {key = 'cmdia_credit_art', set = 'Other', vars = { "u/someonenoonenever", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            return { vars = {} }
        end,
        calculate = function(self, card, context)
            if context.using_consumeable and (not context.CMDIA_dramatist) then

                -- planet cards
                if context.consumeable.ability.set == 'Planet' then


                    SMODS.calculate_effect({message = localize("k_again_ex")}, context.blueprint_card or card)

                    --[[

                    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(context.consumeable.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].chips, mult = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].mult, level=G.GAME.hands[context.consumeable.ability.consumeable.hand_type].level})
                    level_up_hand(context.blueprint_card or card, context.consumeable.ability.consumeable.hand_type)
                    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})

                    ]]

                    local useFunction = context.consumeable.config.center.use or function(z, a, b, c, context, card)

                        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(context.consumeable.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].chips, mult = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].mult, level=G.GAME.hands[context.consumeable.ability.consumeable.hand_type].level})
                        level_up_hand(context.blueprint_card or card, context.consumeable.ability.consumeable.hand_type)
                        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
                    end

                    useFunction(context.consumeable, context.consumeable, context.area, nil, context, card) -- im fricking hoping this doesnt crash

                    SMODS.calculate_context({using_consumeable = true, consumeable = context.consumeable, area = context.area, CMDIA_dramatist = true, CMDIA_comet = context.CMDIA_comet})

                    return({
                        message = localize('k_upgrade_ex'),
                        colour = G.C.SECONDARY_SET.Planet
                    })
                end

                -- tarot cards
                if context.consumeable.ability.set == 'Tarot' then
                    if CMDIA.dramatist_tarots.tarot_supported[context.consumeable.config.center.key] then

                        SMODS.calculate_effect({message = localize("k_again_ex")}, context.blueprint_card or card)

                        G.GAME.consumeable_usage_total.tarot = G.GAME.consumeable_usage_total.tarot + 1

                        CMDIA.dramatist_tarots.tarot_usage[context.consumeable.config.center.key](context.consumeable)

                        SMODS.calculate_context({using_consumeable = true, consumeable = context.consumeable, area = context.area, CMDIA_dramatist = true})
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
            -- "Talisman"
        },
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "Friazes", colours = { G.C.FILTER, G.C.WHITE }}}
            end
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
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "pie-en-argent", colours = { G.C.FILTER, G.C.WHITE }}}
            end
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
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "Pusheenunderscore", colours = { G.C.FILTER, G.C.WHITE }}}
            end
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
    ['jimbos_comet'] = {
        config = {
            extra = {
                level_ups = 1
            }
        },
        pos = { x = 5, y = 0 },
        rarity = 2,
        cost = 6,
        unlocked = true,
        discovered = true,
        blueprint_compat = false, -- false cause hell NO i am not doing all that stupid shit with blueprint
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "GameShowWerewolf", colours = { G.C.WHITE, HEX("de2137") }}}
            end
            return { vars = {card.ability.extra.level_ups} }
        end,
        calculate = function(self, card, context)
            if context.using_consumeable and (not context.CMDIA_comet) and not context.blueprint then

                -- planet cards
                if context.consumeable.ability.set == 'Planet' then

                    local useFunction = context.consumeable.config.center.use or function(z, a, b, c, context, card)

                        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(context.consumeable.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].chips, mult = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].mult, level=G.GAME.hands[context.consumeable.ability.consumeable.hand_type].level})
                        level_up_hand(context.blueprint_card or card, context.consumeable.ability.consumeable.hand_type)
                        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
                    end

                    for i = 1, card.ability.extra.level_ups do
                        useFunction(context.consumeable, context.consumeable, context.area, nil, context, card)
                    end

                    return({
                        message = localize('k_upgrade_ex'),
                        colour = G.C.SECONDARY_SET.Planet
                    })
                end
            end
        end,
    },
    ['filibuster'] = {
        config = {
            extra = {
            }
        },
        pos = { x = 6, y = 0 },
        rarity = 2,
        cost = 6,
        unlocked = true,
        discovered = true,
        blueprint_compat = false,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "yellow-hammer", colours = { G.C.FILTER, G.C.WHITE }}}
                info_queue[#info_queue+1] = {key = 'cmdia_credit_art', set = 'Other', vars = { "yellow-hammer", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            return { vars = {} }
        end,
    },
    ['eternal'] = {
        config = {
            extra = {
                xmult = 1.5
            }
        },
        pos = { x = 7, y = 0 },
        rarity = 3,
        cost = 7,
        unlocked = true,
        discovered = true,
        blueprint_compat = false,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "ihavetoclear", colours = { G.C.FILTER, G.C.WHITE }}}
                info_queue[#info_queue+1] = {key = 'cmdia_credit_art', set = 'Other', vars = { "ihavetoclear", colours = { G.C.FILTER, G.C.WHITE }}}
                info_queue[#info_queue+1] = {key = 'cmdia_modified', set = 'Other', vars = {colours = { G.C.FILTER, G.C.WHITE }}}
            end
            return { vars = {card.ability.extra.xmult} }
        end,
        calculate = function(self, card, context)
            if context.end_of_round and not context.blueprint and G.GAME.blind.boss and not (G.GAME.blind.config and G.GAME.blind.config.bonus) then
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then
                        if i < #G.jokers.cards then
                            G.jokers.cards[i + 1].ability.eternal = true -- idfc about noneternal compat
                            SMODS.calculate_effect({message = CMDIA.get_dictionary("cmdia_locked")}, G.jokers.cards[i + 1])
                        end
                    end
                end
            end
            if context.other_joker and (context.other_joker.ability.eternal) and not context.blueprint then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_joker:juice_up(0.5, 0.5)
                        return true
                    end
                })) 
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}},
                    Xmult_mod = card.ability.extra.xmult
                }
            end
        end
    },
    ['impostor'] = {
        config = {
            extra = {
            }
        },
        pos = { x = 8, y = 0 },
        rarity = 2,
        cost = 7,
        unlocked = true,
        discovered = true,
        blueprint_compat = false,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "Wish_Solid", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            return { vars = {card.ability.extra.xmult} }
        end,
        calculate = function(self, card, context)
            if not context.CMDIA then return end
            if context.blueprint then return end
            if context.CMDIA.modify_hand_before and context.CMDIA.hand and not context.blueprint then
                local hand = context.CMDIA.hand
                local suitsFound = {
                    _buffer = {},
                }
                for i = 1, #hand do
                    suitsFound._buffer[#suitsFound._buffer + 1] = {card = hand[i], suit = hand[i]:CMDIA_get_suit()}

                end

                for i, v in ipairs(suitsFound._buffer) do
                    if not suitsFound[v.suit] then suitsFound[v.suit] = 0 end

                    if v.suit == "All" then
                        for j, w in ipairs(SMODS.Suits) do
                            suitsFound[w] = suitsFound[w] + 1
                        end
                    else
                        suitsFound[v.suit] = suitsFound[v.suit] + 1
                    end

                    
                end

                local transformCard = nil
                local transformSuit = ""
                for suit, count in pairs(suitsFound) do
                    if suit ~= "_buffer" and count >= 4 then
                        transformSuit = suit
                        for _, entry in ipairs(suitsFound._buffer) do
                            if entry.suit ~= suit then
                                transformCard = entry.card
                                break
                            end
                        end
                        break
                    end
                end

                if transformCard then
                    SMODS.calculate_effect({message = CMDIA.get_dictionary("cmdia_sus")}, transformCard)
                    SMODS.change_base(transformCard, transformSuit)
                end

            end
        end
    },
    ['flat_earth'] = {
        config = {
            extra = {
                repetitions = 0
            }
        },
        pos = { x = 9, y = 0 },
        rarity = 2,
        cost = 7,
        unlocked = true,
        discovered = true,
        blueprint_compat = true, -- do it if you dare (unless ur doing a lucky cat build then why not)
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "StatisticalMistake", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            return { vars = {card.ability.extra.xmult} }
        end,
        calculate = function(self, card, context)
            if context.repetition and context.cardarea == G.play then
                if context.other_card then
                    local reps = math.floor((to_number(G.GAME.hands[G.GAME.last_hand_played].level) or 1)*0.1)
                    return {
                        message = localize('k_again_ex'),
                        repetitions = reps,
                        card = card
                    }
                end
            end
            if context.CMDIA and context.CMDIA.blind_modify_hand then
                local s = context.CMDIA.hand_values

                s[1] = math.max(math.floor(s[1]*0.5 + 0.5), 1)
                s[2] = math.max(math.floor(s[2]*0.5 + 0.5), 0)
                s[3] = true

                SMODS.calculate_effect({message = CMDIA.get_dictionary("cmdia_halved")}, context.blueprint_card or card)
            end
        end
    },
    ['shapeshifter'] = {
        config = {
            extra = {
                gainmult = 0.2,
                xmult = 1
            }
        },
        pos = { x = 2, y = 1 },
        rarity = 3,
        cost = 7,
        unlocked = true,
        discovered = true,
        blueprint_compat = true,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "GoinXwell1", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            local valcard = G.GAME.current_round.shape_card or {suit1 = "Spades", suit2 = "Clubs"}
            return { vars = {card.ability.extra.gainmult, card.ability.extra.xmult, valcard.suit1, valcard.suit2} }
        end,
        calculate = function(self, card, context)
            if context.joker_main then
                local check = 0
                local valcard = G.GAME.current_round.shape_card
                for i = 1, #context.scoring_hand do
                    if (context.scoring_hand[i]:is_suit(valcard.suit1) or context.scoring_hand[i]:is_suit(valcard.suit2)) then check = check + 1 end
                end
                
                if check > 1 then
                    if not context.blueprint_card then
                        card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gainmult
                        SMODS.calculate_effect({message = localize('k_upgrade_ex')}, card)
                    end
                    return {
                        message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}},
                        Xmult_mod = card.ability.extra.xmult
                    }
                end
            end
        end
    },
    ['automation'] = {
        config = {
            extra = {
            }
        },
        pos = { x = 1, y = 1 },
        rarity = 2,
        cost = 7,
        unlocked = true,
        discovered = true,
        blueprint_compat = false,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "Zestyclose-Click6190", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            return { vars = {} }
        end,
        calculate = function(self, card, context)
            if context.before and not context.blueprint and (#context.full_hand < 5) then
                local faces = {}
                for k, v in ipairs(context.scoring_hand) do
                    if not (v:is_face()) then 
                        faces[#faces+1] = v
                        v:set_ability(G.P_CENTERS.m_steel, nil, true)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                v:juice_up()
                                return true
                            end
                        })) 
                    end
                end
                if #faces > 0 then 
                    return {
                        message = G.localization.misc.dictionary.cmdia_forged,
                        colour = G.C.BLACK,
                        card = card
                    }
                end
            end
        end
    },
    ['recycler'] = {
        config = {
            extra = {
            }
        },
        pos = { x = 0, y = 1 },
        rarity = 2,
        cost = 5,
        unlocked = true,
        discovered = true,
        blueprint_compat = false,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "ihavetoclear", colours = { G.C.FILTER, G.C.WHITE }}}
                info_queue[#info_queue+1] = {key = 'cmdia_credit_art', set = 'Other', vars = { "ihavetoclear, Me", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            return { vars = {} }
        end,
        calculate = function(self, card, context)
            local isDestroy = ((context.remove_playing_cards) or (context.using_consumeable and context.consumeable.ability.name == 'The Hanged Man') or (context.cards_destroyed and context.glass_shattered))
            if (context.selling_card or isDestroy) and not context.blueprint then
                local ammount = (context.cards_destroyed and context.glass_shattered) and #context.glass_shattered or 1
                local jokers = {}
                for i = 1, #G.jokers.cards do
                    if CMDIA.lib.jkr.recycler_jkrs[G.jokers.cards[i].config.center.key] then
                        jokers[#jokers + 1] = G.jokers.cards[i]
                    end
                end
                for i = 1, ammount do
                    for j = 1, #jokers do
                        local jkr = jokers[j]
                        local entry = CMDIA.lib.jkr.recycler_jkrs[jkr.config.center.key]
                        tableAdd(jkr.ability, entry.scalingVals)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                jkr:juice_up()
                                return true
                            end
                        })) 
                    end
                end
                if #jokers ~= 0 and ammount > 0 then
                    return {
                        message = CMDIA.get_dictionary("cmdia_scaled"),
                        colour = G.C.BLACK,
                        card = card
                    }
                end
            end
        end
    },
    ['microchip'] = {
        config = {
            extra = {
              Xmult = 1.2,
            }
        },
        pos = { x = 3, y = 1 },
        rarity = 2,
        cost = 5,
        unlocked = true,
        discovered = true,
        blueprint_compat = true,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "someonenooneever", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            return { vars = {card.ability.extra.Xmult} }
        end,
        calculate = function(self, card, context)
            if not context.CMDIA then return end
            if context.CMDIA.mchip_modify then
              SMODS.calculate_effect({xmult = card.ability.extra.Xmult}, card)
            end

            if context.CMDIA.blind_modify_hand then
                local s = context.CMDIA.hand_values

                s[2] = 1
                s[3] = true

                SMODS.calculate_effect({message = CMDIA.get_dictionary("cmdia_chipped")}, context.blueprint_card or card)
            end
        end
    },
    ['stanczyk'] = {
        config = {
            extra = {
                Xmult = 1,
                mod = 0.5
            }
        },
        pos = { x = 0, y = 2 },
        soul_pos = { x = 0, y = 3 },
        rarity = 2,
        cost = 5,
        unlocked = true,
        discovered = true,
        blueprint_compat = false,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "Zestyclose-Click6190", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            return { vars = {card.ability.extra.mod, card.ability.extra.Xmult} }
        end,
        calculate = function(self, card, context)
            local cvar = card.ability.extra
            if context.joker_main then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
                    Xmult_mod = card.ability.extra.Xmult
                }
            end
            if context.game_over and G.GAME.current_round.CMDIA.stan_round then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand_text_area.blind_chips:juice_up()
                        G.hand_text_area.game_chips:juice_up()
                        play_sound('tarot1')
                        return true
                    end
                })) 
                cvar.Xmult = math.max(1, cvar.Xmult - cvar.mod)
                return {
                    message = CMDIA.get_dictionary("cmdia_stan_lost"),
                    saved = true,
                    colour = G.C.RED
                }
            end
            if not context.CMDIA then return end
            local condia = context.CMDIA
            if condia.stan_msg then
                SMODS.calculate_effect({message = localize("k_again_ex")}, card)
            end
            --[[
            if condia.stan_lost then
                cvar.Xmult = math.max(1, cvar.Xmult - cvar.mod)
                SMODS.calculate_effect({message = CMDIA.get_dictionary("cmdia_stan_lost")}, card)
                return
            end]]
            if condia.stan_won then
                cvar.Xmult = cvar.Xmult + cvar.mod
                -- SMODS.calculate_effect({message = CMDIA.get_dictionary("cmdia_stan_won")}, card)
            end
        end,
        -- im too lazy to add the cmdia tables in the startup so here lmao
        add_to_deck = function(self, card, from_debuff)
            G.GAME.current_round.CMDIA = G.GAME.current_round.CMDIA or {}
            G.GAME.current_round.CMDIA.stan_round = false
        end,
        remove_from_deck = function(self, card, from_debuff)
            G.GAME.current_round.CMDIA = G.GAME.current_round.CMDIA or {}
            G.GAME.current_round.CMDIA.stan_round = false
        end,
    },
    ['regret'] = {
        config = {
            extra = {
                reps = 1,
            }
        },
        pos = { x = 4, y = 1 },
        rarity = 2,
        cost = 5,
        unlocked = true,
        discovered = true,
        blueprint_compat = true,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "T_A_amb", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            return { vars = {card.ability.extra.Xmult} }
        end,
        calculate = function(self, card, context)
            if context.repetition and context.cardarea == G.play and (#context.scoring_hand < 3) then
                if context.other_card then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = card.ability.extra.reps,
                        card = card
                    }
                end
            end
        end
    },
    ['jokertools'] = {
        config = {
            extra = {
                chanceone = 3,
                chancetwo = 5,
                chips = 15,
                mult = 5,
                reps = 1
            }
        },
        pos = { x = 5, y = 1 },
        rarity = 2,
        cost = 5,
        unlocked = true,
        discovered = true,
        blueprint_compat = true,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "Le_losermeatly75", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            local prob = G.GAME.probabilities.normal
            local cae = card.ability.extra 
            return { vars = {prob or 1, cae.chanceone, cae.chips, cae.mult, cae.chancetwo}}
        end,
        calculate = function(self, card, context)

            -- if your wondering why it doesnt say "Again!", its just how the game handles it
            -- and i am NOT patching allat just so that i can make it say "again!"

            if context.repetition and context.cardarea == G.play then
                local cae = card.ability.extra

                local jt1 = CMDIA.roll('cmdia_jkrtls1', cae.chanceone, 1) or false
                local jt2 = CMDIA.roll('cmdia_jkrtls1', cae.chanceone, 1) or false
                local jt3 = CMDIA.roll('cmdia_jkrtls1', cae.chanceone, 1) or false

                if jt1 then
                    SMODS.calculate_effect({chips = cae.chips, message = localize{ type = 'variable', key = 'a_chips', vars = { cae.chips }}}, card)
                end
                if jt2 then
                    SMODS.calculate_effect({mult  = cae.mult,  message = localize{ type = 'variable', key = 'a_mult',  vars = { cae.mult  }}}, card)
                end
                if jt3 and context.other_card then
                    SMODS.calculate_effect({repetitions = cae.reps, message = localize('k_again_ex')}, card)
                end

            end
        end
    },
    ['crane'] = {
        config = {
            extra = {
                hsize = 6,
                chance = 4,
                debuffed_cards = {}
            }
        },
        pos = { x = 6, y = 1 },
        rarity = 3,
        cost = 5,
        unlocked = true,
        discovered = true,
        blueprint_compat = false,
        atlas = "cmdia_jokers",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "TheBigOrangeLiam864", colours = { G.C.FILTER, G.C.WHITE }}}
            end
            local prob = G.GAME.probabilities.normal
            local cae = card.ability.extra 
            return { vars = {cae.hsize, prob or 1, cae.chance}}
        end,
        calculate = function(self, card, context)

            if context.blueprint then return end

            local cae = card.ability.extra

            if context.before then
                for k, v in ipairs(context.full_hand) do

                    local chance = CMDIA.roll('cmdia_crane', cae.chance) or false

                    if chance then
                        cae.debuffed_cards = cae.debuffed_cards or {}

                        cae.debuffed_cards[#cae.debuffed_cards + 1] = v
                        v:set_debuff(true)
                    end
                end
            end

            --[[
            if context.end_of_round then
                cae.debuffed_cards = cae.debuffed_cards or {}

                for i, v in ipairs(cae.debuffed_cards) do
                    v:set_debuff(false)
                end

                SMODS.calculate_effect({message = CMDIA.get_dictionary("cmdia_crane_clear")}, card)
            end
            ]]
        end,
        add_to_deck = function(self, card, from_debuff)
            G.hand:change_size(card.ability.extra.hsize)
        end,
        remove_from_deck = function(self, card, from_debuff)
            G.hand:change_size(0 - card.ability.extra.hsize)
        end,
    },
    ['questmaster'] = {
        config = {
            extra = {
                quest = nil,
                quest_vars = {

                },
                buffs = {
                    chips = 0,
                    mult = 0,
                    xmult = 1,
                    dollars = 0
                },
                reward = {0, nil},
                seedstuff = 0,
            }
        },
        pos = { x = 0, y = 0 },
        rarity = 3,
        cost = 5,
        unlocked = true,
        discovered = true,
        blueprint_compat = true,
        atlas = "cmdia_j_questmaster",
        loc_vars = function(self, info_queue, card)
            if CMDIA.config.credit_tooltips then
                info_queue[#info_queue+1] = {key = 'cmdia_credit', set = 'Other', vars = { "Subject-Purchase-130", colours = { G.C.FILTER, G.C.WHITE }}}
            end

            local prob = G.GAME.probabilities.normal
            local cae = card.ability.extra

            if not cae.buffs.chips then cae.buffs.chips = 0 end

            local reward = ""
            local thunk = cae.reward[2]
            if cae.quest then
                local vars = {}

                if cae.quest == "deal" or cae.quest == "oddball" then
                    vars[1] = cae.quest_vars["hand"]
                elseif cae.quest == "junk" then
                    vars[1] = (4 * G.GAME.round_resets.discards) - cae.quest_vars.discarded
                end

                info_queue[#info_queue+1] = {key = 'qmqttd_cmdia_' .. cae.quest, set = 'Other', vars = vars}

                if thunk == "m" then 
                    reward = localize{ type = 'variable', key = 'a_mult',  vars = { cae.reward[1]}}
                elseif thunk == "c" then
                    reward = localize{ type = 'variable', key = 'a_chips',  vars = { cae.reward[1]}}
                elseif thunk == "$" then
                    reward = "+$" .. tostring(cae.reward[1])
                elseif thunk == "xm" then
                    reward = localize{type = 'variable', key = 'a_xmult',  vars = { cae.reward[1]}}
                end
            end
            
            info_queue[#info_queue+1] = {key = 'qmqttd_cmdia_buffs', set = 'Other', vars = {cae.buffs.chips, cae.buffs.mult, cae.buffs.xmult, cae.buffs.dollars}}

            return { vars = {
                cae.quest_disp or "None",
                cae.quest and reward or "None",
                colours = {
                    ((thunk == "m" or thunk == "xm") and G.C.MULT or (thunk == "c" and G.C.CHIPS or (thunk == "$" and G.C.MONEY)))
                }}
            }
        end,
        calculate = function(self, card, context)
            local cae = card.ability.extra

            local buffs = cae.buffs

            if not cae.buffs.chips then cae.buffs.chips = 0 end -- for some reson ts is nil so here you go ig

            if context.setting_blind and not context.blueprint then

                SMODS.calculate_effect({message = CMDIA.get_dictionary("cmdia_qm_new")}, card)

                local quests = {
                    {"last_resort", "Last Resort", 1, 0},
                    {"headshot", "HEADSHOT", 2, 0},
                    {"deal", "Deal", 3, 0},
                    {"full_handed", "Full-handed", 0, 1},
                    {"gambling", "Gambling", 1, 1},
                    {"impulse", "Impulse Buyer", 2, 1},
                    {"vanilla", "Pure Vanilla",3, 1},
                    {"topping", "No Toppings",0, 2},
                    {"collector", "Collector",1, 2},
                    {"letting_go", "Letting Go",2, 2},
                    {"reader", "Reader",3, 2},
                    {"oddball", "Oddball",0, 3},
                    {"fast_forward", "Fast-forward",2, 3,},
                    {"junk", "It's All Junk",3, 3},
                }

                local entry = pseudorandom_element(quests, pseudoseed('cmdia_qm_quest_' .. tostring(cae.seedstuff)))

                local pos = card.config.center.pos

                pos.x, pos.y = entry[3], entry[4]

                if entry[1] == "oddball" and (CMDIA.roll('cmdia_qm_sandwich_ee', 50, 1) or false) then
                    pos.x = pos.x + 1
                end

                cae.seedstuff = cae.seedstuff + 1
                cae.quest = entry[1]
                cae.quest_disp = entry[2]

                cae.quest_vars = {}

                if entry[1] == "deal" or entry[1] == "oddball" then
                    local hands = {}

                    for k, v in pairs(G.GAME.hands) do
                        hands[#hands + 1] = k
                    end

                    cae.quest_vars["hand"] = pseudorandom_element(hands, pseudoseed("cmdia_qm_deal" .. tostring(cae.seedstuff)))
                elseif entry[1] == "full_handed" then
                    cae.quest_vars["fives"] = 0
                elseif entry[1] == "gambling" then
                    cae.quest_vars.rolls = 0
                elseif entry[1] == "impulse" then
                    cae.quest_vars.packs = 0
                elseif entry[1] == "vanilla" then
                    cae.quest_vars.scoredEnhanced = false
                elseif entry[1] == "topping" then
                    cae.quest_vars.scoredEditionorSeal = false
                elseif entry[1] == "junk" then
                    cae.quest_vars.discarded = 0
                end
                

                cae.seedstuff = cae.seedstuff + 1

                local rewards = {
                    {5, "m"},
                    {15, "c"},
                    {2, "$"},
                    {0.2, "xm"},
                }

                cae.reward = pseudorandom_element(rewards, pseudoseed('cmdia_qm_reward_' .. tostring(cae.seedstuff)))   
                cae.seedstuff = cae.seedstuff + 1
                
            end

            if context.joker_main then
                if cae.buffs.chips > 0 then
                    SMODS.calculate_effect({chip_mod = buffs.chips, message = localize{type = 'variable', key = 'a_chips',  vars = { buffs.chips}}}, card)
                end
                if cae.buffs.mult > 0 then
                    SMODS.calculate_effect({mult_mod = buffs.mult, message = localize{type = 'variable', key = 'a_mult',  vars = { buffs.mult}}}, card)
                end
                if cae.buffs.xmult - 1 ~= 0 then
                    SMODS.calculate_effect({Xmult_mod = buffs.xmult, message = localize{type = 'variable', key = 'a_xmult',  vars = { buffs.xmult}}}, card)
                end
            end

            local completed = false

            if context.initial_scoring_step then
                if cae.quest == "deal" and context.scoring_name == cae.quest_vars["hand"] then
                    completed = true
                end

            elseif context.before then
                if cae.quest == "full_handed" then
                    cae.quest_vars.fives = cae.quest_vars.fives + 1
                end
                if cae.quest == "vanilla" then
                    for _, card in ipairs(context.scoring_hand) do
                        if card.ability.set == 'Enhanced' then 
                            cae.quest_vars.scoredEnhanced = true
                        end
                    end
                end
                if cae.quest == "topping" then
                    for _, card in ipairs(context.scoring_hand) do
                        if card.edition or card.seal then 
                            cae.quest_vars.scoredEditionorSeal = true
                        end
                    end
                end

            elseif context.reroll_shop then
                if cae.quest == "gambling" then
                    cae.quest_vars.rolls = cae.quest_vars.rolls + 1
                    if cae.quest_vars.rolls == 2 then
                        completed = true
                    end
                end
            elseif context.end_of_round then
                if cae.quest == "headshot" and G.GAME.current_round.hands_played == 0 then
                    completed = true
                elseif cae.quest == "last_resort" and G.GAME.current_round.hands_left == 0 then
                    completed = true
                elseif cae.quest == "full_handed" and cae.quest_vars.fives == G.GAME.current_round.hands_played then
                    completed = true
                elseif cae.quest == "vanilla" then
                    completed = not cae.quest_vars.scoredEnhanced
                elseif cae.quest == "topping" then
                    completed = not cae.quest_vars.scoredEditionorSeal
                end

            elseif context.open_booster then
                if cae.quest == "impulse" then
                    cae.quest_vars.packs = cae.quest_vars.packs + 1
                    if cae.quest_vars.packs == 2 then
                        completed = true
                    end
                end

            elseif context.buying_card then
                if cae.quest == "collector" and context.card.ability.set == "Joker" then
                    completed = true
                end

            elseif context.selling_card then
                if cae.quest == "letting_go" and context.card.ability.set == "Joker" then
                    completed = true
                end

            elseif context.using_consumeable then
                local set = ((context.card or context.consumeable) or {}).ability.set
                if cae.quest == "reader" and (set == "Spectral" or set == "Tarot") then
                    completed = true
                end
                if cae.quest == "oddball" and set == "Planet" and context.consumeable.ability.consumeable.hand_type == cae.quest_vars["hand"] then
                    completed = true
                end

            elseif context.skip_blind then
                if cae.quest == "fast_forward" then
                    completed = true
                end

            elseif context.pre_discard then
                if cae.quest == "junk" then
                    local minimum = 4 * G.GAME.round_resets.discards
                    cae.quest_vars.discarded = cae.quest_vars.discarded + #context.full_hand
                    if cae.quest_vars.discarded >= minimum then
                        completed = true
                    end
                end
            end

            if completed then

                local reward = cae.reward

                if reward[2] == "m" then
                    cae.buffs.mult = cae.buffs.mult + reward[1]
                elseif reward[2] == "c" then
                    cae.buffs.chips = cae.buffs.chips + reward[1]
                elseif reward[2] == "$" then
                    cae.buffs.dollars = cae.buffs.dollars + reward[1]
                elseif reward[2] == "xm" then
                    cae.buffs.xmult = cae.buffs.xmult + reward[1]
                end

                cae.quest = nil
                cae.quest_disp = "Waiting..."

                card.pos.x, card.pos.y = 0, 0

                SMODS.calculate_effect({message = CMDIA.get_dictionary("cmdia_qm_completed")}, card)
            end
        end,
        calc_dollar_bonus = function(self, card)
            if card.ability.extra.buffs.dollars > 0 then return card.ability.extra.buffs.dollars end
        end,
    },
}

-- questmaster stuff



local function chipCheck(addstr, key)
    return (key == addstr .. "_chip"
    or key == addstr .. "chip"
    or key == addstr:upper() .. "chip"
    or key == addstr .. "_chip_mod"
    or key == addstr .. "chip_mod"
    or key == addstr:upper() .. "chip_mod"

    or key == addstr .. "_chips"
    or key == addstr .. "chips"
    or key == addstr:upper() .. "chips"
    or key == addstr .. "_chips_mod"
    or key == addstr .. "chips_mod"
    or key == addstr:upper() .. "chips_mod")
end

-- copied from yahimod and modified a bit for microchip

CMDIA.got_chips = false

local scie = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
  if (
    
    -- normal chips
    
    key == "chips"
	  or key == "chip"
	  or key == "chip_mod"
	  or key == "chips_mod"
    
    -- xchips
    
    or key == "x_chips"
	  or key == "xchips"
	  or key == "Xchips"
	  or key == "x_chips_mod"
	  or key == "xchips_mod"
    or key == "Xchips_mod"
    
    or key == "x_chip"
	  or key == "xchip"
	  or key == "Xchip"
	  or key == "x_chip_mod"
	  or key == "xchip_mod"
    or key == "Xchip_mod"

    or chipCheck("e", key)
    or chipCheck("ee", key)
    or chipCheck("eee", key) -- should be good enough lmao
	) and not (amount <= 1)
	  and not CMDIA.got_chips
	then
	  CMDIA.got_chips = true
      for i = 1, #G.jokers.cards do
        G.jokers.cards[i]:calculate_joker({CMDIA = {mchip_modify = true}, card = G.jokers.cards[i]})
      end
	end
	local ret = scie(effect, scored_card, key, amount, from_edition)
	CMDIA.got_chips = false
	return ret
end


-- for recycler (cryptid will fuck these up when misprint deck wjbaihsndijwnajionsdijm)

-- Vanilla Jokers

CMDIA.lib.recycler_insert("j_ceremonial", {mult = 2,})
CMDIA.lib.recycler_insert("j_ride_the_bus", {mult = 1,})
CMDIA.lib.recycler_insert("j_runner", {extra = {chips = 15,}})
CMDIA.lib.recycler_insert("j_constellation", {x_mult = 0.1,})
CMDIA.lib.recycler_insert("j_green_joker", {mult = 1,})

CMDIA.lib.recycler_insert("j_red_card", {mult = 3})
CMDIA.lib.recycler_insert("j_madness", {x_mult = 0.5})
CMDIA.lib.recycler_insert("j_square", {extra = {chips = 4}})
CMDIA.lib.recycler_insert("j_vampire", {Xmult = 0.1})
CMDIA.lib.recycler_insert("j_hologram", {Xmult = 0.25})

CMDIA.lib.recycler_insert("j_rocket", {extra = {dollars = 2}})
CMDIA.lib.recycler_insert("j_obelisk", {Xmult = 0.2})
CMDIA.lib.recycler_insert("j_lucky_cat", {Xmult = 0.25})
CMDIA.lib.recycler_insert("j_flash", {mult = 2})
CMDIA.lib.recycler_insert("j_trousers", {mult = 2})

CMDIA.lib.recycler_insert("j_castle", {extra = {chips = 3}})
CMDIA.lib.recycler_insert("j_campfire", {x_mult = 0.25})
CMDIA.lib.recycler_insert("j_glass", {Xmult = 0.75})
CMDIA.lib.recycler_insert("j_wee", {chips = 8})
CMDIA.lib.recycler_insert("j_hit_the_road", {x_mult = 0.5})

CMDIA.lib.recycler_insert("j_caino", {caino_xmult = 1})

-- cycles

CMDIA.lib.addCycle(
    "shape",
    {suit1 = "Spades", suit2 = "Hearts"},
    function(card)
        local suits = {}
        local thingy = 0
        for k, v in ipairs({'Spades','Hearts','Clubs','Diamonds'}) do
            if (thingy and (v ~= card.suit2 and v ~= card.suit1) or (v ~= card.suit1)) then suits[#suits + 1] = v; thingy = 1 end
        end
        local shape_card1 = pseudorandom_element(suits, pseudoseed('shape'..G.GAME.round_resets.ante))
        suits[shape_card1] = nil
        card.suit1 = shape_card1
        local shape_card2 = pseudorandom_element(suits, pseudoseed('shifter'..G.GAME.round_resets.ante))
        suits[shape_card2] = nil
        card.suit2 = shape_card2
    end 
)

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

    if false then -- testDeck then

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