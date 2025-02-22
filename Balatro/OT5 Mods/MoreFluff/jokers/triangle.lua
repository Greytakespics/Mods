local joker = {
  name = "Triangle",
  config = {
    extra = {
      x_mult = 3,
    }
  },
  pos = {x = 9, y = 4},
  soul_pos = {x = 9, y = 5},
  drama = {x = 5, y = 5},
  rarity = 4,
  cost = 20,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Triangle",
    text = {
      "Played cards each give",
      "{X:mult,C:white} X#1# {} Mult when scored",
      "if played hand is",
      "a {C:attention}Three of a Kind"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.x_mult }
    }
  end,
  calculate = function(self, card, context)
    local text, disp_text, poker_hands, scoring_hand, non_loc_disp_text = G.FUNCS.get_poker_hand_info(G.play.cards)
    if context.individual and context.cardarea == G.play then
      if non_loc_disp_text == "Three of a Kind" then
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
  JokerDisplay.Definitions["j_mf_triangle"] = {
    text = {
      {
        border_nodes = {
          { text = "X" },
          { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
        },
      },
    },
    reminder_text = {
      { text = "(" },
      { ref_table = "card.joker_display_values", ref_value = "hand" },
      { text = ")" },
    },
    calc_function = function(card)
      local mult = 1
      local text, _, scoring_hand = JokerDisplay.evaluate_hand()
      local _, _, _, _, non_loc_disp_text = G.FUNCS.get_poker_hand_info(scoring_hand)
      if non_loc_disp_text == "Three of a Kind" then
        if old_text ~= 'Unknown' then
          for _, scoring_card in pairs(scoring_hand) do
            mult = mult * card.ability.extra.x_mult ^ JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
          end
        end
      end
      card.joker_display_values.x_mult = mult
      card.joker_display_values.hand = localize("Three of a Kind", 'poker_hands')
    end,
  }
end

return joker
