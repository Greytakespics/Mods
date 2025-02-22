-- note: while this is technically listed under the "en-us"
-- language, they will still be called "Colour" cards.
-- ha ha ha.

return {
  descriptions = {
    Joker = {
      j_mf_badlegaldefence = {
        name = "Bad Legal Defence",
        text = {
          "Create a {C:attention}Death{} {C:tarot}Tarot{}",
          "when {C:attention}Boss Blind{}",
          "is selected",
          "{C:inactive}(Must have room)"
        },
      },
      j_mf_basepaul_card = {
        name = "Basepaul Card",
        text = {
          "{X:mult,C:white} X#1# {} Mult. {X:mult,C:white} X#2# {} Mult",
          "instead for {C:red}Paul{}",
          "{C:inactive}(Who's Paul?)"
        }
      },
      j_mf_bladedance = {
        name = "Blade Dance",
        text = {
          "Adds {C:attention}#1#{} temporary",
          "{C:attention}Steel Cards{}",
          "to your deck when",
          "blind is selected"
        },
      },
      j_mf_blasphemy = {   
        name = "Blasphemy",
        text = {
          "{X:red,C:white} X#1# {} Mult",
          "{C:blue}-#2#{} hands",
          "when hand is played"
        },
      },
      j_mf_bloodpact = {
        name = "Blood Pact",
        text = {
          "{X:mult,C:white} X#1# {} Mult",
          "{C:red}Self destructs{} if you play",
          "a non-{C:hearts}Hearts{} card"
        }
      },
      j_mf_bowlingball = {
        name = "Bowling Ball",
        text = {
          "Played {C:attention}3s{}",
          "give {C:chips}+#1#{} Chips",
          "and {C:mult}+#2#{} Mult",
          "when scored"
        }
      },
      j_mf_cba = {
        name = "Card Buffer Advanced",
        text = {
          "{C:attention}Retrigger{} your first",
          "{C:dark_edition}Editioned{} Joker",
          "{C:inactive}(CBA excluded){}"
        }
      },
      j_mf_clipart = {
        name = "Clipart Joker",
        text = {
          "Create a {C:colourcard}Colour{} card",
          "when {C:attention}Blind{} is selected",
          "{C:inactive}(Must have room)"
        },
      },
      j_mf_colorem = {
        name = "Colorem",
        text = {
          "When a {C:colourcard}Colour{} card is used,",
          "{C:green}#1# in #2#{} chance to add a copy",
          "to your consumable area",
          "{C:inactive}(Must have room)",
        },
      },
      j_mf_coupon_catalogue = {
        name = "Coupon Catalogue",
        text = {
          "{C:mult}+#1#{} Mult for each",
          "{C:attention}Voucher{} purchased",
          "this run",
          "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)",
        }
      },
      j_mf_css = {
        name = "CSS",
        text = {
          "Create a random {C:colourcard}Colour",
          "card when played hand",
          "contains a {C:attention}Flush",
          "{C:inactive}(Must have room)"
        },
      },
      j_mf_dramaticentrance = {    
        name = "Dramatic Entrance",
        text = {
          "{C:chips}+#1#{} Chips",
          "for the first hand",
          "of each round"
        },
      },
      j_mf_dropkick = {
        name = "Dropkick",
        text = {
          "{C:blue}+#1#{} hand when hand",
          "contains a {C:attention}Straight"
        },
      },
      j_mf_expansion_pack = {
        name = "Expansion Pack",
        text = {
          "When {C:attention}Blind{} is selected,",
          "create {C:attention}#1# {C:dark_edition}modded{C:attention} Joker",
          "{C:inactive}(Must have room)"
        },
      },
      j_mf_fleshprison = {
        name = "Flesh Prison",
        text = {
          "{C:red}X#1#{} {C:attention}Boss Blind{} size",
          "When {C:attention}Boss Blind{} is defeated,",
          "{C:red}self destructs{}, and creates",
          "a {C:dark_edition}Negative{} {C:spectral}The Soul{} card"
        }
      },
      j_mf_fleshpanopticon = {
        name = "Flesh Panopticon",
        text = {
          "{C:red}X#1#{} {C:attention}Boss Blind{} size",
          "When {C:attention}Boss Blind{} is defeated,",
          "{C:red}self destructs{}, and creates",
          "a {C:dark_edition}Negative{} {C:spectral}Gateway{} card"
        }
      },
      j_mf_globe = {
        name = "Globe",
        text = {
          "Create #1# {C:planet}Planet{} card",
          "when you {C:attention}reroll{} in the shop",
        }
      },
      j_mf_goldencarrot = {
        name = "Golden Carrot",
        text = {
          "Earn {C:money}$#1#{} at",
          "end of round",
          "{C:money}-$#2#{} given",
          "per hand played"
        }
      },
      j_mf_hallofmirrors = {
        name = "Hall of Mirrors",
        text = {
          "{C:attention}+#2#{} hand size for",
          "each {C:attention}6{} scored in",
          "the current round",
          "{C:inactive}(Currently {C:attention}+#1#{C:inactive} cards)"
        }
      },
      j_mf_hollow = {
        name = "Hollow Joker",
        text = {
          "{C:attention}#1#{} hand size",
          "{C:mult}+#2#{} Mult per hand",
          "size below {C:attention}#3#"
        }
      },
      j_mf_hyperbeam = {
        name = "Hyper Beam",
        text = {
          "{X:red,C:white} X#1# {} Mult",
          "{C:attention}Lose all discards",
          "when {C:attention}Blind{} is selected"
        },
      },
      j_mf_impostor = {
        name = "Impostor",
        text = {
          "{X:mult,C:white} X#1# {} Mult if the",
          "played hand has",
          "exactly one {C:red}red{} card"
        }
      },
      j_mf_jankman = {
        name = "Jankman",
        text = {
          "All {C:dark_edition}modded{} Jokers",
          "{C:inactive}(and also Jolly Joker){}",
          "each give {X:chips,C:white} X#1# {} Chips",
        }
      },
      j_mf_jester = {
        name = "Jester",
        text = {
          "{C:chips,s:1.1}+#1#{} Chips"
        }
      },
      j_mf_loadeddisk = {
        name = "Loaded Disk",
        text = {
          "Creates a {C:colourcard}Pink{} and",
          "a {C:colourcard}Yellow{} {C:colourcard}Colour{} card",
          "when sold",
          "{C:inactive}(Must have room)"
        },
      },
      j_mf_lollipop = {
        name = "Lollipop",
        text = {
          "{X:mult,C:white} X#1# {} Mult",
          "{X:mult,C:white} -X#2# {} Mult per",
          "round played"
        }
      },
      j_mf_luckycharm = {
        name = "Lucky Charm",
        text = {
          "{C:green}#1# in #3#{} chance",
          "for {C:mult}+#2#{} Mult",
          "{C:green}#1# in #5#{} chance",
          "to win {C:money}$#4#",
          "at end of round"
        }
      },
      j_mf_mashupalbum = {
        name = "Mashup Album",
        text = {
          "Gains {C:mult}+#3#{} Mult if played",
          "hand contains a {C:hearts}red{} flush",
          "Gains {C:chips}+#4#{} Chips if played",
          "hand contains a {C:spades}black{} flush",
          "{C:inactive}(Currently {C:mult}+#1#{C:inactive} and {C:chips}+#2#{C:inactive})"
        },
      },
      j_mf_mspaint = {
        name = "MS Paint Joker",
        text = {
          "{C:attention}+#1#{} hand size",
          "for the first hand",
          "of each blind"
        },
      },
      j_mf_paintcan = {
        name = "Paint Can",
        text = {
          "{C:green}#1# in #2#{} chance to add",
          "a round to {C:colourcard}Colour Cards{}",
          "when they gain a round",
        },
      },
      j_mf_pixeljoker = {
        name = "Pixel Joker",
        text = {
          "Played {C:attention}Aces{},",
          "{C:attention}4s{} and {C:attention}9s{} each give",
          "{X:mult,C:white} X#1# {} Mult when scored"
        },
      },
      j_mf_philosophical = {
        name = "Philosophical Joker",
        text = {
          "{C:dark_edition}+#1#{} Joker Slot"
        },
      },
      j_mf_rainbowjoker = {
        name = "Rainbow Joker",
        text = {
          "{C:colourcard}Colour{} cards give",
          "{X:mult,C:white} X#1#{} Mult"
        },
      },
      j_mf_recycling = {
        name = "Recycling",
        text = {
          "Create a random {C:planet}Planet{}",
          "or {C:tarot}Tarot{} card",
          "when any {C:attention}Booster{}",
          "{C:attention}Pack{} is skipped",
          "{C:inactive}(Must have room)"
        },
      },
      j_mf_rosetinted = {
        name = "Rose-Tinted Glasses",
        text = {
          "If {C:attention}first hand{} of round is",
          "a single {C:attention}2{}, destroy it and",
          "create a free {C:attention}Double Tag{}",
        }
      },
      j_mf_simplified = {
        name = "Simplified Joker",
        text = {
          "All {C:blue}Common{} Jokers",
          "each give {C:mult}+#1#{} Mult",
        }
      },
      j_mf_spiral = {
        name = "Spiral Joker",
        text = {
          "{C:mult}+(#1#+#2#cos(pi/#3# x {C:attention}$${C:mult})){} Mult",
          "{C:inactive}({C:attention}$${C:inactive} is your current money)",
          "{C:inactive}(Currently gives {C:mult}+#4#{C:inactive} Mult)"
        }
      },
      j_mf_stylemeter = {
        name = "Style Meter",
        text = {
          "Earn {C:money}$#1#{} at end",
          "of round for each",
          "{C:attention}Blind{} skipped this run",
          "{C:inactive}(Currently {C:money}$#2#{C:inactive})"
        }
      },
      j_mf_teacup = {
        name = "Teacup",
        text = {
          "Upgrade the level of",
          "each {C:attention}played hand{}",
          "for the next {C:attention}#1#{} hands",
        },
      },
      j_mf_the_solo = {
        name = "The Solo",
        text = {
          "Gains {X:mult,C:white} X#2# {} Mult if played",
          "hand has only {C:attention}1{} card",
          "{C:inactive}(Currently {X:mult,C:white} X#1# {C:inactive} Mult)",
        }
      },
      j_mf_tonersoup = {
        name = "I Sip Toner Soup",
        text = {
          "Create a {C:tarot}Tarot{} card",
          "when a hand is played",
          "Destroyed when blind",
          "is defeated",
          "{C:inactive}(Must have room)"
        },
      },
      j_mf_treasuremap = {
        name = "Treasure Map",
        text = {
          "After {C:attention}#2#{} rounds,",
          "sell this card to",
          "earn {C:money}$#3#{}",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2#)"
        },
      },
      j_mf_triangle = {
        name = "Triangle",
        text = {
          "Played cards each give",
          "{X:mult,C:white} X#1# {} Mult when scored",
          "if played hand is",
          "a {C:attention}Three of a Kind"
        },
      },
      j_mf_virtual = { 
        name = "Virtual Joker",
        text = {
          "{X:red,C:white} X#1# {} Mult",
          "Flips and shuffles all",
          "Joker cards when",
          "blind is selected"
        },
      },
      -- ORTALAB SWAPS
      j_mf_clintcondition = {
        name = "Clint Condition",
        text = {
          "{X:chips,C:white} X#1# {} Chips. {X:chips,C:white} X#2# {} Chips",
          "instead for {C:chips}Clint{}",
          "{C:inactive}(Who's Clint?)"
        }
      },
      j_mf_sheetsuggestion = {
        name = "Sheet Suggestion",
        text = {
          "{C:mult,s:1.1}+#1#{} Mult",
          "{C:inactive}(funny flavour text)"
        }
      },

      j_mf_devilsknife = {
        name = "Devilsknife",
        text = {
          "Creates a {C:colourcard}Blue{} and",
          "a {C:colourcard}Lilac{} {C:colourcard}Colour{} card",
          "when sold",
          "{C:inactive}(Must have room)"
        },
      },

      j_mf_twotrucks = {
        name = "Two Trucks",
        text = {
          "Gains {X:chips,C:white} X#1# {} Chips for",
          "each unique pair in played hand",
          "{C:inactive}(Currently {X:chips,C:white} X#2# {} {C:inactive}Chips)",
        },
      },

      -- FAMILIAR SWAPS
      j_mf_jimbojjoker = {
        name = "Jimbo J. Joker",
        text = {
          "{X:mult,C:white} X#1# {} Mult"
        }
      },
    },
    Colour = {
      c_mf_black = {
        name = "Black",
        text = {
          "Add {C:dark_edition}Negative{} to a",
          "random {C:attention}Joker{} for every",
          "{C:attention}#4#{} rounds this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_deepblue = {
        name = "Deep Blue",
        text = {
          "Converts a random card in",
          "hand to {C:spades}Spades{} for every",
          "{C:attention}#4#{} round this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_crimson = {
        name = "Crimson",
        text = {
          "Create a {C:red}Rare Tag{} for",
          "every {C:attention}#4#{} rounds",
          "this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_seaweed = {
        name = "Seaweed",
        text = {
          "Converts a random card in",
          "hand to {C:clubs}Clubs{} for every",
          "{C:attention}#4#{} round this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_brown = {
        name = "Brown",
        text = {
          "Destroys a random card in",
          "hand and gives {C:attention}$#5#{} for every",
          "{C:attention}#4#{} round this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_grey = {
        name = "Grey",
        text = {
          "Create a {C:attention}Double Tag{} for",
          "every {C:attention}#4#{} rounds",
          "this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_silver = {
        name = "Silver",
        text = {
          "Create a {C:dark_edition}Polychrome Tag{} for",
          "every {C:attention}#4#{} rounds",
          "this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_white = {
        name = "White",
        text = {
          "Create a random {C:dark_edition}Negative{}",
          "{C:colourcard}Colour{} card for every",
          "{C:attention}#4#{} rounds this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_red = {
        name = "Red",
        text = {
          "Converts a random card in",
          "hand to {C:hearts}Hearts{} for every",
          "{C:attention}#4#{} round this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_orange = {
        name = "Orange",
        text = {
          "Converts a random card in",
          "hand to {C:diamonds}Diamonds{} for every",
          "{C:attention}#4#{} round this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_yellow = {
        name = "Yellow",
        text = {
          "Gains {C:money}$#5#{} of",
          "{C:attention}sell value{}",
          "every {C:attention}#4# rounds",
          "{C:inactive}({}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_green = {
        name = "Green",
        text = {
          "Create a {C:green}D6 Tag{} for",
          "every {C:attention}#4#{} rounds",
          "this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_blue = {
        name = "Blue",
        text = {
          "Create a random {C:dark_edition}Negative{}",
          "{C:planet}Planet{} card for every",
          "{C:attention}#4#{} rounds this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_lilac = {
        name = "Lilac",
        text = {
          "Create a random {C:dark_edition}Negative{}",
          "{C:tarot}Tarot{} card for every",
          "{C:attention}#4#{} rounds this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_pink = {
        name = "Pink",
        text = {
          "Add {C:attention}1{} round to a random",
          "{C:colourcard}Colour{} card for every",
          "{C:attention}#4#{} rounds this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_peach = {
        name = "Peach",
        text = {
          "Create a {C:dark_edition}Negative{} {C:spectral}Soul{}",
          "card for every {C:attention}#4#{}",
          "rounds this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      
      c_mf_purple = {
        name = "Purple",
        text = {
          "Create an {C:cry_epic}Epic Tag{} for",
          "every {C:attention}#4#{} rounds",
          "this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_moonstone = {
        name = "Moonstone",
        text = {
          "Create a {C:dark_edition}Jolly Joker{}",
          "card for every {C:attention}#4#{}",
          "rounds this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_gold = {
        name = "Mutare Basi Ludum",
        text = {
          "Create a {C:dark_edition}Negative{} {C:cry_exotic}Gateway{}",
          "card for every {C:attention}#4#{}",
          "rounds this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
      c_mf_ooffoo = {
        name = "00FF00",
        text = {
          "Create a {C:dark_edition}Negative{} {C:cry_code}Code{}",
          "card for every {C:attention}#4#{}",
          "rounds this has been held",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
        },
      },
    },
    Oddity = {
      c_mf_jimbophone = {
        name = "JimboPhone",
        text = {
          "Create {C:attention}#1#{} {C:mult}Joker{},",
          "does not need room",
          "{C:inactive}(Joker: +4 Mult)"
        },
      },
    },
    Voucher = {
      v_mf_paintroller = {
        name = "Paint Roller",
        text = {
          "{C:green}1 in 2{} chance to add",
          "{C:attention}1{} round to {C:colourcard}Colour Cards{}",
          "when they gain a round"
        },
      },
      v_mf_colourtheory = {
        name = "Colour Theory",
        text = {
          "Some {C:colourcard}Colour{} cards in",
          "packs are {C:dark_edition}Polychrome{}",
        },
      },
      v_mf_artprogram = {
        name = "Art Program",
        text = {
          "Some {C:colourcard}Colour{} cards in",
          "packs are {C:dark_edition}Negative{}",
        },
      },
    },
    Back = {
      b_mf_grosmichel = {
        name = "Gros Michel Deck",
        text = {
          "Start run with {C:attention}Gros Michel"
        }
      },
      b_mf_philosophical = {
        name = "Philosophical Deck",
        text = {
          "Start run with 5",
          "{C:attention}Philosophical Jokers"
        }
      },
      b_mf_rainbow = {
        name = "Rainbow Deck",
        text = {
          "Start run with a {C:colourcard}White",
          "{C:colourcard}Colour{} card and the",
          "{C:tarot,T:v_mf_paintroller}Paint Roller{} Voucher",
        }
      },
      b_mf_blasphemy = {
        name = "Blasphemous Deck",
        text = {
          "Start run with a {C:dark_edition}Negative{}",
          "{C:spectral}Eternal{} {C:attention}Blasphemy"
        }
      },
    },
    Other = {
      undiscovered_colour = {
        name = "Not Discovered",
        text = {
          "Purchase or use",
          "this card in an",
          "unseeded run to",
          "learn what it does"
        }
      },
      p_mf_colour_normal_1 = {
        name = "Colour Pack",
        text = {
          "Choose {C:attention}#1#{} of up to",
          "{C:attention}#2#{C:colourcard} Colour{} cards to",
          "add to your consumeables"
        }
      },
      p_mf_colour_normal_2 = {
        name = "Colour Pack",
        text = {
          "Choose {C:attention}#1#{} of up to",
          "{C:attention}#2#{C:colourcard} Colour{} cards to",
          "add to your consumeables"
        }
      },
      p_mf_colour_jumbo_1 = {
        name = "Colour Pack",
        text = {
          "Choose {C:attention}#1#{} of up to",
          "{C:attention}#2#{C:colourcard} Colour{} cards to",
          "add to your consumeables"
        }
      },
      p_mf_colour_mega_1 = {
        name = "Colour Pack",
        text = {
          "Choose {C:attention}#1#{} of up to",
          "{C:attention}#2#{C:colourcard} Colour{} cards to",
          "add to your consumeables"
        }
      },
    },
    Sleeve = {
      sleeve_mf_grosmichel = {
        name = "Gros Michel Sleeve",
        text = {
          "Start run with {C:attention}Gros Michel"
        }
      },
      sleeve_mf_grosmichel_alt = {
        name = "Gros Michel Sleeve",
        text = {
          "Start run with {C:attention}Cavendish"
        }
      },
      sleeve_mf_philosophical = {
        name = "Philosophical Sleeve",
        text = {
          "Start run with 5",
          "{C:attention}Philosophical Jokers"
        }
      },
      sleeve_mf_philosophical_alt = {
        name = "Philosophical Sleeve",
        text = {
          "Start run with 10",
          "{C:attention}Philosophical Jokers"
        }
      },
      sleeve_mf_rainbow = {
        name = "Rainbow Sleeve",
        text = {
          "Start run with a {C:colourcard}White",
          "{C:colourcard}Colour{} card and the",
          "{C:tarot}Paint Roller{} Voucher",
        }
      },
      sleeve_mf_rainbow_alt = {
        name = "Rainbow Sleeve",
        text = {
          "Start run with the",
          "{C:tarot}Colour Theory{} Voucher",
        }
      },
      sleeve_mf_blasphemy = {
        name = "Blasphemous Sleeve",
        text = {
          "Start run with a {C:dark_edition}Negative{}",
          "{C:spectral}Eternal{} {C:attention}Blasphemy"
        }
      },
      sleeve_mf_blasphemy_alt = {
        name = "Blasphemous Sleeve",
        text = {
          "Start run with a",
          "{C:dark_edition}Negative{} {C:attention}Blasphemy"
        }
      },
    },
  },
  misc = {
    dictionary = {
      k_colour = "Colour",
      b_colour_cards = "Colour Cards",
      k_colour_pack = "Colour Pack",
      k_plus_colour = "+1 Colour",
      b_take = "TAKE",
      k_death_caps = "DEATH",

      k_display_for_paul = "(for Paul)",
      k_display_for_paul_ex = "(for Paul!)",
      k_display_steel_cards = "Steel Cards",
      k_display_per_round = "per round",
      k_display_lose_all_hands = "(-9999 hands)",
      k_display_only_hearts = "(Only Hearts!)",
      k_display_enhanced = "(Enhanced)",
      k_display_per_voucher = "per Voucher",
      k_display_first_hand = "(first hand)",
      k_display_straight = "(Straight)",
      k_display_modded_joker = "Modded Joker",
      k_display_on_reroll = "(on reroll)",
      k_display_per_hand = "per hand",
      k_display_one_red_card = "(1 red card)",
      k_display_modded = "Modded",
      k_display_hand_size = "Hand Size",
      k_display_joker_slot = "Joker Slot",
      k_display_pack_skipped = "(Pack skipped)",

      mf_config_features = "Features",

      mf_config_jokers = "Jokers",
      mf_config_colour_cards = "Colour Cards",
      mf_config_colour_music = "Colour Pack Music",
      mf_config_achievements = "Achievements",
      mf_config_unfinished = "Unfinished Content",
    },
    labels = {
      colour = "Colour"
    },
    achievement_names = {
      ach_mf_ten_colour_rounds = "10-ted",
      ach_mf_whos_paul = "Who's Paul?",
      ach_mf_jank_it_up = "Love that Janker",
      ach_mf_dropkick_ten_hands = "Going Infinite",
      ach_mf_negative_philosophical = "Deux Pipes",
      ach_mf_huge_and_pixel = "Anti-Aliased Allies",
    },
    achievement_descriptions = {
      ach_mf_ten_colour_rounds = 'Have a Colour Card with 10 triggers',
      ach_mf_whos_paul = "Trigger Basepaul Card's stronger effect",
      ach_mf_jank_it_up = "Have three copies of Jankman",
      ach_mf_dropkick_ten_hands = "Trigger Dropkick 5 times in one round",
      ach_mf_negative_philosophical = "Have a Negative Philosophical Joker",
      ach_mf_huge_and_pixel = "Have a Pixel Joker and a Huge Joker",
    },
  }
}