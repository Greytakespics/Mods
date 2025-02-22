
local joker = {
  name = "Dramatic Entrance",
  config = {
    extra = {chips=150}
  },
  pos = {x = 3, y = 2},
  rarity = 2,
  cost = 6,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Dramatic Entrance",
    text = {
      "{C:chips}+#1#{} Chips",
      "for the first hand",
      "of each round"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.chips }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after and G.GAME.current_round.hands_played == 0 then
      return {
        message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
        chip_mod = card.ability.extra.chips, 
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_dramaticentrance"] = {
    text = {
      { text = "+", colour = G.C.CHIPS },
      { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult", colour = G.C.CHIPS },
    },
    reminder_text = {
      {
        ref_table = "card.joker_display_values", ref_value = "reminder_text",
      },
    },
    calc_function = function(card)
      card.joker_display_values.reminder_text = localize("k_display_first_hand")
    end,
  }
end

return joker
