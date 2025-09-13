return {
    descriptions = {
        Back={},
        Blind={},
        Edition={},
        Enhanced={},
        Joker={
            j_cmdia_fourleaf_clover = {
                name = "Four-leaf Clover",
                text = {
                    "During scoring,",
                    "Gurantees the next",
                    "{C:attention}#1#{} probabilit#2#,",
                }
            },
            j_cmdia_dramatist = {
                name = "Dramatist",
                text = {
                    "Retriggers the",
                    "effects of used",
                    "{C:planet}Planet{} and some",
                    "{C:tarot}Tarot{} cards,",
                }
            },
            j_cmdia_bank_account = {
                name = "Bank Account",
                text = {
                    "Interest is",
                    "always {C:attention}maxed out,{}",
                }
            },
            j_cmdia_kintsugi = {
                name = "Kintsugi",
                text = {
                    "When the self-destruct effect ",
                    "of a {C:attention}glass card{}",
                    "without a seal triggers,",
                    "it instead gains a {C:money}gold seal.{}",
                }
            },
            j_cmdia_theseus = {
                name = "Theseus' Joker",
                text = {
                    "{C:dark_edition}+#1#{C:attention} Joker{} slot,",
                    "{C:inactive,s:0.8}temperance value{}",
                },
                unlock = {
                    "Win a run with an",
                    "extra {E:1,C:attention}Joker slot,{}",
                }
            },
            j_cmdia_jimbos_comet = {
                name = "Jimbo's Comet",
                text = {
                    "{C:planet}Planet{} cards upgrade",
                    "{C:green}#1#{} additional time,",
                },
            },
            j_cmdia_filibuster = {
                name = "Filibuster",
                text = {
                    "Round does not",
                    "end until {C:attention}final{}",
                    "{C:attention}hand{} is played."
                },
            },
            j_cmdia_eternal = {
                name = "Eternal Joker",
                text = {
                    "When {C:attention}Boss Blind{} is",
                    "defeated, apply",
                    "{C:dark_edition}Eternal{} to Joker",
                    "to the right,",
                    "{C:dark_edition}Eternal{} Jokers give",
                    "{X:mult,C:white}X#1#{} Mult"
                }
            },
            j_cmdia_impostor = {
                name = "Impostor",
                text = {
                    "If your hand contains ",
                    "{C:attention}4 cards{} of one suit,",
                    "transform the other card",
                    "into that suit and",
                    "score as a {C:attention}Flush.{}",
                }
            },
            j_cmdia_flat_earth = {
                name = "Flat Earth",
                text = {
                    "{C:attention}Retrigger{} each scoring card",
                    "per {C:planet}10{} Levels of played hand,",
                    "half base {C:chips}Chips{} {C:attention}&{} {C:mult}Mult,{}",
                }
            },
            j_cmdia_commedia = {
                name = "r/commedia",
                text = {
                    "Gives {C:chips}+X{} chips and {C:mult}+Y mult{}",
                    "where X is the number of ",
                    "upvotes on the most recent post",
                    "and Y is the number of comments",
                    "{C:inactive}(Currently: +#1# Chips & +#2# Mult){}"
                }
            },
            j_cmdia_tuning_fork = {
                name = "Tuning Fork",
                text = {
                    "{C:attention}Retrigger{} all scored",
                    "cards without enhancements,"
                }
            },
            j_cmdia_shapeshifter = {
                name = "Shapeshifter",
                text = {
                    "Gains {X:mult,C:white}X#1#{} Mult every",
                    "time a hand contains both",
                    "#3# and #4#,",
                    "suits change every round,",
                    "{C:inactive}(Does not change depending on your deck){}",
                    "{C:inactive}(Currently: X#2#){}",
                }
            },
            j_cmdia_recycler = {
                name = "Recycler",
                text = {
                    "When a card is",
                    "{C:attention}Sold{} or {C:attention}Destroyed{},",
                    "scale all scalable",
                    "{C:attention}Jokers{}",
                }
            },
            j_cmdia_automation = {
                name = "Automation",
                text = {
                    "If a played hand contains",
                    "{C:attention}4 cards{} or less,",
                    "all scored Non-face Cards",
                    "become {C:attention}Steel cards,{}",
                }
            },
            j_cmdia_microchip = {
                name = "Microchip",
                text = {
                    "{X:mult,C:white}X#1#{} Mult each time Chips",
                    "of {C:attention}played hand{} increase,",
                    "Set base Chips of {C:attention}played{}",
                    "{C:attention}hand{} to {C:attention{}1{}",
                }
            },
            j_cmdia_stanczyk = {
                name = "Stanczyk",
                text = {
                    "After Round, Shuffle and replay,",
                    "Win: {X:mult,C:white}+#1#{} Mult,",
                    "Lose: {X:mult,C:white}-#1#{} Mult,",
                    "{C:inactive}(Can't Go below 1){}",
                    "{C:inactive}(Currently: X#2#){}",
                }
            },
            j_cmdia_regret = {
                name = "regret.",
                text = {
                    "{C:attention}Retrigger{} all scored cards",
                    "if played hand contains",
                    "{C:attention}3 or less{} scoring cards.",
                }
            },
            j_cmdia_jokertools = {
                name = "Joker tools",
                text = {
                    "Played cards have a:",
                    "{C:green}#1# in #2#{} chance to give {C:chips}+#3#{} Chips,",
                    "{C:green}#1# in #2#{} chance to give {C:mult}+#4#{} Mult,",
                    "and a {C:green}#1# in #5#{} chance to retrigger.",
                }
            },
        },
        Other={
            cmdia_credit = {
                name = "Credit - Idea",
                text = {
                    "Idea by:",
                    "{V:1,B:2}#1#{}",
                },
            },
            cmdia_credit_art = {
                name = "Credit - Art",
                text = {
                    "Art by:",
                    "{V:1,B:2}#1#{}",
                },
            },
            cmdia_placeholder = {
                name = "Placeholder art",
                text = {
                    "This #1# is using",
                    "placeholder art,",
                    "It will be changed later",
                },
            },
            cmdia_modified = {
                name = "Modified Joker",
                text = {
                    "This Joker was modified",
                    "to better balance",
                    "the game,",
                },
            },
            cmdia_modified_hard = {
                name = "Modified Joker",
                text = {
                    "This Joker was modified",
                    "due to the original idea",
                    "being too hard,",
                },
            },
        },
        Planet={},
        Spectral={},
        Stake={},
        Tag={},
        Tarot={},
        Voucher={}
    },
    misc = {
        achievement_descriptions={},
        achievement_names={},
        blind_states={},
        challenge_names={},
        collabs={},
        dictionary={
            cmdia_plucked = 'Plucked!',
            cmdia_locked = 'Locked!',
            cmdia_forged = 'Forged!',
            cmdia_scaled = 'Scaled!',
            cmdia_credit_next = 'Next',
            cmdia_credit_prev = 'Previous',
            cmdia_credit_page = 'Page',
            cmdia_credit_came_up = 'Came up with',
            cmdia_credit_and = 'and',
            cmdia_sus = 'Sus!',
            cmdia_halved = 'Halved!',
            cmdia_chipped = 'Chipped!',
            cmdia_stan_lost = "Lost.",
            cmdia_stan_won = "Won!",
            cmdia = {
                credit = {
                    Joker = {
                        ["DerpVN12"] = {
                            "Four-leaf Clover"
                        },
                        ["someonenooneever"] = {
                            "Dramatist",
                            "Microchip"
                        },
                        ["Friazes"] = {
                            "Bank Account"
                        },
                        ["pie-en-argent"] = {
                            "Kintsugi"
                        },
                        ["Pusheenunderscore"] = {
                            "Theseus' Joker"
                        },
                        ["GameShowWerewolf"] = {
                            "Jimbo's Comet"
                        },
                        ["yellow-hammer"] = {
                            "Filibuster"
                        },
                        ["ihavetoclear"] = {
                            "Eternal Joker,",
                            "Recycler"
                        },
                        ["Wish_Solid"] = {
                            "Impostor"
                        },
                        ["StatisticalMistake"] = {
                            "Flat Earth"
                        },
                        ["GoinXwell1"] = {
                            "Shapeshifter"
                        },
                        ["Zestyclose-Click6190"] = {
                            "Automation"
                        },
                        ["T_A_amb"] = {
                            "Regret"
                        }
                    },
                    Art = {
                        ["DerpVN12"] = {
                            "Four-leaf Clover"
                        },
                        ["someonenooneever"] = {
                            "Dramatist"
                        },
                        ["yellow-hammer"] = {
                            "Filibuster"
                        },
                        ["ihavetoclear"] = {
                            "Eternal Joker"
                        },
                    },
                    Music = {
                        ["Recycled Scraps"] = {
                            "Going in blind"
                        },
                        ["Vongola"] = {
                            "Bonne Soiree"
                        },
                        ["Bombaflex"] = {
                            "Monkey Buisness"
                        },
                        ["JohnathanSucks"] = {
                            "Raise the stakes"
                        },
                    },
                },
                music = {
                    ["vanilla"] = {
                        "Vanilla",
                        "By: Louis F",
                    },
                    ["going_in_blind"] = {
                        "Going in Blind",
                        "By: Recycled Scraps",
                    },
                    ["bonne_soiree"] = {
                        "Bonne Soiree",
                        "By: Vongola",
                    },
                    ["monkey_buisness"] = {
                        "Monkey Buisness",
                        "By: Bombaflex",
                    },
                    ["raise_the_stakes"] = {
                        "Raise the stakes",
                        "By: JohnathanSucks",
                    },
                },
                config_music_select = "Music"
            },
        },
        high_scores={},
        labels={},
        poker_hand_descriptions={},
        poker_hands={},
        quips={},
        ranks={},
        suits_plural={},
        suits_singular={},
        tutorial={},
        v_dictionary={},
        v_text={},
    },
}