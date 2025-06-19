
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
        -- 
    
end

function CMDIA.config_menu_handler()

    local config = CMDIA.config.music
    local currentOption = {}

    for i = 1, #config do
        if config[i] then
            currentOption[1] = i
            currentOption[2] = CMDIA.music.options[i]
        end
    end

    return {
        n = G.UIT.ROOT,
        config = {align = "cm", padding = 0.2, minw = 8, minh = 6, colour = G.C.BLACK,r = 0.1},
        nodes = {
            create_option_cycle({label = CMDIA.get_dictionary('cmdia').config_music_select, options = CMDIA.music.options, opt_callback = 'cmdia_music_change', colour = G.C.RED, w = 3.7*0.65/(5/6), h=0.8*0.65/(5/6), text_scale=0.5*0.55/(5/6), scale=5/6, no_pips = true, current_option = CMDIA.music.options[1]})
    }}
end

G.FUNCS.cmdia_music_change = function(args)
    print(tostring(args.to_val))
end

function CMDIA.config_menu_updater(e, dir)

    -- Delete the current menu UIBox:
    menu_wrap.config.object:remove()
    -- Create the new menu UIBox:
    menu_wrap.config.object = UIBox({
        definition = CMDIA.config_menu_handler(),
        config = {parent = menu_wrap, no_fill = true} -- You MUST specify parent!
    })
    -- Update the UI:
    menu_wrap.UIBox:recalculate()
end