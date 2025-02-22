local joker = {
  name = "Blood Pact",
  config = {
    extra = 5
  },
  pos = {x = 2, y = 3},
  rarity = 3,
  cost = 9,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Blood Pact",
    text = {
      "{X:mult,C:white} X#1# {} Mult",
      "Destroyed if you play",
      "a non-{C:hearts}Hearts{} card"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after and context.full_hand ~= nil then
      local non_hearts = 0
      for k, v in ipairs(context.full_hand) do
        if not v:is_suit('Hearts', nil, true) then
          non_hearts = non_hearts + 1
        end
      end
      if non_hearts > 0 then
        if not context.blueprint then
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
                    cardcard = nil
                  return true; end})) 
              return true
            end
          })) 
          card.gone = true
          return {
            message = localize('k_extinct_ex')
          }
        end
      else
        return {
          message = localize{type='variable',key='a_xmult',vars={card.ability.extra}},
          Xmult_mod = card.ability.extra,
        }
      end
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_bloodpact"] = {
    text = {
      {
        border_nodes = {
          { text = "X" },
          { ref_table = "card.ability", ref_value = "extra", retrigger_type = "exp" },
        },
      }
    },
    reminder_text = {
      {
        ref_table = "card.joker_display_values", ref_value = "reminder_text",
        colour = G.C.RED
      }
    },
    calc_function = function(card)
      card.joker_display_values.reminder_text = localize("k_display_only_hearts")
    end,
  }
end

return joker
