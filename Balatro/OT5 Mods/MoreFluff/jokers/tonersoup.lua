local joker = {
  name = "I Sip Toner Soup",
  config = {},
  pos = {x = 0, y = 4},
  rarity = 2,
  cost = 8,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = false,
  perishable_compat = true,
  loc_txt = {
    name = "I Sip Toner Soup",
    text = {
      "Create a {C:tarot}Tarot{} card",
      "when a hand is played",
      "Destroyed when blind",
      "is defeated",
      "{C:inactive}(Must have room)"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before then
      if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        local card_type = 'Tarot'
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
          trigger = 'before',
          delay = 0.0,
          func = (function()
              local n_card = create_card(card_type,G.consumeables, nil, nil, nil, nil, nil, 'sup')
              n_card:add_to_deck()
              G.consumeables:emplace(n_card)
              G.GAME.consumeable_buffer = 0
            return true
          end)}))
      end
    end
    if context.end_of_round and not context.individual and not context.repetition  and not context.blueprint then
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
        message = localize('k_drank_ex'),
        colour = G.C.FILTER
      }
    end
  end
}

return joker
