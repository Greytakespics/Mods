local joker = {
  name = "Jimbo J Joker",
  config = {
    extra = {x_mult = 1.25}
  },
  pos = {x = 3, y = 0},
  rarity = 1,
  cost = 4,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Jimbo J. Joker",
    text = {
      "{X:mult,C:white} X#1# {} Mult"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.x_mult }
    }
  end,
  calculate = function(self, card, context)
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
  JokerDisplay.Definitions["j_mf_jimbojjoker"] = {
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
