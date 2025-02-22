--- STEAMODDED HEADER
--- MOD_NAME: Deck of 8
--- MOD_ID: DeckOf8
--- MOD_AUTHOR: [itiseren]
--- MOD_DESCRIPTION: Create a special deck that only contains 8s!

----------------------------------------------
------------MOD CODE -------------------------

local Backapply_to_runRef = Back.apply_to_run
function Back.apply_to_run(arg_56_0)
	Backapply_to_runRef(arg_56_0)

	if arg_56_0.effect.config.only_one_rank then
		G.E_MANAGER:add_event(Event({
			func = function()
				for iter_57_0 = #G.playing_cards, 1, -1 do
					sendDebugMessage(G.playing_cards[iter_57_0].base.id)
					if G.playing_cards[iter_57_0].base.id ~= 8 then
						local suit = string.sub(G.playing_cards[iter_57_0].base.suit, 1, 1) .. "_"
						local rank = "8"

						G.playing_cards[iter_57_0]:set_base(G.P_CARDS[suit .. rank])
					end
				end

				return true
			end
		}))
	end
end

local loc_def = {
	["name"]="Deck of 8s",
	["text"]={
		[1]="Start with a Deck",
		[2]="full of",
		[3]="{C:attention}8s{}"
	},
}

local deckof8 = SMODS.Deck:new("Deck of 8s", "8s", {only_one_rank = 8}, {x = 5, y = 2}, loc_def)
deckof8:register()

----------------------------------------------
------------MOD CODE END----------------------
