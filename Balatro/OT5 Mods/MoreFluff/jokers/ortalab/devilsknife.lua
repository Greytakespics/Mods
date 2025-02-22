if not mf_config["Colour Cards"] then
  return nil
end
local joker = {
  name = "Devilsknife",
  config = { },
  pos = {x = 0, y = 0},
  rarity = 2,
  cost = 6,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = false,
  perishable_compat = true,
  loc_txt = {
    name = "Devilsknife",
    text = {
      "Creates a {C:colourcard}Blue{} and",
      "a {C:colourcard}Lilac{} {C:colourcard}Colour{} card",
      "when sold",
      "{C:inactive}(Must have room)"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { }
    }
  end,
  calculate = function(self, card, context)
    if context.selling_self then
      if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
          func = (function()
            G.E_MANAGER:add_event(Event({
              func = function() 
                local n_card = create_card('Colour',G.consumeables, nil, nil, nil, nil, 'c_mf_blue', nil)
                n_card:add_to_deck()
                G.consumeables:emplace(n_card)
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                return true
              end}))                   
            return true
          end)}))
        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_colour'), colour = G.C.PURPLE})
      end
      if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
          func = (function()
            G.E_MANAGER:add_event(Event({
              func = function() 
                local n_card = create_card('Colour',G.consumeables, nil, nil, nil, nil, 'c_mf_lilac', nil)
                n_card:add_to_deck()
                G.consumeables:emplace(n_card)
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                return true
              end}))                   
            return true
          end)}))
        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_colour'), colour = G.C.PURPLE})
      end
    end
  end
}

if JokerDisplay then
end

return joker
