let jokers = [

]

// works the same. 
let consumables = [
  {
    name: "Io",
    text: [
      "{C:attention}Upgrade{} all",
      "{C:clubs}Club{} cards",
      "in your deck",
      "by {C:chips}+10{} Chips"
    ],
    image_url: "img/io.png",
    rarity: "Planet"
  },

  {
    name: "Europa",
    text: [
      "{C:attention}Upgrade{} all",
      "{C:spades}Spade{} cards",
      "in your deck",
      "by {C:chips}+10{} Chips"
    ],
    image_url: "img/europa.png",
    rarity: "Planet"
  },
  {
    name: "Ganymede",
    text: [
      "{C:attention}Upgrade{} all",
      "{C:diamonds}Diamond{} cards",
      "in your deck",
      "by {C:chips}+10{} Chips"
    ],
    image_url: "img/ganymede.png",
    rarity: "Planet"
  },

  {
    name: "Callisto",
    text: [
      "{C:attention}Upgrade{} all",
      "{C:hearts}Heart{} cards",
      "in your deck",
      "by {C:chips}+10{} Chips"
    ],
    image_url: "img/callisto.png",
    rarity: "Planet"
  },
  {
    name: "Charon",
    text: [
      "{C:attention}Upgrade{} {C:chips}Bonus Cards{}",
      "by {C:chips}+10{} chips",
      "Affects {C:chips}Current{}",
      "and {C:dark_edition}Future{} cards",
    ],
    image_url: "img/charon.png",
    rarity: "Planet"
  },
  {
    name: "Hydra",
    text: [
      "{C:attention}Upgrade{} {C:mult}Mult Cards{}",
      "by {C:mult}+2{} mult",
      "Affects {C:mult}Current{}",
      "and {C:dark_edition}Future{} cards",
    ],
    image_url: "img/hydra.png",
    rarity: "Planet"
  },
]

let card_modifications = [

]

let decks = [
  // {
  //   name: "Joker",
  //   text: [
  //     "{C:mult}+4{} Mult"
  //   ],
  //   image_url: "img/j_joker.png",
  //   rarity: "Deck"
  // },
  {
    name: "Lemon-Lime Deck",
    text: [
      "Divides up the deck!",
      "{C:red}-1{} discard.",
      "The {C:attention}2's{} are extra tasty.",
    ],
    image_url: "img/lemon-lime.png",
    rarity: "Deck",
  },
  {
    name: "Aurora Deck",
    text: [
      "Start with an {C:spectral,T:c_aura}Aura{} card.",
      "{C:attention}Jokers{} and {C:attention}Playing Cards{}",
      "are {C:attention}usually{} {C:dark_edition}Special.",
      "{C:red}-1{} joker slot, {C:red}-1{} hand."
    ],
    image_url: "img/aurora.png",
    rarity: "Deck",
  },
  {
    name: "Sulfur Deck",
    text: [
      "Start with a {C:tarot,T:c_death}Death{} card",
      "and the {C:attention,T:v_overstock_norm}Overstock{} voucher.",
      "{C:attention}Jokers{} appear less often.",
    ],
    image_url: "img/sulfur.png",
    rarity: "Deck",
  },
  {
    name: "Hallowed Deck",
    text: [
      "{C:planet}Planets{} and {C:purple}Tarots{}",
      "no longer appear, while",
      "{C:attention}Playing Cards{} now",
      "appear in the shop."
    ],
    image_url: "img/hallowed.png",
    rarity: "Deck",
  },

  //{
  //  name: "DeckOS",
  //  text: [
  //    "BOOTING...",
  //    "{C:red}FAILED{} TO LOAD...",
  //    "{C:spectral}ATTEMPTING{} TO FIX...",
  //  ],
  //  image_url: "img/deckos.png",
  //  rarity: "Deck",
  //},



]

let stickers = [

]

let blinds = [
  // {
  //   name: "The Wall",
  //   text: [
  //     "Extra large blind",
  //     "{C:inactive}({C:red}4x{C:inactive} Base for {C:attention}$$$$${C:inactive})",
  //     "{C:inactive}(Appears from Ante 2)"
  //   ],
  //   image_url: "img/the_wall.png",
  //   rarity: "Boss Blind"
  // },

  {
    name: "The Prospector",
    text: [
      "All {C:attention}Stone{}, {C:attention}Steel{}, {C:attention}Gold{}, and {C:attention}Glass{} cards are debuffed",
      "{C:inactive}({C:red}2x{C:inactive} Base for {C:attention}$$$$${C:inactive})",
      "{C:inactive}(Appears from Ante 2)"
    ],
    image_url: "img/prospector.png",
    rarity: "Boss Blind"
  },
  {
    name: "The Gambler",
    text: [
      "All {C:attention}Wild{}, {C:attention}Lucky{}, {C:attention}Mult{}, and {C:attention}Bonus{} cards are debuffed",
      "{C:inactive}({C:red}2x{C:inactive} Base for {C:attention}$$$$${C:inactive})",
      "{C:inactive}(Appears from Ante 2)"
    ],
    image_url: "img/gambler.png",
    rarity: "Boss Blind"
  },
  {
    name: "The Pathway",
    text: [
      "All {C:attention}6{}, {C:attention}7{}, {C:attention}8{}, {C:attention}9{}, and {C:attention}10{} cards are debuffed",
      "{C:inactive}({C:red}2x{C:inactive} Base for {C:attention}$$$$${C:inactive})",
      "{C:inactive}(Appears from Ante 1)"
    ],
    image_url: "img/pathway.png",
    rarity: "Boss Blind"
  },
  {
    name: "The Backside",
    text: [
      "All {C:attention}Ace{}, {C:attention}2{}, {C:attention}3{}, {C:attention}4{}, and {C:attention}5{} cards are debuffed",
      "{C:inactive}({C:red}2x{C:inactive} Base for {C:attention}$$$$${C:inactive})",
      "{C:inactive}(Appears from Ante 1)"
    ],
    image_url: "img/backside.png",
    rarity: "Boss Blind"
  },
  {
    name: "The Heatwave",
    text: [
      "All {C:attention}even{} cards are drawn face down",
      "{C:inactive}({C:red}2x{C:inactive} Base for {C:attention}$$$$${C:inactive})",
      "{C:inactive}(Appears from Ante 2)"
    ],
    image_url: "img/heatwave.png",
    rarity: "Boss Blind"
  },
  {
    name: "The Frost",
    text: [
      "All {C:attention}odd{} cards are drawn face down",
      "{C:inactive}({C:red}2x{C:inactive} Base for {C:attention}$$$$${C:inactive})",
      "{C:inactive}(Appears from Ante 2)"
    ],
    image_url: "img/frost.png",
    rarity: "Boss Blind"
  },



]

let shop_items = [
  {
    name: "Stamper",
    text: [
      'Increase chance to find',
      '{C:attention}Playing cards{} with {C:attention}Seals',
      'in {C:attention}Standard Packs',
    ],
    image_url: "img/stamper.png",
    rarity: "Voucher",
  },
  {
    name: "Seal the Deal",
    text: [
      '{C:attention}Playing cards{} from',
      '{C:attention}Standard Packs{} always',
      'have {C:attention}Seals',
    ],
    image_url: "img/sealdeal.png",
    rarity: "Voucher",
  },

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
}

let rarities = {
  "Common": "#009dff", 
  "Uncommon": "#4BC292",
  "Rare": "#fe5f55",
  "Legendary": "#b26cbb",
  "Joker": "#708b91",
  "Tarot": "#a782d1",
  "Planet": "#13afce",
  "Spectral": "#4584fa",
  "Voucher": "#fd682b",
  "Enhancement": "#8389DD",
  "Edition": "#4ca893",
  "Seal": "#4584fa",
  "Deck": "#9bb6bd",
  "Sticker": "#5d5dff",
  "Boss Blind": "#5d5dff",
  "Showdown": "#4584fa",
}

regex = /{([^}]+)}/g;

let add_cards_to_div = (jokers, jokers_div) => {
  for (let joker of jokers) {
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
    } else {
      joker_div.innerHTML = `
        <h3>${joker.name}</h3>
        <img src="${joker.image_url}" alt="${joker.name}" />
        <h4 class="rarity" style="background-color: ${rarities[joker.rarity]}">${joker.rarity}</h4>
        <div class="text">${joker.text}</div>
      `;
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

if (consumables.length === 0) {
  document.querySelector(".consumablesfull").style.display = "none"
} else {
  let consumables_div = document.querySelector(".consumables");
  add_cards_to_div(consumables, consumables_div);
}

if (card_modifications.length === 0) {
  document.querySelector(".cardmodsfull").style.display = "none"
} else {
  let cardmods_div = document.querySelector(".cardmods");
  add_cards_to_div(card_modifications, cardmods_div);
}

if (decks.length === 0) {
  document.querySelector(".decksfull").style.display = "none"
} else {
  let decks_div = document.querySelector(".decks");
  add_cards_to_div(decks, decks_div);
}

if (stickers.length === 0) {
  document.querySelector(".stickersfull").style.display = "none"
} else {
  let stickers_div = document.querySelector(".stickers");
  add_cards_to_div(stickers, stickers_div);
}

if (blinds.length === 0) {
  document.querySelector(".blindsfull").style.display = "none"
} else {
  let blinds_div = document.querySelector(".blinds");
  add_cards_to_div(blinds, blinds_div);
}

if (shop_items.length === 0) {
  document.querySelector(".shopitemsfull").style.display = "none"
} else {
  let shopitems_div = document.querySelector(".shopitems");
  add_cards_to_div(shop_items, shopitems_div);
}