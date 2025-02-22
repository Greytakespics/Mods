local joker = {
  name = "Hyper Beam",
  config = {
    extra = 3
  },
  pos = {x = 6, y = 2},
  rarity = 2,
  cost = 8,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Hyper Beam",
    text = {
      "{X:red,C:white} X#1# {} Mult",
      "{C:attention}Lose all discards",
      "when {C:attention}Blind{} is selected"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra }
    }
  end,
  calculate = function(self, card, context)
    if context.setting_blind and not (context.blueprint_card or card).getting_sliced then
      G.E_MANAGER:add_event(Event({func = function()
        ease_discard(-G.GAME.current_round.discards_left, nil, true)
      return true end }))
    end
    if context.cardarea == G.jokers and not context.before and not context.after then
      return {
        message = localize{type='variable',key='a_xmult',vars={card.ability.extra}},
        Xmult_mod = card.ability.extra,
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_hugejoker"] = {
    text = {
      {
        border_nodes = {
          { text = "X" },
          { ref_table = "card.ability", ref_value = "extra", retrigger_type = "exp" },
        },
      }
    },
  }
end

return joker
