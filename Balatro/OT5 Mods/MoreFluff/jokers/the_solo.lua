local joker = {
  name = "The Solo",
  config = {
    extra = {x_mult = 1, x_mult_gain = 0.1}
  },
  pos = {x = 8, y = 0},
  rarity = 3,
  cost = 7,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "The Solo",
    text = {
      "Gains {X:mult,C:white} X#2# {} Mult if played",
      "hand has only {C:attention}1{} card",
      "{C:inactive}(Currently {X:mult,C:white} X#1# {C:inactive} Mult)",
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.x_mult, center.ability.extra.x_mult_gain }
    }
  end,
  calculate = function(self, card, context)
    if context.before and context.full_hand ~= nil and context.cardarea == G.jokers and not context.blueprint then
      if #context.full_hand == 1 then
        card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
        return {
          message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
        }
      end
    end
    if context.cardarea == G.jokers and not context.before and not context.after then
      return {
        message = localize({type='variable',key='a_xmult',vars={
          card.ability.extra.x_mult
        }}),
        Xmult_mod = card.ability.extra.x_mult,
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_the_solo"] = {
    text = {
      {
        border_nodes = {
          { text = "X" },
          { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "exp" },
        },
      }
    },
  }
end

return joker
