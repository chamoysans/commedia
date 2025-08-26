
function CMDIA.credit_init()
    CMDIA.credit = {
        {name = "DerpVN12", section = "Joker"},
        {name = "someonenooneever", section = "Joker"},
        {name = "Friazes", section = "Joker"},
        {name = "pie-en-argent", section = "Joker"},
        {name = "Pusheenunderscore", section = "Joker"},
        {name = "GameShowWerewolf", section = "Joker"},
        {name = "yellow-hammer", section = "Joker"},
        {name = "ihavetoclear", section = "Joker"},
        {name = "Wish_Solid", section = "Joker"},
        {name = "StatisticalMistake", section = "Joker"},
        {name = "GoinXwell1", section = "Joker"},

        {name = "DerpVN12", section = "Art"},
        {name = "someonenooneever", section = "Art"},
        {name = "yellow-hammer", section = "Art"},
        {name = "ihavetoclear", section = "Art"},

        {name = "Recycled Scraps", section = "Music"},
        {name = "Vongola", section = "Music"},
        {name = "Bombaflex", section = "Music"},
        {name = "JohnathanSucks", section = "Music"},
    }
end

CMDIA.credit_init()

CMDIA._state = {
    page = 1,
    section = CMDIA.credit[1].section
}

SMODS.current_mod.extra_tabs = function()
	return {
		{
			label = 'Credits',
			tab_definition_function = function()

				return CMDIA.credit_menu_handler()
			end,
		},
	}
end

function CMDIA.get_dictionary(id)
    return G.localization.misc.dictionary[id]
end

function CMDIA.get_dictionary_credit(section, name)
    tprint(G.localization.misc.dictionary.cmdia.credit)
    print(section)
    print(name)
    return G.localization.misc.dictionary.cmdia.credit[section][name]
end

--[[

function CMDIA.credit_desc(id)
    local entry = CMDIA.credit[id]
    if not entry then
        return CMDIA.get_dictionary("cmdia_credit_not_found")
    end

    -- Start your sentence
    local current = CMDIA.get_dictionary("cmdia_credit_came_up") .. " "

    for key, list in pairs(entry) do
        if key ~= "name" then
        local label = key:gsub("^%l", string.upper)

        if #list > 1 then label = label .. "s" end

        current = current .. label .. ": "

        if #list == 1 then

            current = current .. list[1]
        elseif #list == 2 then

            current = current .. list[1] .. " " .. CMDIA.get_dictionary("cmdia_credit_and") .. " " .. list[2]
        else

            for i = 1, #list do
            if i < #list then
                current = current .. list[i] .. ", "
            elseif i == #list then
                current = current .. CMDIA.get_dictionary("cmdia_credit_and") .. " " .. list[i]
            end
            end
        end

        current = current .. ", "
        end
    end

    local words = {}
    for word in current:gmatch("%S+") do
        table.insert(words, word)
    end
    
    local forMult = 1

    local splitSentences = {}
    local maxBuckets = math.ceil(#words / 7)
    for b = 1, maxBuckets do -- thats buckets
        
        splitSentences[b] = ""
    end

    for i = 1, #words do

        if i > (7 * forMult) then
            forMult = forMult + 1
        end

        splitSentences[forMult] = splitSentences[forMult] .. " " .. words[i]

    end

    local textObj = {}

    for i = 1, #splitSentences do
        textObj[i] = {n = G.UIT.T, config = {text = splitSentences[i], scale = 0.7, colour = G.C.WHITE, align = "cm"}}
    end

    return textObj
end


]]

function CMDIA.credit_menu_handler(data)

    CMDIA.credit_init()

    local state = CMDIA._state

    local entry = CMDIA.credit[state.page]

    entry.loc_text = CMDIA.get_dictionary_credit(state.section, entry.name)

    entry.loc_text[1] = entry.loc_text[1] or ""
    entry.loc_text[2] = entry.loc_text[2] or ""
  
    return {
      n = G.UIT.ROOT,
      config = {align = "cm", padding = 0.2, minw = 8, minh = 6, colour = G.C.BLACK,r = 0.1},
      nodes = {
        {n = G.UIT.R, config = {align = "cm"}, nodes = {
            {n = G.UIT.R, config = {align = "tm", padding = 0.1}, nodes = {
                {n = G.UIT.T, config = {text = state.section, scale = 0.7, colour = G.C.WHITE, align = "tm"}},
            }},{n = G.UIT.R, config = {align = "tm", padding = 0.1}, nodes = {
                {n = G.UIT.T, config = {text = "---------------------------------", scale = 0.4, colour = G.C.WHITE, align = "tm"}},
            }},
            {n = G.UIT.R, config = {align = "tm", padding = 0.3}, nodes = {
                {n = G.UIT.T, config = {text = entry.name, scale = 0.7, colour = G.C.WHITE, align = "tm"}},
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                {n = G.UIT.T, config = {text = entry.loc_text[1], scale = 0.4, colour = G.C.WHITE, align = "cm"}},
            }},
            {n = G.UIT.R, config = {align = "bm"}, nodes = {
                {n = G.UIT.T, config = {text = entry.loc_text[2], scale = 0.4, colour = G.C.WHITE, align = "cm"}},
            }},
        }},
        {n = G.UIT.R, config = {align = "bm", padding = 0.2, minw = 8, minh = 0.5}, nodes = {
            {n = G.UIT.R, config = {align = "br"}, nodes = {
                UIBox_button({colour = G.C.RED, align = "br", minw = 1.5, minh = 0.5, padding = 0.1, emboss = 0.2, button = "CMDIA_menu_updater_next", label = {CMDIA.get_dictionary('cmdia_credit_next')},}),
            }},
            {n = G.UIT.R, config = {align = "bl"}, nodes = {
                UIBox_button({colour = G.C.RED, align = "bl", minw = 1.5, minh = 0.5, padding = 0.1, emboss = 0.2, button = "CMDIA_menu_updater_prev", label = {CMDIA.get_dictionary('cmdia_credit_prev')},}),
            }},
        }},
    }}
end

function G.FUNCS.CMDIA_menu_updater_next(e)
    CMDIA.menu_updater(e, 1)
end

function G.FUNCS.CMDIA_menu_updater_prev(e)
    CMDIA.menu_updater(e, -1)
end

function CMDIA.menu_updater(e, dir)

    CMDIA.credit_init()

    local state = CMDIA._state

    -- move the index, wrapping with modulo:
    local count = #CMDIA.credit
    state.page = ((state.page - 1 + dir) % count) + 1
    state.section = CMDIA.credit[state.page].section

    local my_menu_uibox = e.UIBox
    -- Get the parent of the menu UIBox, because we want to delete and re-create the menu:
    local menu_wrap = my_menu_uibox.parent

    -- Delete the current menu UIBox:
    menu_wrap.config.object:remove()
    -- Create the new menu UIBox:
    menu_wrap.config.object = UIBox({
        definition = CMDIA.credit_menu_handler(),
        config = {parent = menu_wrap, no_fill = true} -- You MUST specify parent!
    })
    -- Update the UI:
    menu_wrap.UIBox:recalculate()
end