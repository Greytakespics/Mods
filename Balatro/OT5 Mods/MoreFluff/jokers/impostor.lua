local joker = {
  name = "Impostor",
  config = {
    extra = {x_mult = 3, check = 0}
  },
  pos = {x = 0, y = 2},
  rarity = 2,
  cost = 7,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Impostor",
    text = {
      "{X:mult,C:white} X#1# {} Mult if the",
      "played hand has",
      "exactly one {C:red}red{} card"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.x_mult }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before and not context.blueprint then
      local red_suits = 0
      for k, v in ipairs(context.full_hand) do
        if v:is_suit('Hearts', nil, true) or v:is_suit('Diamonds', nil, true) then
          red_suits = red_suits + 1
        end
      end
      card.ability.extra.check = red_suits
    end
    if context.cardarea == G.jokers and not context.before and not context.after then
      if card.ability.extra.check == 1 then
        return {
          message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
          Xmult_mod = card.ability.extra.x_mult,
        }
      end
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_impostor"] = {
    text = {
      {
        border_nodes = {
          { text = "X" },
          { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "exp" },
        },
      }
    },
    reminder_text = {
      {
        ref_table = "card.joker_display_values", ref_value = "reminder_text",
      }
    },
    calc_function = function(card)
      card.joker_display_values.reminder_text = localize("k_display_one_red_card")
    end,
  }
end

return joker
