function find_index(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil -- not found
end

SMODS.current_mod.config_tab = function()
    return CMDIA.config_menu_handler()
end

CMDIA._state.music = {
    current_option = CMDIA.config.current_music or 2
}

function CMDIA.config_menu_handler()
    local get_localization = CMDIA.get_dictionary("cmdia").music

    local music_key = CMDIA.music.keys[CMDIA._state.music.current_option]

    local loc_text = get_localization[music_key]

    return {
        n = G.UIT.ROOT,
        config = { align = "cm", padding = 0.2, minw = 10, minh = 6, colour = G.C.BLACK, r = 0.1 },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = "bm", padding = 0.2, minw = 10, minh = 2.5 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "bl" },
                        nodes = {
                            UIBox_button({ colour = G.C.RED, align = "bl", minw = 0.5, minh = 0.5, padding = 0.1, emboss = 0.2, button =
                            "CMDIA_config_menu_updater_prev", label = { "<" }, }),
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "bm", minh = 2 },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "tm" },
                                nodes = {
                                    UIBox_button({ colour = G.C.RED, align = "tm", minw = 3.5, minh = 0.5, padding = 0.1, emboss = 0.2, button =
                                    "CMDIA_nothing", label = { loc_text[1] }, }),
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "bm" },
                                nodes = {
                                    { n = G.UIT.T, config = { text = loc_text[2], scale = 0.4, padding = 0.1, colour = G.C.WHITE, align = "bm" } },
                                }
                            },
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "br" },
                        nodes = {
                            UIBox_button({ colour = G.C.RED, align = "br", minw = 0.5, minh = 0.5, padding = 0.1, emboss = 0.2, button =
                            "CMDIA_config_menu_updater_next", label = { ">" }, }),
                        }
                    },
                }
            },
        }
    }
end

function G.FUNCS.CMDIA_nothing(e)
    -- like carpet
end

function G.FUNCS.CMDIA_config_menu_updater_next(e)
    CMDIA.config_menu_updater(e, 1)
end

function G.FUNCS.CMDIA_config_menu_updater_prev(e)
    CMDIA.config_menu_updater(e, -1)
end

G.FUNCS.cmdia_music_change = function(args)
    print(tostring(args.to_val))
end

function CMDIA.config_menu_updater(e, dir)
    local state = CMDIA._state.music

    local count = #CMDIA.music.options
    state.current_option = ((state.current_option - 1 + dir) % count) + 1
    CMDIA.config.current_music = state.current_option

    local my_menu_uibox = e.UIBox
    -- Get the parent of the menu UIBox, because we want to delete and re-create the menu:
    local menu_wrap = my_menu_uibox.parent

    -- CMDIA.music_upd()

    menu_wrap.config.object:remove()
    menu_wrap.config.object = UIBox({
        definition = CMDIA.config_menu_handler(),
        config = { parent = menu_wrap, no_fill = true } -- You MUST specify parent!
    })

    menu_wrap.UIBox:recalculate()
end
