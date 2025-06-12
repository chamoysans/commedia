
CMDIA = {}

function CMDIA.get_name_of_thing(typee, set, id)
    return (not not G.localization) and G.localization[typee][set][id].name or "NIL"
end

SMODS.Sound({
    key = "music1",
    path = "music1.mp3",
    replace = "music1"
})

SMODS.Sound({
    key = "music2",
    path = "music2.mp3",
    replace = "music2"
})

SMODS.Sound({
    key = "music3",
    path = "music3.mp3",
    replace = "music3"
})

SMODS.Sound({
    key = "music4",
    path = "music4.mp3",
    replace = "music4"
})

SMODS.Sound({
    key = "music5",
    path = "music5.mp3",
    replace = "music5"
})

SMODS.Atlas{
    key = 'balatro',
    path = 'balatro.png',
    px = 425,
    py = 216,
    prefix_config = { key = false }
}

assert(SMODS.load_file("src/jokers.lua"))()
assert(SMODS.load_file("src/credit-tab.lua"))()