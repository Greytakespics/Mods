if not mf_config["Colour Cards"] then
  return nil
end
local joker = {
  name = "Rainbow Joker",
  config = {
    extra = 1.5
  },
  pos = {x = 5, y = 3},
  rarity = 3,
  cost = 6,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Rainbow Joker",
    text = {
      "{C:colourcard}Colour{} cards give",
      "{X:mult,C:white} X#1#{} Mult"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra }
    }
  end,
  calculate = function(self, card, context)
    if context.other_joker and context.other_joker.ability.set == "Colour" then
      G.E_MANAGER:add_event(Event({
        func = function()
          context.other_joker:juice_up(0.5, 0.5)
          return true
        end
      })) 
      return {
        message = localize{type='variable',key='a_xmult',vars={card.ability.extra}},
        Xmult_mod = card.ability.extra
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_rainbowjoker"] = {
    reminder_text = {
      { text = "(" },
      { ref_table = "card.joker_display_values", ref_value = "count",          colour = G.C.ORANGE },
      { text = "x" },
      { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.SECONDARY_SET.Colour },
      { text = ")" },
    },
    calc_function = function(card)
      local count = 0
      if G.jokers then
        for _, joker_card in ipairs(G.consumeables.cards) do
          if joker_card.ability.set == "Colour" then
            count = count + 1
          end
        end
      end
      card.joker_display_values.count = count
      card.joker_display_values.localized_text = localize("k_colour")
    end
  }
end

return joker
