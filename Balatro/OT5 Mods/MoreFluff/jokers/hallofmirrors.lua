local joker = {
  name = "Hall of Mirrors",
  config = {
    h_size = 0,
    extra = 2,
  },
  pos = {x = 1, y = 4},
  rarity = 2,
  cost = 6,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Hall of Mirrors",
    text = {
      "{C:attention}+#2#{} hand size for",
      "each {C:attention}6{} scored in",
      "the current round",
      "{C:inactive}(Currently {C:attention}+#1#{C:inactive} cards)"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.h_size, center.ability.extra }
    }
  end,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card:get_id() == 6 and not context.blueprint then
      card.ability.h_size = card.ability.h_size + card.ability.extra
      G.hand:change_size(card.ability.extra)
      
      return {
        extra = {focus = card, message = localize('k_upgrade_ex')},
        card = card,
        colour = G.C.MONEY
      }
    end
    if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
      G.hand:change_size(-card.ability.h_size)
      card.ability.h_size = 0
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_hallofmirrors"] = {
    text = {
      { text = "+", colour = G.C.ORANGE },
      { ref_table = "card.ability", ref_value = "h_size", colour = G.C.ORANGE },
    },
    reminder_text = {
      { text = "(6)" },
    },
  }
end

return joker
