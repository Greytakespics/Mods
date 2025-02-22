
local joker = {
  name = "Jester",
  config = {
    extra = {chips=40}
  },
  pos = {x = 3, y = 0},
  rarity = 1,
  cost = 2,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Jester",
    text = {
      "{C:chips,s:1.1}+#1#{} Chips"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.chips }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after then
      return {
        message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
        chip_mod = card.ability.extra.chips, 
        colour = G.C.CHIPS
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_jester"] = {
    text = {
      { text = "+", colour = G.C.CHIPS },
      { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult", colour = G.C.CHIPS },
    },
  }
end

return joker
