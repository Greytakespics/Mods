let jokers = [
  {
    name: "Basepaul Card",
    text: [
      "{X:mult,C:white} X1.25{} Mult. {X:mult,C:white} X12.5{} Mult",
      "instead for {C:red}Paul{}",
      "{C:inactive}(Who's Paul?)"
    ],
    image_url: "assets/j_mf_basepaulcard.png",
    rarity: "Common",
  },
  {
    name: "Clownfish",
    text: [
      "{C:attention}Enhanced{} cards",
      "score {C:chips}+15{} more Chips",
      "and {C:mult}+4{} more Mult",
      "when scored"
    ],
    image_url: "assets/j_mf_clownfish.png",
    rarity: "Common",
    badges: [
      ["assets/badge-balancebuff.png", "+10 -> +15 chips"],
    ],
  },
  {
    name: "Expansion Pack",
    text: [
      "When {C:attention}Blind{} is selected,",
      "create {C:attention}1 {C:dark_edition}modded{C:attention} Joker",
      "{C:inactive}(Must have room)"
    ],
    image_url: "assets/j_mf_expansionpack.png",
    rarity: "Common",
  },
  {
    name: "Hollow Joker",
    text: [
      "{C:attention}-1{} hand size",
      "{C:mult}+10{} Mult per hand",
      "size below {C:attention}9"
    ],
    image_url: "assets/j_mf_hollow.png",
    rarity: "Common",
  },
  {
    name: "Jester",
    text: [
      "{C:chips,s:1.1}+40{} Chips"
    ],
    image_url: "assets/j_mf_jester.png",
    rarity: "Common",
  },
  {
    name: "Lollipop",
    text: [
      "{X:mult,C:white} X1.75{} Mult",
      "{X:mult,C:white} -X0.15{} Mult per",
      "round played"
    ],
    image_url: "assets/j_mf_lollipop.png",
    rarity: "Common",
  },
  {
    name: "Lucky Charm",
    text: [
      "{C:green}1 in 3{} chance for {C:mult}+20{} Mult",
      "{C:green}1 in 8{} chance to win {C:money}$20",
      "at end of round"
    ],
    image_url: "assets/j_mf_luckycharm.png",
    rarity: "Common",
  },
  {
    name: "Monochrome Joker",
    text: [
      "{C:mult}+2{} Mult per round",
      "without a {C:colourcard}Colour Card",
    ],
    image_url: "assets/j_mf_monochrome.png",
    rarity: "Common",
    badges: [
      ["assets/badge-new.png", "This is new!"],
    ]
  },
  {
    name: "MS Paint Joker",
    text: [
      "{C:attention}+4{} hand size",
      "for the first hand",
      "of each blind"
    ],
    image_url: "assets/j_mf_mspaint.png",
    rarity: "Common",
  },
  {
    name: "Simplified Joker",
    text: [
      "All {C:blue}Common{} Jokers",
      "each give {C:mult}+4{} Mult",
    ],
    image_url: "assets/j_mf_simplified.png",
    rarity: "Common",
    badges: [
      ["assets/badge-balancebuff.png", "Now triggers on itself"],
    ],
  },
  {
    name: "Spiral Joker",
    text: [
      "{C:mult}+(10+7cos(pi/8 x {C:attention}$${C:mult})){} Mult",
      "{C:inactive}({C:attention}$${C:inactive} is your current money)",
    ],
    image_url: "assets/j_mf_spiraljoker.png",
    rarity: "Common",
  },
  {
    name: "Treasure Map",
    text: [
      "After {C:attention}2{} rounds,",
      "sell this card to",
      "earn {C:money}$13{}"
    ],
    image_url: "assets/j_mf_treasuremap.png",
    rarity: "Common",
    badges: [
      ["assets/badge-balancerework.png", "3 -> 2 rounds\n$18 -> $13 earned"],
    ],
  },
  {
    name: "Philosophical Joker",
    text: [
      "{C:dark_edition}+1{} Joker Slot"
    ],
    image_url: "assets/j_mf_pipe.png",
    rarity: "Common",
    badges: [
      ["assets/badge-balancebuff.png", "Can now be purchased with full joker slots"],
    ],
  },
  {
    name: "Bad Legal Defence",
    text: [
      "Create a {C:attention}Death{} {C:tarot}Tarot{}",
      "when {C:attention}Boss Blind{}",
      "is selected",
      "{C:inactive}(Must have room)"
    ],
    image_url: "assets/j_mf_badlegaldefence.png",
    rarity: "Uncommon",
    badges: [
      ["assets/badge-balancenerf.png", "Common -> Uncommon"],
    ],
  },
  {
    name: "Clipart Joker",
    text: [
      "Create a {C:colourcard}Colour{} card",
      "when {C:attention}Blind{} is selected",
      "{C:inactive}(Must have room)"
    ],
    image_url: "assets/j_mf_clipart.png",
    rarity: "Uncommon",
  },
  {
    name: "Dropkick",
    text: [
      "{C:blue}+1{} hand when hand",
      "contains a {C:attention}Straight"
    ],
    image_url: "assets/j_mf_dropkick.png",
    rarity: "Uncommon",
  },
  {
    name: "Blade Dance",
    text: [
      "Adds {C:attention}2{} temporary",
      "{C:attention}Steel Cards{}",
      "to your deck when",
      "blind is selected"
    ],
    image_url: "assets/j_mf_bladedance.png",
    rarity: "Uncommon",
  },
  {
    name: "Hyper Beam",
    text: [
      "{X:red,C:white} X3{} Mult",
      "{C:attention}Lose all discards",
      "when {C:attention}Blind{} is selected"
    ],
    image_url: "assets/j_mf_hyperbeam.png",
    rarity: "Uncommon",
  },
  {
    name: "Blasphemy",
    text: [
      "{X:red,C:white} X4{} Mult",
      "{C:blue}-9999{} hands",
      "when hand is played"
    ],
    image_url: "assets/j_mf_blasphemy.png",
    rarity: "Uncommon",
  },
  {
    name: "Dramatic Entrance",
    text: [
      "{C:chips}+150{} Chips",
      "for the first hand",
      "of each round"
    ],
    image_url: "assets/j_mf_dramaticentrance.png",
    rarity: "Uncommon",
  },
  {
    name: "Coupon Catalogue",
    text: [
      "{C:mult}+15{} Mult for each",
      "{C:attention}Voucher{} purchased",
      "this run",
    ],
    image_url: "assets/j_mf_couponcatalogue.png",
    rarity: "Uncommon",
    badges: [
      ["assets/badge-balancerework.png", "+10 -> +15 Mult\nCommon -> Uncommon"],
    ],
  },
  {
    name: "CSS",
    text: [
      "Create a random {C:colourcard}Colour",
      "card when played hand",
      "contains a {C:attention}Flush"
    ],
    image_url: "assets/j_mf_css.png",
    rarity: "Uncommon",
  },
  {
    name: "Globe",
    text: [
      "Create 1 {C:planet}Planet{} card",
      "when you {C:attention}reroll{} in the shop",
    ],
    image_url: "assets/j_mf_globe.png",
    rarity: "Uncommon",
  },
  {
    name: "Golden Carrot",
    text: [
      "Earn {C:money}$10{} at end of round",
      "{C:money}-$1{} given per hand played"
    ],
    image_url: "assets/j_mf_goldencarrot.png",
    rarity: "Uncommon",
  },
  {
    name: "Hall of Mirrors",
    text: [
      "{C:attention}+2{} hand size for",
      "each {C:attention}6{} scored in",
      "the current round",
    ],
    image_url: "assets/j_mf_hallofmirrors.png",
    rarity: "Uncommon",
  },
  {
    name: "Impostor",
    text: [
      "{X:mult,C:white} X3{} Mult if the",
      "played hand has",
      "exactly one {C:red}red{} card"
    ],
    image_url: "assets/j_mf_impostor.png",
    rarity: "Uncommon",
    badges: [
      ["assets/badge-balancebuff.png", "X2 -> X3 Mult"],
    ],
  },
  {
    name: "I Sip Toner Soup",
    text: [
      "Create a {C:tarot}Tarot{} card",
      "when a hand is played",
      "Destroyed when blind",
      "is defeated",
      "{C:inactive}(Must have room)"
    ],
    image_url: "assets/j_mf_tonersoup.png",
    rarity: "Uncommon",
  },
  {
    name: "Loaded Disk",
    text: [
      "Creates a {C:colourcard}Pink{} and",
      "a {C:colourcard}Yellow{} {C:colourcard}Colour{} card",
      "when sold",
      "{C:inactive}(Must have room)"
    ],
    image_url: "assets/j_mf_loadeddisk.png",
    rarity: "Uncommon",
  },
  {
    name: "Style Meter",
    text: [
      "Earn {C:money}$3{} at end",
      "of round for each",
      "{C:attention}Blind{} skipped this run",
    ],
    image_url: "assets/j_mf_stylemeter.png",
    rarity: "Uncommon",
  },
  {
    name: "Teacup",
    text: [
      "Upgrade the level of",
      "each {C:attention}played hand{}",
      "for the next {C:attention}5{} hands",
    ],
    image_url: "assets/j_mf_teacup.png",
    rarity: "Uncommon",
    badges: [
      ["assets/badge-balancebuff.png", "4 hands -> 5 hands"],
    ],
  },
  {
    name: "Recycling",
    text: [
      "Create a random {C:planet}Planet{}",
      "or {C:tarot}Tarot{} card",
      "when any {C:attention}Booster{}",
      "{C:attention}Pack{} is skipped",
      "{C:inactive}(Must have room)"
    ],
    image_url: "assets/j_mf_recycling.png",
    rarity: "Uncommon",
  },
  {
    name: "Virtual Joker",
    text: [
      "{X:red,C:white} X3{} Mult",
      "Flips and shuffles all",
      "Joker cards when",
      "blind is selected"
    ],
    image_url: "assets/j_mf_virtual.png",
    rarity: "Uncommon",
  },
  {
    name: "Blood Pact",
    text: [
      "{X:mult,C:white} X5{} Mult",
      "Destroyed if you play",
      "a non-{C:hearts}Hearts{} card"
    ],
    image_url: "assets/j_mf_bloodpact.png",
    rarity: "Rare",
  },
  {
    name: "Bowling Ball",
    text: [
      "Played {C:attention}3s{}",
      "give {C:chips}+60{} Chips",
      "and {C:mult}+10{} Mult",
      "when scored"
    ],
    image_url: "assets/j_mf_bowlingball.png",
    rarity: "Rare",
  },
  {
    name: "Card Buffer Advanced",
    text: [
      "{C:attention}Retrigger{} your first",
      "{C:dark_edition}Editioned{} Joker",
    ],
    image_url: "assets/j_mf_cba.png",
    rarity: "Rare",
    badges: [
      ["assets/badge-balancerework.png", "Effect has been replaced."],
    ],
  },
  {
    name: "Flesh Prison",
    text: [
      "{C:red}X5{} {C:attention}Boss Blind{} size. When",
      "{C:attention}Boss Blind{} is defeated,",
      "{C:red}self destructs{},",
      "and creates a",
      "{C:dark_edition}Negative{} {C:spectral}The Soul{} card"
    ],
    image_url: "assets/j_mf_fleshprison.png",
    rarity: "Rare",
  },
  {
    name: "Huge Joker",
    text: [
      "{X:red,C:white} X3{} Mult",
      "{C:attention}-2{} hand size"
    ],
    image_url: "assets/jimbo.png",
    rarity: "Rare",
  },
  {
    name: "Jankman",
    text: [
      "All {C:dark_edition}modded{} Jokers",
      "{C:inactive}(and also Jolly Joker){}",
      "each give {X:mult,C:white} X1.31{} Mult",
    ],
    image_url: "assets/j_mf_jankman.png",
    rarity: "Rare",
    badges: [
      ["assets/badge-balancebuff.png", "X1.25 -> X1.31 Mult\nNow triggers on itself, and Jolly Jokers"],
    ],
  },
  {
    name: "Mashup Album",
    text: [
      "Gains {C:mult}+4{} Mult if played",
      "hand contains a {C:hearts}red{} flush",
      "Gains {C:chips}+15{} Chips if played",
      "hand contains a {C:spades}black{} flush"
    ],
    image_url: "assets/j_mf_mouthmoods.png",
    rarity: "Rare",
    badges: [
      ["assets/badge-balancebuff.png", "Starts at +4 Mult and +15 Chips"],
    ],
  },
  {
    name: "Pixel Joker",
    text: [
      "Played {C:attention}Aces{},",
      "{C:attention}4s{} and {C:attention}9s{} each give",
      "{X:mult,C:white} X1.5{} Mult when scored"
    ],
    image_url: "assets/j_mf_pixeljoker.png",
    rarity: "Rare",
  },
  {
    name: "Rainbow Joker",
    text: [
      "{C:colourcard}Colour{} cards give",
      "{X:mult,C:white} X1.5{} Mult"
    ],
    image_url: "assets/j_mf_rainbow.png",
    rarity: "Rare",
    badges: [
      ["assets/badge-balancenerf.png", "X2 -> X1.5 Mult"],
    ],
  },
  {
    name: "Rose-Tinted Glasses",
    text: [
      "If {C:attention}first hand{} of round is",
      "a single {C:attention}2{}, destroy it and",
      "create a free {C:attention}Double Tag{}",
    ],
    image_url: "assets/j_mf_rosetinted.png",
    rarity: "Rare",
  },
  {
    name: "The Solo",
    text: [
      "Gains {X:mult,C:white} X0.1{} Mult if played",
      "hand has only {C:attention}1{} card",
    ],
    image_url: "assets/j_mf_thesolo.png",
    rarity: "Rare",
  },
  {
    name: "Triangle",
    text: [
      "Played cards each give",
      "{X:mult,C:white} X3{} Mult when scored",
      "if played hand is",
      "a {C:attention}Three of a Kind"
    ],
    image_url: "assets/j_mf_triangle.png",
    rarity: "Legendary",
    soul: true,
    badges: [
      ["assets/badge-new.png", "This is new!"],
    ],
  },
  {
    name: "Colorem",
    text: [
      "When a {C:colourcard}Colour{} card is",
      "used, {C:green}1 in 3{} chance to add",
      "a copy to your consumable",
      "area {C:inactive}(Must have room)",
      "",// so the badges get out of the way
      "",
    ],
    image_url: "assets/j_mf_colorem.png",
    rarity: "Exotic",
    exotic: true,
    badges: [
      ["assets/badge-new.png", "This is new!"],
      ["assets/badge-cryptid.png", "This requires Cryptid."],
    ],
  },
]

// works the same. 
let consumables = [
  {
    name: "Black",
    text: [
      "Add {C:dark_edition}Negative{} to a",
      "random {C:attention}Joker{} for every",
      "{C:attention}4{} rounds this has been held"
    ],
    image_url: "assets/c_mf_black.png",
    rarity: "Colour"
  },
  {
    name: "Deep Blue",
    text: [
      "Converts a random card in",
      "hand to {C:spades}Spades{} for every",
      "round this has been held",
    ],
    image_url: "assets/c_mf_deepblue.png",
    rarity: "Colour"
  },
  {
    name: "Crimson",
    text: [
      "Create a {C:red}Rare Tag{} for",
      "every {C:attention}3{} rounds",
      "this has been held",
    ],
    image_url: "assets/c_mf_crimson.png",
    rarity: "Colour"
  },
  {
    name: "Seaweed",
    text: [
      "Converts a random card in",
      "hand to {C:clubs}Clubs{} for every",
      "round this has been held",
    ],
    image_url: "assets/c_mf_seaweed.png",
    rarity: "Colour"
  },
  {
    name: "Brown",
    text: [
      "Destroys a random card in",
      "hand and gives {C:attention}$2{} for every",
      "round this has been held",
    ],
    image_url: "assets/c_mf_brown.png",
    rarity: "Colour"
  },
  {
    name: "Grey",
    text: [
      "Create a {C:attention}Double Tag{} for",
      "every {C:attention}3{} rounds",
      "this has been held",
    ],
    image_url: "assets/c_mf_grey.png",
    rarity: "Colour"
  },
  {
    name: "Silver",
    text: [
      "Create a {C:dark_edition}Polychrome Tag{}",
      "for every {C:attention}3{} rounds",
      "this has been held",
    ],
    image_url: "assets/c_mf_silver.png",
    rarity: "Colour"
  },
  {
    name: "White",
    text: [
      "Create a random {C:dark_edition}Negative{}",
      "{C:colourcard}Colour{} card for every",
      "{C:attention}3{} rounds this has been held",
    ],
    image_url: "assets/c_mf_white.png",
    rarity: "Colour"
  },
  {
    name: "Red",
    text: [
      "Converts a random card in",
      "hand to {C:hearts}Hearts{} for every",
      "round this has been held",
    ],
    image_url: "assets/c_mf_red.png",
    rarity: "Colour"
  },
  {
    name: "Orange",
    text: [
      "Converts a random card in",
      "hand to {C:diamonds}Diamonds{} for every",
      "round this has been held",
    ],
    image_url: "assets/c_mf_orange.png",
    rarity: "Colour"
  },
  {
    name: "Yellow",
    text: [
      "Gains {C:money}$8{} of",
      "{C:attention}sell value{}",
      "every {C:attention}3{} rounds"
    ],
    image_url: "assets/c_mf_yellow.png",
    rarity: "Colour"
  },
  {
    name: "Green",
    text: [
      "Create a {C:green}D6 Tag{} for",
      "every {C:attention}3{} rounds",
      "this has been held",
    ],
    image_url: "assets/c_mf_green.png",
    rarity: "Colour"
  },
  {
    name: "Blue",
    text: [
      "Create a random {C:dark_edition}Negative{}",
      "{C:planet}Planet{} card for every",
      "{C:attention}2{} rounds this has been held",
    ],
    image_url: "assets/c_mf_blue.png",
    rarity: "Colour"
  },
  {
    name: "Lilac",
    text: [
      "Create a random {C:dark_edition}Negative{}",
      "{C:tarot}Tarot{} card for every",
      "{C:attention}2{} rounds this has been held",
    ],
    image_url: "assets/c_mf_lilac.png",
    rarity: "Colour"
  },
  {
    name: "Pink",
    text: [
      "Add {C:attention}1{} round to a random",
      "{C:colourcard}Colour{} card for every",
      "{C:attention}2{} rounds this has been held",
    ],
    image_url: "assets/c_mf_pink.png",
    rarity: "Colour"
  },
  {
    name: "Peach",
    text: [
      "Create a {C:dark_edition}Negative{} {C:spectral}Soul{}",
      "card for every {C:attention}6{}",
      "rounds this has been held",
    ],
    image_url: "assets/c_mf_peach.png",
    rarity: "Colour"
  },
  {
    name: "Purple",
    text: [
      "Create an {C:cry_epic}Epic Tag{} for",
      "every {C:attention}4{} rounds",
      "this has been held",
      "",
      "",
    ],
    image_url: "assets/c_mf_purple.png",
    rarity: "Colour",
    badges: [
      ["assets/badge-new.png", "This is new!"],
      ["assets/badge-cryptid.png", "This requires Cryptid."],
    ]
  },
  {
    name: "Moonstone",
    text: [
      "Create a {C:dark_edition}Jolly Joker{}",
      "card for every {C:attention}2{}",
      "rounds this has been held",
    ],
    image_url: "assets/c_mf_moonstone.png",
    rarity: "Colour",
    badges: [
      ["assets/badge-new.png", "This is new!"],
      ["assets/badge-cryptid.png", "This requires Cryptid."],
    ]
  },
  {
    name: "Mutare Basi Ludum",
    text: [
      "Create a {C:dark_edition}Negative{} {C:spectral}Gateway{}",
      "card for every {C:attention}9{}",
      "rounds this has been held",
    ],
    image_url: "assets/c_mf_gold.png",
    rarity: "Colour",
    badges: [
      ["assets/badge-new.png", "This is new!"],
      ["assets/badge-cryptid.png", "This requires Cryptid."],
    ]
  },
  {
    name: "00FF00",
    text: [
      "Create a {C:dark_edition}Negative{} {C:green}Code{}",
      "card for every {C:attention}4{}",
      "rounds this has been held",
    ],
    image_url: "assets/c_mf_ooffoo.png",
    rarity: "Colour",
    badges: [
      ["assets/badge-new.png", "This is new!"],
      ["assets/badge-cryptid.png", "This requires Cryptid."],
    ]
  },
]

let decks = [
  {
    name: "Gros Michel Deck",
    text: [
      "Start run with {C:attention}Gros Michel"
    ],
    image_url: "assets/b_mf_grosmichel.png",
    rarity: "Deck"
  },
  {
    name: "Rainbow Deck",
    text: [
      "Start run with a {C:colourcard}White",
      "{C:colourcard}Colour{} card and the",
      "{C:tarot,T:v_mf_paintroller}Paint Roller{} Voucher",
    ],
    image_url: "assets/b_mf_rainbow.png",
    rarity: "Deck"
  },
  {
    name: "Philosophical Deck",
    text: [
      "Start run with 5",
      "{C:attention}Philosophical Jokers"
    ],
    image_url: "assets/b_mf_philosophical.png",
    rarity: "Deck"
  },
  {
    name: "Blasphemous Deck",
    text: [
      "Start run with a {C:dark_edition}Negative{}",
      "{C:spectral}Eternal{} {C:attention}Blasphemy"
    ],
    image_url: "assets/b_mf_blasphemy.png",
    rarity: "Deck"
  },
]

let sleeves = [
  {
    name: "Gros Michel Sleeve",
    text: [
      "Start run with {C:attention}Gros Michel",
      "{C:yellow}(Cavendish)"
    ],
    image_url: "assets/s_mf_grosmichel.png",
    rarity: "Sleeve"
  },
  {
    name: "Rainbow Sleeve",
    text: [
      "Start run with a {C:colourcard}White",
      "{C:colourcard}Colour{} card and the",
      "{C:tarot,T:v_mf_paintroller}Paint Roller{} Voucher",
      "{C:yellow}(and the Colour Theory voucher)",
    ],
    image_url: "assets/s_mf_rainbow.png",
    rarity: "Sleeve"
  },
  {
    name: "Philosophical Sleeve",
    text: [
      "Start run with 5 {C:yellow}(10)",
      "{C:attention}Philosophical Jokers"
    ],
    image_url: "assets/s_mf_philosophical.png",
    rarity: "Sleeve"
  },
  {
    name: "Blasphemous Sleeve",
    text: [
      "Start run with a {C:dark_edition}Negative{}",
      "{C:spectral}Eternal{} {C:yellow}(not eternal)",
      "{C:attention}Blasphemy",
    ],
    image_url: "assets/s_mf_blasphemy.png",
    rarity: "Sleeve"
  },
]

let packs = [
  {
    name: "Paint Roller",
    text: [
      "{C:green}1 in 2{} chance to add",
      "{C:attention}1{} round to {C:colourcard}Colour Cards{}",
      "when they gain a round",
    ],
    image_url: "assets/v_mf_paintroller.png",
    rarity: "Voucher"
  },
  {
    name: "Colour Theory",
    text: [
      "Some {C:colourcard}Colour{} cards in",
      "packs are {C:dark_edition}Polychrome{}",
    ],
    image_url: "assets/v_mf_colourtheory.png",
    rarity: "Voucher"
  },
  {
    name: "Art Program",
    text: [
      "Some {C:colourcard}Colour{} cards in",
      "packs are {C:dark_edition}Negative{}",
    ],
    image_url: "assets/v_mf_artprogram.png",
    rarity: "Voucher",
    badges: [
      ["assets/badge-new.png", "This is new!"],
      ["assets/badge-cryptid.png", "This requires Cryptid."],
    ]
  },
]

let blinds = [
]

let shop_items = [
]

let cols = {
  
  MULT: "#FE5F55",
  CHIPS: "#009dff",
  MONEY: "#f3b958",
  XMULT: "#FE5F55",
  FILTER: "#ff9a00",
  ATTENTION: "#ff9a00",
  BLUE: "#009dff",
  RED: "#FE5F55",
  GREEN: "#4BC292",
  PALE_GREEN: "#56a887",
  ORANGE: "#fda200",
  IMPORTANT: "#ff9a00",
  GOLD: "#eac058",
  YELLOW: "#ffff00",
  CLEAR: "#00000000", 
  WHITE: "#ffffff",
  PURPLE: "#8867a5",
  BLACK: "#374244",
  L_BLACK: "#4f6367",
  GREY: "#5f7377",
  CHANCE: "#4BC292",
  JOKER_GREY: "#bfc7d5",
  VOUCHER: "#cb724c",
  BOOSTER: "#646eb7",
  EDITION: "#ffffff",
  DARK_EDITION: "#5d5dff",
  ETERNAL: "#c75985",
  INACTIVE: "#ffffff99",
  HEARTS: "#f03464",
  DIAMONDS: "#f06b3f",
  SPADES: "#403995",
  CLUBS: "#235955",
  ENHANCED: "#8389DD",
  JOKER: "#708b91",
  TAROT: "#a782d1",
  PLANET: "#13afce",
  SPECTRAL: "#4584fa",
  VOUCHER: "#fd682b",
  EDITION: "#4ca893",

  ALCHEMICAL: "#C09D75",
  COLOURCARD: "#8867a5",
  
  FLEURONS: "#d6901a",
  HALBERDS: "#993283",
  STARS: "#DF509F",
  MOONS: "#696076",
  NOTES: "#D61BAF",
}

let rarities = {
  "Common": "#009dff", 
  "Uncommon": "#4BC292",
  "Rare": "#fe5f55",
  "Legendary": "#b26cbb",
  "Exotic": "#708b91",
  "Joker": "#708b91",
  "Tarot": "#a782d1",
  "Planet": "#13afce",
  "Spectral": "#4584fa",
  "Voucher": "#fd682b",
  "Pack": "#9bb6bd",
  "Enhancement": "#8389DD",
  "Edition": "#4ca893",
  "Seal": "#4584fa",
  "Deck": "#9bb6bd",
  "Sticker": "#5d5dff",
  "Boss Blind": "#5d5dff",
  "Showdown": "#4584fa",

  "Colour": "#8867a5",
  "Fusion": "#F7D762",
  "Sleeve": "#9bb6bd",
}

regex = /{([^}]+)}/g;
let add_cards_to_div = (jokers, jokers_div) => {
  for (let joker of jokers) {
    if (joker.hidden) {
      let joker_div = document.createElement("div");
      jokers_div.appendChild(joker_div);
      continue
    }
    console.log("adding joker", joker.name);
  
    joker.text = joker.text.map((line) => { return line + "{}"});
  
    joker.text = joker.text.join("<br/>");
    joker.text = joker.text.replaceAll("{}", "</span>");
    joker.text = joker.text.replace(regex, function replacer(match, p1, offset, string, groups) {
      let classes = p1.split(",");
  
      let css_styling = "";
  
      for (let i = 0; i < classes.length; i++) {
        let parts = classes[i].split(":");
        if (parts[0] === "C") {
          css_styling += `color: ${cols[parts[1].toUpperCase()]};`;
        } else if (parts[0] === "X") {
          css_styling += `background-color: ${cols[parts[1].toUpperCase()]}; border-radius: 5px; padding: 0 5px;`;
        }
      }
  
      return `</span><span style='${css_styling}'>`;
    });
  
    let joker_div = document.createElement("div");
    joker_div.classList.add("joker");
    if (joker.rarity === "Sticker" || joker.rarity == "Seal") {
      joker_div.innerHTML = `
        <h3>${joker.name}</h3>
        <img src="${joker.image_url}" alt="${joker.name}" class="hasback" />
        <h4 class="rarity" style="background-color: ${rarities[joker.rarity]}">${joker.rarity}</h4>
        <div class="text">${joker.text}</div>
      `;
    } else if (joker.soul) {
      joker_div.innerHTML = `
        <h3>${joker.name}</h3>
        <span class="soulholder">
          <img src="${joker.image_url}" alt="${joker.name}" class="soul-bg" />
          <img src="${joker.image_url}" alt="${joker.name}" class="soul-top" />
        </span>
        <h4 class="rarity" style="background-color: ${rarities[joker.rarity]}">${joker.rarity}</h4>
        <div class="text">${joker.text}</div>
      `;
    } else if (joker.exotic) {
      joker_div.innerHTML = `
        <h3>${joker.name}</h3>
        <span class="soulholder">
          <img src="${joker.image_url}" alt="${joker.name}" class="exotic-bg" />
          <img src="${joker.image_url}" alt="${joker.name}" class="exotic-mid" />
          <img src="${joker.image_url}" alt="${joker.name}" class="exotic-top" />
        </span>
        <h4 class="rarity" style="background-color: ${rarities[joker.rarity]}">${joker.rarity}</h4>
        <div class="text">${joker.text}</div>
      `;
    } else {
      joker_div.innerHTML = `
        <h3>${joker.name}</h3>
        <img src="${joker.image_url}" alt="${joker.name}" />
        <h4 class="rarity" style="background-color: ${rarities[joker.rarity]}">${joker.rarity}</h4>
        <div class="text">${joker.text}</div>
      `;
    }
    if (joker.name == "Huge Joker" || joker.name == "Huge Stuntman") {
      joker_div.classList.add("hugejoker");
    }
    if (joker.name == "Pixel Joker") {
      joker_div.classList.add("pixeljoker");
    }
    if (joker.name == "Mashup Album" || joker.name == "Triangle Joker") {
      joker_div.classList.add("mouthmoods");
    }
    if (joker.badges) {
      let badge_div = document.createElement("div");
      badge_div.classList.add("badges")
      for (badge of joker.badges) {
        let elem = document.createElement("img");
        elem.src = badge[0]
        elem.title = badge[1]
        badge_div.appendChild(elem)
      }
      joker_div.appendChild(badge_div)
    }
  
    jokers_div.appendChild(joker_div);
  }
}

if (jokers.length === 0) {
  document.querySelector(".jokersfull").style.display = "none"
} else {
  let jokers_div = document.querySelector(".jokers");
  add_cards_to_div(jokers, jokers_div);
}

// if (blinds.length === 0) {
//   document.querySelector(".blindsfull").style.display = "none"
// } else {
//   let blinds_div = document.querySelector(".blinds");
//   add_cards_to_div(blinds, blinds_div);
// }

if (consumables.length === 0) {
  document.querySelector(".consumablesfull").style.display = "none"
} else {
  let consumables_div = document.querySelector(".consumables");
  add_cards_to_div(consumables, consumables_div);
}

if (packs.length === 0) {
  document.querySelector(".packsfull").style.display = "none"
} else {
  let packs_div = document.querySelector(".packs");
  add_cards_to_div(packs, packs_div);
}

if (decks.length === 0) {
  document.querySelector(".decksfull").style.display = "none"
} else {
  let decks_div = document.querySelector(".decks");
  add_cards_to_div(decks, decks_div);
}

if (sleeves.length === 0) {
  document.querySelector(".sleevesfull").style.display = "none"
} else {
  let sleeves_div = document.querySelector(".sleeves");
  add_cards_to_div(sleeves, sleeves_div);
}

// if (extras.length === 0) {
//   document.querySelector(".extrasfull").style.display = "none"
// } else {
//   let extras_div = document.querySelector(".extras");
//   add_cards_to_div(extras, extras_div);
// }

document.querySelector(".jokercount").innerHTML = document.querySelector(".jokercount").innerHTML.replace("{{count}}", jokers.length);


var coll = document.getElementsByClassName("collapsible");
var i;

for (i = 0; i < coll.length; i++) {
  coll[i].addEventListener("click", function() {
    this.classList.toggle("active");
    var content = this.nextElementSibling;
    if (content.style.maxHeight){
      this.innerHTML = "Show Fusion"
      content.style.maxHeight = null;
    } else {
      this.innerHTML = "Hide Fusion"
      content.style.maxHeight = content.scrollHeight + "px";
    }
  });
}