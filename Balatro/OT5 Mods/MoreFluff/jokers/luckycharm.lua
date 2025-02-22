local joker = {
  name = "Lucky Charm",
  config = {
    extra = {mult_chance = 3, mult = 20, money_chance = 8, money = 20}
  },
  pos = {x = 8, y = 1},
  rarity = 1,
  cost = 6,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Lucky Charm",
    text = {
      "{C:green}#1# in #3#{} chance",
      "for {C:mult}+#2#{} Mult",
      "{C:green}#1# in #5#{} chance",
      "to win {C:money}$#4#",
      "at end of round"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = {G.GAME.probabilities.normal, center.ability.extra.mult, center.ability.extra.mult_chance, center.ability.extra.money, center.ability.extra.money_chance}
    }
  end,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
      if pseudorandom('lucky_charm_money') < G.GAME.probabilities.normal/card.ability.extra.money_chance then
        ease_dollars(card.ability.extra.money)
        return {
          message = localize('$')..card.ability.extra.money,
          colour = G.C.MONEY,
          delay = 0.45, 
          remove = true,
          card = self
        }
      end
    end
    
    if context.cardarea == G.jokers and not context.before and not context.after  then
      if pseudorandom('lucky_charm_mult') < G.GAME.probabilities.normal/card.ability.extra.mult_chance then
        return {
          message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
          mult_mod = card.ability.extra.mult
        }
      end
    end
  end
}

-- idk how to add this one

return joker
