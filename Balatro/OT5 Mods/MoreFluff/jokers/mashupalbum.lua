local joker = {
  name = "Mashup Album",
  config = {
    extra = {
      mult = 4,
      chips = 15,
      mult_gain = 4,
      chips_gain = 15,
    }
  },
  pos = {x = 8, y = 2},
  rarity = 3,
  cost = 8,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Mashup Album",
    text = {
      "Gains {C:mult}+#3#{} Mult if played",
      "hand contains a {C:hearts}red{} flush",
      "Gains {C:chips}+#4#{} Chips if played",
      "hand contains a {C:spades}black{} flush",
      "{C:inactive}(Currently {C:mult}+#1#{C:inactive} and {C:chips}+#2#{C:inactive})"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.mult, center.ability.extra.chips, center.ability.extra.mult_gain, center.ability.extra.chips_gain }
    }
  end,
  calculate = function(self, card, context)
    if not context.repetition and not context.other_joker and context.cardarea == G.jokers and context.before and next(context.poker_hands['Flush']) then
      local _, cards = next(context.poker_hands['Flush'])
      local h_card = cards[1]

      if h_card:is_suit("Hearts") or h_card:is_suit("Diamonds") then
        card.ability.extra.mult = card.ability.extra.mult + 4
        return {
          message = localize('k_upgrade_ex'),
          card = card,
          colour = G.C.RED
        }
      else
        card.ability.extra.chips = card.ability.extra.chips + 15
        return {
          message = localize('k_upgrade_ex'),
          card = card,
          colour = G.C.CHIPS
        }
      end
    end
    if context.cardarea == G.jokers and not context.before and not context.after then
      if card.ability.extra.mult > 0 and card.ability.extra.chips > 0 then
        hand_chips = mod_chips(hand_chips + card.ability.extra.chips)
        update_hand_text({delay = 0}, {chips = hand_chips})
        card_eval_status_text(card, 'extra', nil, nil, nil, {
          message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
          colour = G.C.CHIPS
        }) 
        return {
          message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
          mult_mod = card.ability.extra.mult,
        }
      elseif card.ability.extra.mult > 0 then
        return {
          message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
          mult_mod = card.ability.extra.mult,
        }
      elseif card.ability.extra.chips > 0 then
        return {
          message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
          chip_mod = card.ability.extra.chips,
        }
      end
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_mashupalbum"] = {
    text = {
      { text = "+", colour = G.C.CHIPS },
      { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult", colour = G.C.CHIPS },
      { text = ", ", colour = G.C.INACTIVE },
      { text = "+", colour = G.C.MULT },
      { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult", colour = G.C.MULT },
    },
  }
end

return joker
