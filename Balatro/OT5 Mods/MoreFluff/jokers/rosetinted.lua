local joker = {
  name = "Rose-Tinted Glasses",
  config = {},
  pos = {x = 3, y = 1},
  rarity = 3,
  cost = 7,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Rose-Tinted Glasses",
    text = {
      "If {C:attention}first hand{} of round is",
      "a single {C:attention}2{}, destroy it and",
      "create a free {C:attention}Double Tag{}",
    }
  },
  loc_vars = function(self, info_queue, center)
    return {vars = { } }
  end,
  calculate = function(self, card, context)
    if context.destroying_card and not context.blueprint and #context.full_hand == 1 and context.full_hand[1]:get_id() == 2 and G.GAME.current_round.hands_played == 0 then
      G.E_MANAGER:add_event(Event({
        func = (function()
            add_tag(Tag('tag_double'))
            play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
            play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
            return true
        end)
      }))
      return true
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_rosetinted"] = { -- Sixth Sense
    text = {
      { text = "+" },
      { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" }
    },
    reminder_text = {
      { text = "(2)", scale = 0.35 },
    },
    calc_function = function(card)
      local _, _, scoring_hand = JokerDisplay.evaluate_hand()
      local sixth_sense_eval = #scoring_hand == 1 and scoring_hand[1]:get_id() == 2
      card.joker_display_values.active = G.GAME and G.GAME.current_round.hands_played == 0
      card.joker_display_values.count = (card.joker_display_values.active and sixth_sense_eval) and 1 or 0
    end
  }
end

return joker
