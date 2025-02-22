local joker = {
  name = "Philosophical Joker",
  config = {
    extra = 1
  },
  pos = {x = 4, y = 0},
  rarity = 1,
  cost = 1,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  loc_txt = {
    name = "Philosophical Joker",
    text = {
      "{C:dark_edition}+#1#{} Joker Slot"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra }
    }
  end,
	add_to_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra
	end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_philosophical"] = {
    text = {
      { text = "+", colour = G.C.DARK_EDITION },
      { ref_table = "card.ability", ref_value = "extra", colour = G.C.DARK_EDITION },
      { text = " " },
      {
        ref_table = "card.joker_display_values", ref_value = "joker_slot",
      },
    },
    calc_function = function(card)
      card.joker_display_values.joker_slot = localize("k_display_joker_slot")
    end,
  }
end

return joker
