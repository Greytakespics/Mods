local joker = {
  name = "Sheet Suggestion",
  config = {
    extra = {mult=4}
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
    name = "Sheet Suggestion",
    text = {
      "{C:mult,s:1.1}+#1#{} Mult",
      "{C:inactive}(funny flavour text)"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.mult }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after then
      return {
        message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
        mult_modd = card.ability.extra.mult, 
        colour = G.C.MULT
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_sheetsuggestion"] = {
    text = {
      { text = "+", colour = G.C.MULT },
      { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult", colour = G.C.MULT },
    },
  }
end

return joker
