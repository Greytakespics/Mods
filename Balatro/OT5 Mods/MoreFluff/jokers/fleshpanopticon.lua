if not Cryptid then
  return nil
end
local joker = {
  name = "Flesh Panopticon",
  config = {
    extra = {boss_size = 20}
  },
  pos = {x = 2, y = 4},
  rarity = "cry_epic",
  cost = 15,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = false,
  perishable_compat = true,
  loc_txt = {
    name = "Flesh Panopticon",
    text = {
      "{C:red}X#1#{} {C:attention}Boss Blind{} size",
      "When {C:attention}Boss Blind{} is defeated,",
      "{C:red}self destructs{}, and creates",
      "a {C:dark_edition}Negative{} {C:spectral}Gateway{} card"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.boss_size }
    }
  end,
  calculate = function(self, card, context)
    if context.setting_blind and not context.blueprint and context.blind.boss and not card.getting_sliced then
      card.gone = false
      G.GAME.blind.chips = G.GAME.blind.chips * card.ability.extra.boss_size
      G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
      G.HUD_blind:recalculate(true)
      G.E_MANAGER:add_event(Event({func = function()
        G.E_MANAGER:add_event(Event({func = function()
          play_sound('timpani')
          delay(0.4)
          return true end }))
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Good luck!'})
      return true end }))
    end
    if context.end_of_round and not context.individual and not context.repetition and not context.blueprint and G.GAME.blind.boss and not card.gone then
      G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0.0,
        func = (function()
            local card = create_card(nil,G.consumeables, nil, nil, nil, nil, 'c_cry_gateway', 'sup')
            card:set_edition({negative = true}, true)
            card:add_to_deck()
            G.consumeables:emplace(card)
          return true
        end)}))
      if not card.ability.eternal then
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
      end
      card.gone = true
    end
  end
}

-- to code lurkers. uhhhh
-- this doesn't have a joker display. some vanilla ones don't either
-- i dunno if this is correct but oh well

return joker
