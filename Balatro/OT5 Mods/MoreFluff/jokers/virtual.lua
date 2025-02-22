local joker = {
  name = "Virtual Joker",
  config = {
    extra = 3
  },
  pos = {x = 1, y = 3},
  rarity = 2,
  cost = 7,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Virtual Joker",
    text = {
      "{X:red,C:white} X#1# {} Mult",
      "Flips and shuffles all",
      "Joker cards when",
      "blind is selected"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra }
    }
  end,
  calculate = function(self, card, context)
    if context.setting_blind and not self.getting_sliced and not (context.blueprint_card or card).getting_sliced and not context.blueprint then
      if #G.jokers.cards > 1 then 
        G.jokers:unhighlight_all()
        for k, v in ipairs(G.jokers.cards) do
          v:flip()
        end
        G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.2, func = function() 
          G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 0.85);return true end })) 
          delay(0.15)
          G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 1.15);return true end })) 
          delay(0.15)
          G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 1);return true end })) 
          delay(0.5)
        return true end })) 
      end
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
  JokerDisplay.Definitions["j_mf_virtual"] = {
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
