local joker = {
  name = "Golden Carrot",
  config = {
    extra = { gain = 10, loss = 1 }
  },
  pos = {x = 6, y = 0},
  rarity = 2,
  cost = 4,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = false,
  perishable_compat = true,
  loc_txt = {
    name = "Golden Carrot",
    text = {
      "Earn {C:money}$#1#{} at",
      "end of round",
      "{C:money}-$#2#{} given",
      "per hand played"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.gain, center.ability.extra.loss }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.after and not context.blueprint and not card.gone then
      if card.ability.extra.gain - card.ability.extra.loss <= 0 then 
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card.T.r = -0.2
                card:juice_up(0.3, 0.4)
                card.states.drag.is = true
                card.children.center.pinch.x = true
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                    func = function()
                            G.jokers:remove_card(self)
                            card:remove()
                            card = nil
                        return true; end})) 
                return true
            end
        })) 
        return {
            message = localize('k_eaten_ex'),
            colour = G.C.MONEY
        }
      else
        card.ability.extra.gain = card.ability.extra.gain - card.ability.extra.loss
        return {
            message = "$"..card.ability.extra.gain,
            colour = G.C.MONEY
        }
      end
    end
  end,
  calc_dollar_bonus = function(self, card)
    local bonus = math.max(0, card.ability.extra.gain)
    if bonus > 0 then return bonus end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_goldencarrot"] = {
    text = {
      { text = "$", colour = G.C.MONEY },
      { ref_table = "card.ability.extra", ref_value = "gain", retrigger_type = "mult", colour = G.C.MONEY  },
    },
    reminder_text = {
      { text = "-$", colour = G.C.MONEY },
      { ref_table = "card.ability.extra", ref_value = "loss", retrigger_type = "mult", colour = G.C.MONEY },
      { text = " ", colour = G.C.MONEY },
      { ref_table = "card.joker_display_values", ref_value = "per_hand" },
    },
    calc_function = function(card)
      card.joker_display_values.per_hand = localize("k_display_per_hand")
    end,
  }
end

return joker
