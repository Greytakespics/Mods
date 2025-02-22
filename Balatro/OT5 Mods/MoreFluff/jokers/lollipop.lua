local joker = {
  name = "Basepaul Card",
  config = { Xmult = 1.75, extra = 0.15 },
  pos = {x = 7, y = 1},
  rarity = 1,
  cost = 6,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = false,
  perishable_compat = true,
  loc_txt = {
    name = "Lollipop",
    text = {
      "{X:mult,C:white} X#1# {} Mult",
      "{X:mult,C:white} -X#2# {} Mult per",
      "round played"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.x_mult, center.ability.extra }
    }
  end,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition and not context.blueprint and not context.retrigger_joker then
      if card.ability.x_mult - card.ability.extra <= 1.01 then 
        G.E_MANAGER:add_event(Event({
          func = function()
            play_sound('tarot1')
            card.T.r = -0.2
            card:juice_up(0.3, 0.4)
            card.states.drag.is = true
            card.children.center.pinch.x = true
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
              func = function()
                  G.jokers:remove_card(card)
                  card:remove()
                  card = nil
                return true; end})) 
            return true
          end
        })) 
        return {
          message = localize('k_eaten_ex'),
          colour = G.C.FILTER
        }
      else
        card.ability.x_mult = card.ability.x_mult - card.ability.extra
        return {
          message = localize{type='variable',key='a_xmult_minus',vars={card.ability.extra}},
          colour = G.C.RED
        }
      end
    elseif context.cardarea == G.jokers and not context.before and not context.after then
        return {
          message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
          Xmult_mod = card.ability.x_mult,
        }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_lollipop"] = {
    text = {
      {
        border_nodes = {
          { text = "X" },
          { ref_table = "card.ability", ref_value = "x_mult", retrigger_type = "exp" },
        },
      }
    }
  }
end

return joker
