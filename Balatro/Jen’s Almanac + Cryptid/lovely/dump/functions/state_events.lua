LOVELY_INTEGRITY = 'cafd95906db3619524c557a8c0e342367b9d6be2cb63f6f88e533f34308391bc'

function win_game()
    if not G.GAME.seeded and not G.GAME.challenge then
        set_joker_win()
        set_deck_win()
        
        check_and_set_high_score('win_streak', G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt+1)
        check_and_set_high_score('current_streak', G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt+1)
        check_for_unlock({type = 'win_no_hand'})
        check_for_unlock({type = 'win_no'})
        check_for_unlock({type = 'win_custom'})
        check_for_unlock({type = 'win_deck'})
        check_for_unlock({type = 'win_stake'})
        check_for_unlock({type = 'win'})
        check_for_unlock({type = 'cry_win_with_hand', hand = G.GAME.last_hand_played})
        inc_career_stat('c_wins', 1)
    end

    set_profile_progress()

    if G.GAME.challenge then
        G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[G.GAME.challenge] = true
        set_challenge_unlock()
        check_for_unlock({type = 'win_challenge'})
        G:save_settings()
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function()
            for k, v in pairs(G.I.CARD) do
                v.sticker_run = nil
            end
            
            play_sound('win')
            G.SETTINGS.paused = true

            G.FUNCS.overlay_menu{
                definition = create_UIBox_win(),
                config = {no_esc = true}
            }
            local Jimbo = nil

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 2.5,
                blocking = false,
                func = (function()
                    if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('jimbo_spot') then 
                        Jimbo = Card_Character({x = 0, y = 5})
                        local spot = G.OVERLAY_MENU:get_UIE_by_ID('jimbo_spot')
                        spot.config.object:remove()
                        spot.config.object = Jimbo
                        Jimbo.ui_object_updated = true
                        Jimbo:add_speech_bubble('wq_'..math.random(1,7), nil, {quip = true})
                        Jimbo:say_stuff(5)
                        if G.F_JAN_CTA then 
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    Jimbo:add_button(localize('b_wishlist'), 'wishlist_steam', G.C.DARK_EDITION, nil, true, 1.6)
                                    return true
                                end}))
                        end
                        end
                    return true
                end)
            }))
            
            return true
        end)
    }))

    if not G.GAME.seeded and not G.GAME.challenge then
        G.PROFILES[G.SETTINGS.profile].stake = math.max(G.PROFILES[G.SETTINGS.profile].stake or 1, (G.GAME.stake or 1)+1)
    end
    G:save_progress()
    G.FILE_HANDLER.force = true
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function()
            if not G.SETTINGS.paused then
                G.GAME.current_round.round_text = 'Endless Round '
                return true
            end
        end)
    }))
end

function end_round()
G.GAME.cry_exploit_override = nil
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.2,
      func = function()
        G.GAME.blind.in_blind = false
        local game_over = true
        local game_won = false
        G.RESET_BLIND_STATES = true
        G.RESET_JIGGLES = true
        if G.GAME.current_round.semicolon then
            game_over = false
        end
            if to_big(G.GAME.chips) >= to_big(G.GAME.blind.chips) then
                game_over = false
            end
            for i = 1, #G.playing_cards do
            	local CARD = G.playing_cards[i]
                CARD.cry_debuff_immune = false
            end
            for i = 1, #G.jokers.cards do
                local eval = nil
                eval = G.jokers.cards[i]:calculate_joker({end_of_round = true, game_over = game_over, callback = function(card, eval)
                if eval then
                    if eval.saved then
                        game_over = false
                    end
                    card_eval_status_text(card, 'jokers', nil, nil, nil, eval)
                end
            end})

                G.jokers.cards[i]:calculate_rental()
                G.jokers.cards[i]:calculate_perishable()
            end
                G.GAME.selected_back:trigger_effect({context = 'end_of_round', game_over = game_over})
            if G.GAME.voucher_sticker_index then
            	if G.GAME.voucher_sticker_index.perishable then
            		for k, v in pairs(G.GAME.voucher_sticker_index.perishable) do
            			if v > 1 then
            				G.GAME.voucher_sticker_index.perishable[k] = v - 1
            			end
            			if v == 1 then
            				G.GAME.voucher_sticker_index.perishable[k] = v - 1	
            				for kk, vv in pairs(G.P_CENTERS) do
            					if k == vv.name then
            						cry_debuff_voucher(kk)
            						G.GAME.used_vouchers.vv = nil
            						G.GAME.used_vouchers[kk] = nil
            						break
            					end
            				end
            			end
            		end
            	end
            	if G.GAME.voucher_sticker_index.rental then
            		local cumulative_rental = 0
            		for k, v in pairs(G.GAME.voucher_sticker_index.rental) do
            			cumulative_rental = cumulative_rental + G.GAME.cry_voucher_rental_rate
            		end
            		if cumulative_rental > 0 then
            			G.E_MANAGER:add_event(Event({
            				trigger = 'immediate',
            				blocking = false,
            				blockable = false,
            				func = (function()
            					ease_dollars(-cumulative_rental)
            				return true
            			end)}))
            		end
            	end
            	if G.GAME.voucher_sticker_index.banana then		-- i'm pretty sure unredeem breaks if spectrals are disabled? unsure though
            		local voucher_queue = {}
            		local current_round_voucher=G.GAME.current_round.voucher
            		for k, v in pairs(G.GAME.voucher_sticker_index.banana) do
            			if (pseudorandom('byebyevoucher') < G.GAME.probabilities.normal/G.GAME.cry_voucher_banana_odds) then
            				area = G.play
            				local unredeemed_voucher = ''
            				for kk, vv in pairs(G.P_CENTERS) do
            					if k == vv.name then
            						unredeemed_voucher = kk
            						break
            					end
            				end
            			        local card = create_card('Voucher', area, nil, nil, nil, nil, unredeemed_voucher)
            				if G.GAME.voucher_edition_index[card.ability.name] then		-- i made this bullshit a function
            					local edition = cry_edition_to_table(G.GAME.voucher_edition_index[card.ability.name])
            					if edition then
            						card:set_edition(edition, true, true)
            					end
            				end
            				if G.GAME.voucher_sticker_index.eternal[card.ability.name] then
            	    				card:set_eternal(true)
            	    				card.ability.eternal = true
            				end
            				if G.GAME.voucher_sticker_index.perishable[card.ability.name] then
            	    				card:set_perishable(true)
            	    				card.ability.perish_tally = G.GAME.voucher_sticker_index.perishable[card.ability.name]
            	    				card.ability.perishable = true
            	    				if G.GAME.voucher_sticker_index.perishable[card.ability.name] == 0 then
            						card.debuff = true
            					end
            				end
            				if G.GAME.voucher_sticker_index.rental[card.ability.name] then
            	   				card:set_rental(true)
            	  				card.ability.rental = true
            				end
            				if G.GAME.voucher_sticker_index.pinned[card.ability.name] then
            					card.pinned = true
            				end
            				if G.GAME.voucher_sticker_index.banana[card.ability.name] then
            					card.ability.banana = true
            				end
                    			card:start_materialize()
                    			area:emplace(card)
                    			card.cost=0
                    			card.shop_voucher=false
            				voucher_queue[#voucher_queue+1] = card
            			end
            		end
            		for k, v in pairs(voucher_queue) do
            			v:unredeem()
                    		G.E_MANAGER:add_event(Event({
            				trigger = 'after',
            				delay =  0,
            				func = function() 
            					v:start_dissolve()
            				return true
            			end}))
            		end
            		G.GAME.current_round.voucher=current_round_voucher
            	end
            end
            local i = 1
            while i <= #G.jokers.cards do
                local gone = G.jokers.cards[i]:calculate_banana()
                if not gone then i = i + 1 end
            end
            i = 1
            while i <= #G.consumeables.cards do
                G.consumeables.cards[i]:cry_calculate_consumeable_rental()
                G.consumeables.cards[i]:cry_calculate_consumeable_perishable()
                local gone = nil
                if not gone then i = i + 1 end
            end
            if G.GAME.round_resets.ante >= G.GAME.win_ante and G.GAME.blind_on_deck == 'Boss' then
                game_won = true
                G.GAME.won = true
            end
            if game_over then
                G.STATE = G.STATES.GAME_OVER
                if not G.GAME.won and not G.GAME.seeded and not G.GAME.challenge then 
                    G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
                end
                G:save_settings()
                G.FILE_HANDLER.force = true
                G.STATE_COMPLETE = false
            else
                G.GAME.unused_discards = (G.GAME.unused_discards or 0) + G.GAME.current_round.discards_left
                if G.GAME.blind and G.GAME.blind.config.blind then 
                    discover_card(G.GAME.blind.config.blind)
                end

                if G.GAME.blind_on_deck == 'Boss' then
                    local _handname, _played, _order = 'High Card', -1, 100
                    for k, v in pairs(G.GAME.hands) do
                        if v.played > _played or (v.played == _played and _order > v.order) then 
                            _played = v.played
                            _handname = k
                        end
                    end
                    G.GAME.current_round.most_played_poker_hand = _handname
                end

                if G.GAME.blind:get_type() == 'Boss' and not G.GAME.seeded and not G.GAME.challenge  then
                    G.GAME.current_boss_streak = G.GAME.current_boss_streak + 1
                    check_and_set_high_score('boss_streak', G.GAME.current_boss_streak)
                end
                
                if G.GAME.current_round.hands_played == 1 then 
                    inc_career_stat('c_single_hand_round_streak', 1)
                else
                    if not G.GAME.seeded and not G.GAME.challenge  then
                        G.PROFILES[G.SETTINGS.profile].career_stats.c_single_hand_round_streak = 0
                        G:save_settings()
                    end
                end

                check_for_unlock({type = 'round_win'})
                set_joker_usage()
                if game_won and not G.GAME.win_notified then
                    G.GAME.win_notified = true
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        blocking = false,
                        blockable = false,
                        func = (function()
                            if G.STATE == G.STATES.ROUND_EVAL then 
                                win_game()
                                G.GAME.won = true
                                return true
                            end
                        end)
                    }))
                end
                if scoring_hand then
                    local unscoring_hand = {}
                    for i = 1, #G.play.cards do
                        local is_scoring = false
                        for j = 1, #scoring_hand do
                            if G.play.cards[i] == scoring_hand[j] then
                                is_scoring = true
                            end
                        end
                        if not is_scoring then
                            unscoring_hand[#unscoring_hand+1] = G.play.cards[i]
                        end
                    end
                    for i = 1, #unscoring_hand do
                        unscoring_hand[i]:calculate_seal{unscoring = true}
                    end
                end
                for i=1, #G.hand.cards do
                    --Check for hand doubling
                    local reps = {1}
                    local j = 1
                    while j <= #reps do
                        local percent = (i-0.999)/(#G.hand.cards-0.998) + (j-1)*0.1
                        if reps[j] ~= 1 then card_eval_status_text((reps[j].jokers or reps[j].seals).card, 'jokers', nil, nil, nil, (reps[j].jokers or reps[j].seals)) end
    
                        --calculate the hand effects
                        local effects = {G.hand.cards[i]:get_end_of_round_effect()}
                        G.hand.cards[i]:calculate_rental()
                        G.hand.cards[i]:calculate_perishable()
                        local extra_enhancements = SMODS.get_enhancements(G.hand.cards[i], true)
                        local old_ability = copy_table(G.hand.cards[i].ability)
                        local old_center = G.hand.cards[i].config.center
                        local old_center_key = G.hand.cards[i].config.center_key
                        for k, _ in pairs(extra_enhancements) do
                            if G.P_CENTERS[k] then
                                G.hand.cards[i]:set_ability(G.P_CENTERS[k])
                                G.hand.cards[i].ability.extra_enhancement = k
                                effects[#effects+1] = G.hand.cards[i]:get_end_of_round_effect()
                            end
                        end
                        G.hand.cards[i].ability = old_ability
                        G.hand.cards[i].config.center = old_center
                        G.hand.cards[i].config.center_key = old_center_key
                        G.hand.cards[i]:set_sprites(old_center)
                        for k=1, #G.jokers.cards do
                            --calculate the joker individual card effects
                            local eval = G.jokers.cards[k]:calculate_joker({cardarea = G.hand, other_card = G.hand.cards[i], individual = true, end_of_round = true, callback = function(card, eval, retrigger)
                            if eval then 
                                table.insert(effects, eval)
effects[#effects].from_retrigger = retrigger
end end, no_retrigger_anim = true})

                        end

                        if reps[j] == 1 then 
                            --Check for hand doubling
                            --From Red seal
                            local eval = eval_card(G.hand.cards[i], {end_of_round = true,cardarea = G.hand, repetition = true, repetition_only = true})
                            if next(eval) and (next(effects[1]) or #effects > 1)  then 
                                for h = 1, eval.seals.repetitions do
                                    reps[#reps+1] = eval
                                end
                            end

                            --from Jokers
                            for j=1, #G.jokers.cards do
                                --calculate the joker effects
                                local eval = eval_card(G.jokers.cards[j], {cardarea = G.hand, other_card = G.hand.cards[i], repetition = true, end_of_round = true, card_effects = effects, callback = function(card, ret) eval = {jokers = ret}
                                if next(eval) then 
                                    for h  = 1, eval.jokers.repetitions do
                                        reps[#reps+1] = eval
                                    end
                                end end})
                            end
                        end
        
                        for ii = 1, #effects do
                            --if this effect came from a joker
                            if effects[ii].card and not Talisman.config_file.disable_anims then
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'immediate',
                                    func = (function() effects[ii].card:juice_up(0.7);return true end)
                                }))
                            end
                            
                            --If dollars
                            if effects[ii].h_dollars then 
                                ease_dollars(effects[ii].h_dollars)
                                card_eval_status_text(G.hand.cards[i], 'dollars', effects[ii].h_dollars, percent)
                            end

                            --Any extras
                            if effects[ii].extra then
                                card_eval_status_text(G.hand.cards[i], 'extra', nil, percent, nil, effects[ii].extra)
                            end
                        end
                        j = j + 1
                    end
                end
                delay(0.3)


                local i = 1
                while i <= #G.hand.cards do
                    local gone = G.hand.cards[i]:calculate_banana()
                    if not gone then i = i + 1 end
                end
                for i = 1, #G.discard.cards do
                    G.discard.cards[i]:calculate_perishable()
                end
                i = 1
                while i <= #G.deck.cards do
                    G.deck.cards[i]:calculate_perishable()
                    local gone = G.deck.cards[i]:calculate_banana()
                    if not gone then i = i + 1 end
                end
                if G.GAME.used_vouchers.v_cry_double_down then
                    local function update_dbl(area)
                        for i = 1, #area.cards do
                            if area.cards[i].dbl_side then
                                --tweak to do deck effects with on the flip side
                                cry_misprintize(area.cards[i].dbl_side, {min = 1.5, max = 1.5}, nil, true)
                                card_eval_status_text(area.cards[i], "extra", nil, nil, nil, { message = localize("k_upgrade_ex") })
                            end
                        end
                    end
                    update_dbl(G.jokers)
                    update_dbl(G.consumeables)
                    update_dbl(G.hand)
                    update_dbl(G.discard)
                    update_dbl(G.deck)
                end
                G.FUNCS.draw_from_hand_to_discard()
                if G.GAME.blind_on_deck == 'Boss' then
                    G.GAME.voucher_restock = nil
                    if G.GAME.modifiers.set_eternal_ante and (G.GAME.round_resets.ante == G.GAME.modifiers.set_eternal_ante) then 
                        for k, v in ipairs(G.jokers.cards) do
                            v:set_eternal(true)
                        end
                    end
                    if G.GAME.modifiers.set_joker_slots_ante and (G.GAME.round_resets.ante == G.GAME.modifiers.set_joker_slots_ante) then 
                        G.jokers.config.card_limit = 0
                    end
                    delay(0.4); ease_ante(G.GAME.blind and G.GAME.blind:cry_calc_ante_gain() or 1); cry_apply_ante_tax(); delay(0.4); check_for_unlock({type = 'ante_up', ante = G.GAME.round_resets.ante + 1})
                end
                G.FUNCS.draw_from_discard_to_deck()
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        G.STATE = G.STATES.ROUND_EVAL
                        G.STATE_COMPLETE = false

                        if G.GAME.blind_on_deck == 'Small' then
                            G.GAME.round_resets.blind_states.Small = 'Defeated'
                        elseif G.GAME.blind_on_deck == 'Big' then
                            G.GAME.round_resets.blind_states.Big = 'Defeated'
                        else
                            if G.GAME.current_round.cry_voucher_stickers.pinned == false then
                            	if not G.GAME.modifiers.cry_no_vouchers then
                            	    if not G.GAME.modifiers.cry_voucher_restock_antes or G.GAME.round_resets.ante % G.GAME.modifiers.cry_voucher_restock_antes == 0 then
                            	        G.GAME.current_round.voucher = get_next_voucher_key()
                            	        G.GAME.current_round.cry_bonusvouchers = {}
                            	        G.GAME.cry_bonusvouchersused = {}	-- i'm not sure why i'm putting these in two separate tables but it doesn't matter much
                            	        for i = 1, G.GAME.cry_bonusvouchercount do
                            	        	G.GAME.current_round.cry_bonusvouchers[i] = get_next_voucher_key()
                            	        end
                            	    end
                            	else
                            	    very_fair_quip = pseudorandom_element(G.localization.misc.very_fair_quips, pseudoseed("cry_very_fair"))
                            	end
                            	G.GAME.current_round.cry_voucher_edition = cry_get_next_voucher_edition()
                            	G.GAME.current_round.cry_voucher_stickers = cry_get_next_voucher_stickers()
                            end
                            G.GAME.round_resets.blind_states.Boss = 'Defeated'
                            for k, v in ipairs(G.playing_cards) do
                                v.ability.played_this_ante = nil
                            end
                        end

                        if G.GAME.round_resets.temp_handsize then G.hand:change_size(-G.GAME.round_resets.temp_handsize); G.GAME.round_resets.temp_handsize = nil end
                        if G.GAME.round_resets.temp_reroll_cost then G.GAME.round_resets.temp_reroll_cost = nil; calculate_reroll_cost(true) end
                        for _, v in pairs(find_joker("cry-loopy")) do
                        	if v.ability.extra.retrigger ~= 0 then 
                        		v.ability.extra.retrigger = 0
                        		card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize("k_reset"), colour = G.C.GREEN})
                        	end
                        end
                        for i = 1, #G.jokers.cards do
                        	G.jokers.cards[i]:calculate_joker({end_of_round2 = true})
                        end

                        reset_idol_card()
                        reset_mail_rank()
                        reset_ancient_card()
                        reset_castle_card()                        for _, mod in ipairs(SMODS.mod_list) do
                        	if mod.reset_game_globals and type(mod.reset_game_globals) == 'function' then
                        		mod.reset_game_globals(false)
                        	end
                        end
                        for k, v in ipairs(G.playing_cards) do
                            v.ability.discarded = nil
                            v.ability.forced_selection = nil
                        end
                    return true
                    end
                }))
            end
        return true
      end
    }))
  end
  
function new_round()
    G.RESET_JIGGLES = nil
    delay(0.4)
    G.E_MANAGER:add_event(Event({
      trigger = 'immediate',
      func = function()
            G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
            G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))
            G.GAME.current_round.hands_played = 0
            G.GAME.current_round.discards_used = 0
            G.GAME.current_round.reroll_cost_increase = 0
            G.GAME.current_round.used_packs = {}

            for k, v in pairs(G.GAME.hands) do 
                v.played_this_round = 0
            end

            for k, v in pairs(G.playing_cards) do
                v.ability.wheel_flipped = nil
            end

            local chaos = find_joker('Chaos the Clown')
            G.GAME.current_round.free_rerolls = #chaos
            calculate_reroll_cost(true)

            G.GAME.round_bonus.next_hands = 0
            G.GAME.round_bonus.discards = 0

            local blhash = ''
            if G.GAME.blind_on_deck == 'Small' then
                G.GAME.round_resets.blind_states.Small = 'Current'
                G.GAME.current_boss_streak = 0
                blhash = 'S'
            elseif G.GAME.blind_on_deck == 'Big' then
                G.GAME.round_resets.blind_states.Big = 'Current'
                G.GAME.current_boss_streak = 0
                blhash = 'B'
            else
                G.GAME.round_resets.blind_states.Boss = 'Current'
                blhash = 'L'
            end
            G.GAME.subhash = (G.GAME.round_resets.ante)..(blhash)

            G.GAME.blind:set_blind(G.GAME.round_resets.blind)
            if G.GAME.modifiers.cry_card_each_round then
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        local front = pseudorandom_element(G.P_CARDS, pseudoseed('cry_horizon'))
                        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                        local edition = G.P_CENTERS.c_base
                        local card = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, front, G.P_CENTERS.c_base, {playing_card = G.playing_card})
                        card:start_materialize()
                        if G.GAME.selected_back.effect.config.cry_force_edition and G.GAME.selected_back.effect.config.cry_force_edition ~= "random" then
                            local edition = {}
                            edition[G.GAME.selected_back.effect.config.cry_force_edition] = true
                            card:set_edition(edition, true, true);
                        end
                        G.play:emplace(card)
                        table.insert(G.playing_cards, card)
                        playing_card_joker_effects({true})
                        return true
                    end}))
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        return true
                    end}))
                draw_card(G.play,G.deck, 90,'up', nil) 
            end
            if G.GAME.modifiers.cry_conveyor and #G.jokers.cards>0 then
                local duplicated_joker = copy_card(G.jokers.cards[#G.jokers.cards])
                duplicated_joker:add_to_deck()
                G.jokers:emplace(duplicated_joker)
                G.jokers.cards[1]:start_dissolve()
            end
            G.GAME.current_round.semicolon = false
            
            for i = 1, #G.playing_cards do
            	local CARD = G.playing_cards[i]
                CARD.cry_debuff_immune = false
            end
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i]:calculate_joker({setting_blind = true, blind = G.GAME.round_resets.blind})
            end
                G.GAME.selected_back:trigger_effect({context = 'setting_blind', blind = G.GAME.round_resets.blind})
            delay(0.4)

            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.STATE = G.STATES.DRAW_TO_HAND
                    G.deck:shuffle('nr'..G.GAME.round_resets.ante)
                    G.deck:hard_set_T()
if G.SCORING_COROUTINE then return false end 
                    G.STATE_COMPLETE = false
                    return true
                end
            }))
            return true
            end
        }))
end

G.FUNCS.draw_from_deck_to_hand = function(e)
    if not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and
        G.hand.config.card_limit <= 0 and #G.hand.cards == 0 then 
        G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false 
        return true
    end

    local hand_space = e
    if not hand_space then
        local limit = G.hand.config.card_limit - #G.hand.cards
        local n = 0
        while n < #G.deck.cards do
            local card = G.deck.cards[#G.deck.cards-n]
            limit = limit - 1 + (card.edition and card.edition.card_limit or 0)
            if limit < 0 then break end
            n = n + 1
        end
        hand_space = n
    end
    if G.GAME.blind.name == 'The Serpent' and
        not G.GAME.blind.disabled and
        (G.GAME.current_round.hands_played > 0 or
        G.GAME.current_round.discards_used > 0) then
            hand_space = math.min(#G.deck.cards, 3)
    end
    delay(0.3)
    if not G.GAME.USING_RUN then
    for i=1, hand_space do --draw cards from deckL
        if G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK then 
            draw_card(G.deck,G.hand, i*100/hand_space,'up', true)
        else
            draw_card(G.deck,G.hand, i*100/hand_space,'up', true)
        end
    end
else
	for i = 1, #G.cry_runarea.cards do
		draw_card(G.cry_runarea,G.hand, i*100/#G.cry_runarea.cards,'up', true)
	end
end

G.FUNCS.draw_from_hand_to_run = function(e)	-- might as well just slap this here
	local hand_count = #G.hand.cards
	for i=1, hand_count do --draw cards from deck
		draw_card(G.hand, G.cry_runarea, i*100/hand_count,'down', nil, nil,  0.08)
	end
end
end

G.FUNCS.discard_cards_from_highlighted = function(e, hook)
    stop_use()
    G.CONTROLLER.interrupt.focus = true
    G.CONTROLLER:save_cardarea_focus('hand')

    for k, v in ipairs(G.playing_cards) do
        v.ability.forced_selection = nil
    end

    if G.CONTROLLER.focused.target and G.CONTROLLER.focused.target.area == G.hand then G.card_area_focus_reset = {area = G.hand, rank = G.CONTROLLER.focused.target.rank} end
    local highlighted_count = math.min(#G.hand.highlighted, G.discard.config.card_limit - #G.play.cards)
    if highlighted_count > 0 then 
        update_hand_text({immediate = true, nopulse = true, delay = 0}, {mult = 0, chips = 0, level = '', handname = ''})
        table.sort(G.hand.highlighted, function(a,b) return a.T.x < b.T.x end)
        inc_career_stat('c_cards_discarded', highlighted_count)
        for i = 1, #G.hand.cards do
            eval_card(G.hand.cards[i], {pre_discard = true, full_hand = G.hand.highlighted, hook = hook})
        end
        for j = 1, #G.jokers.cards do
            G.jokers.cards[j]:calculate_joker({pre_discard = true, full_hand = G.hand.highlighted, hook = hook})
        end
        local cards = {}
        local destroyed_cards = {}
        for i=1, highlighted_count do
            local removed = false
            local eval = nil
            eval = eval_card(G.hand.highlighted[i], {discard = true, full_hand = G.hand.highlighted})
            if eval and eval.remove then
                removed = true
                card_eval_status_text(G.hand.highlighted[i], 'jokers', nil, 1, nil, eval)
            end
            for j = 1, #G.jokers.cards do
                local eval = nil
                eval = G.jokers.cards[j]:calculate_joker({discard = true, other_card =  G.hand.highlighted[i], full_hand = G.hand.highlighted, callback = function(card, eval)
                if eval then
                    if eval.remove then removed = true end
                    card_eval_status_text(card, 'jokers', nil, 1, nil, eval)
                end
            end})

            end
                    G.GAME.selected_back:trigger_effect({context = 'discard', other_card =  G.hand.highlighted[i], full_hand = G.hand.highlighted})
            table.insert(cards, G.hand.highlighted[i])
            if removed then
                destroyed_cards[#destroyed_cards + 1] = G.hand.highlighted[i]
                if SMODS.has_enhancement(G.hand.highlighted[i], 'm_glass') then
                    G.hand.highlighted[i]:shatter()
                else
                    G.hand.highlighted[i]:start_dissolve()
                end
            else 
                G.hand.highlighted[i].ability.discarded = true
                draw_card(G.hand, G.discard, i*100/highlighted_count, 'down', false, G.hand.highlighted[i])
            end
        end

        if destroyed_cards[1] then 
            for j=1, #G.jokers.cards do
                eval_card(G.jokers.cards[j], {cardarea = G.jokers, remove_playing_cards = true, removed = destroyed_cards})
            end
        end

        G.GAME.round_scores.cards_discarded.amt = G.GAME.round_scores.cards_discarded.amt + #cards
        check_for_unlock({type = 'discard_custom', cards = cards})
        if not hook then
            if G.GAME.modifiers.discard_cost then
                ease_dollars(-G.GAME.modifiers.discard_cost)
            end
            ease_discard(-1)
            G.GAME.current_round.discards_used = G.GAME.current_round.discards_used + 1
            G.STATE = G.STATES.DRAW_TO_HAND
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
if G.SCORING_COROUTINE then return false end 
                    G.STATE_COMPLETE = false
                    return true
                end
            }))
        end
    end
end
  
G.FUNCS.play_cards_from_highlighted = function(e)
    if G.play and G.play.cards[1] then return end
    --check the hand first

    stop_use()
    G.GAME.blind.triggered = false
    G.CONTROLLER.interrupt.focus = true
    G.CONTROLLER:save_cardarea_focus('hand')

    for k, v in ipairs(G.playing_cards) do
        v.ability.forced_selection = nil
    end
    
    table.sort(G.hand.highlighted, function(a,b) return a.T.x < b.T.x end)

    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            G.STATE = G.STATES.HAND_PLAYED
            G.STATE_COMPLETE = true
            return true
        end
    }))
    inc_career_stat('c_cards_played', #G.hand.highlighted)
    inc_career_stat('c_hands_played', 1)
    ease_hands_played(-1)
    delay(0.4)

        for i=1, #G.hand.highlighted do
            if G.hand.highlighted[i]:is_face() then inc_career_stat('c_face_cards_played', 1) end
            G.hand.highlighted[i].base.times_played = G.hand.highlighted[i].base.times_played + 1
            G.hand.highlighted[i].ability.played_this_ante = true
            G.GAME.round_scores.cards_played.amt = G.GAME.round_scores.cards_played.amt + 1
            draw_card(G.hand, G.play, i*100/#G.hand.highlighted, 'up', nil, G.hand.highlighted[i])
        end

        check_for_unlock({type = 'run_card_replays'})

        if G.GAME.blind:press_play() then
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = (function()
                    SMODS.juice_up_blind()
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                        play_sound('tarot2', 0.76, 0.4);return true end}))
                    play_sound('tarot2', 1, 0.4)
                    return true
                end)
            }))
            delay(0.4)
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = (function()
                check_for_unlock({type = 'hand_contents', cards = G.play.cards})

                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        G.FUNCS.evaluate_play()
                        return true
                    end
                }))

                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        if G.SCORING_COROUTINE then return false end 
                        check_for_unlock({type = 'play_all_hearts'})
                        G.FUNCS.draw_from_play_to_discard()
                        G.GAME.hands_played = G.GAME.hands_played + 1
                        G.GAME.current_round.hands_played = G.GAME.current_round.hands_played + 1
                        return true
                    end
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
if G.SCORING_COROUTINE then return false end 
                        G.STATE_COMPLETE = false
                        return true
                    end
                }))
                return true
            end)
        }))
end

G.FUNCS.get_poker_hand_info = function(_cards)
    local poker_hands = evaluate_poker_hand(_cards)
    local scoring_hand = {}
    local text,disp_text,loc_disp_text = 'NULL','NULL', 'NULL'
    if next(poker_hands["Flush Five"]) then text = "Flush Five"; scoring_hand = poker_hands["Flush Five"][1]
    elseif next(poker_hands["Flush House"]) then text = "Flush House"; scoring_hand = poker_hands["Flush House"][1]
    elseif next(poker_hands["Five of a Kind"]) then text = "Five of a Kind"; scoring_hand = poker_hands["Five of a Kind"][1]
    elseif next(poker_hands["Straight Flush"]) then text = "Straight Flush"; scoring_hand = poker_hands["Straight Flush"][1]
    elseif next(poker_hands["Four of a Kind"]) then text = "Four of a Kind"; scoring_hand = poker_hands["Four of a Kind"][1]
    elseif next(poker_hands["Full House"]) then text = "Full House"; scoring_hand = poker_hands["Full House"][1]
    elseif next(poker_hands["Flush"]) then text = "Flush"; scoring_hand = poker_hands["Flush"][1]
    elseif next(poker_hands["Straight"]) then text = "Straight"; scoring_hand = poker_hands["Straight"][1]
    elseif next(poker_hands["Three of a Kind"]) then text = "Three of a Kind"; scoring_hand = poker_hands["Three of a Kind"][1]
    elseif next(poker_hands["Two Pair"]) then text = "Two Pair"; scoring_hand = poker_hands["Two Pair"][1]
    elseif next(poker_hands["Pair"]) then text = "Pair"; scoring_hand = poker_hands["Pair"][1]
    elseif next(poker_hands["High Card"]) then text = "High Card"; scoring_hand = poker_hands["High Card"][1] end

    disp_text = text
    if text =='Straight Flush' then
        local min = 10
        for j = 1, #scoring_hand do
            if scoring_hand[j]:get_id() < min then min =scoring_hand[j]:get_id() end
        end
        if min >= 10 then 
            disp_text = 'Royal Flush'
        end
    end
    loc_disp_text = localize(disp_text, 'poker_hands')
    return text, loc_disp_text, poker_hands, scoring_hand, disp_text
end
  
G.FUNCS.evaluate_play = function(e)
    local text,disp_text,poker_hands,scoring_hand,non_loc_disp_text = G.FUNCS.get_poker_hand_info(G.play.cards)
    
    G.GAME.hands[text].played = G.GAME.hands[text].played + 1
    if G.GAME.current_round.current_hand.cry_asc_num > 0 then G.GAME.cry_asc_played = G.GAME.cry_asc_played and G.GAME.cry_asc_played+1 or 1 end
    G.GAME.hands[text].played_this_round = G.GAME.hands[text].played_this_round + 1
    G.GAME.last_hand_played = text
    set_hand_usage(text)
    G.GAME.hands[text].visible = true

    --Add all the pure bonus cards to the scoring hand
    local pures = {}
    for i=1, #G.play.cards do
        if next(find_joker('Splash')) then
            scoring_hand[i] = G.play.cards[i]
        else
            if SMODS.always_scores(G.play.cards[i]) then
                local inside = false
                for j=1, #scoring_hand do
                    if scoring_hand[j] == G.play.cards[i] then
                        inside = true
                    end
                end
                if not inside then table.insert(pures, G.play.cards[i]) end
            end
        end
    end
    for i=1, #pures do
        table.insert(scoring_hand, pures[i])
    end
    table.sort(scoring_hand, function (a, b) return a.T.x < b.T.x end )
    delay(0.2)
    for i=1, #scoring_hand do
        --Highlight all the cards used in scoring and play a sound indicating highlight
        highlight_card(scoring_hand[i],(i-0.999)/5,'up')
    end

    local percent = 0.3
    local percent_delta = 0.08

    if G.GAME.current_round.current_hand.handname ~= disp_text then delay(0.3) end
    update_hand_text({sound = G.GAME.current_round.current_hand.handname ~= disp_text and 'button' or nil, volume = 0.4, immediate = true, nopulse = nil,
                                delay = G.GAME.current_round.current_hand.handname ~= disp_text and 0.4 or 0}, {handname=disp_text, level=G.GAME.hands[text].level, mult = cry_ascend(G.GAME.hands[text].mult), chips = cry_ascend(G.GAME.hands[text].chips)})

    if not G.GAME.blind:debuff_hand(G.play.cards, poker_hands, text) then
                mult = mod_mult(cry_ascend(G.GAME.hands[text].mult))
                hand_chips = mod_chips(cry_ascend(G.GAME.hands[text].chips))

        check_for_unlock({type = 'hand', handname = text, disp_text = non_loc_disp_text, scoring_hand = scoring_hand, full_hand = G.play.cards})

        delay(0.4)

        if G.GAME.first_used_hand_level and G.GAME.first_used_hand_level > 0 then
            level_up_hand(G.deck.cards[1], text, nil, G.GAME.first_used_hand_level)
            G.GAME.first_used_hand_level = nil
        end

        local hand_text_set = false
        for i=1, #G.jokers.cards do
            --calculate the joker effects
            local effects = eval_card(G.jokers.cards[i], {cardarea = G.jokers, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, before = true, callback = function(card, ret) effects = {jokers = ret}
            if effects.jokers then
                card_eval_status_text(card, 'jokers', nil, percent, nil, effects.jokers)
                percent = percent + percent_delta
                if effects.jokers.level_up then
                    level_up_hand(card, text)
                end
            end
        end})
        end
                    G.GAME.selected_back:trigger_effect({context = 'before_hand', full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands})

                mult = mod_mult(cry_ascend(G.GAME.hands[text].mult))
                hand_chips = mod_chips(cry_ascend(G.GAME.hands[text].chips))

        local modded = false

        mult, hand_chips, modded = G.GAME.blind:modify_hand(G.play.cards, poker_hands, text, mult, hand_chips)
        mult, hand_chips = mod_mult(mult), mod_chips(hand_chips)
        if modded then update_hand_text({sound = 'chips2', modded = modded}, {chips = hand_chips, mult = mult}) end
        for i=1, #scoring_hand do
            --add cards played to list
            if not SMODS.has_no_rank(scoring_hand[i]) then
                G.GAME.cards_played[scoring_hand[i].base.value].total = G.GAME.cards_played[scoring_hand[i].base.value].total + 1
                if not SMODS.has_no_suit(scoring_hand[i]) then
                    G.GAME.cards_played[scoring_hand[i].base.value].suits[scoring_hand[i].base.suit] = true
                end
            end
            --if card is debuffed
            if scoring_hand[i].debuff then
                G.GAME.blind.triggered = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = (function() SMODS.juice_up_blind();return true end)
                }))
                card_eval_status_text(scoring_hand[i], 'debuff')
            else
                --Check for play doubling
                local reps = {1}
                
                --From Red seal
                local eval = eval_card(scoring_hand[i], {repetition_only = true,cardarea = G.play, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, repetition = true})
                if next(eval) then 
                    for h = 1, eval.seals.repetitions do
                        reps[#reps+1] = eval
                    end
                end
                --From jokers
                for j=1, #G.jokers.cards do
                    --calculate the joker effects
                    local eval = eval_card(G.jokers.cards[j], {cardarea = G.play, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = scoring_hand[i], repetition = true, callback = function(card, ret) eval = {jokers = ret}
                    if next(eval) and eval.jokers then 
                        if not eval.jokers.repetitions then eval.jokers.repetitions = 0 end
                        for h = 1, eval.jokers.repetitions do
                            reps[#reps+1] = eval
                        end
                    end end})
                end
                --From edition
                if scoring_hand[i].edition and scoring_hand[i].edition.key then
                    local ed = SMODS.Centers[scoring_hand[i].edition.key]
                    if ed.config and ed.config.retriggers then
                        for h = 1, ed.config.retriggers do
                            reps[#reps+1] = {seals = {
                                message = localize("k_again_ex"),
                                card = scoring_hand[i]
                            }}
                        end
                    end
                    if ed.calculate and type(ed.calculate) == 'function' then
                        local check = ed:calculate(scoring_hand[i], {retrigger_edition_check = true, cardarea = G.play, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = scoring_hand[i], repetition = true})
                        if check and type(check) == 'table' and next(check) then 
                            for j = 1, check.repetitions do
                                reps[#reps+1] = {seals = check}
                            end
                        end
                    end
                end
                for j=1,#reps do
                    percent = percent + percent_delta
                    if reps[j] ~= 1 and (not scoring_hand or not scoring_hand[i] or not scoring_hand[i].will_shatter) then
                        card_eval_status_text((reps[j].jokers or reps[j].seals).card, 'jokers', nil, nil, nil, (reps[j].jokers or reps[j].seals))
                    end
                    
                    --calculate the hand effects
                    local effects = {eval_card(scoring_hand[i], {cardarea = G.play, full_hand = G.play.cards, scoring_hand = scoring_hand, poker_hand = text})}
                    local post_effect = {seals = effects[1].seals, edition = effects[1].edition}
                    effects[1].seals = nil
                    effects[1].edition = nil
                    local extra_enhancements = SMODS.get_enhancements(scoring_hand[i], true)
                    local old_ability = copy_table(scoring_hand[i].ability)
                    local old_center = scoring_hand[i].config.center
                    local old_center_key = scoring_hand[i].config.center_key
                    for k, _ in pairs(extra_enhancements) do
                        if G.P_CENTERS[k] then
                            scoring_hand[i]:set_ability(G.P_CENTERS[k])
                            scoring_hand[i].ability.extra_enhancement = k
                            effects[#effects+1] = eval_card(scoring_hand[i], {cardarea = G.play, full_hand = G.play.cards, scoring_hand = scoring_hand, poker_hand = text, extra_enhancement = true})
                        end
                    end
                    effects[#effects+1] = post_effect
                    scoring_hand[i].ability = old_ability
                    scoring_hand[i].config.center = old_center
                    scoring_hand[i].config.center_key = old_center_key
                    scoring_hand[i]:set_sprites(old_center)
                    for k=1, #G.jokers.cards do
                        --calculate the joker individual card effects
                        local eval = G.jokers.cards[k]:calculate_joker({cardarea = G.play, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = scoring_hand[i], individual = true, callback = function(card, eval, retrigger)
                        if eval then 
                            table.insert(effects, eval)
effects[#effects].from_retrigger = retrigger
end end, no_retrigger_anim = true})

                    end
                    scoring_hand[i].lucky_trigger = nil

                    for ii = 1, #effects do
                        --If chips added, do chip add event and add the chips to the total
                        if effects[ii].chips then 
                            if effects[ii].card then juice_card(effects[ii].card) end
                            hand_chips = mod_chips(hand_chips + effects[ii].chips)
                            update_hand_text({delay = 0}, {chips = hand_chips})
                            card_eval_status_text(scoring_hand[i], 'chips', effects[ii].chips, percent)
                        end

                        --If mult added, do mult add event and add the mult to the total
                        if effects[ii].mult then 
                            if effects[ii].card then juice_card(effects[ii].card) end
                            mult = mod_mult(mult + effects[ii].mult)
                            update_hand_text({delay = 0}, {mult = mult})
                            card_eval_status_text(scoring_hand[i], 'mult', effects[ii].mult, percent)
                        end

                        --If play dollars added, add dollars to total
                        if effects[ii].p_dollars then 
                            if effects[ii].card then juice_card(effects[ii].card) end
                            ease_dollars(effects[ii].p_dollars)
                            card_eval_status_text(scoring_hand[i], 'dollars', effects[ii].p_dollars, percent)
                        end

                        --If dollars added, add dollars to total
                        if effects[ii].dollars then 
                            if effects[ii].card then juice_card(effects[ii].card) end
                            ease_dollars(effects[ii].dollars)
                            card_eval_status_text(scoring_hand[i], 'dollars', effects[ii].dollars, percent)
                        end

                        --Any extra effects
                        if effects[ii].extra then 
                            if effects[ii].card then juice_card(effects[ii].card) end
                            local extras = {mult = false, hand_chips = false}
                            if effects[ii].extra.mult_mod then mult =mod_mult( mult + effects[ii].extra.mult_mod);extras.mult = true end
                            if effects[ii].extra.chip_mod then hand_chips = mod_chips(hand_chips + effects[ii].extra.chip_mod);extras.hand_chips = true end
                            if effects[ii].extra.swap then 
                                local old_mult = mult
                                mult = mod_mult(hand_chips)
                                hand_chips = mod_chips(old_mult)
                                extras.hand_chips = true; extras.mult = true
                            end
                            if effects[ii].extra.func then effects[ii].extra.func() end
                            update_hand_text({delay = 0}, {chips = extras.hand_chips and hand_chips, mult = extras.mult and mult})
                            card_eval_status_text(scoring_hand[i], 'extra', nil, percent, nil, effects[ii].extra)
                        end

                        if effects[ii].seals then
                            if effects[ii].seals.chips then 
                                if effects[ii].card then juice_card(effects[ii].card) end
                                hand_chips = mod_chips(hand_chips + effects[ii].seals.chips)
                                update_hand_text({delay = 0}, {chips = hand_chips})
                                card_eval_status_text(scoring_hand[i], 'chips', effects[ii].seals.chips, percent)
                            end
                            
                            if effects[ii].seals.mult then 
                                if effects[ii].card then juice_card(effects[ii].card) end
                                mult = mod_mult(mult + effects[ii].seals.mult)
                                update_hand_text({delay = 0}, {mult = mult})
                                card_eval_status_text(scoring_hand[i], 'mult', effects[ii].seals.mult, percent)
                            end
                            
                            if effects[ii].seals.p_dollars then 
                                if effects[ii].card then juice_card(effects[ii].card) end
                                ease_dollars(effects[ii].seals.p_dollars)
                                card_eval_status_text(scoring_hand[i], 'dollars', effects[ii].seals.p_dollars, percent)
                            end
                            
                            if effects[ii].seals.dollars then 
                                if effects[ii].card then juice_card(effects[ii].card) end
                                ease_dollars(effects[ii].seals.dollars)
                                card_eval_status_text(scoring_hand[i], 'dollars', effects[ii].seals.dollars, percent)
                            end
                            
                            if effects[ii].seals.x_mult then 
                                if effects[ii].card then juice_card(effects[ii].card) end
                                mult = mod_mult(mult*effects[ii].seals.x_mult)
                                update_hand_text({delay = 0}, {mult = mult})
                                card_eval_status_text(scoring_hand[i], 'x_mult', effects[ii].seals.x_mult, percent)
                            end
                        
                            if effects[ii].seals.func then
                                effects[ii].seals.func()
                            end
                        end
                        
                        --If x_mult added, do mult add event and mult the mult to the total
                        if effects[ii].x_mult then 
                            if effects[ii].card then juice_card(effects[ii].card) end
                            mult = mod_mult(mult*effects[ii].x_mult)
                            update_hand_text({delay = 0}, {mult = mult})
                            card_eval_status_text(scoring_hand[i], 'x_mult', effects[ii].x_mult, percent)
                            if next(find_joker("cry-Exponentia")) then
                                for _, v in pairs(find_joker("cry-Exponentia")) do
                                    local old = v.ability.extra.Emult
                                    v.ability.extra.Emult = v.ability.extra.Emult + v.ability.extra.Emult_mod
                                    card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_powmult',vars={number_format(to_big(v.ability.extra.Emult))}}})
                                    exponentia_scale_mod(v, v.ability.extra.Emult_mod, old, v.ability.extra.Emult)
                                end
                            end
                        end

                        if effects[ii].x_chips then
                        	mod_percent = true
                        	if effects[ii].card then juice_card(effects[ii].card) end
                        	hand_chips = mod_chips(hand_chips*effects[ii].x_chips)
                        	update_hand_text({delay = 0}, {chips = hand_chips})
                        	card_eval_status_text(scoring_hand[i], 'x_chips', effects[ii].x_chips, percent)
                        end
                        if effects[ii].e_chips then
                        	mod_percent = true
                        	if effects[ii].card then juice_card(effects[ii].card) end
                        	hand_chips = mod_chips(hand_chips^effects[ii].e_chips)
                        	update_hand_text({delay = 0}, {chips = hand_chips})
                        	card_eval_status_text(scoring_hand[i], 'e_chips', effects[ii].e_chips, percent)
                        end
                        if effects[ii].ee_chips then
                        	mod_percent = true
                        	if effects[ii].card then juice_card(effects[ii].card) end
                        	hand_chips = mod_chips(hand_chips:arrow(2, effects[ii].ee_chips))
                        	update_hand_text({delay = 0}, {chips = hand_chips})
                        	card_eval_status_text(scoring_hand[i], 'ee_chips', effects[ii].ee_chips, percent)
                        end
                        if effects[ii].eee_chips then
                        	mod_percent = true
                        	if effects[ii].card then juice_card(effects[ii].card) end
                        	hand_chips = mod_chips(hand_chips:arrow(3, effects[ii].eee_chips))
                        	update_hand_text({delay = 0}, {chips = hand_chips})
                        	card_eval_status_text(scoring_hand[i], 'eee_chips', effects[ii].eee_chips, percent)
                        end
                        if effects[ii].hyper_chips and type(effects[ii].hyper_chips) == 'table' then
                        	mod_percent = true
                        	if effects[ii].card then juice_card(effects[ii].card) end
                        	hand_chips = mod_chips(hand_chips:arrow(effects[ii].hyper_chips[1], effects[ii].hyper_chips[2]))
                        	update_hand_text({delay = 0}, {chips = hand_chips})
                        	card_eval_status_text(scoring_hand[i], 'hyper_chips', effects[ii].hyper_chips, percent)
                        end
                        if effects[ii].e_mult then
                        	mod_percent = true
                        	if effects[ii].card then juice_card(effects[ii].card) end
                        	mult = mod_mult(mult^effects[ii].e_mult)
                        	update_hand_text({delay = 0}, {mult = mult})
                        	card_eval_status_text(scoring_hand[i], 'e_mult', effects[ii].e_mult, percent)
                        end
                        if effects[ii].ee_mult then
                        	mod_percent = true
                        	if effects[ii].card then juice_card(effects[ii].card) end
                        	mult = mod_mult(mult:arrow(2, effects[ii].ee_mult))
                        	update_hand_text({delay = 0}, {mult = mult})
                        	card_eval_status_text(scoring_hand[i], 'ee_mult', effects[ii].ee_mult, percent)
                        end
                        if effects[ii].eee_mult then
                        	mod_percent = true
                        	if effects[ii].card then juice_card(effects[ii].card) end
                        	mult = mod_mult(mult:arrow(3, effects[ii].eee_mult))
                        	update_hand_text({delay = 0}, {mult = mult})
                        	card_eval_status_text(scoring_hand[i], 'eee_mult', effects[ii].eee_mult, percent)
                        end
                        if effects[ii].hyper_mult and type(effects[ii].hyper_mult) == 'table' then
                        	mod_percent = true
                        	if effects[ii].card then juice_card(effects[ii].card) end
                        	mult = mod_mult(mult:arrow(effects[ii].hyper_mult[1], effects[ii].hyper_mult[2]))
                        	update_hand_text({delay = 0}, {mult = mult})
                        	card_eval_status_text(scoring_hand[i], 'hyper_mult', effects[ii].hyper_mult, percent)
                        end
                        
                        --calculate the card edition effects
                        if effects[ii].edition then
                            if effects[ii].edition.chip_mod then
                                hand_chips = mod_chips(hand_chips + effects[ii].edition.chip_mod)
                                local key_switch = (effects[ii].edition.chip_mod > 0 and 'a_chips' or 'a_chips_minus')
                                card_eval_status_text(scoring_hand[i], 'extra', nil, percent, nil, {
                                    message = localize{type='variable', key=key_switch, vars={math.abs(effects[ii].edition.chip_mod)}},
                                    chip_mod = true,
                                    colour = G.C.DARK_EDITION,
                                    edition = true
                                })
                                update_hand_text({delay = 0}, {chips = hand_chips})
                            end
                            if effects[ii].edition.mult_mod then
                                mult = mult + effects[ii].edition.mult_mod
                                card_eval_status_text(scoring_hand[i], 'extra', nil, percent, nil, {
                                    message = localize{type='variable', key='a_mult', vars={effects[ii].edition.mult_mod}},
                                    mult_mod = true,
                                    colour = G.C.DARK_EDITION,
                                    edition = true
                                })
                                update_hand_text({delay = 0}, {mult = mult})
                            end
                            if effects[ii].edition.x_mult_mod then
                                mult = mult * effects[ii].edition.x_mult_mod
                                card_eval_status_text(scoring_hand[i], 'extra', nil, percent, nil, {
                                    message = localize{type='variable', key='a_xmult', vars={effects[ii].edition.x_mult_mod}},
                                    x_mult_mod = true,
                                    colour = G.C.DARK_EDITION,
                                    edition = true
                                })
                                update_hand_text({delay = 0}, {mult = mult})
                            end
                            if scoring_hand and scoring_hand[i] and scoring_hand[i].edition then
                            	local trg = scoring_hand[i]
                            	local edi = trg.edition
                            	if edi.x_chips then
                            		hand_chips = mod_chips(hand_chips * edi.x_chips)
                            		update_hand_text({delay = 0}, {chips = hand_chips})
                            		card_eval_status_text(trg, 'extra', nil, percent, nil,
                            		{message = 'X'.. edi.x_chips ..' Chips',
                            		edition = true,
                            		x_chips = true})
                            	end
                            	if edi.e_chips then
                            		hand_chips = mod_chips(hand_chips ^ edi.e_chips)
                            		update_hand_text({delay = 0}, {chips = hand_chips})
                            		card_eval_status_text(trg, 'extra', nil, percent, nil,
                            		{message = '^'.. edi.e_chips ..' Chips',
                            		edition = true,
                            		e_chips = true})
                            	end
                            	if edi.ee_chips then
                            		hand_chips = mod_chips(hand_chips:arrow(2, edi.ee_chips))
                            		update_hand_text({delay = 0}, {chips = hand_chips})
                            		card_eval_status_text(trg, 'extra', nil, percent, nil,
                            		{message = '^^'.. edi.ee_chips ..' Chips',
                            		edition = true,
                            		ee_chips = true})
                            	end
                            	if edi.eee_chips then
                            		hand_chips = mod_chips(hand_chips:arrow(3, edi.eee_chips))
                            		update_hand_text({delay = 0}, {chips = hand_chips})
                            		card_eval_status_text(trg, 'extra', nil, percent, nil,
                            		{message = '^^^'.. edi.eee_chips ..' Chips',
                            		edition = true,
                            		eee_chips = true})
                            	end
                            	if edi.hyper_chips and type(edi.hyper_chips) == 'table' then
                            		hand_chips = mod_chips(hand_chips:arrow(edi.hyper_chips[1], edi.hyper_chips[2]))
                            		update_hand_text({delay = 0}, {chips = hand_chips})
                            		card_eval_status_text(trg, 'extra', nil, percent, nil,
                            		{message = (edi.hyper_chips[1] > 5 and ('{' .. edi.hyper_chips[1] .. '}') or string.rep('^', edi.hyper_chips[1])) .. edi.hyper_chips[2] ..' Chips',
                            		edition = true,
                            		eee_chips = true})
                            	end
                            	if edi.e_mult then
                            		mult = mod_mult(mult ^ edi.e_mult)
                            		update_hand_text({delay = 0}, {mult = mult})
                            		card_eval_status_text(trg, 'extra', nil, percent, nil,
                            		{message = '^'.. edi.e_mult ..' Mult',
                            		edition = true,
                            		e_mult = true})
                            	end
                            	if edi.ee_mult then
                            		mult = mod_mult(mult:arrow(2, edi.ee_mult))
                            		update_hand_text({delay = 0}, {mult = mult})
                            		card_eval_status_text(trg, 'extra', nil, percent, nil,
                            		{message = '^^'.. edi.ee_mult ..' Mult',
                            		edition = true,
                            		ee_mult = true})
                            	end
                            	if edi.eee_mult then
                            		mult = mod_mult(mult:arrow(3, edi.eee_mult))
                            		update_hand_text({delay = 0}, {mult = mult})
                            		card_eval_status_text(trg, 'extra', nil, percent, nil,
                            		{message = '^^^'.. edi.eee_mult ..' Mult',
                            		edition = true,
                            		eee_mult = true})
                            	end
                            	if edi.hyper_mult and type(edi.hyper_mult) == 'table' then
                            		mult = mod_mult(mult:arrow(edi.hyper_mult[1], edi.hyper_mult[2]))
                            		update_hand_text({delay = 0}, {mult = mult})
                            		card_eval_status_text(trg, 'extra', nil, percent, nil,
                            		{message = (edi.hyper_mult[1] > 5 and ('{' .. edi.hyper_mult[1] .. '}') or string.rep('^', edi.hyper_mult[1])) .. edi.hyper_mult[2] ..' Mult',
                            		edition = true,
                            		hyper_mult = true})
                            	end
                            end
                            if effects[ii].edition.p_dollars_mod then
                                if effects[ii].card then juice_card(effects[ii].card) end
                                ease_dollars(effects[ii].edition.p_dollars_mod)
                                card_eval_status_text(scoring_hand[i], 'dollars', effects[ii].edition.p_dollars_mod, percent)
                            end
                            if not effects[ii].edition then
                            hand_chips = mod_chips(hand_chips + (effects[ii].edition.chip_mod or 0))
                            mult = mult + (effects[ii].edition.mult_mod or 0)
                            mult = mod_mult(mult*(effects[ii].edition.x_mult_mod or 1))
                            update_hand_text({delay = 0}, {
                                chips = effects[ii].edition.chip_mod and hand_chips or nil,
                                mult = (effects[ii].edition.mult_mod or effects[ii].edition.x_mult_mod) and mult or nil,
                            })
                            card_eval_status_text(scoring_hand[i], 'extra', nil, percent, nil, {
                                message = (effects[ii].edition.chip_mod and localize{type='variable',key='a_chips',vars={effects[ii].edition.chip_mod}}) or
                                        (effects[ii].edition.mult_mod and localize{type='variable',key='a_mult',vars={effects[ii].edition.mult_mod}}) or
                                        (effects[ii].edition.x_mult_mod and localize{type='variable',key='a_xmult',vars={effects[ii].edition.x_mult_mod}}),
                                chip_mod =  effects[ii].edition.chip_mod,
                                mult_mod =  effects[ii].edition.mult_mod,
                                x_mult_mod =  effects[ii].edition.x_mult_mod,
                                colour = G.C.DARK_EDITION,
                                edition = true})end
                        end
                                        if effects[ii].from_retrigger then
                        card_eval_status_text(effects[ii].from_retrigger.card, 'jokers', nil, nil, nil, effects[ii].from_retrigger)
                    end 
                
end
                end
            end
        end

        delay(0.3)
        local mod_percent = false
            if scoring_hand then
                local unscoring_hand = {}
                for i = 1, #G.play.cards do
                    local is_scoring = false
                    for j = 1, #scoring_hand do
                        if G.play.cards[i] == scoring_hand[j] then
                            is_scoring = true
                        end
                    end
                    if not is_scoring then
                        unscoring_hand[#unscoring_hand+1] = G.play.cards[i]
                    end
                end
                for i = 1, #unscoring_hand do
                    unscoring_hand[i]:calculate_seal{unscoring = true}
                end
            end
            for i=1, #G.hand.cards do
                if mod_percent then percent = percent + percent_delta end
                mod_percent = false

                --Check for hand doubling
                local reps = {1}
                local j = 1
                while j <= #reps do
                    if reps[j] ~= 1 and (not scoring_hand or not scoring_hand[i] or not scoring_hand[i].will_shatter) then
                        card_eval_status_text((reps[j].jokers or reps[j].seals).card, 'jokers', nil, nil, nil, (reps[j].jokers or reps[j].seals))
                        percent = percent + percent_delta
                    end

                    --calculate the hand effects
                    local effects = {eval_card(G.hand.cards[i], {cardarea = G.hand, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands})}
                    local extra_enhancements = SMODS.get_enhancements(G.hand.cards[i], true)
                    local old_ability = copy_table(G.hand.cards[i].ability)
                    local old_center = G.hand.cards[i].config.center
                    local old_center_key = G.hand.cards[i].config.center_key
                    for k, _ in pairs(extra_enhancements) do
                        if G.P_CENTERS[k] then
                            G.hand.cards[i]:set_ability(G.P_CENTERS[k])
                            G.hand.cards[i].ability.extra_enhancement = k
                            effects[#effects+1] = eval_card(G.hand.cards[i], {cardarea = G.hand, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, extra_enhancement = true})
                        end
                    end
                    G.hand.cards[i].ability = old_ability
                    G.hand.cards[i].config.center = old_center
                    G.hand.cards[i].config.center_key = old_center_key
                    G.hand.cards[i]:set_sprites(old_center)

                    for k=1, #G.jokers.cards do
                        --calculate the joker individual card effects
                        local eval = G.jokers.cards[k]:calculate_joker({cardarea = G.hand, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = G.hand.cards[i], individual = true, callback = function(card, eval, retrigger)
                        if eval then 
                            mod_percent = true
                            table.insert(effects, eval)
effects[#effects].from_retrigger = retrigger
end end, no_retrigger_anim = true})

                    end

                    if reps[j] == 1 then 
                        --Check for hand doubling

                        --From Red seal
                        local eval = eval_card(G.hand.cards[i], {repetition_only = true,cardarea = G.hand, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, repetition = true, card_effects = effects})
                        if next(eval) and (next(effects[1]) or #effects > 1) then 
                            for h  = 1, eval.seals.repetitions do
                                reps[#reps+1] = eval
                            end
                        end

                        --From Joker
                        for j=1, #G.jokers.cards do
                            --calculate the joker effects
                            local eval = eval_card(G.jokers.cards[j], {cardarea = G.hand, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = G.hand.cards[i], repetition = true, card_effects = effects, callback = function(card, ret) eval = {jokers = ret}
                            if next(eval) then 
                                for h  = 1, eval.jokers.repetitions do
                                    reps[#reps+1] = eval
                                end
                            end end})
                        end
                    end
    
                    for ii = 1, #effects do
                        --if this effect came from a joker
                        if effects[ii].card and not Talisman.config_file.disable_anims then
                            mod_percent = true
                            G.E_MANAGER:add_event(Event({
                                trigger = 'immediate',
                                func = (function() effects[ii].card:juice_up(0.7);return true end)
                            }))
                        end
                        
                        --If hold mult added, do hold mult add event and add the mult to the total
                        
                        --If dollars added, add dollars to total
                        if effects[ii].dollars then 
                            ease_dollars(effects[ii].dollars)
                            card_eval_status_text(G.hand.cards[i], 'dollars', effects[ii].dollars, percent)
                        end

                        if effects[ii].h_mult then
                            mod_percent = true
                            mult = mod_mult(mult + effects[ii].h_mult)
                            update_hand_text({delay = 0}, {mult = mult})
                            card_eval_status_text(G.hand.cards[i], 'h_mult', effects[ii].h_mult, percent)
                        end
                            if effects[ii].h_chips then 
                                if effects[ii].card then juice_card(effects[ii].card) end
                                hand_chips = mod_chips(hand_chips + effects[ii].h_chips)
                                update_hand_text({delay = 0}, {chips = hand_chips})
                                card_eval_status_text(effects[ii].card, 'chips', effects[ii].h_chips, percent)
                            end

                        if effects[ii].x_mult then
                            mod_percent = true
                            mult = mod_mult(mult*effects[ii].x_mult)
                            update_hand_text({delay = 0}, {mult = mult})
                            card_eval_status_text(G.hand.cards[i], 'x_mult', effects[ii].x_mult, percent)
                            if next(find_joker("cry-Exponentia")) then
                                for _, v in pairs(find_joker("cry-Exponentia")) do
                                    local old = v.ability.extra.Emult
                                    v.ability.extra.Emult = v.ability.extra.Emult + v.ability.extra.Emult_mod
                                    card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_powmult',vars={number_format(to_big(v.ability.extra.Emult))}}})
                                    exponentia_scale_mod(v, v.ability.extra.Emult_mod, old, v.ability.extra.Emult)
                                end
                            end
                        end

                        if effects[ii].x_chips then
                        	mod_percent = true
                        	hand_chips = mod_chips(hand_chips*effects[ii].x_chips)
                        	update_hand_text({delay = 0}, {chips = hand_chips})
                        	card_eval_status_text(G.hand.cards[i], 'x_chips', effects[ii].x_chips, percent)
                        end
                        if effects[ii].e_chips then
                        	mod_percent = true
                        	hand_chips = mod_chips(hand_chips^effects[ii].e_chips)
                        	update_hand_text({delay = 0}, {chips = hand_chips})
                        	card_eval_status_text(G.hand.cards[i], 'e_chips', effects[ii].e_chips, percent)
                        end
                        if effects[ii].ee_chips then
                        	mod_percent = true
                        	hand_chips = mod_chips(hand_chips:arrow(2, effects[ii].ee_chips))
                        	update_hand_text({delay = 0}, {chips = hand_chips})
                        	card_eval_status_text(G.hand.cards[i], 'ee_chips', effects[ii].ee_chips, percent)
                        end
                        if effects[ii].eee_chips then
                        	mod_percent = true
                        	hand_chips = mod_chips(hand_chips:arrow(3, effects[ii].eee_chips))
                        	update_hand_text({delay = 0}, {chips = hand_chips})
                        	card_eval_status_text(G.hand.cards[i], 'eee_chips', effects[ii].eee_chips, percent)
                        end
                        if effects[ii].hyper_chips and type(effects[ii].hyper_chips) == 'table' then
                        	mod_percent = true
                        	hand_chips = mod_chips(hand_chips:arrow(effects[ii].hyper_chips[1], effects[ii].hyper_chips[2]))
                        	update_hand_text({delay = 0}, {chips = hand_chips})
                        	card_eval_status_text(G.hand.cards[i], 'hyper_chips', effects[ii].hyper_chips, percent)
                        end
                        if effects[ii].e_mult then
                        	mod_percent = true
                        	mult = mod_mult(mult^effects[ii].e_mult)
                        	update_hand_text({delay = 0}, {mult = mult})
                        	card_eval_status_text(G.hand.cards[i], 'e_mult', effects[ii].e_mult, percent)
                        end
                        if effects[ii].ee_mult then
                        	mod_percent = true
                        	mult = mod_mult(mult:arrow(2, effects[ii].ee_mult))
                        	update_hand_text({delay = 0}, {mult = mult})
                        	card_eval_status_text(G.hand.cards[i], 'ee_mult', effects[ii].ee_mult, percent)
                        end
                        if effects[ii].eee_mult then
                        	mod_percent = true
                        	mult = mod_mult(mult:arrow(3, effects[ii].eee_mult))
                        	update_hand_text({delay = 0}, {mult = mult})
                        	card_eval_status_text(G.hand.cards[i], 'eee_mult', effects[ii].eee_mult, percent)
                        end
                        if effects[ii].hyper_mult and type(effects[ii].hyper_mult) == 'table' then
                        	mod_percent = true
                        	mult = mod_mult(mult:arrow(effects[ii].hyper_mult[1], effects[ii].hyper_mult[2]))
                        	update_hand_text({delay = 0}, {mult = mult})
                        	card_eval_status_text(G.hand.cards[i], 'hyper_mult', effects[ii].hyper_mult, percent)
                        end
                        
                        if effects[ii].message then
                            mod_percent = true
                            update_hand_text({delay = 0}, {mult = mult})
                            card_eval_status_text(G.hand.cards[i], 'extra', nil, percent, nil, effects[ii])
                        end
                                        if effects[ii].from_retrigger then
                        card_eval_status_text(effects[ii].from_retrigger.card, 'jokers', nil, nil, nil, effects[ii].from_retrigger)
                    end 
                
end
                    j = j +1
                end
            end
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        --Joker Effects
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        percent = percent + percent_delta
        local numcards = #G.jokers.cards + #G.consumeables.cards
        if G.GAME.modifiers.cry_beta then numcards = #G.jokers.cards end
        for i=1, numcards do
            local _card = G.jokers.cards[i] or G.consumeables.cards[i - #G.jokers.cards]
            --calculate the joker edition effects
            local edition_effects = eval_card(_card, {cardarea = G.jokers, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, edition = true})
            if not edition_effects then edition_effects = {} end
            if edition_effects.jokers then
                edition_effects.jokers.edition = true
                if edition_effects.jokers.p_dollars_mod then
                    ease_dollars(edition_effects.jokers.p_dollars_mod)
                    card_eval_status_text(_card, 'dollars', edition_effects.jokers.p_dollars_mod, percent)
                end
                if edition_effects.jokers.chip_mod then
                    hand_chips = mod_chips(hand_chips + edition_effects.jokers.chip_mod)
                    update_hand_text({delay = 0}, {chips = hand_chips})
                    card_eval_status_text(_card, 'jokers', nil, percent, nil, {
                        message = localize{type='variable',key='a_chips',vars={edition_effects.jokers.chip_mod}},
                        chip_mod =  edition_effects.jokers.chip_mod,
                        colour =  G.C.EDITION,
                        edition = true})
                        if (effects and effects[ii] and effects[ii].edition and effects[ii].edition.x_mult_mod or edition_effects and edition_effects.jokers and edition_effects.jokers.x_mult_mod) and next(find_joker("cry-Exponentia")) then
                            for _, v in pairs(find_joker("cry-Exponentia")) do
                                local old = v.ability.extra.Emult
                                v.ability.extra.Emult = v.ability.extra.Emult + v.ability.extra.Emult_mod
                                card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_powmult',vars={number_format(to_big(v.ability.extra.Emult))}}})
                                exponentia_scale_mod(v, v.ability.extra.Emult_mod, old, v.ability.extra.Emult)
                            end
                        end
                end
                if edition_effects.jokers.mult_mod then
                    mult = mod_mult(mult + edition_effects.jokers.mult_mod)
                    update_hand_text({delay = 0}, {mult = mult})
                    card_eval_status_text(_card, 'jokers', nil, percent, nil, {
                        message = localize{type='variable',key='a_mult',vars={edition_effects.jokers.mult_mod}},
                        mult_mod =  edition_effects.jokers.mult_mod,
                        colour = G.C.DARK_EDITION,
                        edition = true})
                        if (effects and effects[ii] and effects[ii].edition and effects[ii].edition.x_mult_mod or edition_effects and edition_effects.jokers and edition_effects.jokers.x_mult_mod) and next(find_joker("cry-Exponentia")) then
                            for _, v in pairs(find_joker("cry-Exponentia")) do
                                local old = v.ability.extra.Emult
                                v.ability.extra.Emult = v.ability.extra.Emult + v.ability.extra.Emult_mod
                                card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_powmult',vars={number_format(to_big(v.ability.extra.Emult))}}})
                                exponentia_scale_mod(v, v.ability.extra.Emult_mod, old, v.ability.extra.Emult)
                            end
                        end
                end
                percent = percent+percent_delta
            end

            --calculate the joker effects
            local effects = eval_card(_card, {cardarea = G.jokers, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, joker_main = true, callback = function(_card, ret) effects = {jokers = ret}
            G.GAME.selected_back:trigger_effect({context = 'joker_main', joker =  _card, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands})

            --Any Joker effects
            if effects.jokers then 
                local extras = {mult = false, hand_chips = false}
                if effects.jokers.mult_mod then mult = mod_mult(mult + effects.jokers.mult_mod);extras.mult = true end
                if effects.jokers.chip_mod then hand_chips = mod_chips(hand_chips + effects.jokers.chip_mod);extras.hand_chips = true end
                if effects.jokers.Xmult_mod then mult = mod_mult(mult*effects.jokers.Xmult_mod);extras.mult = true  end
                if effects.jokers.Emult_mod then mult = mod_mult(mult^effects.jokers.Emult_mod);extras.mult = true end
                if effects.jokers.EEmult_mod then mult = mod_mult(mult:arrow(2, effects.jokers.EEmult_mod));extras.mult = true end
                if effects.jokers.EEEmult_mod then mult = mod_mult(mult:arrow(3, effects.jokers.EEEmult_mod));extras.mult = true end
                if effects.jokers.hypermult_mod and type(effects.jokers.hypermult_mod) == 'table' then mult = mod_mult(mult:arrow(effects.jokers.hypermult_mod[1], effects.jokers.hypermult_mod[2]));extras.mult = true end
                if effects.jokers.Xchip_mod then hand_chips = mod_chips(hand_chips*effects.jokers.Xchip_mod);extras.hand_chips = true end
                if effects.jokers.Echip_mod then hand_chips = mod_chips(hand_chips^effects.jokers.Echip_mod);extras.hand_chips = true end
                if effects.jokers.EEchip_mod then hand_chips = mod_chips(hand_chips:arrow(2, effects.jokers.EEchip_mod));extras.hand_chips = true end
                if effects.jokers.EEEchip_mod then hand_chips = mod_chips(hand_chips:arrow(3, effects.jokers.EEEchip_mod));extras.hand_chips = true end
                if effects.jokers.hyperchip_mod and type(effects.jokers.hyperchip_mod) == 'table' then hand_chips = mod_chips(hand_chips:arrow(effects.jokers.hyperchip_mod[1], effects.jokers.hyperchip_mod[2]));extras.hand_chips = true end
                update_hand_text({delay = 0}, {chips = extras.hand_chips and hand_chips, mult = extras.mult and mult})
                card_eval_status_text(_card, 'jokers', nil, percent, nil, effects.jokers)
                if effects.jokers.Xmult_mod and effects.jokers.Xmult_mod ~= 1 and next(find_joker("cry-Exponentia")) then
                    for _, v in pairs(find_joker("cry-Exponentia")) do
                        local old = v.ability.extra.Emult
                        v.ability.extra.Emult = v.ability.extra.Emult + v.ability.extra.Emult_mod
                        card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_powmult',vars={number_format(to_big(v.ability.extra.Emult))}}})
                        exponentia_scale_mod(v, v.ability.extra.Emult_mod, old, v.ability.extra.Emult)
                    end
                end
                percent = percent+percent_delta
            end

            end})
            --Joker on Joker effects
            for _, v in ipairs(G.jokers.cards) do
                local effect = v:calculate_joker({full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_joker = _card, callback = function(v, effect)
                if effect then
                    local extras = {mult = false, hand_chips = false}
                    if effect.mult_mod then mult = mod_mult(mult + effect.mult_mod);extras.mult = true end
                    if effect.chip_mod then hand_chips = mod_chips(hand_chips + effect.chip_mod);extras.hand_chips = true end
                    if effect.Xmult_mod then mult = mod_mult(mult*effect.Xmult_mod);extras.mult = true  end
                    if effect.Emult_mod then mult = mod_mult(mult^effect.Emult_mod);extras.mult = true end
                    if effect.EEmult_mod then mult = mod_mult(mult:arrow(2, effect.EEmult_mod));extras.mult = true end
                    if effect.EEEmult_mod then mult = mod_mult(mult:arrow(3, effect.EEEmult_mod));extras.mult = true end
                    if effect.hypermult_mod and type(effect.hypermult_mod) == 'table' then mult = mod_mult(mult:arrow(effect.hypermult_mod[1], effect.hypermult_mod[2]));extras.mult = true end
                    if effect.Xchip_mod then hand_chips = mod_chips(hand_chips*effect.Xchip_mod);extras.hand_chips = true end
                    if effect.Echip_mod then hand_chips = mod_chips(hand_chips^effect.Echip_mod);extras.hand_chips = true end
                    if effect.EEchip_mod then hand_chips = mod_chips(hand_chips:arrow(2, effect.EEchip_mod));extras.hand_chips = true end
                    if effect.EEEchip_mod then hand_chips = mod_chips(hand_chips:arrow(3, effect.EEEchip_mod));extras.hand_chips = true end
                    if effect.hyperchip_mod and type(effect.hyperchip_mod) == 'table' then hand_chips = mod_chips(hand_chips:arrow(effect.hyperchip_mod[1], effect.hyperchip_mod[2]));extras.hand_chips = true end
                    if extras.mult or extras.hand_chips then update_hand_text({delay = 0}, {chips = extras.hand_chips and hand_chips, mult = extras.mult and mult}) end
                    if extras.mult or extras.hand_chips then card_eval_status_text(v, 'jokers', nil, percent, nil, effect) end
                    if effects.Xmult_mod and next(find_joker("cry-Exponentia")) then
                        for _, v in pairs(find_joker("cry-Exponentia")) do
                            local old = v.ability.extra.Emult
                            v.ability.extra.Emult = v.ability.extra.Emult + v.ability.extra.Emult_mod
                            card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_powmult',vars={number_format(to_big(v.ability.extra.Emult))}}})
                            exponentia_scale_mod(v, v.ability.extra.Emult_mod, old, v.ability.extra.Emult)
                        end
                    end
                    if effect.Xmult_mod and effect.Xmult_mod ~= 1 and next(find_joker("cry-Exponentia")) then
                        for _, v in pairs(find_joker("cry-Exponentia")) do
                            local old = v.ability.extra.Emult
                            v.ability.extra.Emult = v.ability.extra.Emult + v.ability.extra.Emult_mod
                            card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_powmult',vars={number_format(to_big(v.ability.extra.Emult))}}})
                            exponentia_scale_mod(v, v.ability.extra.Emult_mod, old, v.ability.extra.Emult)
                        end
                    end
                    percent = percent+percent_delta
                end end}) end if edition_effects.jokers then
                if edition_effects.jokers.x_mult_mod then
                	mult = mod_mult(mult*edition_effects.jokers.x_mult_mod)
                	update_hand_text({delay = 0}, {mult = mult})
                	card_eval_status_text(_card, 'jokers', nil, percent, nil, {
                		message = localize{type='variable',key='a_xmult',vars={edition_effects.jokers.x_mult_mod}},
                		x_mult_mod =  edition_effects.jokers.x_mult_mod,
                		colour =  G.C.EDITION,
                		edition = true})
                end
                if G.jokers.cards and G.jokers.cards[i] and G.jokers.cards[i].edition then
                	local trg = G.jokers.cards[i]
                	local edi = trg.edition
                	if edi.x_chips then
                		hand_chips = mod_chips(hand_chips * edi.x_chips)
                		update_hand_text({delay = 0}, {chips = hand_chips})
                		card_eval_status_text(trg, 'extra', nil, percent, nil,
                		{message = 'X'.. edi.x_chips ..' Chips',
                		edition = true,
                		x_chips = true})
                	end
                	if edi.e_chips then
                		hand_chips = mod_chips(hand_chips ^ edi.e_chips)
                		update_hand_text({delay = 0}, {chips = hand_chips})
                		card_eval_status_text(trg, 'extra', nil, percent, nil,
                		{message = '^'.. edi.e_chips ..' Chips',
                		edition = true,
                		e_chips = true})
                	end
                	if edi.ee_chips then
                		hand_chips = mod_chips(hand_chips:arrow(2, edi.ee_chips))
                		update_hand_text({delay = 0}, {chips = hand_chips})
                		card_eval_status_text(trg, 'extra', nil, percent, nil,
                		{message = '^^'.. edi.ee_chips ..' Chips',
                		edition = true,
                		ee_chips = true})
                	end
                	if edi.eee_chips then
                		hand_chips = mod_chips(hand_chips:arrow(3, edi.eee_chips))
                		update_hand_text({delay = 0}, {chips = hand_chips})
                		card_eval_status_text(trg, 'extra', nil, percent, nil,
                		{message = '^^^'.. edi.eee_chips ..' Chips',
                		edition = true,
                		eee_chips = true})
                	end
                	if edi.hyper_chips and type(edi.hyper_chips) == 'table' then
                		hand_chips = mod_chips(hand_chips:arrow(edi.hyper_chips[1], edi.hyper_chips[2]))
                		update_hand_text({delay = 0}, {chips = hand_chips})
                		card_eval_status_text(trg, 'extra', nil, percent, nil,
                		{message = (edi.hyper_chips[1] > 5 and ('{' .. edi.hyper_chips[1] .. '}') or string.rep('^', edi.hyper_chips[1])) .. edi.hyper_chips[2] ..' Chips',
                		edition = true,
                		eee_chips = true})
                	end
                	if edi.e_mult then
                		mult = mod_mult(mult ^ edi.e_mult)
                		update_hand_text({delay = 0}, {mult = mult})
                		card_eval_status_text(trg, 'extra', nil, percent, nil,
                		{message = '^'.. edi.e_mult ..' Mult',
                		edition = true,
                		e_mult = true})
                	end
                	if edi.ee_mult then
                		mult = mod_mult(mult:arrow(2, edi.ee_mult))
                		update_hand_text({delay = 0}, {mult = mult})
                		card_eval_status_text(trg, 'extra', nil, percent, nil,
                		{message = '^^'.. edi.ee_mult ..' Mult',
                		edition = true,
                		ee_mult = true})
                	end
                	if edi.eee_mult then
                		mult = mod_mult(mult:arrow(3, edi.eee_mult))
                		update_hand_text({delay = 0}, {mult = mult})
                		card_eval_status_text(trg, 'extra', nil, percent, nil,
                		{message = '^^^'.. edi.eee_mult ..' Mult',
                		edition = true,
                		eee_mult = true})
                	end
                	if edi.hyper_mult and type(edi.hyper_mult) == 'table' then
                		mult = mod_mult(mult:arrow(edi.hyper_mult[1], edi.hyper_mult[2]))
                		update_hand_text({delay = 0}, {mult = mult})
                		card_eval_status_text(trg, 'extra', nil, percent, nil,
                		{message = (edi.hyper_mult[1] > 5 and ('{' .. edi.hyper_mult[1] .. '}') or string.rep('^', edi.hyper_mult[1])) .. edi.hyper_mult[2] ..' Mult',
                		edition = true,
                		hyper_mult = true})
                	end
                end
                edition_effects.jokers.x_mult_mod = nil
                if edition_effects.jokers.x_mult_mod then
                    mult = mod_mult(mult*edition_effects.jokers.x_mult_mod)
                    update_hand_text({delay = 0}, {mult = mult})
                    card_eval_status_text(_card, 'jokers', nil, percent, nil, {
                        message = localize{type='variable',key='a_xmult',vars={edition_effects.jokers.x_mult_mod}},
                        x_mult_mod =  edition_effects.jokers.x_mult_mod,
                        colour =  G.C.EDITION,
                        edition = true})
                        if (effects and effects[ii] and effects[ii].edition and effects[ii].edition.x_mult_mod or edition_effects and edition_effects.jokers and edition_effects.jokers.x_mult_mod) and next(find_joker("cry-Exponentia")) then
                            for _, v in pairs(find_joker("cry-Exponentia")) do
                                local old = v.ability.extra.Emult
                                v.ability.extra.Emult = v.ability.extra.Emult + v.ability.extra.Emult_mod
                                card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_powmult',vars={number_format(to_big(v.ability.extra.Emult))}}})
                                exponentia_scale_mod(v, v.ability.extra.Emult_mod, old, v.ability.extra.Emult)
                            end
                        end
                end
                percent = percent+percent_delta
            end
        end

        local nu_chip, nu_mult = G.GAME.selected_back:trigger_effect{context = 'final_scoring_step', chips = hand_chips, mult = mult}
        mult = mod_mult(nu_mult or mult)
        hand_chips = mod_chips(nu_chip or hand_chips)

        local cards_destroyed = {}
        for i=1, #scoring_hand do
            local destroyed = nil
            --un-highlight all cards
            highlight_card(scoring_hand[i],(i-0.999)/(#scoring_hand-0.998),'down')

            for j = 1, #G.jokers.cards do
                destroyed = G.jokers.cards[j]:calculate_joker({destroying_card = scoring_hand[i], full_hand = G.play.cards, callback = function(card, ret) if ret then destroyed=true end end})
                if destroyed then break end
            end

            if SMODS.has_enhancement(scoring_hand[i], 'm_glass') and not scoring_hand[i].debuff and pseudorandom('glass') < cry_prob(scoring_hand[i].ability.cry_prob, scoring_hand[i].ability.extra or G.P_CENTERS.m_glass.config.extra, scoring_hand[i].ability.cry_rigged)/(scoring_hand[i].ability.name == 'Glass Card' and scoring_hand[i].ability.extra or G.P_CENTERS.m_glass.config.extra) then
                destroyed = true
            end

            if scoring_hand[i].will_shatter then destroyed = true end
            if scoring_hand[i]:calculate_seal({destroying_card = scoring_hand[i], full_hand = G.play.cards}) and not scoring_hand[i].ability.eternal then
                destroyed = true
            end
            
            if destroyed then 
                if SMODS.has_enhancement(scoring_hand[i], 'm_glass') then
                    scoring_hand[i].shattered = true
                else 
                    scoring_hand[i].destroyed = true
                end 
                cards_destroyed[#cards_destroyed+1] = scoring_hand[i]
            end
        end
        for j=1, #G.jokers.cards do
            eval_card(G.jokers.cards[j], {cardarea = G.jokers, remove_playing_cards = true, removed = cards_destroyed})
        end
            G.GAME.selected_back:trigger_effect({context = 'remove_playing_cards', removed = cards_destroyed})

        local glass_shattered = {}
        for k, v in ipairs(cards_destroyed) do
            if v.shattered then glass_shattered[#glass_shattered+1] = v end
        end

        check_for_unlock{type = 'shatter', shattered = glass_shattered}
        
        for i=1, #cards_destroyed do
            G.E_MANAGER:add_event(Event({
                func = function()
                    if SMODS.has_enhancement(cards_destroyed[i], 'm_glass') then
                        cards_destroyed[i]:shatter()
                    else
                        cards_destroyed[i]:start_dissolve()
                    end
                  return true
                end
              }))
        end
    else
        mult = mod_mult(0)
        hand_chips = mod_chips(0)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = (function()
                SMODS.juice_up_blind()
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                    play_sound('tarot2', 0.76, 0.4);return true end}))
                play_sound('tarot2', 1, 0.4)
                return true
            end)
        }))

        play_area_status_text("Not Allowed!")--localize('k_not_allowed_ex'), true)
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        --Joker Debuff Effects
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        for i=1, #G.jokers.cards do
            
            --calculate the joker effects
            local effects = eval_card(G.jokers.cards[i], {cardarea = G.jokers, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, debuffed_hand = true, callback = function(card, ret) effects = {jokers = ret}

            --Any Joker effects
            if effects.jokers then
                card_eval_status_text(card, 'jokers', nil, percent, nil, effects.jokers)
                percent = percent+percent_delta
            end
 end})        end
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',delay = 0.4,
        func = (function()  update_hand_text({delay = 0, immediate = true}, {mult = 0, chips = 0, chip_total = G.GAME.blind.cry_cap_score and G.GAME.blind:cry_cap_score(math.floor(hand_chips*mult)) or math.floor(hand_chips*mult), level = '', handname = ''});play_sound('button', 0.9, 0.6);return true end)
      }))
          G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = (function() G.GAME.current_round.current_hand.cry_asc_num = 0;G.GAME.current_round.current_hand.cry_asc_num_text = '';return true end)
          }))
      check_and_set_high_score('hand', hand_chips*mult)

      check_for_unlock({type = 'chip_score', chips = math.floor(hand_chips*mult)})
   
    if to_big(hand_chips)*mult > to_big(0) then
        delay(0.8)
        G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function() play_sound('chips2');return true end)
        }))
    end
    G.E_MANAGER:add_event(Event({
      trigger = 'ease',
      blocking = false,
      ref_table = G.GAME,
      ref_value = 'chips',
      ease_to = G.GAME.chips + (G.GAME.blind.cry_cap_score and G.GAME.blind:cry_cap_score(math.floor(hand_chips*mult)) or math.floor(hand_chips*mult)),
      delay =  0.5,
      func = (function(t) return math.floor(t) end)
    }))
    G.E_MANAGER:add_event(Event({
      trigger = 'ease',
      blocking = true,
      ref_table = G.GAME.current_round.current_hand,
      ref_value = 'chip_total',
      ease_to = 0,
      delay =  0.5,
      func = (function(t) return math.floor(t) end)
    }))
    G.E_MANAGER:add_event(Event({
      trigger = 'immediate',
      func = (function() G.GAME.current_round.current_hand.handname = '';return true end)
    }))
    delay(0.3)

    for i=1, #G.jokers.cards do
        --calculate the joker after hand played effects
        local effects = eval_card(G.jokers.cards[i], {cardarea = G.jokers, full_hand = G.play.cards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, after = true, callback = function(card, ret) effects = {jokers = ret}
        if effects.jokers then
            card_eval_status_text(card, 'jokers', nil, percent, nil, effects.jokers)
            percent = percent + percent_delta
        end
    end

    }) end
 
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function()     
            if G.GAME.modifiers.debuff_played_cards then 
                for k, v in ipairs(scoring_hand) do v.ability.perma_debuff = true end
            end
        return true end)
      }))

  end
  
  G.FUNCS.draw_from_play_to_discard = function(e)
    local play_count = #G.play.cards
    local it = 1
    for k, v in ipairs(G.play.cards) do
        if (not v.shattered) and (not v.destroyed) then 
            draw_card(G.play,G.discard, it*100/play_count,'down', false, v)
            it = it + 1
        end
    end
  end

  G.FUNCS.draw_from_play_to_hand = function(cards)
    local gold_count = #cards
    for i=1, gold_count do --draw cards from play
        if not cards[i].shattered and not cards[i].destroyed then
            draw_card(G.play,G.hand, i*100/gold_count,'up', true, cards[i])
        end
    end
  end
  
  G.FUNCS.draw_from_discard_to_deck = function(e)
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            local discard_count = #G.discard.cards
            for i=1, discard_count do --draw cards from deck
                draw_card(G.discard, G.deck, i*100/discard_count,'up', nil ,nil, 0.005, i%2==0, nil, math.max((21-i)/20,0.7))
            end
            return true
        end
      }))
  end

  G.FUNCS.draw_from_hand_to_deck = function(e)
    local hand_count = #G.hand.cards
    for i=1, hand_count do --draw cards from deck
        draw_card(G.hand, G.deck, i*100/hand_count,'down', nil, nil,  0.08)
    end
  end
  
  G.FUNCS.draw_from_hand_to_discard = function(e)
    local hand_count = #G.hand.cards
    for i=1, hand_count do
        draw_card(G.hand,G.discard, i*100/hand_count,'down', nil, nil, 0.07)
    end
end

G.FUNCS.evaluate_round = function()
    total_cashout_rows = 0
    local pitch = 0.95
    local dollars = 0

    if to_big(G.GAME.chips) >= to_big(G.GAME.blind.chips) then
        add_round_eval_row({dollars = G.GAME.blind.dollars, name='blind1', pitch = pitch})
        pitch = pitch + 0.06
        dollars = dollars + G.GAME.blind.dollars
    else
        add_round_eval_row({dollars = 0, name='blind1', pitch = pitch, saved = true})
        pitch = pitch + 0.06
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 1.3*math.min(G.GAME.blind.dollars+2, 7)/2*0.15 + 0.5,
        func = function()
          G.GAME.blind:defeat()
          return true
        end
      }))
    delay(0.2)
    G.E_MANAGER:add_event(Event({
        func = function()
            ease_background_colour_blind(G.STATES.ROUND_EVAL, '')
            return true
        end
    }))
    G.GAME.selected_back:trigger_effect({context = 'eval'})

    if G.GAME.current_round.hands_left > 0 and not G.GAME.modifiers.no_extra_hand_money then
        add_round_eval_row({dollars = G.GAME.current_round.hands_left*(G.GAME.modifiers.money_per_hand or 1), disp = G.GAME.current_round.hands_left, bonus = true, name='hands', pitch = pitch})
        pitch = pitch + 0.06
        dollars = dollars + G.GAME.current_round.hands_left*(G.GAME.modifiers.money_per_hand or 1)
    end
    if G.GAME.current_round.discards_left > 0 and G.GAME.modifiers.money_per_discard then
        add_round_eval_row({dollars = G.GAME.current_round.discards_left*(G.GAME.modifiers.money_per_discard), disp = G.GAME.current_round.discards_left, bonus = true, name='discards', pitch = pitch})
        pitch = pitch + 0.06
        dollars = dollars +  G.GAME.current_round.discards_left*(G.GAME.modifiers.money_per_discard)
    end
    for i = 1, #G.playing_cards do
    	local CARD = G.playing_cards[i]
        CARD.cry_debuff_immune = false
    end
    for i = 1, #G.jokers.cards do
        local ret = G.jokers.cards[i]:calculate_dollar_bonus()
        if ret then
            add_round_eval_row({dollars = ret, bonus = true, name='joker'..i, pitch = pitch, card = G.jokers.cards[i]})
            pitch = pitch + 0.06
            dollars = dollars + ret
        end
    end
    for i = 1, #G.GAME.tags do
        local ret = G.GAME.tags[i]:apply_to_run({type = 'eval'})
        if ret then
            add_round_eval_row({dollars = ret.dollars, bonus = true, name='tag'..i, pitch = pitch, condition = ret.condition, pos = ret.pos, tag = ret.tag})
            pitch = pitch + 0.06
            dollars = dollars + ret.dollars
        end
    end
    if G.GAME.dollars >= 5 and not G.GAME.modifiers.no_interest and G.GAME.cry_payload then
        add_round_eval_row({bonus = true, payload = G.GAME.cry_payload, name='interest_payload', pitch = pitch, dollars = G.GAME.interest_amount*G.GAME.cry_payload*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5)})
        pitch = pitch + 0.06
        if not G.GAME.seeded and not G.GAME.challenge then
            if G.GAME.interest_amount*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5) == G.GAME.interest_amount*G.GAME.interest_cap/5 then 
                G.PROFILES[G.SETTINGS.profile].career_stats.c_round_interest_cap_streak = G.PROFILES[G.SETTINGS.profile].career_stats.c_round_interest_cap_streak + 1
            else
                G.PROFILES[G.SETTINGS.profile].career_stats.c_round_interest_cap_streak = 0
            end
        end
        check_for_unlock({type = 'interest_streak'})
        dollars = dollars + G.GAME.interest_amount*G.GAME.cry_payload*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5)
        G.GAME.cry_payload = nil
    elseif G.GAME.dollars >= 5 and not G.GAME.modifiers.no_interest then
        add_round_eval_row({bonus = true, name='interest', pitch = pitch, dollars = G.GAME.interest_amount*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5)})
        pitch = pitch + 0.06
        if not G.GAME.seeded and not G.GAME.challenge then
            if G.GAME.interest_amount*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5) == G.GAME.interest_amount*G.GAME.interest_cap/5 then 
                G.PROFILES[G.SETTINGS.profile].career_stats.c_round_interest_cap_streak = G.PROFILES[G.SETTINGS.profile].career_stats.c_round_interest_cap_streak + 1
            else
                G.PROFILES[G.SETTINGS.profile].career_stats.c_round_interest_cap_streak = 0
            end
        end
        check_for_unlock({type = 'interest_streak'})
        dollars = dollars + G.GAME.interest_amount*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5)
    end

    pitch = pitch + 0.06

    if total_cashout_rows > 7 then
        local total_hidden = total_cashout_rows - 7
    
        G.E_MANAGER:add_event(Event({
            trigger = 'before',delay = 0.38,
            func = function()
                local hidden = {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.O, config={object = DynaText({
                        string = {localize{type = 'variable', key = 'cashout_hidden', vars = {total_hidden}}}, 
                        colours = {G.C.WHITE}, shadow = true, float = false, 
                        scale = 0.45,
                        font = G.LANGUAGES['en-us'].font, pop_in = 0
                    })}}
                }}
    
                G.round_eval:add_child(hidden, G.round_eval:get_UIE_by_ID('bonus_round_eval'))
                return true
            end
        }))
    end
    add_round_eval_row({name = 'bottom', dollars = dollars})
    Talisman.dollars = dollars
end

G.FUNCS.tutorial_controller = function()
    if G.F_SKIP_TUTORIAL then
        G.SETTINGS.tutorial_complete = true
        G.SETTINGS.tutorial_progress = nil
        return
    end
    G.SETTINGS.tutorial_progress = G.SETTINGS.tutorial_progress or 
    {
        forced_shop = {'j_joker', 'c_empress'},
        forced_voucher = 'v_grabber',
        forced_tags = {'tag_handy', 'tag_garbage'},
        hold_parts = {},
        completed_parts = {},
    }
    if not G.SETTINGS.paused and (not G.SETTINGS.tutorial_complete) then
        if G.STATE == G.STATES.BLIND_SELECT and G.blind_select and not G.SETTINGS.tutorial_progress.completed_parts['small_blind'] then
            G.SETTINGS.tutorial_progress.section = 'small_blind'
            G.FUNCS.tutorial_part('small_blind')
            G.SETTINGS.tutorial_progress.completed_parts['small_blind']  = true
            G:save_progress()
        end
        if G.STATE == G.STATES.BLIND_SELECT and G.blind_select and not G.SETTINGS.tutorial_progress.completed_parts['big_blind'] and G.GAME.round > 0 then
            G.SETTINGS.tutorial_progress.section = 'big_blind'
            G.FUNCS.tutorial_part('big_blind')
            G.SETTINGS.tutorial_progress.completed_parts['big_blind']  = true
            G.SETTINGS.tutorial_progress.forced_tags = nil
            G:save_progress()
        end
        if G.STATE == G.STATES.SELECTING_HAND and not G.SETTINGS.tutorial_progress.completed_parts['second_hand'] and G.SETTINGS.tutorial_progress.hold_parts['big_blind'] then
            G.SETTINGS.tutorial_progress.section = 'second_hand'
            G.FUNCS.tutorial_part('second_hand')
            G.SETTINGS.tutorial_progress.completed_parts['second_hand']  = true
            G:save_progress()
        end
        if G.SETTINGS.tutorial_progress.hold_parts['second_hand'] then
            G.SETTINGS.tutorial_complete = true
        end
        if not G.SETTINGS.tutorial_progress.completed_parts['first_hand_section'] then 
            if G.STATE == G.STATES.SELECTING_HAND and not G.SETTINGS.tutorial_progress.completed_parts['first_hand'] then
                G.SETTINGS.tutorial_progress.section = 'first_hand'
                G.FUNCS.tutorial_part('first_hand')
                G.SETTINGS.tutorial_progress.completed_parts['first_hand']  = true
                G:save_progress()
            end
            if G.STATE == G.STATES.SELECTING_HAND and not G.SETTINGS.tutorial_progress.completed_parts['first_hand_2'] and G.SETTINGS.tutorial_progress.hold_parts['first_hand']  then
                G.FUNCS.tutorial_part('first_hand_2')
                G.SETTINGS.tutorial_progress.completed_parts['first_hand_2']  = true
                G:save_progress()
            end
            if G.STATE == G.STATES.SELECTING_HAND and not G.SETTINGS.tutorial_progress.completed_parts['first_hand_3'] and G.SETTINGS.tutorial_progress.hold_parts['first_hand_2']  then
                G.FUNCS.tutorial_part('first_hand_3')
                G.SETTINGS.tutorial_progress.completed_parts['first_hand_3']  = true
                G:save_progress()
            end
            if G.STATE == G.STATES.SELECTING_HAND and not G.SETTINGS.tutorial_progress.completed_parts['first_hand_4'] and G.SETTINGS.tutorial_progress.hold_parts['first_hand_3']  then
                G.FUNCS.tutorial_part('first_hand_4')
                G.SETTINGS.tutorial_progress.completed_parts['first_hand_4']  = true
                G.SETTINGS.tutorial_progress.completed_parts['first_hand_section']  = true
                G:save_progress()
            end
        end
         if G.STATE == G.STATES.SHOP and G.shop and G.shop.VT.y < 5 and not G.SETTINGS.tutorial_progress.completed_parts['shop_1'] then
            G.SETTINGS.tutorial_progress.section = 'shop'
            G.FUNCS.tutorial_part('shop_1')
            G.SETTINGS.tutorial_progress.completed_parts['shop_1']  = true
            G.SETTINGS.tutorial_progress.forced_voucher = nil
            G:save_progress()
        end
    end
end

G.FUNCS.tutorial_part = function(_part)
    local step = 1
    G.SETTINGS.paused = true
    if _part == 'small_blind' then 
        step = tutorial_info({
            text_key = 'sb_1',
            attach = {major = G.ROOM_ATTACH, type = 'cm', offset = {x = 0, y = 0}},
            step = step,
        })
        step = tutorial_info({
            text_key = 'sb_2',
            attach = {major = G.ROOM_ATTACH, type = 'cm', offset = {x = 0, y = 0}},
            step = step,
        })
        step = tutorial_info({
            text_key = 'sb_3',
            highlight = {
                G.blind_select.UIRoot.children[1].children[1].config.object:get_UIE_by_ID('blind_name'),
                G.blind_select.UIRoot.children[1].children[1].config.object:get_UIE_by_ID('blind_desc'),
            },
            attach = {major =  G.blind_select.UIRoot.children[1].children[1], type = 'tr', offset = {x = 2, y = 4}},
            step = step,
        })
        step = tutorial_info({
            text_key = 'sb_4',
            highlight = {
                G.blind_select.UIRoot.children[1].children[1]
            },
            snap_to = function() 
                if G.blind_select and G.blind_select.UIRoot and G.blind_select.UIRoot.children[1] and G.blind_select.UIRoot.children[1].children[1] and G.blind_select.UIRoot.children[1].children[1].config.object then 
                    return G.blind_select.UIRoot.children[1].children[1].config.object:get_UIE_by_ID('select_blind_button') end
                end,
            attach = {major =  G.blind_select.UIRoot.children[1].children[1], type = 'tr', offset = {x = 2, y = 4}},
            step = step,
            no_button = true,
            button_listen = 'select_blind'
        })
    elseif _part == 'big_blind' then 
        step = tutorial_info({
            text_key = 'bb_1',
            highlight = {
                G.blind_select.UIRoot.children[1].children[2].config.object:get_UIE_by_ID('blind_name'),
                G.blind_select.UIRoot.children[1].children[2].config.object:get_UIE_by_ID('blind_desc'),
            },
            hard_set = true,
            attach = {major =  G.HUD, type = 'cm', offset = {x = 0, y = -2}},
            step = step,
        })
        step = tutorial_info({
            text_key = 'bb_2',
            highlight = {
                G.blind_select.UIRoot.children[1].children[2].config.object:get_UIE_by_ID('blind_name'),
                G.blind_select.UIRoot.children[1].children[2].config.object:get_UIE_by_ID('tag_desc'),
            },
            attach = {major =  G.HUD, type = 'cm', offset = {x = 0, y = -2}},
            step = step,
        })
        step = tutorial_info({
            text_key = 'bb_3',
            highlight = {
                G.blind_select.UIRoot.children[1].children[3].config.object:get_UIE_by_ID('blind_name'),
                G.blind_select.UIRoot.children[1].children[3].config.object:get_UIE_by_ID('blind_desc'),
            },
            attach = {major =  G.HUD, type = 'cm', offset = {x = 0, y = -2}},
            step = step,
        })
        step = tutorial_info({
            text_key = 'bb_4',
            highlight = {
                G.blind_select.UIRoot.children[1].children[3].config.object:get_UIE_by_ID('blind_name'),
                G.blind_select.UIRoot.children[1].children[3].config.object:get_UIE_by_ID('blind_desc'),
                G.blind_select.UIRoot.children[1].children[3].config.object:get_UIE_by_ID('blind_extras'),
                G.HUD:get_UIE_by_ID('hud_ante')
            },
            attach = {major =  G.HUD, type = 'cm', offset = {x = 0, y = -2}},
            step = step,
        })
        step = tutorial_info({
            text_key = 'bb_5',
            loc_vars = {G.GAME.win_ante},
            highlight = {
                G.blind_select,
                G.HUD:get_UIE_by_ID('hud_ante')
            },
            attach = {major =  G.HUD, type = 'cm', offset = {x = 0, y = -2}},
            step = step,
            no_button = true,
            snap_to = function() 
                if G.blind_select and G.blind_select.UIRoot and G.blind_select.UIRoot.children[1] and G.blind_select.UIRoot.children[1].children[2] and
                G.blind_select.UIRoot.children[1].children[2].config.object then 
                    return G.blind_select.UIRoot.children[1].children[2].config.object:get_UIE_by_ID('select_blind_button') end
                end,
            button_listen = 'select_blind'
        })
    elseif _part == 'first_hand' then
        step = tutorial_info({
            text_key = 'fh_1',
            attach = {major = G.ROOM_ATTACH, type = 'cm', offset = {x = 0, y = 0}},
            step = step,
        })
        step = tutorial_info({
            text_key = 'fh_2',
            highlight = {
                G.HUD:get_UIE_by_ID('hand_text_area')
            },
            attach = {major = G.ROOM_ATTACH, type = 'cm', offset = {x = 0, y = 0}},
            step = step,
        })
        step = tutorial_info({
            text_key = 'fh_3',
            attach = {major = G.ROOM_ATTACH, type = 'cm', offset = {x = 0, y = 0}},
            highlight = {
                G.HUD:get_UIE_by_ID('run_info_button')
            },
            no_button = true,
            button_listen = 'run_info',
            snap_to = function() return G.HUD:get_UIE_by_ID('run_info_button') end,
            step = step,
        })
    elseif _part == 'first_hand_2' then
        step = tutorial_info({
            hard_set = true,
            text_key = 'fh_4',
            highlight = {
                G.hand,
                G.HUD:get_UIE_by_ID('run_info_button')
            },
            attach = {major = G.hand, type = 'cl', offset = {x = -1.5, y = 0}},
            snap_to = function() return G.hand.cards[1] end,
            step = step,
        })
        step = tutorial_info({
            text_key = 'fh_5',
            highlight = {
                G.hand,
                G.buttons:get_UIE_by_ID('play_button'),
                G.HUD:get_UIE_by_ID('run_info_button')
            },
            attach = {major = G.hand, type = 'cl', offset = {x = -1.5, y = 0}},
            no_button = true,
            button_listen = 'play_cards_from_highlighted',
            step = step,
        })
    elseif _part == 'first_hand_3' then
        step = tutorial_info({
            hard_set = true,
            text_key = 'fh_6',
            highlight = {
                G.hand,
                G.buttons:get_UIE_by_ID('discard_button'),
                G.HUD:get_UIE_by_ID('run_info_button')
            },
            attach = {major = G.hand, type = 'cl', offset = {x = -1.5, y = 0}},
            no_button = true,
            button_listen = 'discard_cards_from_highlighted',
            step = step,
        })
    elseif _part == 'first_hand_4' then
        step = tutorial_info({
            hard_set = true,
            text_key = 'fh_7',
            highlight = {
                G.HUD:get_UIE_by_ID('hud_hands').parent,
            },
            attach = {major = G.ROOM_ATTACH, type = 'cm', offset = {x = 0, y = 0}},
            step = step,
        })
        step = tutorial_info({
            text_key = 'fh_8',
            highlight = {
                G.HUD:get_UIE_by_ID('hud_hands').parent,
                G.HUD:get_UIE_by_ID('row_dollars_chips'),
                G.HUD_blind
            },
            attach = {major = G.ROOM_ATTACH, type = 'cm', offset = {x = 0, y = 0}},
            step = step,
        })
    elseif _part == 'second_hand' then
        step = tutorial_info({
            text_key = 'sh_1',
            hard_set = true,
            highlight = {
                G.jokers
            },
            attach = {major =  G.HUD, type = 'cm', offset = {x = 0, y = -2}},
            step = step,
        })
        local empress = find_joker('The Empress')[1]
        if empress then 
            step = tutorial_info({
                text_key = 'sh_2',
                highlight = {
                    empress
                },
                attach = {major =  G.HUD, type = 'cm', offset = {x = 0, y = -2}},
                step = step,
            })
            step = tutorial_info({
                text_key = 'sh_3',
                attach = {major =  G.HUD, type = 'cm', offset = {x = 0, y = -2}},
                highlight = {
                    empress,
                    G.hand
                },
                no_button = true,
                button_listen = 'use_card',
                snap_to = function() return G.hand.cards[1] end,
                step = step,
            })
        end
    elseif _part == 'shop_1' then
        step = tutorial_info({
            hard_set = true,
            text_key = 's_1',
            highlight = {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent
            },
            attach = {major = G.shop, type = 'tm', offset = {x = 0, y = 4}},
            step = step,
        })
        step = tutorial_info({
            text_key = 's_2',
            highlight = {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent,
                G.shop_jokers.cards[2],
            },
            snap_to = function() return G.shop_jokers.cards[2] end,
            attach = {major = G.shop, type = 'tr', offset = {x = -0.5, y = 6}},
            no_button = true,
            button_listen = 'buy_from_shop',
            step = step,
        })
        step = tutorial_info({
            text_key = 's_3',
            loc_vars = {#G.P_CENTER_POOLS.Joker},
            highlight = function() return {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent,
                G.jokers.cards[1],
            } end,
            attach = {major = G.shop, type = 'tm', offset = {x = 0, y = 6}},
            step = step,
        })
        step = tutorial_info({
            text_key = 's_4',
            highlight = function() return {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent,
                G.jokers.cards[1],
            } end,
            attach = {major = G.shop, type = 'tm', offset = {x = 0, y = 6}},
            step = step,
        })
        step = tutorial_info({
            text_key = 's_5',
            highlight = function() return {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent,
                G.jokers,
            } end,
            attach = {major = G.shop, type = 'tm', offset = {x = 0, y = 6}},
            step = step,
        })
        step = tutorial_info({
            text_key = 's_6',
            highlight = function() return {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent,
                G.shop_jokers.cards[1],
            } end,
            snap_to = function() return G.shop_jokers.cards[1] end,
            no_button = true,
            button_listen = 'buy_from_shop',
            attach = {major = G.shop, type = 'tr', offset = {x = -0.5, y = 6}},
            step = step,
        })
        step = tutorial_info({
            text_key = 's_7',
            highlight = function() return {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent,
                G.consumeables.cards[#G.consumeables.cards],
            } end,
            attach = {major = G.shop, type = 'tm', offset = {x = 0, y = 6}},
            step = step,
        })
        step = tutorial_info({
            text_key = 's_8',
            highlight = function() return {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent,
                G.consumeables
            } end,
            attach = {major = G.shop, type = 'tm', offset = {x = 0, y = 6}},
            step = step,
        })
        step = tutorial_info({
            text_key = 's_9',
            highlight = function() return {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent,
                G.shop_vouchers,
            } end,
            snap_to = function() return G.shop_vouchers.cards[1] end,
            attach = {major = G.shop, type = 'tr', offset = {x = -4, y = 6}},
            step = step,
        })
        step = tutorial_info({
            text_key = 's_10',
            highlight = function() return {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent,
                G.shop_vouchers,
            } end,
            attach = {major = G.shop, type = 'tr', offset = {x = -4, y = 6}},
            step = step,
        })
        step = tutorial_info({
            text_key = 's_11',
            highlight = function() return {
                G.SHOP_SIGN,
                G.HUD:get_UIE_by_ID('dollar_text_UI').parent.parent.parent,
                G.shop_booster,
            } end,
            snap_to = function() return G.shop_booster.cards[1] end,
            attach = {major = G.shop, type = 'tl', offset = {x = 3, y = 6}},
            step = step,
        })
        step = tutorial_info({
            text_key = 's_12',
            highlight = function() return {
                G.shop:get_UIE_by_ID('next_round_button'),
            } end,
            snap_to = function() if G.shop then return G.shop:get_UIE_by_ID('next_round_button') end end,
            no_button = true,
            button_listen = 'toggle_shop',
            attach = {major = G.shop, type = 'tm', offset = {x = 0, y = 6}},
            step = step,
        })
    end

    
    G.E_MANAGER:add_event(Event({
        blockable = false,
        timer = 'REAL',
        func = function()
            if (G.OVERLAY_TUTORIAL.step == step and
            not G.OVERLAY_TUTORIAL.step_complete) or G.OVERLAY_TUTORIAL.skip_steps then
                if G.OVERLAY_TUTORIAL.Jimbo then G.OVERLAY_TUTORIAL.Jimbo:remove() end
                if G.OVERLAY_TUTORIAL.content then G.OVERLAY_TUTORIAL.content:remove() end
                G.OVERLAY_TUTORIAL:remove()
                G.OVERLAY_TUTORIAL = nil
                G.SETTINGS.tutorial_progress.hold_parts[_part]=true
                return true
            end
            return G.OVERLAY_TUTORIAL.step > step or G.OVERLAY_TUTORIAL.skip_steps
        end
    }), 'tutorial') 
    G.SETTINGS.paused = false
end
