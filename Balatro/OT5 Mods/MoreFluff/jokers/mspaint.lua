local joker = {
  name = "MS Paint Joker",
  config = {
    h_size = 0,
    extra = 4,
  },
  pos = {x = 2, y = 1},
  rarity = 1,
  cost = 5,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "MS Paint Joker",
    text = {
      "{C:attention}+#1#{} hand size",
      "for the first hand",
      "of each blind"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra }
    }
  end,
  calculate = function(self, card, context)
    if context.first_hand_drawn and not context.blueprint and card.ability.h_size == 0 then
      card.ability.h_size = card.ability.h_size + card.ability.extra
      G.hand:change_size(card.ability.extra)
    end
    if context.after and not context.blueprint and card.ability.h_size ~= 0 and context.cardarea == G.jokers then
      G.hand:change_size(-card.ability.extra)
      card.ability.h_size = 0
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_mspaint"] = {
    text = {
      { text = "+", colour = G.C.ORANGE },
      { ref_table = "card.ability", ref_value = "extra", colour = G.C.ORANGE },
      { text = " " },
      {
        ref_table = "card.joker_display_values", ref_value = "hand_size",
      },
    },
    reminder_text = {
      {
        ref_table = "card.joker_display_values", ref_value = "reminder_text",
      },
    },
    calc_function = function(card)
      card.joker_display_values.reminder_text = localize("k_display_first_hand")
      card.joker_display_values.hand_size = localize("k_display_hand_size")
    end,
  }
end

return joker
