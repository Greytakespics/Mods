
local joker = {
  name = "Pixel Joker",
  config = {
    extra = {x_mult = 1.5}
  },
  pos = {x = 9, y = 3},
  rarity = 3,
  cost = 8,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Pixel Joker",
    text = {
      "Played {C:attention}Aces{},",
      "{C:attention}4s{} and {C:attention}9s{} each give",
      "{X:mult,C:white} X#1# {} Mult when scored"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.x_mult }
    }
  end,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
      if context.other_card:get_id() == 14 or context.other_card:get_id() == 4 or context.other_card:get_id() == 9 then
        return {
          x_mult = card.ability.extra.x_mult,
          colour = G.C.RED,
          card = card
        }
      end
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_pixeljoker"] = {
    text = {
      {
        border_nodes = {
          { text = "X" },
          { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
        },
      },
    },
    reminder_text = {
      { text = "(1, 4, 9)" },
    },
    calc_function = function(card)
      local mult = 1
      local text, _, scoring_hand = JokerDisplay.evaluate_hand()
      if text ~= 'Unknown' then
        for _, scoring_card in pairs(scoring_hand) do
          if scoring_card:get_id() and (scoring_card:get_id() == 14 or scoring_card:get_id() == 4 or scoring_card:get_id() == 9) then
            mult = mult * card.ability.extra.x_mult ^ JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
          end
        end
      end
      card.joker_display_values.x_mult = mult
    end,
  }
end

return joker
