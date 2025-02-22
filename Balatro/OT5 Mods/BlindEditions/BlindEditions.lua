--- STEAMODDED HEADER
--- MOD_NAME: Blind Editions
--- MOD_ID: BlindEditions
--- PREFIX: ble
--- MOD_AUTHOR: [mathguy]
--- MOD_DESCRIPTION: Blinds may now have editions.
--- VERSION: 1.0.0
--- PRIORITY: -100
----------------------------------------------
------------MOD CODE -------------------------

function SMODS.current_mod.process_loc_text()
    G.localization.descriptions.BlindEdition = {}
end

SMODS.current_mod.custom_collection_tabs = function()
	return { UIBox_button {
        count = G.ACTIVE_MOD_UI and modsCollectionTally(G.P_BLIND_EDITIONS),
        button = 'your_collection_blind_editions', label = {"Blind Editions"}, count = G.ACTIVE_MOD_UI and modsCollectionTally(G.P_BLIND_EDITIONS), minw = 5, id = 'your_collection_blind_editions'
    }}
end

G.FUNCS.your_collection_blind_editions = function(e)
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu{
	  definition = blind_edition_popup(),
	}
end

function blind_edition_popup()
    local blinds_page = nil
    local blind_matrix = {
        {},{},{}
    }
    local blind_tab = {}
    for k, v in pairs(G.P_BLIND_EDITIONS) do
        blind_tab[#blind_tab+1] = G.P_BLIND_EDITIONS[k]
    end
    local dim_x = 8
    if #blind_tab <= 9 then
        dim_x = 3
    elseif #blind_tab <= 16 then
        dim_x = 4
    elseif #blind_tab <= 20 then
        dim_x = 5
    elseif #blind_tab <= 30 then
        dim_x = 6
    elseif #blind_tab <= 35 then
        dim_x = 7
    end

    table.sort(blind_tab, function (a, b) return a.order < b.order end)
    local blind_tab2 = blind_tab

    local blinds_to_be_alerted = {}
    for k, v in ipairs(blind_tab2) do
        local discovered = v.discovered
        local model_blind = G.P_BLINDS['bl_small']
        local temp_blind = AnimatedSprite(0,0,1.3,1.3, G.ANIMATION_ATLAS[model_blind.atlas or 'blind_chips'], discovered and model_blind.pos or G.b_undiscovered.pos)
        local a_table = {
            {shader = 'dissolve', shadow_height = 0.05},
            {shader = 'dissolve'},
        }
        if v.blind_shader and (type(v.blind_shader) == "table") then
            for i, j in ipairs(v.blind_shader) do
                a_table[#a_table + 1] = {shader = j}
            end
        elseif v.blind_shader then
            a_table[#a_table + 1] = {shader = v.blind_shader}
        end
        temp_blind:define_draw_steps(a_table)
        if k == 1 then 
            G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = (function()
                G.CONTROLLER:snap_to{node = temp_blind}
                return true
            end)
            }))
        end
        temp_blind.float = true
        temp_blind.states.hover.can = true
        temp_blind.states.drag.can = false
        temp_blind.states.collide.can = true
        temp_blind.config = {blind = model_blind, force_focus = true}
        if discovered and not v.alerted then 
            blinds_to_be_alerted[#blinds_to_be_alerted+1] = temp_blind
        end
        temp_blind.hover = function()
            if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then 
                if not temp_blind.hovering and temp_blind.states.visible then
                    temp_blind.hovering = true
                    temp_blind.hover_tilt = 3
                    temp_blind:juice_up(0.05, 0.02)
                    play_sound('chips1', math.random()*0.1 + 0.55, 0.12)
                    temp_blind.config.h_popup = create_UIBox_blind_edition_popup(v, discovered)
                    temp_blind.config.h_popup_config ={align = 'cl', offset = {x=-0.1,y=0},parent = temp_blind}
                    Node.hover(temp_blind)
                    if temp_blind.children.alert then 
                        temp_blind.children.alert:remove()
                        temp_blind.children.alert = nil
                        temp_blind.config.blind.alerted = true
                        G:save_progress()
                    end
                end
            end
            temp_blind.stop_hover = function() temp_blind.hovering = false; Node.stop_hover(temp_blind); temp_blind.hover_tilt = 0 end
        end
        blind_matrix[math.ceil((k-1)/dim_x+0.001)][1+((k-1)%dim_x)] = {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
            ((k % (2 * dim_x)) == dim_x + 1) and {n=G.UIT.B, config={h=0.2,w=0.5}} or nil,
            {n=G.UIT.O, config={object = temp_blind, focus_with_object = true}},
            ((k % (2 * dim_x)) == dim_x) and {n=G.UIT.B, config={h=0.2,w=0.5}} or nil,
        }} 
    end

    local all_rows = {}
    for i, j in ipairs(blind_matrix) do
        table.insert(all_rows, {n=G.UIT.R, config={align = "cm"}, nodes=j})
    end

    local t = 
    {n=G.UIT.C, config={align = "cm"}, nodes={
        {n=G.UIT.R, config={align = "cm", minw = 3, minh = 4.5, padding = 0.1, colour = G.C.BLACK, emboss = 0.05,r = 0.1}, nodes=all_rows}
    }}
    t = {n=G.UIT.R, config={align = "cm", colour = G.C.CLEAR, paddng = 0.1, minw = 2.5,}, nodes = {t}}
    t = create_UIBox_generic_options({ back_func = G.ACTIVE_MOD_UI and "openModUI_"..G.ACTIVE_MOD_UI.id or 'your_collection', contents = {t}})
    return t
end

function create_UIBox_blind_edition_popup(blind_edition, discovered)
    local blind_text = {}
    
    local loc_vars = nil
    if blind_edition.collection_loc_vars and type(blind_edition.collection_loc_vars) == 'function' then
        loc_vars = blind_edition:collection_loc_vars() or {}
    elseif blind_edition.loc_vars and type(blind_edition.loc_vars) == 'function' then
        loc_vars = blind_edition:loc_vars() or {}
    end
    local loc_target = localize{type = 'raw_descriptions', key = blind_edition.key, set = 'BlindEdition', vars = loc_vars or {}}
    local loc_name = localize{type = 'name_text', key = blind_edition.key, set = 'BlindEdition'}
  
    if discovered then 
        local ability_text = {}
        if loc_target then 
            for k, v in ipairs(loc_target) do
                ability_text[#ability_text + 1] = {n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = v, scale = 0.35, shadow = true, colour = G.C.WHITE}}}}
            end
        end
        blind_text[#blind_text + 1] =
            {n=G.UIT.R, config={align = "cm", emboss = 0.05, r = 0.1, minw = 2.5, padding = 0.07, colour = G.C.WHITE}, nodes={
                ability_text[1] and {n=G.UIT.R, config={align = "cm", padding = 0.08, colour = mix_colours(G.C.GREY, G.C.GREY, 0.4), r = 0.1, emboss = 0.05, minw = 2.5, minh = 0.9}, nodes=ability_text} or nil
            }}
    end
    return {n=G.UIT.ROOT, config={align = "cm", padding = 0.05, colour = lighten(G.C.JOKER_GREY, 0.5), r = 0.1, emboss = 0.05}, nodes={
        {n=G.UIT.R, config={align = "cm", emboss = 0.05, r = 0.1, minw = 2.5, padding = 0.1, colour = G.C.GREY}, nodes={
            {n=G.UIT.O, config={object = DynaText({string = discovered and loc_name or localize('k_not_discovered'), colours = {G.C.UI.TEXT_LIGHT}, shadow = true, rotate = not discovered, spacing = discovered and 2 or 0, bump = true, scale = 0.4})}},
            }},
        {n=G.UIT.R, config={align = "cm"}, nodes=blind_text},
    }}
end

SMODS.BlindEditions = {}
SMODS.BlindEdition = SMODS.GameObject:extend {
    obj_table = SMODS.BlindEditions,
    obj_buffer = {},
    required_params = {
        'key',
    },
    set = 'BlindEdition',
    weight = 1,
    class_prefix = 'ble',
    inject = function(self)
        local count = 0
        for i, j in pairs(G.P_BLIND_EDITIONS) do
            count = count + 1
        end
        G.P_BLIND_EDITIONS[self.key] = self
        self.order = count + 1
    end,
    no_color = function(self)
        if not self.colour and not self.new_colour and not self.special_colour and not self.tertiary_colour then
            return true
        end
        return false
    end,
    get_weight = function(self, blind_on_deck)
        return self.weight
    end,
    in_pool = function(self, blind_on_deck)
        return true
    end,
    discovered = true
}

SMODS.BlindEdition {
    key = 'base',
    weight = 4,
    has_text = false,
    loc_txt = {
        name = "Base",
        text = {"No Effect"}
    },
}

SMODS.BlindEdition {
    key = 'foil',
    blind_shader = 'foil',
    loc_txt = {
        name = "Foil",
        text = {"X#1# Blind Size"}
    },
    blind_size_mult = 1.5,
    weight = 0.4,
    loc_vars = function(self, blind_on_deck)
        return {1.5}
    end,
    collection_loc_vars = function(self, blind_on_deck)
        return {1.5}
    end,
    dollars_mod = 1
}

SMODS.BlindEdition {
    key = 'holographic',
    blind_shader = 'holo',
    loc_txt = {
        name = "Holographic",
        text = {"-#1# Hand Size"}
    },
    weight = 0.3,
    loc_vars = function(self, blind_on_deck)
        return {1}
    end,
    collection_loc_vars = function(self, blind_on_deck)
        return {1}
    end,
    set_blind = function(self, blind_on_deck)
        G.hand:change_size(-1)
    end,
    defeat = function(self, blind_on_deck)
        G.hand:change_size(1)
    end,
    dollars_mod = 3
}

SMODS.BlindEdition {
    key = 'polychrome',
    blind_shader = 'polychrome',
    weight = 0.2,
    dollars_mod = 3,
    loc_txt = {
        name = "Polychrome",
        text = {"-#1# Hand"}
    },
    set_blind = function(self, blind_on_deck)
        if G.GAME.current_round.hands_left > 1 then
            ease_hands_played(-1)
        end
    end,
    loc_vars = function(self, blind_on_deck)
        return {1}
    end,
    collection_loc_vars = function(self, blind_on_deck)
        return {1}
    end,
    in_pool = function(self, blind_type)
        boss_blind = G.GAME.round_resets.blind_choices.Boss 
        if (boss_blind == "bl_needle") or (boss_blind == "bl_cruel_sword") or (boss_blind == "bl_jen_one") then
            return false
        end
        if (boss_blind == "bl_cry_obsidian_orb") then
            for i, j in pairs(G.GAME.defeated_blinds) do
                if (i == "bl_needle") or (i == "bl_cruel_sword") or (i == "bl_jen_one") then
                    return false
                end
            end
        end
        return true
    end
}

SMODS.BlindEdition {
    key = 'negative',
    blind_shader = 'negative',
    weight = 0.01,
    loc_txt = {
        name = "Negative",
        text = {
            "X#1# Blind Size",
            "+#2# Joker Slot"
        }
    },
    blind_size_mult = 8,
    loc_vars = function(self, blind_on_deck)
        return {8, 1}
    end,
    collection_loc_vars = function(self, blind_on_deck)
        return {8, 1}
    end,
    defeat = function(self, blind_on_deck)
        if G.jokers then 
            G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        end
    end,
}

function set_blind_editions(just_boss)
    if not G.GAME.blind_edition then
        G.GAME.blind_edition = {
            Small = "",
            Big = "",
            Boss = "",
        }
    end
    G.GAME.blind_edition.first_ante = nil
    for i, j in pairs(G.GAME.blind_edition) do
        if not just_boss or (i == "Boss") then
            local total_weight = 0
            local weight_table = {}
            for i2, j2 in pairs(G.P_BLIND_EDITIONS or {}) do
                if j2.in_pool and (type(j2.in_pool) == "function") and j2:in_pool(i) then
                    local weight = j2.get_weight and (type(j2.get_weight) == "function") and j2:get_weight(i) or j2.weight or 1
                    table.insert(weight_table, {key = j2.key, weight = weight})
                    total_weight = total_weight + weight
                end
            end
            if total_weight > 0 then
                local num = pseudorandom('blind_edition') * total_weight
                local curr_weight = 0
                local selected = weight_table[#weight_table].key
                for i2, j2 in ipairs(weight_table) do
                    curr_weight = curr_weight + j2.weight
                    if num < curr_weight then
                        selected = j2.key
                        break
                    end
                end
                G.GAME.blind_edition[i] = selected
            else
                G.GAME.blind_edition[i] = 'ble_ble_base'
            end
        end
    end
end

function type_(a)
    return type(a)
end

function dollars_to_string(dollars)
    if not dollars then
        return "-"
    end
    if dollars <= -9 then
        return "-$" .. tostring(-dollars)
    elseif dollars < 0 then
        return "-" .. string.rep("$", -dollars)
    elseif dollars >= 9 then
        return "$" .. tostring(dollars)
    elseif dollars > 0 then
        return string.rep("$", dollars)
    else
        return ""
    end
end

local old_reset_blinds = reset_blinds
function reset_blinds()
    if (G.GAME.round_resets.blind_states.Boss == 'Defeated') or (G.GAME.blind_edition.first_ante) then
        old_reset_blinds()
        set_blind_editions()
    else
        old_reset_blinds()
    end
end

----------------------------------------------
------------MOD CODE END----------------------