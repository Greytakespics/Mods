
local joker = {
  name = "Dramatic Entrance",
  config = {
    extra = 2
  },
  pos = {x = 5, y = 2},
  rarity = 2,
  cost = 8,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Blade Dance",
    text = {
      "Adds {C:attention}#1#{} temporary",
      "{C:attention}Steel Cards{}",
      "to your deck when",
      "blind is selected"
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra }
    }
  end,
  calculate = function(self, card, context)
    if context.setting_blind and not card.getting_sliced and not (context.blueprint_card or card).getting_sliced then
      if not G.bladedance_temp_ids then
        G.bladedance_temp_ids = {}
      end
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.7,
        func = function() 
          local cards = {}
          for i=1, card.ability.extra do
            cards[i] = true
            local _suit, _rank = nil, nil
            _rank = pseudorandom_element(SMODS.Ranks, pseudoseed('bladedance_create')).card_key
            _suit = pseudorandom_element(SMODS.Suits, pseudoseed('bladedance_create')).card_key
            local card = create_playing_card({front = G.P_CARDS[_suit..'_'.._rank], center = G.P_CENTERS.m_steel
            }, G.hand, nil, i ~= 1, {G.C.SECONDARY_SET.Spectral})
            table.insert(G.bladedance_temp_ids, card.unique_val)
          end
          playing_card_joker_effects(cards)
          return true end }))
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_bladedance"] = {
    text = {
      {
        ref_table = "card.ability", ref_value = "extra", retrigger_type = "mult"
      },
      { text = " " },
      {
        ref_table = "card.joker_display_values", ref_value = "steel_cards",
        colour = G.C.ORANGE,
      }
    },
    reminder_text = {
      {
        ref_table = "card.joker_display_values", ref_value = "reminder_text"
      }
    },
    calc_function = function(card)
      card.joker_display_values.steel_cards = localize("k_display_steel_cards")
      card.joker_display_values.reminder_text = localize("k_display_per_round")
    end,
  }
end


return joker
