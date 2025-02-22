local joker = {
  name = "Simplified Joker",
  config = {
    extra = {mult = 4}
  },
  pos = {x = 9, y = 0},
  rarity = 1,
  cost = 5,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Simplified Joker",
    text = {
      "All {C:blue}Common{} Jokers",
      "each give {C:mult}+#1#{} Mult",
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.mult }
    }
  end,
  calculate = function(self, card, context)
    if context.other_joker and context.other_joker.config.center.rarity == 1 and context.other_joker.ability.set == "Joker" then
      G.E_MANAGER:add_event(Event({
        func = function()
          context.other_joker:juice_up(0.5, 0.5)
          return true
        end
      })) 
      return {
        message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
        mult_mod = card.ability.extra.mult
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_simplified"] = {
    reminder_text = {
      { text = "(" },
      { ref_table = "card.joker_display_values", ref_value = "count",          colour = G.C.ORANGE },
      { text = "x" },
      { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.BLUE },
      { text = ")" },
    },
    calc_function = function(card)
      local count = 0
      if G.jokers then
        for _, joker_card in ipairs(G.jokers.cards) do
          if joker_card.config.center.rarity and joker_card.config.center.rarity == 1 then
            count = count + 1
          end
        end
      end
      card.joker_display_values.count = count
      card.joker_display_values.localized_text = localize("k_common")
    end,
    mod_function = function(card, mod_joker)
      return { mult = (card.config.center.rarity == 1 and mod_joker.ability.extra.mult * JokerDisplay.calculate_joker_triggers(mod_joker) or nil) }
    end
  }
end

return joker
