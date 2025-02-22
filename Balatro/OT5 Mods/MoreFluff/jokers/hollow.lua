local joker = {
  name = "Hollow Joker",
  config = {
    h_size = -1,
    extra = {
      mult_per = 10,
      thresh = 9,
    }
  },
  pos = {x = 4, y = 1},
  rarity = 1,
  cost = 4,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Hollow Joker",
    text = {
      "{C:attention}#1#{} hand size",
      "{C:mult}+#2#{} Mult per hand",
      "size below {C:attention}#3#"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {vars = { center.ability.h_size, center.ability.extra.mult_per, center.ability.extra.thresh } }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after and G.hand.config.card_limit < card.ability.extra.thresh then
      return {
        message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult_per * (card.ability.extra.thresh - G.hand.config.card_limit)}},
        mult_mod = card.ability.extra.mult_per * (card.ability.extra.thresh - G.hand.config.card_limit)
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_hollow"] = {
    text = {
      { text = "+", colour = G.C.MULT },
      { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult", colour = G.C.MULT },
    },
    calc_function = function(card)
      if G.hand.config.card_limit < card.ability.extra.thresh then
        card.joker_display_values.mult = card.ability.extra.mult_per * (card.ability.extra.thresh - G.hand.config.card_limit)
      else
        card.joker_display_values.mult = 0
      end
    end,
  }
end

return joker
