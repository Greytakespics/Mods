local joker = {
  name = "Card Buffer Advanced",
  config = {
    cba = true
  },
  pos = {x = 9, y = 1},
  rarity = 3,
  cost = 10,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Card Buffer Advanced",
    text = {
      "{C:attention}Retrigger{} your first",
      "{C:dark_edition}Editioned{} Joker",
      "{C:inactive}(CBA excluded){}"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { }
    }
  end,
  calculate = function(self, card, context)
		if context.retrigger_joker_check and not context.retrigger_joker and context.other_card ~= self then
      retrigger_card = nil
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i].edition then
          retrigger_card = G.jokers.cards[i]
          break
        end
			end
      if retrigger_card == context.other_card then
        return {
          message = localize('k_again_ex'),
          repetitions = 1,
          card = card
        }
      end
		end
  end
}

if JokerDisplay then
	JokerDisplay.Definitions["j_mf_cba"] = {
		text = {
			{ text = "x" },
			{ ref_table = "card.joker_display_values", ref_value = "num_retriggers" },
		},
		calc_function = function(card)
			card.joker_display_values.num_retriggers = 1
		end,
		retrigger_joker_function = function(card, retrigger_joker)
      retrigger_card = nil
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i].edition then
          retrigger_card = G.jokers.cards[i]
          break
        end
			end
			return (card == retrigger_card) and 1 or 0
		end,
  }
end

return joker
