if not mf_config["Colour Cards"] or not Cryptid then
  return nil
end

local joker = {
  name = "Colorem",
  config = {
    extra = { odds = 3 }
  },
  pos = {x = 6, y = 5},
  soul_pos = {x = 8, y = 5, extra = {x = 7, y = 5}},
  rarity = "cry_exotic",
  cost = 50,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Colorem",
    text = {
      "When a {C:colourcard}Colour{} card is used,",
      "{C:green}#1# in #2#{} chance to add a copy",
      "to your consumable area",
      "{C:inactive}(Must have room)",
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { (G.GAME and G.GAME.probabilities.normal or 1), (center and center.ability.extra.odds or 2) }
    }
  end,
  calculate = function(self, card, context)
		if
			context.using_consumeable
			and context.consumeable.ability.set == "Colour"
			and not context.consumeable.beginning_end
		then
			if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
				if pseudorandom("colorem") < G.GAME.probabilities.normal / card.ability.extra.odds then
					G.E_MANAGER:add_event(Event({
						func = function()
							local cards = copy_card(context.consumeable)
							cards:add_to_deck()
							G.consumeables:emplace(cards)
							return true
						end,
					}))
					card_eval_status_text(
						context.blueprint_cards or card,
						"extra",
						nil,
						nil,
						nil,
						{ message = localize("k_copied_ex") }
					)
				end
			end
		end
  end
}

return joker
