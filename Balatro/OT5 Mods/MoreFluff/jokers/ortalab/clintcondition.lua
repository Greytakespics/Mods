local joker = {
  name = "Clint Condition",
  config = {
    extra = {x_chips = 1.33}
  },
  pos = {x = 1, y = 0},
  rarity = 1,
  cost = 5,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Clint Condition",
    text = {
      "{X:chips,C:white} X#1# {} Chips. {X:chips,C:white} X#2# {} Chips",
      "instead for {C:chips}Clint{}",
      "{C:inactive}(Who's Clint?)"
    }
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.x_chips, center.ability.extra.x_chips * 10 }
    }
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and not context.before and not context.after then
      if string.find(string.lower(G.PROFILES[G.SETTINGS.profile].name), "clint") then
        check_for_unlock({type = 'mf_trigger_paul'})
        return {
          message = localize({ type = "variable", key = "a_xchips", vars = { card.ability.extra.x_chips * 10 } }),
          Xchip_mod = card.ability.extra.x_chips * 10,
          colour = G.C.CHIPS,
        }
      else
        return {
          message = localize({ type = "variable", key = "a_xchips", vars = { card.ability.extra.x_chips } }),
          Xchip_mod = card.ability.extra.x_chips,
          colour = G.C.CHIPS,
        }
      end
    end
  end
}

if JokerDisplay then
  JokerDisplay.Definitions["j_mf_basepaul_card"] = {
    text = {
      {
        border_nodes = {
          { text = "X" },
          { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
        },
      }
    },
    reminder_text = {
      {
        ref_table = "card.joker_display_values", ref_value = "inactive_text",
        colour = G.C.GRAY,
      },
      {
        ref_table = "card.joker_display_values", ref_value = "active_text",
        colour = G.C.RED,
      }
    },
    calc_function = function(card)
      if string.find(string.lower(G.PROFILES[G.SETTINGS.profile].name), "paul") then
        card.joker_display_values.x_mult = card.ability.extra.x_mult * 10
        card.joker_display_values.inactive_text = ""
        card.joker_display_values.active_text = localize("k_display_for_paul_ex")
      else
        card.joker_display_values.x_mult = card.ability.extra.x_mult
        card.joker_display_values.inactive_text = localize("k_display_for_paul")
        card.joker_display_values.active_text = ""
      end
    end,
  }
end

return joker
