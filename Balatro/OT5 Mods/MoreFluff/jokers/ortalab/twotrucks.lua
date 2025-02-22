local joker = {
  name = "Two Trucks",
  config = {
    extra = {
      xchips_gain = 0.1,
      xchips = 1
    }
  },
  pos = {x = 0, y = 0},
  rarity = 3,
  cost = 10,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_txt = {
    name = "Two Trucks",
    text = {
      "Gains {X:chips,C:white} X#1# {} Chips for",
      "each unique pair in played hand",
      "{C:inactive}(Currently {X:chips,C:white} X#2# {} {C:inactive}Chips)",
    },
  },
  loc_vars = function(self, info_queue, center)
    return {
      vars = { center.ability.extra.xchips_gain, center.ability.extra.xchips }
    }
  end,
  calculate = function(self, card, context)
    if not context.repetition and not context.other_joker and context.cardarea == G.jokers and context.before then
      local counts = {}
      local pair_count = 0
      for k, v in ipairs(context.full_hand) do
        if v.config.center_key == 'm_stone' or (v.config.center.no_rank) then goto continue end

        local rank = v:get_id()
        if counts[rank] == nil then
          counts[rank] = 0
        end

        counts[rank] = counts[rank] + 1
        if counts[rank] == 2 then
          pair_count = pair_count + 1
        end

        ::continue::
      end

      if pair_count > 0 then
        card.ability.extra.xchips = card.ability.extra.xchips + card.ability.extra.xchips_gain * pair_count
        return {
          message = localize('k_upgrade_ex'),
          card = card,
          colour = G.C.CHIPS
        }
      end
    end
    if context.cardarea == G.jokers and not context.before and not context.after then
      if card.ability.extra.x_chips ~= 1 then
        return {
          message = localize({ type = "variable", key = "a_xchips", vars = { card.ability.extra.xchips } }),
          Xchip_mod = card.ability.extra.xchips,
          colour = G.C.CHIPS,
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
