local joker = {
  name = "Blasphemy",
  config = {
    extra = {
      xmult = 4,
      hands_lost = 9999
    }
  },
  pos = {x = 7, y = 2},
  rarity = 2,
  cost = 5,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Blasphemy",
    text = {
      "{X:red,C:white} X#1# {} Mult",
      "{C:blue}-#2#{} hands",
      "when hand is played"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.xmult, center.ability.extra.hands_lost }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before and not context.blueprint then
      ease_hands_played(-G.GAME.current_round.hands_left, true)
    end
    if context.cardarea == G.jokers and not context.before and not context.after then
      return {
        message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}},
        Xmult_mod = card.ability.extra.xmult,
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_blasphemy"] = {
    text = {
      {
        border_nodes = {
          { text = "X" },
          { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
        },
      }
    },
    reminder_text = {
      {
        ref_table = "card.joker_display_values", ref_value = "reminder_text",
      }
    },
    calc_function = function(card)
      card.joker_display_values.reminder_text = localize("k_display_lose_all_hands")
    end,
  }
end

return joker
