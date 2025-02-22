local joker = {
  name = "Huge Joker",
  config = {
    h_size = -2,
    extra = {
      x_mult = 3
    }
  },
  pos = {x = 3, y = 3},
  rarity = 3,
  cost = 8,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Huge Joker",
    text = {
      "{X:red,C:white} X#1# {} Mult",
      "{C:attention}#2#{} hand size"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.x_mult, 
      center.ability.h_size < 0 and center.ability.h_size or "+" .. center.ability.h_size, }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after then
      return {
        message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
        Xmult_mod = card.ability.extra.x_mult,
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
          { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "exp" },
        },
      }
    },
  }
end

return joker
