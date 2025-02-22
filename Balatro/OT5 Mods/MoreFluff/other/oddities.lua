function init()
  SMODS.Consumable({
    object_type = "Consumable",
    set = "Oddity",
    name = "odd-jimbophone",
    key = "jimbophone",
    pos = { x = 1, y = 0 },
    config = {
      val = 1,
    },
    cost = 3,
    rarity = 1,
    atlas = "mf_oddities",
    unlocked = true,
    discovered = true,
    can_use = function(self, card)
      return true
    end,
    use = function(self, card, area, copier)
      for i = 1, card.ability.val do
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
          play_sound('timpani')
          local n_card = create_card(nil,G.jokers, nil, nil, nil, nil, 'j_joker', 'sup')
          n_card:add_to_deck()
          G.jokers:emplace(n_card)
          card:juice_up(0.3, 0.5)
          return true end }))
      end
      delay(0.6)
    end,
    loc_vars = function(self, info_queue, card)
      return { vars = {card.ability.val} }
    end
  })
end

return init