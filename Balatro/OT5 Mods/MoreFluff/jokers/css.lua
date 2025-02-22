if not mf_config["Colour Cards"] then
  return nil
end
local joker = {
  name = "CSS",
  config = {},
  pos = {x = 3, y = 4},
  rarity = 2,
  cost = 6,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "CSS",
    text = {
      "Create a random {C:colourcard}Colour",
      "card when played hand",
      "contains a {C:attention}Flush"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit and context.poker_hands then
      if next(context.poker_hands["Flush"]) then
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
          func = (function()
            G.E_MANAGER:add_event(Event({
              func = function() 
                local card = create_card('Colour',G.consumeables, nil, nil, nil, nil, nil, 'css')
                card:add_to_deck()
                G.consumeables:emplace(card)
                G.GAME.consumeable_buffer = 0
                return true
              end}))   
              card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_colour'), colour = G.C.PURPLE})                       
            return true
          end)}))
      end
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_css"] = {
    text = {
      {
        ref_table = "card.joker_display_values", ref_value = "colour",
      }
    },
    reminder_text = {
      { text = "(" },
      { ref_table = "card.joker_display_values", ref_value = "hand" },
      { text = ")" },
    },
    calc_function = function(card)
      card.joker_display_values.colour = localize("k_plus_colour")
      card.joker_display_values.hand = localize("Flush", 'poker_hands')
    end,
  }
end

return joker
