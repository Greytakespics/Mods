local joker = {
  name = "Bad Legal Defence",
  config = {},
  pos = {x = 7, y = 3},
  rarity = 2,
  cost = 6,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Bad Legal Defence",
    text = {
      "Create a {C:attention}Death{} {C:tarot}Tarot{}",
      "when {C:attention}Boss Blind{}",
      "is selected",
      "{C:inactive}(Must have room)"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { }
    }
  end,
  calculate = function(self, card, context)
    if context.setting_blind and context.blind.boss and not (context.blueprint_card or self).getting_sliced then
      if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
          trigger = 'before',
          delay = 0.0,
          func = (function()
              local n_card = create_card(nil,G.consumeables, nil, nil, nil, nil, 'c_death', 'sup')
              n_card:add_to_deck()
              G.consumeables:emplace(n_card)
              G.GAME.consumeable_buffer = 0
            return true
          end)}))
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize("k_death_caps"), colour = G.C.PURPLE})
      end
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_clipart"] = {
    text = {
      {
        ref_table = "card.joker_display_values", ref_value = "colour",
      }
    },
    reminder_text = {
      {
        ref_table = "card.joker_display_values", ref_value = "reminder_text"
      }
    },
    calc_function = function(card)
      card.joker_display_values.colour = localize("k_plus_colour")
      card.joker_display_values.reminder_text = localize("k_display_per_round")
    end,
  }
end

return joker
