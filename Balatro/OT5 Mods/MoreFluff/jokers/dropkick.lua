local joker = {
  name = "Dropkick",
  config = {
    extra = {
      hands = 1,
      current_triggers = 0,
    }
  },
  pos = {x = 4, y = 2},
  rarity = 2,
  cost = 8,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Dropkick",
    text = {
      "{C:blue}+#1#{} hand when hand",
      "contains a {C:attention}Straight"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.hands }
    }
  end,
  calculate = function(self, card, context)
    if context.setting_blind then
      card.ability.extra.current_triggers = 0
    end
    if context.after and context.cardarea == G.jokers and next(context.poker_hands['Straight']) and not context.blueprint then
      card.ability.extra.current_triggers = card.ability.extra.current_triggers + 1
      if card.ability.extra.current_triggers >= 5 then
        check_for_unlock({type = 'mf_dropkick_ten_hands'})
      end
      ease_hands_played(card.ability.extra.hands)
      card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+"..card.ability.extra.hands.." Hand"})
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_dropkick"] = {
    text = {
      { text = "+", colour = G.C.BLUE },
      { ref_table = "card.ability.extra", ref_value = "hands", retrigger_type = "mult", colour = G.C.BLUE },
      { text = " " },
      { ref_table = "card.joker_display_values", ref_value = "hands", colour = G.C.BLUE },
    },
    reminder_text = {
      {
        ref_table = "card.joker_display_values", ref_value = "reminder_text",
      },
    },
    calc_function = function(card)
      card.joker_display_values.reminder_text = localize("k_display_straight")
      card.joker_display_values.hands = localize("k_hud_hands")
    end,
  }
end

return joker
