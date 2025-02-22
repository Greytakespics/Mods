
local joker = {
  name = "Clownfish",
  config = {
    extra = {chips=15, mult=4}
  },
  pos = {x = 0, y = 3},
  rarity = 1,
  cost = 6,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Clownfish",
    text = {
      "{C:attention}Enhanced{} cards",
      "score {C:chips}+#1#{} more Chips",
      "and {C:mult}+#2#{} more Mult",
      "when scored"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.chips, center.ability.extra.mult }
    }
  end,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card.ability.name ~= "Default Base" then
      return {
        chips = card.ability.extra.chips,
        mult = card.ability.extra.mult,
        card = card
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_clownfish"] = {
    text = {
      { text = "+", colour = G.C.CHIPS },
      { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult", colour = G.C.CHIPS },
      { text = ", ", colour = G.C.INACTIVE },
      { text = "+", colour = G.C.MULT },
      { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult", colour = G.C.MULT },
    },
    reminder_text = {
      { ref_table = "card.joker_display_values", ref_value = "reminder_text", color = G.C.INACTIVE },
    },
    calc_function = function(card)
      local mult = 0
      local chips = 0
      local text, _, scoring_hand = JokerDisplay.evaluate_hand()
      if text ~= 'Unknown' then
        for _, scoring_card in pairs(scoring_hand) do
          if scoring_card.ability.name ~= "Default Base" then
            mult = mult +
              card.ability.extra.mult *
              JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
            chips = chips +
              card.ability.extra.chips *
              JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
          end
        end
      end
      card.joker_display_values.mult = mult
      card.joker_display_values.chips = chips
      card.joker_display_values.reminder_text = localize("k_display_enhanced")
    end,
  }
end

return joker
