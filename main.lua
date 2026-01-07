-- This mod is licensed under the GNU GPL v3
-- See LICENSE for details.
-- Note: Reason why I just now added a license is because I got some code from Entropy,

CMDIA = {
    ingame_buffer = {
        CAI = {},
        main_menu_offset = 5.25,
    },
    music = {
        options = {
            "Vanilla",
            "Going in blind",
            "Bonne Soiree",
            "Monkey Buisness",
            "Raise the stakes",
        },
        keys = {
            "vanilla",
            "going_in_blind",
            "bonne_soiree",
            "monkey_buisness",
            "raise_the_stakes",
        },
    },
    config = SMODS.current_mod.config,
}

to_big = to_big or function(x) return x end

to_number = to_number or function(x) return x end

lenient_bignum = lenient_bignum or function(x) return x end

function CMDIA.get_name_of_thing(typee, set, id)
    return (not not G.localization) and G.localization[typee][set][id].name or "NIL"
end

-- for kintsugi, hoping noone overrites this function or patches this in the SMODS area thing

function SMODS.calculate_destroying_cards(context, cards_destroyed, scoring_hand)
    for i, card in ipairs(context.cardarea.cards) do
        local destroyed = nil
        --un-highlight all cards
        local in_scoring = scoring_hand and SMODS.in_scoring(card, context.scoring_hand)
        if scoring_hand and in_scoring and not card.destroyed then
            -- Use index of card in scoring hand to determine pitch
            local m = 1
            for j, _card in pairs(scoring_hand) do
                if card == _card then
                    m = j
                    break
                end
            end
            highlight_card(card, (m - 0.999) / (#scoring_hand - 0.998), 'down')
        end

        -- context.destroying_card calculations
        context.destroy_card = card
        context.destroying_card = nil
        if scoring_hand then
            if in_scoring then
                context.cardarea = G.play
                context.destroying_card = card
            else
                context.cardarea = 'unscored'
            end
        end
        local flags = SMODS.calculate_context(context)
        if flags.remove then destroyed = true end

        -- TARGET: card destroyed

        if destroyed then
            card.getting_sliced = true
            if SMODS.shatters(card) then
                if SMODS.has_enhancement(card, 'm_glass') and next(SMODS.find_card('j_cmdia_kintsugi')) then
                    card:set_seal('Gold')
                else
                    card.shattered = true
                end
            else
                card.destroyed = true
            end
            if not (SMODS.has_enhancement(card, 'm_glass') and next(SMODS.find_card('j_cmdia_kintsugi'))) then
                cards_destroyed[#cards_destroyed + 1] = card
            end
        end
    end
end

-- main menu stuff, surprised this works

local oldfunc = Game.main_menu
Game.main_menu = function(change_context)
    local ret = oldfunc(change_context)

    local CAI = CMDIA.ingame_buffer.CAI

    SC_scale = 1.1 * (G.debug_splash_size_toggle and 0.8 or 1)


    G.title_top.T.x = G.title_top.T.x + CMDIA.ingame_buffer.main_menu_offset

    G.SPLASH_LOGO:set_alignment({
        major = G.title_top,
        type = 'cm',
        bond = 'Strong',
        offset = { x = -CMDIA.ingame_buffer.main_menu_offset, y = 0 }
    })
    G.SPLASH_LOGO:define_draw_steps({ {
        shader = 'dissolve',
    } })


    G.SPLASH_LOGO.dissolve_colours = { G.C.WHITE, G.C.WHITE }
    G.SPLASH_LOGO.dissolve = 1

    return ret
end

function CMDIA.music_upd()
    local music_choice_index = CMDIA.config.current_music or 2

    local music_choice = CMDIA.music.keys[music_choice_index]

    SMODS.Sound({
        key = "music1",
        path = music_choice .. "/music1." .. (CMDIA.config.current_music == 2 and "mp3" or "ogg"),
        replace = "music1"
    })

    SMODS.Sound({
        key = "music2",
        path = music_choice .. "/music2." .. (CMDIA.config.current_music == 2 and "mp3" or "ogg"),
        replace = "music2"
    })

    SMODS.Sound({
        key = "music3",
        path = music_choice .. "/music3." .. (CMDIA.config.current_music == 2 and "mp3" or "ogg"),
        replace = "music3"
    })

    SMODS.Sound({
        key = "music4",
        path = music_choice .. "/music4." .. (CMDIA.config.current_music == 2 and "mp3" or "ogg"),
        replace = "music4"
    })

    SMODS.Sound({
        key = "music5",
        path = music_choice .. "/music5." .. (CMDIA.config.current_music == 2 and "mp3" or "ogg"),
        replace = "music5"
    })
end

CMDIA.music_upd()

SMODS.Atlas {
    key = 'balatro',
    path = 'balatro.png',
    px = 425,
    py = 216,
    prefix_config = { key = false }
}

assert(SMODS.load_file("src/lib.lua"))()
assert(SMODS.load_file("src/jokers.lua"))()
assert(SMODS.load_file("src/enhancements.lua"))()
assert(SMODS.load_file("src/credit-tab.lua"))()
assert(SMODS.load_file("src/config-tab.lua"))()
