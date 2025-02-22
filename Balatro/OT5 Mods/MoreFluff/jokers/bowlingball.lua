
local joker = {
  name = "Bowling Ball",
  config = {
    extra = {chips=60, mult=10}
  },
  pos = {x = 9, y = 2},
  rarity = 3,
  cost = 8,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Bowling Ball",
    text = {
      "Played {C:attention}3s{}",
      "give {C:chips}+#1#{} Chips",
      "and {C:mult}+#2#{} Mult",
      "when scored"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.chips, center.ability.extra.mult }
    }
  end,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
      if context.other_card:get_id() == 3 then
        return {
          chips = card.ability.extra.chips,
          mult = card.ability.extra.mult,
          card = card
        }
      end
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_bowlingball"] = {
    text = {
      { text = "+", colour = G.C.CHIPS },
      { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult", colour = G.C.CHIPS },
      { text = ", ", colour = G.C.INACTIVE },
      { text = "+", colour = G.C.MULT },
      { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult", colour = G.C.MULT },
    },
    reminder_text = {
      { text = "(3)" },
    },
    calc_function = function(card)
      local mult = 0
      local chips = 0
      local text, _, scoring_hand = JokerDisplay.evaluate_hand()
      if text ~= 'Unknown' then
        for _, scoring_card in pairs(scoring_hand) do
          if scoring_card:get_id() and scoring_card:get_id() == 3 then
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
    end,
  }
end

return joker
