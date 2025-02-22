local joker = {
  name = "Treasure Map",
  config = {
    extra = {
      c_rounds = 0,
      rounds = 2,
      money = 13,
    }
  },
  pos = {x = 8, y = 3},
  rarity = 1,
  cost = 4,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = false,
  perishable_compat = true,
  loc_txt = {
    name = "Treasure Map",
    text = {
      "After {C:attention}#2#{} rounds,",
      "sell this card to",
      "earn {C:money}$#3#{}",
      "{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2#)"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {vars = { center.ability.extra.c_rounds, center.ability.extra.rounds, center.ability.extra.money } }
  end,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition  and not context.blueprint then
      card.ability.extra.c_rounds = card.ability.extra.c_rounds + 1
      if card.ability.extra.c_rounds >= card.ability.extra.rounds and (card.ability.extra.c_rounds - 1) < card.ability.extra.rounds then 
        local eval = function(card) return not card.REMOVED end
        juice_card_until(card, eval, true)
      end
      return {
        message = (card.ability.extra.c_rounds < card.ability.extra.rounds) and (card.ability.extra.c_rounds..'/'..card.ability.extra.rounds) or localize('k_active_ex'),
        colour = G.C.FILTER
      }
    end
    if context.selling_self and (card.ability.extra.c_rounds >= card.ability.extra.rounds) and not context.blueprint then
      local eval = function(card) return (card.ability.loyalty_remaining == 0) and not G.RESET_JIGGLES end
        juice_card_until(card, eval, true)
      ease_dollars(card.ability.extra.money)
      return {
        message = localize('$')..card.ability.extra.money,
        colour = G.C.MONEY,
        card = card
      }
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_treasuremap"] = {
    reminder_text = {
      { text = "(" },
      { ref_table = "card.ability.extra", ref_value = "c_rounds" },
      { text = "/" },
      { ref_table = "card.ability.extra", ref_value = "rounds" },
      { text = ")" },
    }
  }
end

return joker
