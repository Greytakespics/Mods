--- STEAMODDED HEADER
--- MOD_NAME: Ace in the Hole
--- MOD_ID: AceInTheHole
--- MOD_AUTHOR: [Chamels and UnknownEternity]
--- MOD_DESCRIPTION: Create a special deck that only contains one Ace of each suit!

----------------------------------------------
------------MOD CODE -------------------------

local Backapply_to_runRef = Back.apply_to_run
function Back.apply_to_run(arg_56_0)
	Backapply_to_runRef(arg_56_0)

	if arg_56_0.effect.config.only_one_rank_aces then
        local card_id = arg_56_0.effect.config.only_one_rank_aces
        local suit_size = arg_56_0.effect.config.amount_per_suit_aces

        if suit_size < 1 then suit_size = 1 end

		G.E_MANAGER:add_event(Event({
			func = function()
                G.starting_deck_size = suit_size * 4

                local cards_by_suit = {
                    ["S"] = {},
                    ["H"] = {},
                    ["C"] = {},
                    ["D"] = {}
                }

				for idx = #G.playing_cards, 1, -1 do
					sendDebugMessage(G.playing_cards[idx].base.suit .. G.playing_cards[idx].base.id)

                    local suit = string.sub(G.playing_cards[idx].base.suit, 1, 1)
                    local rank = ""

					if G.playing_cards[idx].base.id ~= card_id then
                        if card_id < 10 then rank = tostring(card_id)
                        elseif card_id == 10 then rank = "T"
                        elseif card_id == 11 then rank = "J"
                        elseif card_id == 12 then rank = "Q"
                        elseif card_id == 13 then rank = "K"
                        else rank = "A" end

						G.playing_cards[idx]:set_base(G.P_CARDS[suit .. "_" .. rank])
					end

                    table.insert(cards_by_suit[suit], G.playing_cards[idx])
				end

				for idx = #cards_by_suit["S"], 1, -1 do
                    if idx > suit_size then cards_by_suit["S"][idx]:set_ability(G.P_CENTERS.m_glass) end
                end
				for idx = #cards_by_suit["H"], 1, -1 do
                    if idx > suit_size then cards_by_suit["H"][idx]:set_ability(G.P_CENTERS.m_glass) end
                end
				for idx = #cards_by_suit["C"], 1, -1 do
                    if idx > suit_size then cards_by_suit["C"][idx]:set_ability(G.P_CENTERS.m_glass) end
                end
				for idx = #cards_by_suit["D"], 1, -1 do
                    if idx > suit_size then cards_by_suit["D"][idx]:set_ability(G.P_CENTERS.m_glass) end
                end

				for idx = #G.playing_cards, 1, -1 do
                    if G.playing_cards[idx].ability.name == 'Glass Card' then G.playing_cards[idx]:start_dissolve(nil, true) end
                end
				return true
			end
		}))
	end
end

local Backtrigger_effectref_aces = Back.trigger_effect
function Back.trigger_effect(self, args)
  if self.name == "Ace_in_the_Hole" and args.context == "eval" and G.GAME.round then
    G.E_MANAGER:add_event(Event({
      func = (function()
        add_tag(Tag("tag_standard"))
        return true
      end)
    }))
  end
  return Backtrigger_effectref_aces(self, args)
end

local loc_def = {
	["name"]="Ace in the Hole",
	["text"]={
		[1]="Start with a Deck",
		[2]="containing only one {C:attention}Ace{} of each suit",
		[3]="Gain {C:attention,T:p_standard_mega_1}Mega Standard Pack{}",
        [4]="after each round"
	},
}

local d_aces = SMODS.Deck:new("Ace_in_the_Hole", "aces", {only_one_rank_aces = 14, amount_per_suit_aces = 1}, {x = 6, y = 0}, loc_def)
d_aces:register()

----------------------------------------------
------------MOD CODE END----------------------