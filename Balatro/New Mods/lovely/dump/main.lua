LOVELY_INTEGRITY = '9089b97cc61c22e7d7cb061a9013faef963c622f20f29d007dcb889fd03b2a79'

if (love.system.getOS() == 'OS X' ) and (jit.arch == 'arm64' or jit.arch == 'arm') then jit.off() end
require "engine/object"
require "bit"
require "engine/string_packer"
require "engine/controller"
require "back"
require "tag"
require "engine/event"
require "engine/node"
require "engine/moveable"
require "engine/sprite"
require "engine/animatedsprite"
require "functions/misc_functions"
require "game"
require "globals"
require "engine/ui"
require "functions/UI_definitions"
require "functions/state_events"
require "functions/common_events"
require "functions/button_callbacks"
require "functions/misc_functions"
require "functions/test_functions"
require "card"
require "cardarea"
require "blind"
require "card_character"
require "engine/particles"
require "engine/text"
require "challenges"

math.randomseed( G.SEED )

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0
	local dt_smooth = 1/100
	local run_time = 0

	-- Main loop time.
	return function()
		run_time = love.timer.getTime()
		-- Process events.
		if love.event and G and G.CONTROLLER then
			love.event.pump()
			local _n,_a,_b,_c,_d,_e,_f,touched
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				if name == 'touchpressed' then
					touched = true
				elseif name == 'mousepressed' then 
					_n,_a,_b,_c,_d,_e,_f = name,a,b,c,d,e,f
				else
					love.handlers[name](a,b,c,d,e,f)
				end
			end
			if _n then 
				love.handlers['mousepressed'](_a,_b,_c,touched)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end
		dt_smooth = math.min(0.8*dt_smooth + 0.2*dt, 0.1)
		-- Call update and draw
		if love.update then love.update(dt_smooth) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			if love.draw then love.draw() end
			love.graphics.present()
		end

		run_time = math.min(love.timer.getTime() - run_time, 0.1)
		G.FPS_CAP = G.FPS_CAP or 500
		if run_time < 1./G.FPS_CAP then love.timer.sleep(1./G.FPS_CAP - run_time) end
	end
end

function love.load() 
	G:start_up()
	--Steam integration
	local os = love.system.getOS()
	if os == 'OS X' or os == 'Windows' then 
		local st = nil
		--To control when steam communication happens, make sure to send updates to steam as little as possible
		if os == 'OS X' then
			local dir = love.filesystem.getSourceBaseDirectory()
			local old_cpath = package.cpath
			package.cpath = package.cpath .. ';' .. dir .. '/?.so'
			st = require 'luasteam'
			package.cpath = old_cpath
		else
			st = require 'luasteam'
		end

		st.send_control = {
			last_sent_time = -200,
			last_sent_stage = -1,
			force = false,
		}
		if not (st.init and st:init()) then
			love.event.quit()
		end
		--Set up the render window and the stage for the splash screen, then enter the gameloop with :update
		G.STEAM = st
	else
	end

	--Set the mouse to invisible immediately, this visibility is handled in the G.CONTROLLER
	love.mouse.setVisible(false)
end

function love.quit()
	--Steam integration
	if G.SOUND_MANAGER then G.SOUND_MANAGER.channel:push({type = 'stop'}) end
	if G.STEAM then G.STEAM:shutdown() end
end

function love.update( dt )
	--Perf monitoring checkpoint
    timer_checkpoint(nil, 'update', true)
    G:update(dt)
end

function love.draw()
	--Perf monitoring checkpoint
    timer_checkpoint(nil, 'draw', true)
	G:draw()
end

function love.keypressed(key)
	if not _RELEASE_MODE and G.keybind_mapping[key] then love.gamepadpressed(G.CONTROLLER.keyboard_controller, G.keybind_mapping[key])
	else
		G.CONTROLLER:set_HID_flags('mouse')
		G.CONTROLLER:key_press(key)
	end
end

function love.keyreleased(key)
	if not _RELEASE_MODE and G.keybind_mapping[key] then love.gamepadreleased(G.CONTROLLER.keyboard_controller, G.keybind_mapping[key])
	else
		G.CONTROLLER:set_HID_flags('mouse')
		G.CONTROLLER:key_release(key)
	end
end

function love.gamepadpressed(joystick, button)
	button = G.button_mapping[button] or button
	G.CONTROLLER:set_gamepad(joystick)
    G.CONTROLLER:set_HID_flags('button', button)
    G.CONTROLLER:button_press(button)
end

function love.gamepadreleased(joystick, button)
	button = G.button_mapping[button] or button
    G.CONTROLLER:set_gamepad(joystick)
    G.CONTROLLER:set_HID_flags('button', button)
    G.CONTROLLER:button_release(button)
end

function love.mousepressed(x, y, button, touch)
    G.CONTROLLER:set_HID_flags(touch and 'touch' or 'mouse')
    if button == 1 then 
		G.CONTROLLER:queue_L_cursor_press(x, y)
	end
	if button == 2 then
		G.CONTROLLER:queue_R_cursor_press(x, y)
	end
end


function love.mousereleased(x, y, button)
    if button == 1 then G.CONTROLLER:L_cursor_release(x, y) end
end

function love.mousemoved(x, y, dx, dy, istouch)
	G.CONTROLLER.last_touch_time = G.CONTROLLER.last_touch_time or -1
	if next(love.touch.getTouches()) ~= nil then
		G.CONTROLLER.last_touch_time = G.TIMERS.UPTIME
	end
    G.CONTROLLER:set_HID_flags(G.CONTROLLER.last_touch_time > G.TIMERS.UPTIME - 0.2 and 'touch' or 'mouse')
end

function love.joystickaxis( joystick, axis, value )
    if math.abs(value) > 0.2 and joystick:isGamepad() then
		G.CONTROLLER:set_gamepad(joystick)
        G.CONTROLLER:set_HID_flags('axis')
    end
end

function love.errhand(msg)
	if G.F_NO_ERROR_HAND then return end
	msg = tostring(msg)

	if G.SETTINGS.crashreports and _RELEASE_MODE and G.F_CRASH_REPORTS then 
		local http_thread = love.thread.newThread([[
			local https = require('https')
			CHANNEL = love.thread.getChannel("http_channel")

			while true do
				--Monitor the channel for any new requests
				local request = CHANNEL:demand()
				if request then
					https.request(request)
				end
			end
		]])
		local http_channel = love.thread.getChannel('http_channel')
		http_thread:start()
		local httpencode = function(str)
			local char_to_hex = function(c)
				return string.format("%%%02X", string.byte(c))
			end
			str = str:gsub("\n", "\r\n"):gsub("([^%w _%%%-%.~])", char_to_hex):gsub(" ", "+")
			return str
		end
		

		local error = msg
		local file = string.sub(msg, 0,  string.find(msg, ':'))
		local function_line = string.sub(msg, string.len(file)+1)
		function_line = string.sub(function_line, 0, string.find(function_line, ':')-1)
		file = string.sub(file, 0, string.len(file)-1)
		local trace = debug.traceback()
		local boot_found, func_found = false, false
		for l in string.gmatch(trace, "(.-)\n") do
			if string.match(l, "boot.lua") then
				boot_found = true
			elseif boot_found and not func_found then
				func_found = true
				trace = ''
				function_line = string.sub(l, string.find(l, 'in function')+12)..' line:'..function_line
			end

			if boot_found and func_found then 
				trace = trace..l..'\n'
			end
		end

		http_channel:push('https://958ha8ong3.execute-api.us-east-2.amazonaws.com/?error='..httpencode(error)..'&file='..httpencode(file)..'&function_line='..httpencode(function_line)..'&trace='..httpencode(trace)..'&version='..(G.VERSION))
	end

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local font = love.graphics.setNewFont("resources/fonts/m6x11plus.ttf", 20)

	love.graphics.clear(G.C.BLACK)
	love.graphics.origin()


	local p = 'Oops! Something went wrong:\n'..msg..'\n\n'..(not _RELEASE_MODE and debug.traceback() or G.SETTINGS.crashreports and
		'Since you are opted in to sending crash reports, LocalThunk HQ was sent some useful info about what happened.\nDon\'t worry! There is no identifying or personal information. If you would like\nto opt out, change the \'Crash Report\' setting to Off' or
		'Crash Reports are set to Off. If you would like to send crash reports, please opt in in the Game settings.\nThese crash reports help us avoid issues like this in the future')

	local function draw()
		local pos = love.window.toPixels(70)
		love.graphics.push()
		love.graphics.clear(G.C.BLACK)
		love.graphics.setColor(1., 1., 1., 1.)
		love.graphics.printf(p, font, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.pop()
		love.graphics.present()

	end

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			elseif e == "keypressed" and a == "escape" then
				return
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end

function love.resize(w, h)
	if w/h < 1 then --Dont allow the screen to be too square, since pop in occurs above and below screen
		h = w/1
	end

	--When the window is resized, this code resizes the Canvas, then places the 'room' or gamearea into the middle without streching it
	if w/h < G.window_prev.orig_ratio then
		G.TILESCALE = G.window_prev.orig_scale*w/G.window_prev.w
	else
		G.TILESCALE = G.window_prev.orig_scale*h/G.window_prev.h
	end

	if G.ROOM then
		G.ROOM.T.w = G.TILE_W
		G.ROOM.T.h = G.TILE_H
		G.ROOM_ATTACH.T.w = G.TILE_W
		G.ROOM_ATTACH.T.h = G.TILE_H		

		if w/h < G.window_prev.orig_ratio then
			G.ROOM.T.x = G.ROOM_PADDING_W
			G.ROOM.T.y = (h/(G.TILESIZE*G.TILESCALE) - (G.ROOM.T.h+G.ROOM_PADDING_H))/2 + G.ROOM_PADDING_H/2
		else
			G.ROOM.T.y = G.ROOM_PADDING_H
			G.ROOM.T.x = (w/(G.TILESIZE*G.TILESCALE) - (G.ROOM.T.w+G.ROOM_PADDING_W))/2 + G.ROOM_PADDING_W/2
		end

		G.ROOM_ORIG = {
            x = G.ROOM.T.x,
            y = G.ROOM.T.y,
            r = G.ROOM.T.r
        }

		if G.buttons then G.buttons:recalculate() end
		if G.HUD then G.HUD:recalculate() end
	end

	G.WINDOWTRANS = {
		x = 0, y = 0,
		w = G.TILE_W+2*G.ROOM_PADDING_W, 
		h = G.TILE_H+2*G.ROOM_PADDING_H,
		real_window_w = w,
		real_window_h = h
	}

	G.CANV_SCALE = 1

	if love.system.getOS() == 'Windows' and false then --implement later if needed
		local render_w, render_h = love.window.getDesktopDimensions(G.SETTINGS.WINDOW.selcted_display)
		local unscaled_dims = love.window.getFullscreenModes(G.SETTINGS.WINDOW.selcted_display)[1]

		local DPI_scale = math.floor((0.5*unscaled_dims.width/render_w + 0.5*unscaled_dims.height/render_h)*500 + 0.5)/500

		if DPI_scale > 1.1 then
			G.CANV_SCALE = 1.5

			G.AA_CANVAS = love.graphics.newCanvas(G.WINDOWTRANS.real_window_w*G.CANV_SCALE, G.WINDOWTRANS.real_window_h*G.CANV_SCALE, {type = '2d', readable = true})
			G.AA_CANVAS:setFilter('linear', 'linear')
		else
			G.AA_CANVAS = nil
		end
	end

	G.CANVAS = love.graphics.newCanvas(w*G.CANV_SCALE, h*G.CANV_SCALE, {type = '2d', readable = true})
	G.CANVAS:setFilter('linear', 'linear')
end 

----------------------------------------------
------------MOD CORE--------------------------

SMODS = {}
SMODS.GUI = {}
SMODS.GUI.DynamicUIManager = {}
SMODS.BUFFERS = {
    Jokers = {},
    Tarots = {},
    Planets = {},
	Spectrals = {},
    Blinds = {},
	Seals = {},
	Vouchers = {},
}

MODDED_VERSION = "0.9.8-STEAMODDED"

function STR_UNPACK(str)
	local chunk, err = loadstring(str)
	if chunk then
	  setfenv(chunk, {})  -- Use an empty environment to prevent access to potentially harmful functions
	  local success, result = pcall(chunk)
	  if success then
		return result
	  else
		print("Error unpacking string: " .. result)
		return nil
	  end
	else
	  print("Error loading string: " .. err)
	  return nil
	end
  end



function inspect(table)
	if type(table) ~= 'table' then
		return "Not a table"
	end

	local str = ""
	for k, v in pairs(table) do
		local valueStr = type(v) == "table" and "table" or tostring(v)
		str = str .. tostring(k) .. ": " .. valueStr .. "\n"
	end

	return str
end

function inspectDepth(table, indent, depth)
	if depth and depth > 5 then  -- Limit the depth to avoid deep nesting
		return "Depth limit reached"
	end

	if type(table) ~= 'table' then  -- Ensure the object is a table
		return "Not a table"
	end

	local str = ""
	if not indent then indent = 0 end

	for k, v in pairs(table) do
		local formatting = string.rep("  ", indent) .. tostring(k) .. ": "
		if type(v) == "table" then
			str = str .. formatting .. "\n"
			str = str .. inspectDepth(v, indent + 1, (depth or 0) + 1)
		elseif type(v) == 'function' then
			str = str .. formatting .. "function\n"
		elseif type(v) == 'boolean' then
			str = str .. formatting .. tostring(v) .. "\n"
		else
			str = str .. formatting .. tostring(v) .. "\n"
		end
	end

	return str
end

function inspectFunction(func)
	if type(func) ~= 'function' then
		return "Not a function"
	end

	local info = debug.getinfo(func)
	local result = "Function Details:\n"

	if info.what == "Lua" then
		result = result .. "Defined in Lua\n"
	else
		result = result .. "Defined in C or precompiled\n"
	end

	result = result .. "Name: " .. (info.name or "anonymous") .. "\n"
	result = result .. "Source: " .. info.source .. "\n"
	result = result .. "Line Defined: " .. info.linedefined .. "\n"
	result = result .. "Last Line Defined: " .. info.lastlinedefined .. "\n"
	result = result .. "Number of Upvalues: " .. info.nups .. "\n"

	return result
end


local gameMainMenuRef = Game.main_menu
function Game.main_menu(arg_280_0, arg_280_1)
	gameMainMenuRef(arg_280_0, arg_280_1)
	UIBox({
		definition = {
			n = G.UIT.ROOT,
			config = {
				align = "cm",
				colour = G.C.UI.TRANSPARENT_DARK
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						scale = 0.3,
						text = MODDED_VERSION,
						colour = G.C.UI.TEXT_LIGHT
					}
				}
			}
		},
		config = {
			align = "tri",
			bond = "Weak",
			offset = {
				x = 0,
				y = 0.3
			},
			major = G.ROOM_ATTACH
		}
	})
end

local gameUpdateRef = Game.update
function Game.update(arg_298_0, arg_298_1)
	if G.STATE ~= G.STATES.SPLASH and G.MAIN_MENU_UI then
		local var_298_0 = G.MAIN_MENU_UI:get_UIE_by_ID("main_menu_play")

		if var_298_0 and not var_298_0.children.alert then
			var_298_0.children.alert = UIBox({
				definition = create_UIBox_card_alert({
					text = "Modded Version!",
					no_bg = true,
					scale = 0.4,
					text_rot = -0.2
				}),
				config = {
					align = "tli",
					offset = {
						x = -0.1,
						y = 0
					},
					major = var_298_0,
					parent = var_298_0
				}
			})
			var_298_0.children.alert.states.collide.can = false
		end
	end
	gameUpdateRef(arg_298_0, arg_298_1)
end

local function wrapText(text, maxChars)
	local wrappedText = ""
	local currentLineLength = 0

	for word in text:gmatch("%S+") do
		if currentLineLength + #word <= maxChars then
			wrappedText = wrappedText .. word .. ' '
			currentLineLength = currentLineLength + #word + 1
		else
			wrappedText = wrappedText .. '\n' .. word .. ' '
			currentLineLength = #word + 1
		end
	end

	return wrappedText
end

-- Helper function to concatenate author names
local function concatAuthors(authors)
	if type(authors) == "table" then
		return table.concat(authors, ", ")
	end
	return authors or "Unknown"
end

SMODS.customUIElements = {}

function SMODS.registerUIElement(modID, uiElements)
	SMODS.customUIElements[modID] = uiElements
end

function create_UIBox_mods(arg_736_0)
	local var_495_0 = 0.75  -- Scale factor for text
	local maxCharsPerLine = 50

	local wrappedDescription = wrapText(G.ACTIVE_MOD_UI.description, maxCharsPerLine)

	local authors = "Author" .. (#G.ACTIVE_MOD_UI.author > 1 and "s: " or ": ") .. concatAuthors(G.ACTIVE_MOD_UI.author)

	return (create_UIBox_generic_options({
		back_func = "mods_button",
		contents = {
			{
				n = G.UIT.R,
				config = {
					padding = 0,
					align = "tm"
				},
				nodes = {
					create_tabs({
						snap_to_nav = true,
						colour = G.C.BOOSTER,
						tabs = {
							{
								label = G.ACTIVE_MOD_UI.name,
								chosen = true,
								tab_definition_function = function()
									local modNodes = {}


									-- Authors names in blue
									table.insert(modNodes, {
										n = G.UIT.R,
										config = {
											padding = 0,
											align = "cm",
											r = 0.1,
											emboss = 0.1,
											outline = 1,
											padding = 0.07
										},
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = authors,
													shadow = true,
													scale = var_495_0 * 0.65,
													colour = G.C.BLUE,
												}
											}
										}
									})

									-- Mod description
									table.insert(modNodes, {
										n = G.UIT.R,
										config = {
											padding = 0.2,
											align = "cm"
										},
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = wrappedDescription,
													shadow = true,
													scale = var_495_0 * 0.5,
													colour = G.C.UI.TEXT_LIGHT
												}
											}
										}
									})

									local customUI = SMODS.customUIElements[G.ACTIVE_MOD_UI.id]
									if customUI then
										for _, uiElement in ipairs(customUI) do
											table.insert(modNodes, uiElement)
										end
									end

									return {
										n = G.UIT.ROOT,
										config = {
											emboss = 0.05,
											minh = 6,
											r = 0.1,
											minw = 6,
											align = "tm",
											padding = 0.2,
											colour = G.C.BLACK
										},
										nodes = modNodes
									}
								end
							},
						}
					})
				}
			}
		}
	}))
end




-- Helper function to create a clickable mod box
local function createClickableModBox(modInfo, scale)
	return {
		n = G.UIT.R,
		config = {
			padding = 0,
			align = "cm",
		},
		nodes = {
			UIBox_button({
				label = {" " .. modInfo.name .. " ", " By: " .. concatAuthors(modInfo.author) .. " "},
				shadow = true,
				scale = scale,
				colour = G.C.BOOSTER,
				button = "openModUI_" .. modInfo.id,
				minh = 0.8,
				minw = 8
			})
		}
	}
end

local function initializeModUIFunctions()
	for id, modInfo in pairs(SMODS.MODS) do
		G.FUNCS["openModUI_" .. modInfo.id] = function(arg_736_0)
			G.ACTIVE_MOD_UI = modInfo
			G.FUNCS.overlay_menu({
				definition = create_UIBox_mods(arg_736_0)
			})
		end
	end
end

function G.FUNCS.openModsDirectory(options)
    if not love.filesystem.exists("Mods") then
        love.filesystem.createDirectory("Mods")
    end

    love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/Mods")
end

function G.FUNCS.mods_buttons_page(options)
	if not options or not options.cycle_config then
		return
	end
end

function create_UIBox_mods_button()
	local scale = 0.75
	return (create_UIBox_generic_options({
		contents = {
			{
				n = G.UIT.R,
				config = {
					padding = 0,
					align = "cm"
				},
				nodes = {
					create_tabs({
						snap_to_nav = true,
						colour = G.C.BOOSTER,
						tabs = {
							{
								label = "Mods",
								chosen = true,
								tab_definition_function = function()
									return SMODS.GUI.DynamicUIManager.initTab({
										updateFunctions = {
											modsList = G.FUNCS.update_mod_list,
										},
										staticPageDefinition = SMODS.GUI.staticModListContent()
									})
								end
							},
							{

								label = " Steamodded Credits ",
								tab_definition_function = function()
									return {
										n = G.UIT.ROOT,
										config = {
											emboss = 0.05,
											minh = 6,
											r = 0.1,
											minw = 6,
											align = "cm",
											padding = 0.2,
											colour = G.C.BLACK
										},
										nodes = {
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cm"
												},
												nodes = {
													{
														n = G.UIT.T,
														config = {
															text = "Mod Loader",
															shadow = true,
															scale = scale * 0.8,
															colour = G.C.UI.TEXT_LIGHT
														}
													}
												}
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0,
													align = "cm"
												},
												nodes = {
													{
														n = G.UIT.T,
														config = {
															text = "developed by ",
															shadow = true,
															scale = scale * 0.8,
															colour = G.C.UI.TEXT_LIGHT
														}
													},
													{
														n = G.UIT.T,
														config = {
															text = "Steamo",
															shadow = true,
															scale = scale * 0.8,
															colour = G.C.BLUE
														}
													}
												}
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0.2,
													align = "cm",
												},
												nodes = {
													UIBox_button({
														minw = 3.85,
														button = "steamodded_github",
														label = {
															"Github Project"
														}
													})
												}
											},
											{
												n = G.UIT.R,
												config = {
													padding = 0.2,
													align = "cm"
												},
												nodes = {
													{
														n = G.UIT.T,
														config = {
															text = "You can report any bugs there !",
															shadow = true,
															scale = scale * 0.5,
															colour = G.C.UI.TEXT_LIGHT
														}
													}
												}
											}
										}
									}
								end
							}
						}
					})
				}
			}
		}
	}))
end

function G.FUNCS.steamodded_github(arg_736_0)
	love.system.openURL("https://github.com/Steamopollys/Steamodded")
end

function G.FUNCS.mods_button(arg_736_0)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = create_UIBox_mods_button()
	})
end

local create_UIBox_main_menu_buttonsRef = create_UIBox_main_menu_buttons
function create_UIBox_main_menu_buttons()
	local modsButton = UIBox_button({
		id = "mods_button",
		minh = 1.55,
		minw = 1.85,
		col = true,
		button = "mods_button",
		colour = G.C.BOOSTER,
		label = {"MODS"},
		scale = 0.45 * 1.2
	})
	local menu = create_UIBox_main_menu_buttonsRef()
	table.insert(menu.nodes[1].nodes[1].nodes, #menu.nodes[1].nodes[1].nodes + 1, modsButton)
	menu.nodes[1].nodes[1].config = {align = "cm", padding = 0.15, r = 0.1, emboss = 0.1, colour = G.C.L_BLACK, mid = true}
	return(menu)
end

local create_UIBox_profile_buttonRef = create_UIBox_profile_button
function create_UIBox_profile_button()
	local profile_menu = create_UIBox_profile_buttonRef()
	profile_menu.nodes[1].config = {align = "cm", padding = 0.11, r = 0.1, emboss = 0.1, colour = G.C.L_BLACK}
	return(profile_menu)
end

-- Function to find a mod by its ID
function SMODS.findModByID(modID)
    for _, mod in pairs(SMODS.MODS) do
        if mod.id == modID then
            return mod
        end
    end
    return nil  -- Return nil if no mod is found with the given ID
end

-- Disable achievments and crash report upload
function initGlobals()
	G.F_NO_ACHIEVEMENTS = true
	G.F_CRASH_REPORTS = false
end

function G.FUNCS.update_mod_list(args)
	if not args or not args.cycle_config then return end
	SMODS.GUI.DynamicUIManager.updateDynamicAreas({
		["modsList"] = SMODS.GUI.dynamicModListContent(args.cycle_config.current_option)
	})
end

-- Same as Balatro base game code, but accepts a value to match against (rather than the index in the option list)
-- e.g. create_option_cycle({ current_option = 1 })  vs. SMODS.GUID.createOptionSelector({ current_option = "Page 1/2" })
function SMODS.GUI.createOptionSelector(args)
	args = args or {}
	args.colour = args.colour or G.C.RED
	args.options = args.options or {
		'Option 1',
		'Option 2'
	}

	local current_option_index = 1
	for i, option in ipairs(args.options) do
		if option == args.current_option then
			current_option_index = i
			break
		end
	end
	args.current_option_val = args.options[current_option_index]
	args.current_option = current_option_index
	args.opt_callback = args.opt_callback or nil
	args.scale = args.scale or 1
	args.ref_table = args.ref_table or nil
	args.ref_value = args.ref_value or nil
	args.w = (args.w or 2.5)*args.scale
	args.h = (args.h or 0.8)*args.scale
	args.text_scale = (args.text_scale or 0.5)*args.scale
	args.l = '<'
	args.r = '>'
	args.focus_args = args.focus_args or {}
	args.focus_args.type = 'cycle'

	local info = nil
	if args.info then
		info = {}
		for k, v in ipairs(args.info) do
			table.insert(info, {n=G.UIT.R, config={align = "cm", minh = 0.05}, nodes={
				{n=G.UIT.T, config={text = v, scale = 0.3*args.scale, colour = G.C.UI.TEXT_LIGHT}}
			}})
		end
		info =  {n=G.UIT.R, config={align = "cm", minh = 0.05}, nodes=info}
	end

	local disabled = #args.options < 2
	local pips = {}
	for i = 1, #args.options do
		pips[#pips+1] = {n=G.UIT.B, config={w = 0.1*args.scale, h = 0.1*args.scale, r = 0.05, id = 'pip_'..i, colour = args.current_option == i and G.C.WHITE or G.C.BLACK}}
	end

	local choice_pips = not args.no_pips and {n=G.UIT.R, config={align = "cm", padding = (0.05 - (#args.options > 15 and 0.03 or 0))*args.scale}, nodes=pips} or nil

	local t =
	{n=G.UIT.C, config={align = "cm", padding = 0.1, r = 0.1, colour = G.C.CLEAR, id = args.id and (not args.label and args.id or nil) or nil, focus_args = args.focus_args}, nodes={
		{n=G.UIT.C, config={align = "cm",r = 0.1, minw = 0.6*args.scale, hover = not disabled, colour = not disabled and args.colour or G.C.BLACK,shadow = not disabled, button = not disabled and 'option_cycle' or nil, ref_table = args, ref_value = 'l', focus_args = {type = 'none'}}, nodes={
			{n=G.UIT.T, config={ref_table = args, ref_value = 'l', scale = args.text_scale, colour = not disabled and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE}}
		}},
		args.mid and
				{n=G.UIT.C, config={id = 'cycle_main'}, nodes={
					{n=G.UIT.R, config={align = "cm", minh = 0.05}, nodes={
						args.mid
					}},
					not disabled and choice_pips or nil
				}}
				or {n=G.UIT.C, config={id = 'cycle_main', align = "cm", minw = args.w, minh = args.h, r = 0.1, padding = 0.05, colour = args.colour,emboss = 0.1, hover = true, can_collide = true, on_demand_tooltip = args.on_demand_tooltip}, nodes={
			{n=G.UIT.R, config={align = "cm"}, nodes={
				{n=G.UIT.R, config={align = "cm"}, nodes={
					{n=G.UIT.O, config={object = DynaText({string = {{ref_table = args, ref_value = "current_option_val"}}, colours = {G.C.UI.TEXT_LIGHT},pop_in = 0, pop_in_rate = 8, reset_pop_in = true,shadow = true, float = true, silent = true, bump = true, scale = args.text_scale, non_recalc = true})}},
				}},
				{n=G.UIT.R, config={align = "cm", minh = 0.05}, nodes={
				}},
				not disabled and choice_pips or nil
			}}
		}},
		{n=G.UIT.C, config={align = "cm",r = 0.1, minw = 0.6*args.scale, hover = not disabled, colour = not disabled and args.colour or G.C.BLACK,shadow = not disabled, button = not disabled and 'option_cycle' or nil, ref_table = args, ref_value = 'r', focus_args = {type = 'none'}}, nodes={
			{n=G.UIT.T, config={ref_table = args, ref_value = 'r', scale = args.text_scale, colour = not disabled and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE}}
		}},
	}}

	if args.cycle_shoulders then
		t =
		{n=G.UIT.R, config={align = "cm", colour = G.C.CLEAR}, nodes = {
			{n=G.UIT.C, config={minw = 0.7,align = "cm", colour = G.C.CLEAR,func = 'set_button_pip', focus_args = {button = 'leftshoulder', type = 'none', orientation = 'cm', scale = 0.7, offset = {x = -0.1, y = 0}}}, nodes = {}},
			{n=G.UIT.C, config={id = 'cycle_shoulders', padding = 0.1}, nodes={t}},
			{n=G.UIT.C, config={minw = 0.7,align = "cm", colour = G.C.CLEAR,func = 'set_button_pip', focus_args = {button = 'rightshoulder', type = 'none', orientation = 'cm', scale = 0.7, offset = {x = 0.1, y = 0}}}, nodes = {}},
		}}
	else
		t =
		{n=G.UIT.R, config={align = "cm", colour = G.C.CLEAR, padding = 0.0}, nodes = {
			t
		}}
	end
	if args.label or args.info then
		t = {n=G.UIT.R, config={align = "cm", padding = 0.05, id = args.id or nil}, nodes={
			args.label and {n=G.UIT.R, config={align = "cm"}, nodes={
				{n=G.UIT.T, config={text = args.label, scale = 0.5*args.scale, colour = G.C.UI.TEXT_LIGHT}}
			}} or nil,
			t,
			info,
		}}
	end
	return t
end

local function generateBaseNode(staticPageDefinition)
	return {
		n = G.UIT.ROOT,
		config = {
			emboss = 0.05,
			minh = 6,
			r = 0.1,
			minw = 8,
			align = "cm",
			padding = 0.2,
			colour = G.C.BLACK
		},
		nodes = {
			staticPageDefinition
		}
	}
end

-- Initialize a tab with sections that can be updated dynamically (e.g. modifying text labels, showing additional UI elements after toggling buttons, etc.)
function SMODS.GUI.DynamicUIManager.initTab(args)
	local updateFunctions = args.updateFunctions
	local staticPageDefinition = args.staticPageDefinition

	for _, updateFunction in pairs(updateFunctions) do
		G.E_MANAGER:add_event(Event({func = function()
			updateFunction{cycle_config = {current_option = 1}}
			return true
		end}))
	end
	return generateBaseNode(staticPageDefinition)
end

-- Call this to trigger an update for a list of dynamic content areas
function SMODS.GUI.DynamicUIManager.updateDynamicAreas(uiDefinitions)
	for id, uiDefinition in pairs(uiDefinitions) do
		local dynamicArea = G.OVERLAY_MENU:get_UIE_by_ID(id)
		if dynamicArea and dynamicArea.config.object then
			dynamicArea.config.object:remove()
			dynamicArea.config.object = UIBox{
				definition = uiDefinition,
				config = {offset = {x=0, y=0}, align = 'cm', parent = dynamicArea}
			}
		end
	end
end

local function recalculateModsList(page)
	local modsPerPage = 4
	local startIndex = (page - 1) * modsPerPage + 1
	local endIndex = startIndex + modsPerPage - 1
	local totalPages = math.ceil(#SMODS.MODS / modsPerPage)
	local currentPage = "Page " .. page .. "/" .. totalPages
	local pageOptions = {}
	for i = 1, totalPages do
		table.insert(pageOptions, ("Page " .. i .. "/" .. totalPages))
	end
	local showingList = #SMODS.MODS > 0

	return currentPage, pageOptions, showingList, startIndex, endIndex, modsPerPage
end

-- Define the content in the pane that does not need to update
-- Should include OBJECT nodes that indicate where the dynamic content sections will be populated
-- EX: in this pane the 'modsList' node will contain the dynamic content which is defined in the function below
function SMODS.GUI.staticModListContent()
	local scale = 0.75
	local currentPage, pageOptions, showingList = recalculateModsList(1)
	return {
		n = G.UIT.ROOT,
		config = {
			minh = 6,
			r = 0.1,
			minw = 10,
			align = "tm",
			padding = 0.2,
			colour = G.C.BLACK
		},
		nodes = {
			-- row container
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.05 },
				nodes = {
					-- column container
					{
						n = G.UIT.C,
						config = { align = "cm", minw = 3, padding = 0.2, r = 0.1, colour = G.C.CLEAR },
						nodes = {
							-- title row
							{
								n = G.UIT.R,
								config = {
									padding = 0.05,
									align = "cm"
								},
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = "List of Activated Mods",
											shadow = true,
											scale = scale * 0.6,
											colour = G.C.UI.TEXT_LIGHT
										}
									}
								}
							},

							-- add some empty rows for spacing
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.05 },
								nodes = {}
							},
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.05 },
								nodes = {}
							},
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.05 },
								nodes = {}
							},
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.05 },
								nodes = {}
							},

							-- dynamic content rendered in this row container
							-- list of 4 mods on the current page
							{
								n = G.UIT.R,
								config = {
									padding = 0.05,
									align = "cm",
									minh = 2,
									minw = 4
								},
								nodes = {
									{n=G.UIT.O, config={id = 'modsList', object = Moveable()}},
								}
							},

							-- another empty row for spacing
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.3 },
								nodes = {}
							},

							-- page selector
							-- does not appear when list of mods is empty
							showingList and SMODS.GUI.createOptionSelector({label = "", scale = 0.8, options = pageOptions, opt_callback = 'update_mod_list', no_pips = true, current_option = (
									currentPage
							)}) or nil
						}
					},
				}
			},
		}
	}
end

function SMODS.GUI.dynamicModListContent(page)
    local scale = 0.75
    local _, __, showingList, startIndex, endIndex, modsPerPage = recalculateModsList(page)

    local modNodes = {}

    -- If no mods are loaded, show a default message
    if showingList == false then
        table.insert(modNodes, {
            n = G.UIT.R,
            config = {
                padding = 0,
                align = "cm"
            },
            nodes = {
                {
                    n = G.UIT.T,
                    config = {
                        text = "No mods have been detected...",
                        shadow = true,
                        scale = scale * 0.5,
                        colour = G.C.UI.TEXT_DARK
                    }
                }
            }
        })
        table.insert(modNodes, {
            n = G.UIT.R,
            config = {
                padding = 0,
                align = "cm",
            },
            nodes = {
                UIBox_button({
                    label = { "Open Mods directory" },
                    shadow = true,
                    scale = scale,
                    colour = G.C.BOOSTER,
                    button = "openModsDirectory",
                    minh = 0.8,
                    minw = 8
                })
            }
        })
    else
        local modCount = 0
        for id, modInfo in ipairs(SMODS.MODS) do
            if id >= startIndex and id <= endIndex then
                table.insert(modNodes, createClickableModBox(modInfo, scale * 0.5))
                modCount = modCount + 1
                if modCount >= modsPerPage then break end
            end
        end
    end

    return {
        n = G.UIT.R,
        config = {
            r = 0.1,
            align = "cm",
            padding = 0.2,
        },
        nodes = modNodes
    }
end

function SMODS.SAVE_UNLOCKS()
	G:save_progress()
    -------------------------------------
    local TESTHELPER_unlocks = false and not _RELEASE_MODE
    -------------------------------------
    if not love.filesystem.getInfo(G.SETTINGS.profile .. '') then
        love.filesystem.createDirectory(G.SETTINGS.profile ..
            '')
    end
    if not love.filesystem.getInfo(G.SETTINGS.profile .. '/' .. 'meta.jkr') then
        love.filesystem.append(
            G.SETTINGS.profile .. '/' .. 'meta.jkr', 'return {}')
    end

    convert_save_to_meta()

    local meta = STR_UNPACK(get_compressed(G.SETTINGS.profile .. '/' .. 'meta.jkr') or 'return {}')
    meta.unlocked = meta.unlocked or {}
    meta.discovered = meta.discovered or {}
    meta.alerted = meta.alerted or {}

    for k, v in pairs(G.P_CENTERS) do
        if not v.wip and not v.demo then
            if TESTHELPER_unlocks then
                v.unlocked = true; v.discovered = true; v.alerted = true
            end --REMOVE THIS
            if not v.unlocked and (string.find(k, '^j_') or string.find(k, '^b_') or string.find(k, '^v_')) and meta.unlocked[k] then
                v.unlocked = true
            end
            if not v.unlocked and (string.find(k, '^j_') or string.find(k, '^b_') or string.find(k, '^v_')) then
                G.P_LOCKED[#G.P_LOCKED + 1] =
                    v
            end
            if not v.discovered and (string.find(k, '^j_') or string.find(k, '^b_') or string.find(k, '^e_') or string.find(k, '^c_') or string.find(k, '^p_') or string.find(k, '^v_')) and meta.discovered[k] then
                v.discovered = true
            end
            if v.discovered and meta.alerted[k] or v.set == 'Back' or v.start_alerted then
                v.alerted = true
            elseif v.discovered then
                v.alerted = false
            end
        end
    end

	for k, v in pairs(G.P_BLINDS) do
        v.key = k
        if not v.wip and not v.demo then 
            if TESTHELPER_unlocks then v.discovered = true; v.alerted = true  end --REMOVE THIS
            if not v.discovered and meta.discovered[k] then 
                v.discovered = true
            end
            if v.discovered and meta.alerted[k] then 
                v.alerted = true
            elseif v.discovered then
                v.alerted = false
            end
        end
    end

    for k, v in pairs(G.P_SEALS) do
        v.key = k
        if not v.wip and not v.demo then
            if TESTHELPER_unlocks then
                v.discovered = true; v.alerted = true
            end                                                                   --REMOVE THIS
            if not v.discovered and meta.discovered[k] then
                v.discovered = true
            end
            if v.discovered and meta.alerted[k] then
                v.alerted = true
            elseif v.discovered then
                v.alerted = false
            end
        end
    end
end

function SMODS.LOAD_LOC()
    for g_k, group in pairs(G.localization) do
        if g_k == 'descriptions' then
            for _, set in pairs(group) do
                for _, center in pairs(set) do
                    center.text_parsed = {}
                    for _, line in ipairs(center.text) do
                        center.text_parsed[#center.text_parsed + 1] = loc_parse_string(line)
                    end
                    center.name_parsed = {}
                    for _, line in ipairs(type(center.name) == 'table' and center.name or { center.name }) do
                        center.name_parsed[#center.name_parsed + 1] = loc_parse_string(line)
                    end
                    if center.unlock then
                        center.unlock_parsed = {}
                        for _, line in ipairs(center.unlock) do
                            center.unlock_parsed[#center.unlock_parsed + 1] = loc_parse_string(line)
                        end
                    end
                end
            end
        end
    end
end

----------------------------------------------
------------MOD CORE END----------------------

----------------------------------------------
------------MOD CORE API DECK-----------------

SMODS.Decks = {}
SMODS.Deck = {name = "", slug = "", config = {}, spritePos = {}, loc_txt = {}, unlocked = true, discovered = true}

function SMODS.Deck:new(name, slug, config, spritePos, loc_txt, unlocked, discovered)
	o = {}
	setmetatable(o, self)
	self.__index = self

	o.loc_txt = loc_txt
	o.name = name
	o.slug = "b_" .. slug
	o.config = config or {}
	o.spritePos = spritePos or {x = 0, y = 0}
	o.unlocked = unlocked or true
	o.discovered = discovered or true

	return o
end

--[[ local Backgenerate_UIRef = Back.generate_UI
function SMODS.Deck:createUI()
	Back.generate_UI = function(arg_53_0, arg_53_1, arg_53_2, arg_53_3)
	end
end ]]

function SMODS.Deck:register()
	if not SMODS.Decks[self] then
		table.insert(SMODS.Decks, self)
	end
end

function SMODS.injectDecks()
	local minId = 17
	local id = 0
	local replacedId = ""
	local replacedName = ""

    for i, deck in ipairs(SMODS.Decks) do
        -- Prepare some Datas
        id = i + minId - 1

        local deck_obj = {
            stake = 1,
            key = deck.slug,
            discovered = deck.discovered,
            alerted = true,
            name = deck.name,
            set = "Back",
            unlocked = deck.unlocked,
            order = id - 1,
            pos = deck.spritePos,
            config = deck.config
        }

        -- Now we replace the others
        G.P_CENTERS[deck.slug] = deck_obj
        G.P_CENTER_POOLS.Back[id - 1] = deck_obj

        -- Setup Localize text
        G.localization.descriptions["Back"][deck.slug] = deck.loc_txt

        sendInfoMessage("Registered Deck " .. deck.name .. " with the slug " .. deck.slug .. " at ID " .. id .. ".", 'DeckAPI')
    end
end

local back_initref = Back.init;
function Back:init(selected_back)
	back_initref(self, selected_back)
	self.atlas = "centers"
    if self.effect.center.config.atlas then
        self.atlas = self.effect.center.config.atlas
    end
end

local back_changetoref = Back.change_to;
function Back:change_to(new_back)
	back_changetoref(self, new_back)
	self.atlas = "centers"
    if new_back.config.atlas then
        self.atlas = new_back.config.atlas
    end
end

local change_viewed_backref = G.FUNCS.change_viewed_back
G.FUNCS.change_viewed_back = function(args)
	change_viewed_backref(args)
	
	for key, val in pairs(G.sticker_card.area.cards) do
		val.children.back = false
		val:set_ability(val.config.center, true)
	  end
end

local set_spritesref = Card.set_sprites;
function Card:set_sprites(_center, _front)
	if _center then 
		if not self.children.back then
            local atlas_id = "centers"

			if G.GAME.selected_back then
                if G.GAME.selected_back.atlas then
                    atlas_id = G.GAME.selected_back.atlas
                end
            end

            if G.GAME.viewed_back and G.GAME.viewed_back ~= G.GAME.selected_back then
                if G.GAME.viewed_back.atlas then
                    atlas_id = G.GAME.viewed_back.atlas
                end
                
            end
			
            self.children.back = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[atlas_id], self.params.bypass_back or (self.playing_card and G.GAME[self.back].pos or G.P_CENTERS['b_red'].pos))
            atlas_id = "centers"
            self.children.back.states.hover = self.states.hover
            self.children.back.states.click = self.states.click
            self.children.back.states.drag = self.states.drag
            self.children.back.states.collide.can = false
            self.children.back:set_role({major = self, role_type = 'Glued', draw_major = self})
        end
	end

	set_spritesref(self, _center, _front);
end

----------------------------------------------
------------MOD CORE API DECK END-------------
-- ----------------------------------------------
-- ------------MOD CORE API JOKER----------------

SMODS.Jokers = {}
SMODS.Joker = {
    name = "",
    slug = "",
    config = {},
    spritePos = {},
    loc_txt = {},
    rarity = 1,
    cost = 0,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    effect = ""
}

function SMODS.Joker:new(name, slug, config, spritePos, loc_txt, rarity, cost, unlocked, discovered, blueprint_compat,
                         eternal_compat, effect, atlas, soul_pos)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.loc_txt = loc_txt
    o.name = name
    o.slug = "j_" .. slug
    o.config = config or {}
    o.pos = spritePos or {
        x = 0,
        y = 0
    }
    o.soul_pos = soul_pos
    o.rarity = rarity or 1
    o.cost = cost
    o.unlocked = (unlocked == nil) and true or unlocked
    o.discovered = (discovered == nil) and true or discovered
    o.blueprint_compat = blueprint_compat or false
    o.eternal_compat = (eternal_compat == nil) and true or eternal_compat
    o.effect = effect or ''
    o.atlas = atlas or nil
    o.mod_name = SMODS._MOD_NAME
    o.badge_colour = SMODS._BADGE_COLOUR
    return o
end

function SMODS.Joker:register()
    if not SMODS.Jokers[self.slug] then
        SMODS.Jokers[self.slug] = self
        SMODS.BUFFERS.Jokers[#SMODS.BUFFERS.Jokers + 1] = self.slug
    end
end

function SMODS.injectJokers()
    local minId = table_length(G.P_CENTER_POOLS['Joker']) + 1
    local id = 0
    local i = 0
    local joker = nil
    for k, slug in ipairs(SMODS.BUFFERS.Jokers) do
        joker = SMODS.Jokers[slug]
        if joker.order then
            id = joker.order
        else
            i = i + 1
            id = i + minId
        end
        local joker_obj = {
            discovered = joker.discovered,
            name = joker.name,
            set = "Joker",
            unlocked = joker.unlocked,
            order = id,
            key = joker.slug,
            pos = joker.pos,
            config = joker.config,
            rarity = joker.rarity,
            blueprint_compat = joker.blueprint_compat,
            eternal_compat = joker.eternal_compat,
            effect = joker.effect,
            cost = joker.cost,
            cost_mult = 1.0,
            atlas = joker.atlas or nil,
            mod_name = joker.mod_name,
            badge_colour = joker.badge_colour,
            soul_pos = joker.soul_pos,
            -- * currently unsupported
            no_pool_flag = joker.no_pool_flag,
            yes_pool_flag = joker.yes_pool_flag,
            unlock_condition = joker.unlock_condition,
            enhancement_gate = joker.enhancement_gate,
            start_alerted = joker.start_alerted
        }
        for _i, sprite in ipairs(SMODS.Sprites) do
            if sprite.name == joker_obj.key then
                joker_obj.atlas = sprite.name
            end
        end

        -- Now we replace the others
        G.P_CENTERS[slug] = joker_obj
        if not joker.taken_ownership then
            table.insert(G.P_CENTER_POOLS['Joker'], joker_obj)
            table.insert(G.P_JOKER_RARITY_POOLS[joker_obj.rarity], joker_obj)
        else
            for kk, v in ipairs(G.P_CENTER_POOLS['Joker']) do
                if v.key == slug then G.P_CENTER_POOLS['Joker'][kk] = joker_obj end
            end
            if joker_obj.rarity == joker.rarity_original then
                for kk, v in ipairs(G.P_JOKER_RARITY_POOLS[joker_obj.rarity]) do
                    if v.key == slug then G.P_JOKER_RARITY_POOLS[kk] = joker_obj end
                end
            else
                table.insert(G.P_JOKER_RARITY_POOLS[joker_obj.rarity], joker_obj)
                local j
                for kk, v in ipairs(G.P_JOKER_RARITY_POOLS[joker.rarity_original]) do
                    if v.key == slug then j = kk end
                end
                table.remove(G.P_JOKER_RARITY_POOLS[joker.rarity_original], j)
            end
        end
        -- Setup Localize text
        G.localization.descriptions["Joker"][slug] = joker.loc_txt

        sendInfoMessage("Registered Joker " .. joker.name .. " with the slug " .. joker.slug .. " at ID " .. id .. ".")
    end
end

function SMODS.Joker:take_ownership(slug)
    if not (string.sub(slug, 1, 2) == 'j_') then slug = 'j_' .. slug end
    local joker = G.P_CENTERS[slug]
    if not joker then
        sendWarnMessage('Tried to take ownership of non-existent Joker: ' .. slug, 'JokerAPI')
        return nil
    end
    if joker.mod_name then
        sendWarnMessage('Can only take ownership of unclaimed vanilla Jokers! ' ..
            slug .. ' belongs to ' .. joker.mod_name, 'JokerAPI')
        return nil
    end
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.loc_txt = G.localization.descriptions['Joker'][slug]
    o.slug = slug
    for k, v in pairs(joker) do
        o[k] = v
    end
    o.rarity_original = o.rarity
    o.mod_name = SMODS._MOD_NAME
    o.badge_colour = SMODS._BADGE_COLOUR
    o.taken_ownership = true
    return o
end

local cardset_abilityRef = Card.set_ability
function Card.set_ability(self, center, initial, delay_sprites)
    cardset_abilityRef(self, center, initial, delay_sprites)
    local key = self.config.center.key
    local joker_obj = SMODS.Jokers[key]
    if joker_obj and joker_obj.set_ability and type(joker_obj.set_ability) == 'function' then
        joker_obj.set_ability(self, center, initial, delay_sprites)
    end
end

local calculate_jokerref = Card.calculate_joker;
function Card:calculate_joker(context)
    if not self.debuff then
        local key = self.config.center.key
        local center_obj = SMODS.Jokers[key] or SMODS.Tarots[key] or SMODS.Planets[key] or SMODS.Spectrals[key]
        if center_obj and center_obj.calculate and type(center_obj.calculate) == "function" then
            local o = center_obj.calculate(self, context)
            if o then return o end
        end
    end
    return calculate_jokerref(self, context)
end

local ability_table_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table()
    local card_type, hide_desc = self.ability.set or "None", nil
    local loc_vars = nil
    local main_start, main_end = nil, nil
    local no_badge = nil
    if not self.bypass_lock and self.config.center.unlocked ~= false and
        self.ability.set == 'Joker' and
        not self.config.center.discovered and
        ((self.area ~= G.jokers and self.area ~= G.consumeables and self.area) or not self.area) then
        card_type = 'Undiscovered'
    end

    if self.config.center.unlocked == false and not self.bypass_lock then    -- For everyting that is locked
    elseif card_type == 'Undiscovered' and not self.bypass_discovery_ui then -- Any Joker or tarot/planet/voucher that is not yet discovered
    elseif self.debuff then
    elseif card_type == 'Default' or card_type == 'Enhanced' then
    elseif self.ability.set == 'Joker' then
        local key = self.config.center.key
        local joker_obj = SMODS.Jokers[key]
        if joker_obj and joker_obj.loc_def and type(joker_obj.loc_def) == 'function' then
            local o, m = joker_obj.loc_def(self)
            if o then loc_vars = o end
            if m then main_end = m end
        end
    end
    if loc_vars then
        local badges = {}
        if (card_type ~= 'Locked' and card_type ~= 'Undiscovered' and card_type ~= 'Default') or self.debuff then
            badges.card_type = card_type
        end
        if self.ability.set == 'Joker' and self.bypass_discovery_ui and (not no_badge) then
            badges.force_rarity = true
        end
        if self.edition then
            if self.edition.type == 'negative' and self.ability.consumeable then
                badges[#badges + 1] = 'negative_consumable'
            else
                badges[#badges + 1] = (self.edition.type == 'holo' and 'holographic' or self.edition.type)
            end
        end
        if self.seal then
            badges[#badges + 1] = string.lower(self.seal) .. '_seal'
        end
        if self.ability.eternal then
            badges[#badges + 1] = 'eternal'
        end
        if self.pinned then
            badges[#badges + 1] = 'pinned_left'
        end

        if self.sticker then
            loc_vars = loc_vars or {};
            loc_vars.sticker = self.sticker
        end

        local center = self.config.center
        return generate_card_ui(center, nil, loc_vars, card_type, badges, hide_desc, main_start, main_end)
    end
    return ability_table_ref(self)
end

function SMODS.end_calculate_context(c)
    if not c.after and not c.before and not c.other_joker and not c.repetition and not c.individual and
        not c.end_of_round and not c.discard and not c.pre_discard and not c.debuffed_hand and not c.using_consumeable and
        not c.remove_playing_cards and not c.cards_destroyed and not c.destroying_card and not c.setting_blind and
        not c.first_hand_drawn and not c.playing_card_added and not c.skipping_booster and not c.skip_blind and
        not c.ending_shop and not c.reroll_shop and not c.selling_card and not c.selling_self and not c.buying_card and
        not c.open_booster then
        return true
    end
    return false
end

-- ----------------------------------------------
-- ------------MOD CORE API JOKER END------------

SMODS.Blinds = {}
SMODS.Blind = {
    name = "",
    slug = "",
    loc_txt = {},
    dollars = 5,
    mult = 2,
    vars = {},
    debuff = {},
    pos = { x = 0, y = 0 },
    --boss = {},
    --boss_colour =
    --    HEX('FFFFFF'),
    discovered = false
}

function SMODS.Blind:new(name, slug, loc_txt, dollars, mult, vars, debuff, pos, boss, boss_colour, defeated, atlas)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.loc_txt = loc_txt
    o.name = name
    o.slug = "bl_" .. slug
    o.dollars = dollars or 5
    o.mult = mult or 2
    o.vars = vars or {}
    o.debuff = debuff or {}
    o.pos = pos or { x = 0, y = 0 }
    o.boss = boss or {}
    o.boss_colour = boss_colour or HEX('FFFFFF')
    o.discovered = defeated or false
    o.atlas = atlas or "BlindChips"

    return o
end

function SMODS.Blind:register()
    if not SMODS.Blinds[self.slug] then
        SMODS.Blinds[self.slug] = self
        SMODS.BUFFERS.Blinds[#SMODS.BUFFERS.Blinds + 1] = self.slug
    end
end

function SMODS.injectBlinds()
    local minId = table_length(G.P_BLINDS) + 1
    local id = 0
    local i = 0
    local blind = nil
    for _, slug in ipairs(SMODS.BUFFERS.Blinds) do
        blind = SMODS.Blinds[slug]
        if blind.order then
            id = blind.order
        else
            i = i + 1
            id = minId + i
        end
        local blind_obj = {
            key = blind.slug,
            order = id,
            name = blind.name,
            dollars = blind.dollars,
            mult = blind.mult,
            vars = blind.vars,
            debuff = blind.debuff,
            pos = blind.pos,
            boss = blind.boss,
            boss_colour = blind.boss_colour,
            discovered = blind.discovered,
            atlas = blind.atlas,
            debuff_text = blind.debuff_text
        }
        -- Now we replace the others
        G.P_BLINDS[blind.slug] = blind_obj

        -- Setup Localize text
        G.localization.descriptions["Blind"][blind.slug] = blind.loc_txt

        sendInfoMessage("Registered Blind " .. blind.name .. " with the slug " .. blind.slug .. " at ID " .. id .. ".", 'BlindAPI')
    end
end

function SMODS.Blind:take_ownership(slug)
    if not (string.sub(slug, 1, 3) == 'bl_') then slug = 'bl_' .. slug end
    local obj = G.P_BLINDS[slug]
    if not obj then
        sendWarnMessage('Tried to take ownership of non-existent Blind: ' .. slug, 'BlindAPI')
        return nil
    end
    if SMODS.Blinds[slug] then
        sendWarnMessage('Can only take ownership of unclaimed vanilla Blinds! ' ..
            slug .. ' is already registered', 'BlindAPI')
        return nil
    end
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.loc_txt = G.localization.descriptions['Blind'][slug]
    o.slug = slug
    for k, v in pairs(obj) do
        o[k] = v
    end
	o.taken_ownership = true
	return o
end

local set_blindref = Blind.set_blind;
function Blind:set_blind(blind, reset, silent)
    set_blindref(self, blind, reset, silent)
    if not reset then
        local prev_anim = self.children.animatedSprite
        self.config.blind = blind or {}
        local blind_atlas = 'blind_chips'
        if self.config.blind and self.config.blind.atlas then
            blind_atlas = self.config.blind.atlas
        end
        self.children.animatedSprite = AnimatedSprite(self.T.x, self.T.y, self.T.w, self.T.h,
            G.ANIMATION_ATLAS[blind_atlas],
            G.P_BLINDS.bl_small.pos)
        self.children.animatedSprite.states = prev_anim.states
        self.children.animatedSprite.states.visible = prev_anim.states.visible
        self.children.animatedSprite.states.drag.can = prev_anim.states.drag.can
        local key = self.config.blind.key
        local blind_obj = SMODS.Blinds[key]
        if blind_obj and blind_obj.set_blind and type(blind_obj.set_blind) == 'function' then
            blind_obj.set_blind(self, blind, reset, silent)
        end
    end
    for _, v in ipairs(G.playing_cards) do
        self:debuff_card(v)
    end
    for _, v in ipairs(G.jokers.cards) do
        if not reset then self:debuff_card(v, true) end
    end
end

local blind_disable_ref = Blind.disable
function Blind:disable()
    local key = self.config.blind.key
    local blind_obj = SMODS.Blinds[key]
    if blind_obj and blind_obj.disable and type(blind_obj.disable) == 'function' then
        blind_obj.disable(self)
    end
    blind_disable_ref(self)
end

local blind_defeat_ref = Blind.defeat
function Blind:defeat(silent)
    local key = self.config.blind.key
    local blind_obj = SMODS.Blinds[key]
    if blind_obj and blind_obj.defeat and type(blind_obj.defeat) == 'function' then
        blind_obj.set_blind(self, silent)
    end
    blind_defeat_ref(self, silent)
end

local blind_debuff_card_ref = Blind.debuff_card
function Blind:debuff_card(card, from_blind)
    blind_debuff_card_ref(self, card, from_blind)
    local key = self.config.blind.key
    local blind_obj = SMODS.Blinds[key]
    if blind_obj and blind_obj.debuff_card and type(blind_obj.debuff_card) == 'function' and not self.disabled then
        blind_obj.debuff_card(self, card, from_blind)
    end
end

local blind_stay_flipped_ref = Blind.stay_flipped
function Blind:stay_flipped(area, card)
    local key = self.config.blind.key
    local blind_obj = SMODS.Blinds[key]
    if blind_obj and blind_obj.stay_flipped and type(blind_obj.stay_flipped) == 'function' and not self.disabled and area == G.hand then
        return blind_obj.stay_flipped(self, area, card)
    end
    return blind_stay_flipped_ref(self, area, card)
end

local blind_drawn_to_hand_ref = Blind.drawn_to_hand
function Blind:drawn_to_hand()
    local key = self.config.blind.key
    local blind_obj = SMODS.Blinds[key]
    if blind_obj and blind_obj.drawn_to_hand and type(blind_obj.drawn_to_hand) == 'function' and not self.disabled then
        blind_obj.drawn_to_hand(self)
    end
    blind_drawn_to_hand_ref(self)
end

local blind_debuff_hand_ref = Blind.debuff_hand
function Blind:debuff_hand(cards, hand, handname, check)
    local key = self.config.blind.key
    local blind_obj = SMODS.Blinds[key]
    if blind_obj and blind_obj.debuff_hand and type(blind_obj.debuff_hand) == 'function' and not self.disabled then
        return blind_obj.debuff_hand(self, cards, hand, handname, check)
    end
    return blind_debuff_hand_ref(self, cards, hand, handname, check)
end

local blind_modify_hand_ref = Blind.modify_hand
function Blind:modify_hand(cards, poker_hands, text, mult, hand_chips)
    local key = self.config.blind.key
    local blind_obj = SMODS.Blinds[key]
    if blind_obj and blind_obj.modify_hand and type(blind_obj.modify_hand) == 'function' and not self.debuff then
        return blind_obj.modify_hand(cards, poker_hands, text, mult, hand_chips)
    end
    return blind_modify_hand_ref(self, cards, poker_hands, text, mult, hand_chips)
end

local blind_press_play_ref = Blind.press_play
function Blind:press_play()
    local key = self.config.blind.key
    local blind_obj = SMODS.Blinds[key]
    if blind_obj and blind_obj.press_play and type(blind_obj.press_play) == 'function' and not self.disabled then
        return blind_obj.press_play(self)
    end
    return blind_press_play_ref(self)
end

local blind_get_loc_debuff_text_ref = Blind.get_loc_debuff_text
function Blind:get_loc_debuff_text()
    local key = self.config.blind.key
    local blind_obj = SMODS.Blinds[key]
    if blind_obj and blind_obj.get_loc_debuff_text and type(blind_obj.get_loc_debuff_text) == 'function' then
        return blind_obj.get_loc_debuff_text(self)
    end
    return blind_get_loc_debuff_text_ref(self)
end

local blind_set_text = Blind.set_text
function Blind:set_text()
    local key = self.config.blind.key
    local blind_obj = SMODS.Blinds[key]
    local loc_vars = nil
    if blind_obj and blind_obj.loc_def and type(blind_obj.loc_def) == 'function' and not self.disabled then
        loc_vars = blind_obj.loc_def(self)
        local loc_target = localize { type = 'raw_descriptions', key = self.config.blind.key, set = 'Blind', vars = loc_vars or self.config.blind.vars }
        if loc_target then
            self.loc_name = self.name == '' and self.name or
                localize { type = 'name_text', key = self.config.blind.key, set = 'Blind' }
            self.loc_debuff_text = ''
            for k, v in ipairs(loc_target) do
                self.loc_debuff_text = self.loc_debuff_text .. v .. (k <= #loc_target and ' ' or '')
            end
            self.loc_debuff_lines[1] = loc_target[1] or ''
            self.loc_debuff_lines[2] = loc_target[2] or ''
        else
            self.loc_name = ''; self.loc_debuff_text = ''
            self.loc_debuff_lines[1] = ''
            self.loc_debuff_lines[2] = ''
        end
        return
    end
    blind_set_text(self)
end

function create_UIBox_blind_choice(type, run_info)
    if not G.GAME.blind_on_deck then
        G.GAME.blind_on_deck = 'Small'
    end
    if not run_info then G.GAME.round_resets.blind_states[G.GAME.blind_on_deck] = 'Select' end

    local disabled = false
    type = type or 'Small'

    local blind_choice = {
        config = G.P_BLINDS[G.GAME.round_resets.blind_choices[type]],
    }

    local blind_atlas = 'blind_chips'
    if blind_choice.config and blind_choice.config.atlas then
        blind_atlas = blind_choice.config.atlas
    end
    blind_choice.animation = AnimatedSprite(0, 0, 1.4, 1.4, G.ANIMATION_ATLAS[blind_atlas], blind_choice.config.pos)
    blind_choice.animation:define_draw_steps({
        { shader = 'dissolve', shadow_height = 0.05 },
        { shader = 'dissolve' }
    })
    local extras = nil
    local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.5)

    G.GAME.orbital_choices = G.GAME.orbital_choices or {}
    G.GAME.orbital_choices[G.GAME.round_resets.ante] = G.GAME.orbital_choices[G.GAME.round_resets.ante] or {}

    if not G.GAME.orbital_choices[G.GAME.round_resets.ante][type] then
        local _poker_hands = {}
        for k, v in pairs(G.GAME.hands) do
            if v.visible then _poker_hands[#_poker_hands + 1] = k end
        end

        G.GAME.orbital_choices[G.GAME.round_resets.ante][type] = pseudorandom_element(_poker_hands, pseudoseed('orbital'))
    end



    if type == 'Small' then
        extras = create_UIBox_blind_tag(type, run_info)
    elseif type == 'Big' then
        extras = create_UIBox_blind_tag(type, run_info)
    elseif not run_info then
        local dt1 = DynaText({ string = { { string = localize('ph_up_ante_1'), colour = G.C.FILTER } }, colours = { G.C.BLACK }, scale = 0.55, silent = true, pop_delay = 4.5, shadow = true, bump = true, maxw = 3 })
        local dt2 = DynaText({ string = { { string = localize('ph_up_ante_2'), colour = G.C.WHITE } }, colours = { G.C.CHANCE }, scale = 0.35, silent = true, pop_delay = 4.5, shadow = true, maxw = 3 })
        local dt3 = DynaText({ string = { { string = localize('ph_up_ante_3'), colour = G.C.WHITE } }, colours = { G.C.CHANCE }, scale = 0.35, silent = true, pop_delay = 4.5, shadow = true, maxw = 3 })
        extras =
        {
            n = G.UIT.R,
            config = { align = "cm" },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.07, r = 0.1, colour = { 0, 0, 0, 0.12 }, minw = 2.9 },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "cm" },
                            nodes = {
                                { n = G.UIT.O, config = { object = dt1 } },
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm" },
                            nodes = {
                                { n = G.UIT.O, config = { object = dt2 } },
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm" },
                            nodes = {
                                { n = G.UIT.O, config = { object = dt3 } },
                            }
                        },
                    }
                },
            }
        }
    end
    G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
    local loc_target = localize { type = 'raw_descriptions', key = blind_choice.config.key, set = 'Blind', vars = { localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands') } }
    local loc_name = localize { type = 'name_text', key = blind_choice.config.key, set = 'Blind' }
    local text_table = loc_target
    local blind_col = get_blind_main_colour(type)
    local blind_amt = get_blind_amount(G.GAME.round_resets.blind_ante) * blind_choice.config.mult *
        G.GAME.starting_params.ante_scaling

    local blind_state = G.GAME.round_resets.blind_states[type]
    local _reward = true
    if G.GAME.modifiers.no_blind_reward and G.GAME.modifiers.no_blind_reward[type] then _reward = nil end
    if blind_state == 'Select' then blind_state = 'Current' end
    local run_info_colour = run_info and
        (blind_state == 'Defeated' and G.C.GREY or blind_state == 'Skipped' and G.C.BLUE or blind_state == 'Upcoming' and G.C.ORANGE or blind_state == 'Current' and G.C.RED or G.C.GOLD)
    local t =
    {
        n = G.UIT.R,
        config = { id = type, align = "tm", func = 'blind_choice_handler', minh = not run_info and 10 or nil, ref_table = { deck = nil, run_info = run_info }, r = 0.1, padding = 0.05 },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm", colour = mix_colours(G.C.BLACK, G.C.L_BLACK, 0.5), r = 0.1, outline = 1, outline_colour = G.C.L_BLACK },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.2 },
                        nodes = {
                            not run_info and
                            {
                                n = G.UIT.R,
                                config = { id = 'select_blind_button', align = "cm", ref_table = blind_choice.config, colour = disabled and G.C.UI.BACKGROUND_INACTIVE or G.C.ORANGE, minh = 0.6, minw = 2.7, padding = 0.07, r = 0.1, shadow = true, hover = true, one_press = true, button = 'select_blind' },
                                nodes = {
                                    { n = G.UIT.T, config = { ref_table = G.GAME.round_resets.loc_blind_states, ref_value = type, scale = 0.45, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.UI.TEXT_LIGHT, shadow = not disabled } }
                                }
                            } or
                            {
                                n = G.UIT.R,
                                config = { id = 'select_blind_button', align = "cm", ref_table = blind_choice.config, colour = run_info_colour, minh = 0.6, minw = 2.7, padding = 0.07, r = 0.1, emboss = 0.08 },
                                nodes = {
                                    { n = G.UIT.T, config = { text = localize(blind_state, 'blind_states'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
                                }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { id = 'blind_name', align = "cm", padding = 0.07 },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm", r = 0.1, outline = 1, outline_colour = blind_col, colour = darken(blind_col, 0.3), minw = 2.9, emboss = 0.1, padding = 0.07, line_emboss = 1 },
                                nodes = {
                                    { n = G.UIT.O, config = { object = DynaText({ string = loc_name, colours = { disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE }, shadow = not disabled, float = not disabled, y_offset = -4, scale = 0.45, maxw = 2.8 }) } },
                                }
                            },
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.05 },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { id = 'blind_desc', align = "cm", padding = 0.05 },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cm" },
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm", minh = 1.5 },
                                                nodes = {
                                                    { n = G.UIT.O, config = { object = blind_choice.animation } },
                                                }
                                            },
                                            text_table[1] and
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm", minh = 0.7, padding = 0.05, minw = 2.9 },
                                                nodes = {
                                                    text_table[1] and {
                                                        n = G.UIT.R,
                                                        config = { align = "cm", maxw = 2.8 },
                                                        nodes = {
                                                            { n = G.UIT.T, config = { id = blind_choice.config.key, ref_table = { val = '' }, ref_value = 'val', scale = 0.32, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled, func = 'HUD_blind_debuff_prefix' } },
                                                            { n = G.UIT.T, config = { text = text_table[1] or '-', scale = 0.32, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled } }
                                                        }
                                                    } or nil,
                                                    text_table[2] and {
                                                        n = G.UIT.R,
                                                        config = { align = "cm", maxw = 2.8 },
                                                        nodes = {
                                                            { n = G.UIT.T, config = { text = text_table[2] or '-', scale = 0.32, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled } }
                                                        }
                                                    } or nil,
                                                }
                                            } or nil,
                                        }
                                    },
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cm", r = 0.1, padding = 0.05, minw = 3.1, colour = G.C.BLACK, emboss = 0.05 },
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm", maxw = 3 },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = localize('ph_blind_score_at_least'), scale = 0.3, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled } }
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm", minh = 0.6 },
                                                nodes = {
                                                    { n = G.UIT.O, config = { w = 0.5, h = 0.5, colour = G.C.BLUE, object = stake_sprite, hover = true, can_collide = false } },
                                                    { n = G.UIT.B, config = { h = 0.1, w = 0.1 } },
                                                    { n = G.UIT.T, config = { text = number_format(blind_amt), scale = score_number_scale(0.9, blind_amt), colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.RED, shadow = not disabled } }
                                                }
                                            },
                                            _reward and {
                                                n = G.UIT.R,
                                                config = { align = "cm" },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = localize('ph_blind_reward'), scale = 0.35, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled } },
                                                    { n = G.UIT.T, config = { text = string.rep(localize("$"), blind_choice.config.dollars) .. '+', scale = 0.35, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.MONEY, shadow = not disabled } }
                                                }
                                            } or nil,
                                        }
                                    },
                                }
                            },
                        }
                    },
                }
            },
            {
                n = G.UIT.R,
                config = { id = 'blind_extras', align = "cm" },
                nodes = {
                    extras,
                }
            }

        }
    }
    return t
end

function create_UIBox_your_collection_blinds(exit)
    local blind_matrix = {
        {}, {}, {}, {}, {}, {}
    }
    local blind_tab = {}
    for k, v in pairs(G.P_BLINDS) do
        blind_tab[#blind_tab + 1] = v
    end

    local blinds_per_row = math.ceil(#blind_tab / 6)
    sendTraceMessage("Blinds per row:" .. tostring(blinds_per_row), 'BlindAPI')

    table.sort(blind_tab, function(a, b) return a.order < b.order end)

    local blinds_to_be_alerted = {}
    for k, v in ipairs(blind_tab) do
        local discovered = v.discovered
        local atlas = 'blind_chips'
        if v.atlas and discovered then
            atlas = v.atlas
        end
        local temp_blind = AnimatedSprite(0, 0, 1.3, 1.3, G.ANIMATION_ATLAS[atlas],
            discovered and v.pos or G.b_undiscovered.pos)
        temp_blind:define_draw_steps({
            { shader = 'dissolve', shadow_height = 0.05 },
            { shader = 'dissolve' }
        })
        if k == 1 then
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = (function()
                    G.CONTROLLER:snap_to { node = temp_blind }
                    return true
                end)
            }))
        end
        temp_blind.float = true
        temp_blind.states.hover.can = true
        temp_blind.states.drag.can = false
        temp_blind.states.collide.can = true
        temp_blind.config = { blind = v, force_focus = true }
        if discovered and not v.alerted then
            blinds_to_be_alerted[#blinds_to_be_alerted + 1] = temp_blind
        end
        temp_blind.hover = function()
            if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
                if not temp_blind.hovering and temp_blind.states.visible then
                    temp_blind.hovering = true
                    temp_blind.hover_tilt = 3
                    temp_blind:juice_up(0.05, 0.02)
                    play_sound('chips1', math.random() * 0.1 + 0.55, 0.12)
                    temp_blind.config.h_popup = create_UIBox_blind_popup(v, discovered)
                    temp_blind.config.h_popup_config = { align = 'cl', offset = { x = -0.1, y = 0 }, parent = temp_blind }
                    Node.hover(temp_blind)
                    if temp_blind.children.alert then
                        temp_blind.children.alert:remove()
                        temp_blind.children.alert = nil
                        temp_blind.config.blind.alerted = true
                        G:save_progress()
                    end
                end
            end
            temp_blind.stop_hover = function()
                temp_blind.hovering = false; Node.stop_hover(temp_blind); temp_blind.hover_tilt = 0
            end
        end
        local row = math.ceil((k - 1) / blinds_per_row + 0.001)
        table.insert(blind_matrix[row], {
            n = G.UIT.C,
            config = { align = "cm", padding = 0.1 },
            nodes = {
                ((k - blinds_per_row) % (2 * blinds_per_row) == 1) and { n = G.UIT.B, config = { h = 0.2, w = 0.5 } } or
                nil,
                { n = G.UIT.O, config = { object = temp_blind, focus_with_object = true } },
                ((k - blinds_per_row) % (2 * blinds_per_row) == 0) and { n = G.UIT.B, config = { h = 0.2, w = 0.5 } } or
                nil,
            }
        })
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function()
            for _, v in ipairs(blinds_to_be_alerted) do
                v.children.alert = UIBox {
                    definition = create_UIBox_card_alert(),
                    config = { align = "tri", offset = { x = 0.1, y = 0.1 }, parent = v }
                }
                v.children.alert.states.collide.can = false
            end
            return true
        end)
    }))

    local ante_amounts = {}
    for i = 1, math.min(16, math.max(16, G.PROFILES[G.SETTINGS.profile].high_scores.furthest_ante.amt)) do
        local spacing = 1 -
            math.min(20, math.max(15, G.PROFILES[G.SETTINGS.profile].high_scores.furthest_ante.amt)) * 0.06
        if spacing > 0 and i > 1 then
            ante_amounts[#ante_amounts + 1] = { n = G.UIT.R, config = { minh = spacing }, nodes = {} }
        end
        local blind_chip = Sprite(0, 0, 0.2, 0.2, G.ASSET_ATLAS["ui_" .. (G.SETTINGS.colourblind_option and 2 or 1)],
            { x = 0, y = 0 })
        blind_chip.states.drag.can = false
        ante_amounts[#ante_amounts + 1] = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.03 },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cm", minw = 0.7 },
                    nodes = {
                        { n = G.UIT.T, config = { text = i, scale = 0.4, colour = G.C.FILTER, shadow = true } },
                    }
                },
                {
                    n = G.UIT.C,
                    config = { align = "cr", minw = 2.8 },
                    nodes = {
                        { n = G.UIT.O, config = { object = blind_chip } },
                        { n = G.UIT.C, config = { align = "cm", minw = 0.03, minh = 0.01 },                                                                                                                                         nodes = {} },
                        { n = G.UIT.T, config = { text = number_format(get_blind_amount(i)), scale = 0.4, colour = i <= G.PROFILES[G.SETTINGS.profile].high_scores.furthest_ante.amt and G.C.RED or G.C.JOKER_GREY, shadow = true } },
                    }
                }
            }
        }
    end

    local extras = nil
    local t = create_UIBox_generic_options({
        back_func = exit or 'your_collection',
        contents = {
            {
                n = G.UIT.C,
                config = { align = "cm", r = 0.1, colour = G.C.BLACK, padding = 0.1, emboss = 0.05 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm", r = 0.1, colour = G.C.L_BLACK, padding = 0.1, force_focus = true, focus_args = { nav = 'tall' } },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm", padding = 0.05 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cm", minw = 0.7 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = localize('k_ante_cap'), scale = 0.4, colour = lighten(G.C.FILTER, 0.2), shadow = true } },
                                        }
                                    },
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cr", minw = 2.8 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = localize('k_base_cap'), scale = 0.4, colour = lighten(G.C.RED, 0.2), shadow = true } },
                                        }
                                    }
                                }
                            },
                            { n = G.UIT.R, config = { align = "cm" }, nodes = ante_amounts }
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "cm" },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.R, config = { align = "cm" }, nodes = blind_matrix[1] },
                                    { n = G.UIT.R, config = { align = "cm" }, nodes = blind_matrix[2] },
                                    { n = G.UIT.R, config = { align = "cm" }, nodes = blind_matrix[3] },
                                    { n = G.UIT.R, config = { align = "cm" }, nodes = blind_matrix[4] },
                                    { n = G.UIT.R, config = { align = "cm" }, nodes = blind_matrix[5] },
                                    { n = G.UIT.R, config = { align = "cm" }, nodes = blind_matrix[6] },
                                }
                            }
                        }
                    }
                }
            }
        }
    })
    return t
end

function create_UIBox_round_scores_row(score, text_colour)
    local label = G.GAME.round_scores[score] and localize('ph_score_' .. score) or ''
    local check_high_score = false
    local score_tab = {}
    local label_w, score_w, h = ({ hand = true, poker_hand = true })[score] and 3.5 or 2.9,
        ({ hand = true, poker_hand = true })[score] and 3.5 or 1, 0.5

    if score == 'furthest_ante' then
        label_w = 1.9
        check_high_score = true
        label = localize('k_ante')
        score_tab = {
            { n = G.UIT.O, config = { object = DynaText({ string = { number_format(G.GAME.round_resets.ante) }, colours = { text_colour or G.C.FILTER }, shadow = true, float = true, scale = 0.45 }) } },
        }
    end
    if score == 'furthest_round' then
        label_w = 1.9
        check_high_score = true
        label = localize('k_round')
        score_tab = {
            { n = G.UIT.O, config = { object = DynaText({ string = { number_format(G.GAME.round) }, colours = { text_colour or G.C.FILTER }, shadow = true, float = true, scale = 0.45 }) } },
        }
    end
    if score == 'seed' then
        label_w = 1.9
        score_w = 1.9
        label = localize('k_seed')
        score_tab = {
            { n = G.UIT.O, config = { object = DynaText({ string = { G.GAME.pseudorandom.seed }, colours = { text_colour or G.C.WHITE }, shadow = true, float = true, scale = 0.45 }) } },
        }
    end
    if score == 'defeated_by' then
        label = localize('k_defeated_by')
        local blind_choice = { config = G.GAME.blind.config.blind or G.P_BLINDS.bl_small }
        local atlas = 'blind_chips'
        if blind_choice.config.atlas then
            atlas = blind_choice.config.atlas
        end
        blind_choice.animation = AnimatedSprite(0, 0, 1.4, 1.4, G.ANIMATION_ATLAS[atlas], blind_choice.config.pos)
        blind_choice.animation:define_draw_steps({
            { shader = 'dissolve', shadow_height = 0.05 },
            { shader = 'dissolve' }
        })

        score_tab = {
            {
                n = G.UIT.R,
                config = { align = "cm", minh = 0.6 },
                nodes = {
                    { n = G.UIT.O, config = { object = DynaText({ string = localize { type = 'name_text', key = blind_choice.config.key, set = 'Blind' }, colours = { G.C.WHITE }, shadow = true, float = true, maxw = 2.2, scale = 0.45 }) } }
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.1 },
                nodes = {
                    { n = G.UIT.O, config = { object = blind_choice.animation } }
                }
            },
        }
    end

    local label_scale = 0.5

    if score == 'poker_hand' then
        local handname, amount = localize('k_none'), 0
        for k, v in pairs(G.GAME.hand_usage) do
            if v.count > amount then
                handname = v.order; amount = v.count
            end
        end
        score_tab = {
            { n = G.UIT.O, config = { object = DynaText({ string = { amount < 1 and handname or localize(handname, 'poker_hands') }, colours = { text_colour or G.C.WHITE }, shadow = true, float = true, scale = 0.45, maxw = 2.5 }) } },
            { n = G.UIT.T, config = { text = " (" .. amount .. ")", scale = 0.35, colour = G.C.JOKER_GREY } }
        }
    elseif score == 'hand' then
        check_high_score = true
        local chip_sprite = Sprite(0, 0, 0.3, 0.3, G.ASSET_ATLAS["ui_" .. (G.SETTINGS.colourblind_option and 2 or 1)],
            { x = 0, y = 0 })
        chip_sprite.states.drag.can = false
        score_tab = {
            {
                n = G.UIT.C,
                config = { align = "cm" },
                nodes = {
                    { n = G.UIT.O, config = { w = 0.3, h = 0.3, object = chip_sprite } }
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm" },
                nodes = {
                    { n = G.UIT.O, config = { object = DynaText({ string = { number_format(G.GAME.round_scores[score].amt) }, colours = { text_colour or G.C.RED }, shadow = true, float = true, scale = math.min(0.6, score_number_scale(1.2, G.GAME.round_scores[score].amt)) }) } },
                }
            },
        }
    elseif G.GAME.round_scores[score] and not score_tab[1] then
        score_tab = {
            { n = G.UIT.O, config = { object = DynaText({ string = { number_format(G.GAME.round_scores[score].amt) }, colours = { text_colour or G.C.FILTER }, shadow = true, float = true, scale = score_number_scale(0.6, G.GAME.round_scores[score].amt) }) } },
        }
    end
    return {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.JOKER_GREY, 0.1), emboss = 0.05, func = check_high_score and 'high_score_alert' or nil, id = score },
        nodes = {
            {
                n = score == 'defeated_by' and G.UIT.R or G.UIT.C,
                config = { align = "cm", padding = 0.02, minw = label_w, maxw = label_w },
                nodes = {
                    { n = G.UIT.T, config = { text = label, scale = label_scale, colour = G.C.UI.TEXT_LIGHT, shadow = true } },
                }
            },
            {
                n = score == 'defeated_by' and G.UIT.R or G.UIT.C,
                config = { align = "cr" },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm", minh = h, r = 0.1, minw = score == 'defeated_by' and label_w or score_w, colour = (score == 'seed' and G.GAME.seeded) and G.C.RED or G.C.BLACK, emboss = 0.05 },
                        nodes = {
                            { n = G.UIT.C, config = { align = "cm", padding = 0.05, r = 0.1, minw = score_w }, nodes = score_tab },
                        }
                    }
                }
            },
        }
    }
end

function add_round_eval_row(config)
    local config = config or {}
    local width = G.round_eval.T.w - 0.51
    local num_dollars = config.dollars or 1
    local scale = 0.9

    if config.name ~= 'bottom' then
        if config.name ~= 'blind1' then
            if not G.round_eval.divider_added then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.25,
                    func = function()
                        local spacer = {
                            n = G.UIT.R,
                            config = { align = "cm", minw = width },
                            nodes = {
                                { n = G.UIT.O, config = { object = DynaText({ string = { '......................................' }, colours = { G.C.WHITE }, shadow = true, float = true, y_offset = -30, scale = 0.45, spacing = 13.5, font = G.LANGUAGES['en-us'].font, pop_in = 0 }) } }
                            }
                        }
                        G.round_eval:add_child(spacer,
                            G.round_eval:get_UIE_by_ID(config.bonus and 'bonus_round_eval' or 'base_round_eval'))
                        return true
                    end
                }))
                delay(0.6)
                G.round_eval.divider_added = true
            end
        else
            delay(0.2)
        end

        delay(0.2)

        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.5,
            func = function()
                --Add the far left text and context first:
                local left_text = {}
                if config.name == 'blind1' then
                    local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.5)
                    local atlas = 'blind_chips'
                    if G.GAME.blind.config.blind.atlas then
                        atlas = G.GAME.blind.config.blind.atlas
                    end
                    local blind_sprite = AnimatedSprite(0, 0, 1.2, 1.2, G.ANIMATION_ATLAS[atlas],
                        copy_table(G.GAME.blind.pos))
                    blind_sprite:define_draw_steps({
                        { shader = 'dissolve', shadow_height = 0.05 },
                        { shader = 'dissolve' }
                    })
                    table.insert(left_text,
                        { n = G.UIT.O, config = { w = 1.2, h = 1.2, object = blind_sprite, hover = true, can_collide = false } })

                    table.insert(left_text,
                        config.saved and
                        {
                            n = G.UIT.C,
                            config = { padding = 0.05, align = 'cm' },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = 'cm' },
                                    nodes = {
                                        { n = G.UIT.O, config = { object = DynaText({ string = { ' ' .. localize('ph_mr_bones') .. ' ' }, colours = { G.C.FILTER }, shadow = true, pop_in = 0, scale = 0.5 * scale, silent = true }) } }
                                    }
                                }
                            }
                        }
                        or {
                            n = G.UIT.C,
                            config = { padding = 0.05, align = 'cm' },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = 'cm' },
                                    nodes = {
                                        { n = G.UIT.O, config = { object = DynaText({ string = { ' ' .. localize('ph_score_at_least') .. ' ' }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } }
                                    }
                                },
                                {
                                    n = G.UIT.R,
                                    config = { align = 'cm', minh = 0.8 },
                                    nodes = {
                                        { n = G.UIT.O, config = { w = 0.5, h = 0.5, object = stake_sprite, hover = true, can_collide = false } },
                                        { n = G.UIT.T, config = { text = G.GAME.blind.chip_text, scale = scale_number(G.GAME.blind.chips, scale, 100000), colour = G.C.RED, shadow = true } }
                                    }
                                }
                            }
                        })
                elseif string.find(config.name, 'tag') then
                    local blind_sprite = Sprite(0, 0, 0.7, 0.7, G.ASSET_ATLAS['tags'], copy_table(config.pos))
                    blind_sprite:define_draw_steps({
                        { shader = 'dissolve', shadow_height = 0.05 },
                        { shader = 'dissolve' }
                    })
                    blind_sprite:juice_up()
                    table.insert(left_text,
                        { n = G.UIT.O, config = { w = 0.7, h = 0.7, object = blind_sprite, hover = true, can_collide = false } })
                    table.insert(left_text,
                        { n = G.UIT.O, config = { object = DynaText({ string = { config.condition }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
                elseif config.name == 'hands' then
                    table.insert(left_text,
                        { n = G.UIT.T, config = { text = config.disp or config.dollars, scale = 0.8 * scale, colour = G.C.BLUE, shadow = true, juice = true } })
                    table.insert(left_text,
                        { n = G.UIT.O, config = { object = DynaText({ string = { " " .. localize { type = 'variable', key = 'remaining_hand_money', vars = { G.GAME.modifiers.money_per_hand or 1 } } }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
                elseif config.name == 'discards' then
                    table.insert(left_text,
                        { n = G.UIT.T, config = { text = config.disp or config.dollars, scale = 0.8 * scale, colour = G.C.RED, shadow = true, juice = true } })
                    table.insert(left_text,
                        { n = G.UIT.O, config = { object = DynaText({ string = { " " .. localize { type = 'variable', key = 'remaining_discard_money', vars = { G.GAME.modifiers.money_per_discard or 0 } } }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
                elseif string.find(config.name, 'joker') then
                    table.insert(left_text,
                        { n = G.UIT.O, config = { object = DynaText({ string = localize { type = 'name_text', set = config.card.config.center.set, key = config.card.config.center.key }, colours = { G.C.FILTER }, shadow = true, pop_in = 0, scale = 0.6 * scale, silent = true }) } })
                elseif config.name == 'interest' then
                    table.insert(left_text,
                        { n = G.UIT.T, config = { text = num_dollars, scale = 0.8 * scale, colour = G.C.MONEY, shadow = true, juice = true } })
                    table.insert(left_text,
                        { n = G.UIT.O, config = { object = DynaText({ string = { " " .. localize { type = 'variable', key = 'interest', vars = { G.GAME.interest_amount, 5, G.GAME.interest_amount * G.GAME.interest_cap / 5 } } }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
                end
                local full_row = {
                    n = G.UIT.R,
                    config = { align = "cm", minw = 5 },
                    nodes = {
                        { n = G.UIT.C, config = { padding = 0.05, minw = width * 0.55, minh = 0.61, align = "cl" }, nodes = left_text },
                        { n = G.UIT.C, config = { padding = 0.05, minw = width * 0.45, align = "cr" },              nodes = { { n = G.UIT.C, config = { align = "cm", id = 'dollar_' .. config.name }, nodes = {} } } }
                    }
                }

                if config.name == 'blind1' then
                    G.GAME.blind:juice_up()
                end
                G.round_eval:add_child(full_row,
                    G.round_eval:get_UIE_by_ID(config.bonus and 'bonus_round_eval' or 'base_round_eval'))
                play_sound('cancel', config.pitch or 1)
                play_sound('highlight1', (1.5 * config.pitch) or 1, 0.2)
                if config.card then config.card:juice_up(0.7, 0.46) end
                return true
            end
        }))
        local dollar_row = 0
        if num_dollars > 60 then
            local dollar_string = localize('$') .. num_dollars
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.38,
                func = function()
                    G.round_eval:add_child(
                        {
                            n = G.UIT.R,
                            config = { align = "cm", id = 'dollar_row_' .. (dollar_row + 1) .. '_' .. config.name },
                            nodes = {
                                { n = G.UIT.O, config = { object = DynaText({ string = { localize('$') .. num_dollars }, colours = { G.C.MONEY }, shadow = true, pop_in = 0, scale = 0.65, float = true }) } }
                            }
                        },
                        G.round_eval:get_UIE_by_ID('dollar_' .. config.name))

                    play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7)
                    play_sound('coin6', 1.3, 0.8)
                    return true
                end
            }))
        else
            for i = 1, num_dollars or 1 do
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.18 - ((num_dollars > 20 and 0.13) or (num_dollars > 9 and 0.1) or 0),
                    func = function()
                        if i % 30 == 1 then
                            G.round_eval:add_child(
                                { n = G.UIT.R, config = { align = "cm", id = 'dollar_row_' .. (dollar_row + 1) .. '_' .. config.name }, nodes = {} },
                                G.round_eval:get_UIE_by_ID('dollar_' .. config.name))
                            dollar_row = dollar_row + 1
                        end

                        local r = { n = G.UIT.T, config = { text = localize('$'), colour = G.C.MONEY, scale = ((num_dollars > 20 and 0.28) or (num_dollars > 9 and 0.43) or 0.58), shadow = true, hover = true, can_collide = false, juice = true } }
                        play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7 - (num_dollars > 20 and 0.2 or 0))

                        if config.name == 'blind1' then
                            G.GAME.current_round.dollars_to_be_earned = G.GAME.current_round.dollars_to_be_earned:sub(2)
                        end

                        G.round_eval:add_child(r,
                            G.round_eval:get_UIE_by_ID('dollar_row_' .. (dollar_row) .. '_' .. config.name))
                        G.VIBRATION = G.VIBRATION + 0.4
                        return true
                    end
                }))
            end
        end
    else
        delay(0.4)
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.5,
            func = function()
                UIBox {
                    definition = { n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR }, nodes = {
                        { n = G.UIT.R, config = { id = 'cash_out_button', align = "cm", padding = 0.1, minw = 7, r = 0.15, colour = G.C.ORANGE, shadow = true, hover = true, one_press = true, button = 'cash_out', focus_args = { snap_to = true } }, nodes = {
                            { n = G.UIT.T, config = { text = localize('b_cash_out') .. ": ", scale = 1, colour = G.C.UI.TEXT_LIGHT, shadow = true } },
                            { n = G.UIT.T, config = { text = localize('$') .. config.dollars, scale = 1.2 * scale, colour = G.C.WHITE, shadow = true, juice = true } }
                        } }, } },
                    config = {
                        align = 'tmi',
                        offset = { x = 0, y = 0.4 },
                        major = G.round_eval }
                }

                --local left_text = {n=G.UIT.R, config={id = 'cash_out_button', align = "cm", padding = 0.1, minw = 2, r = 0.15, colour = G.C.ORANGE, shadow = true, hover = true, one_press = true, button = 'cash_out', focus_args = {snap_to = true}}, nodes={
                --    {n=G.UIT.T, config={text = localize('b_cash_out')..": ", scale = 1, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
                --    {n=G.UIT.T, config={text = localize('$')..config.dollars, scale = 1.3*scale, colour = G.C.WHITE, shadow = true, juice = true}}
                --}}
                --G.round_eval:add_child(left_text,G.round_eval:get_UIE_by_ID('eval_bottom'))

                G.GAME.current_round.dollars = config.dollars

                play_sound('coin6', config.pitch or 1)
                G.VIBRATION = G.VIBRATION + 1
                return true
            end
        }))
    end
end

local blind_loadref = Blind.load
function Blind.load(self, blindTable)
    self.config.blind = G.P_BLINDS[blindTable.config_blind] or {}
    if self.config.blind.atlas then
        self.children.animatedSprite.atlas = G.ANIMATION_ATLAS[self.config.blind.atlas]
    end
    blind_loadref(self, blindTable)
end

SMODS.SOUND_SOURCES = {}

function register_sound(name, path, filename)
	local sound_code = string.sub(filename, 1, -5)
	local s = {
		sound = love.audio.newSource(path .. "assets/sounds/" .. filename, string.find(sound_code,'music') and "stream" or 'static'),
		filepath = path .. "assets/sounds/" .. filename
	}
	s.original_pitch = 1
	s.original_volume = 0.75
	s.sound_code = name

	sendInfoMessage("Registered sound " .. name .. " from file " .. filename, 'SoundAPI')
	SMODS.SOUND_SOURCES[name] = s
end


function modded_play_sound(sound_code, stop_previous_instance, volume, pitch)
    stop_previous_instance = stop_previous_instance or false
    sound_code = string.lower(sound_code)
    for _, s in pairs(SMODS.SOUND_SOURCES) do
        if s.sound_code == sound_code then
            if volume then
                s.original_volume = volume
            else
                s.original_volume = 1
            end
            if pitch then
                s.original_pitch = pitch
            else
                s.original_pitch = 1
            end
            sendTraceMessage("found sound code: " .. sound_code, 'SoundAPI')
            s.sound:setPitch(pitch)
            local sound_vol = s.original_volume*(G.SETTINGS.SOUND.volume/100.0)*(G.SETTINGS.SOUND.game_sounds_volume/100.0)
            if sound_vol <= 0 then
                s.sound:setVolume(0)
            else
                s.sound:setVolume(sound_vol)
            end
            s.sound:setPitch(s.original_pitch)
            if stop_previous_instance and s.sound:isPlaying() then
                s.sound:stop()
            end
            love.audio.play(s.sound)
            return true
        end
    end
    return false
end
-- ----------------------------------------------
-- ------------MOD CORE API SPRITE---------------


-- BASE REFERENCES FROM MAIN GAME
-- G.animation_atli = {
--     {name = "blind_chips", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/BlindChips.png",px=34,py=34, frames = 21},
--     {name = "shop_sign", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/ShopSignAnimation.png",px=113,py=57, frames = 4}
-- }
-- G.asset_atli = {
--     {name = "cards_1", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/8BitDeck.png",px=71,py=95},
--     {name = "cards_2", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/8BitDeck_opt2.png",px=71,py=95},
--     {name = "centers", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/Enhancers.png",px=71,py=95},
--     {name = "Joker", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/Jokers.png",px=71,py=95},
--     {name = "Tarot", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/Tarots.png",px=71,py=95},
--     {name = "Voucher", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/Vouchers.png",px=71,py=95},
--     {name = "Booster", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/boosters.png",px=71,py=95},
--     {name = "ui_1", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/ui_assets.png",px=18,py=18},
--     {name = "ui_2", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/ui_assets_opt2.png",px=18,py=18},
--     {name = "balatro", path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/balatro.png",px=333,py=216},        
--     {name = 'gamepad_ui', path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/gamepad_ui.png",px=32,py=32},
--     {name = 'icons', path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/icons.png",px=66,py=66},
--     {name = 'tags', path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/tags.png",px=34,py=34},
--     {name = 'stickers', path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/stickers.png",px=71,py=95},
--     {name = 'chips', path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/chips.png",px=29,py=29}
-- }
-- G.asset_images = {
--     {name = "playstack_logo", path = "resources/textures/1x/playstack-logo.png", px=1417,py=1417},
--     {name = "localthunk_logo", path = "resources/textures/1x/localthunk-logo.png", px=1390,py=560}
-- }

SMODS.Sprites = {}
SMODS.Sprite = {name = "", top_lpath = "", path = "", px = 0, py = 0, type = "", frames = 0}

function SMODS.Sprite:new(name, top_lpath, path, px, py, type, frames)
	o = {}
	setmetatable(o, self)
	self.__index = self

	o.name = name
    o.top_lpath = top_lpath .. "assets/"
	o.path = path
	o.px = px
	o.py = py
    if type == "animation_atli" then
        o.frames = frames
        o.type = type
    elseif type == "asset_atli" or type == "asset_images" then
        o.type = type
    else
        error("Bad Sprite type")
    end

	return o
end

function SMODS.Sprite:register()
	if not SMODS.Sprites[self] then
		table.insert(SMODS.Sprites, self)
	end
end

function SMODS.injectSprites()

	for i, sprite in ipairs(SMODS.Sprites) do
        local foundAndReplaced = false

		if sprite.type == "animation_atli" then
            for i, asset in ipairs(G.animation_atli) do
                if asset.name == sprite.name then
                    G.animation_atli[i] = {name = sprite.name, path = sprite.top_lpath .. G.SETTINGS.GRAPHICS.texture_scaling .. 'x/' .. sprite.path, px = sprite.px, py = sprite.py , frames = sprite.frames}
                    foundAndReplaced = true
                    break
                end
            end
            if foundAndReplaced ~= true then
                table.insert(G.animation_atli, {name = sprite.name, path = sprite.top_lpath .. G.SETTINGS.GRAPHICS.texture_scaling .. 'x/' .. sprite.path, px = sprite.px, py = sprite.py , frames = sprite.frames})
            end
        elseif sprite.type == "asset_atli" then
            for i, asset in ipairs(G.asset_atli) do
                if asset.name == sprite.name then
                    G.asset_atli[i] = {name = sprite.name, path = sprite.top_lpath .. G.SETTINGS.GRAPHICS.texture_scaling .. 'x/' .. sprite.path, px = sprite.px, py = sprite.py}
                    foundAndReplaced = true
                    break
                end
            end
            if foundAndReplaced ~= true then
                table.insert(G.asset_atli, {name = sprite.name, path = sprite.top_lpath .. G.SETTINGS.GRAPHICS.texture_scaling .. 'x/' .. sprite.path, px = sprite.px, py = sprite.py})
            end
        elseif sprite.type == "asset_images" then
            for i, asset in ipairs(G.asset_images) do
                if asset.name == sprite.name then
                    G.asset_images[i] = {name = sprite.name, path = sprite.top_lpath .. '1x/' .. sprite.path, px = sprite.px, py = sprite.py}
                    foundAndReplaced = true
                    break
                end
            end
            if foundAndReplaced ~= true then
                table.insert(G.asset_images, {name = sprite.name, path = sprite.top_lpath .. '1x/' .. sprite.path, px = sprite.px, py = sprite.py})
            end
        else
            error("Bad Sprite type")
        end
		
		sendInfoMessage("Registered Sprite " .. sprite.name .. " with path " .. sprite.path .. ".", 'SpriteAPI')
	end

    --Reload Textures
    
    G.SETTINGS.GRAPHICS.texture_scaling = G.SETTINGS.GRAPHICS.texture_scaling or 2

    --Set fiter to linear interpolation and nearest, best for pixel art
    love.graphics.setDefaultFilter(
        G.SETTINGS.GRAPHICS.texture_scaling == 1 and 'nearest' or 'linear',
        G.SETTINGS.GRAPHICS.texture_scaling == 1 and 'nearest' or 'linear', 1)

    --self.CANVAS = self.CANVAS or love.graphics.newCanvas(500, 500, {readable = true})
    love.graphics.setLineStyle("rough")

    for i=1, #G.animation_atli do
        G.ANIMATION_ATLAS[G.animation_atli[i].name] = {}
        G.ANIMATION_ATLAS[G.animation_atli[i].name].name = G.animation_atli[i].name
        local file_data = NFS.newFileData( G.animation_atli[i].path )
        if file_data then
            local image_data = love.image.newImageData(file_data)
            if image_data then
                G.ANIMATION_ATLAS[G.animation_atli[i].name].image = love.graphics.newImage(image_data, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
            else
                G.ANIMATION_ATLAS[G.animation_atli[i].name].image = love.graphics.newImage(G.animation_atli[i].path, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
            end
        else
            G.ANIMATION_ATLAS[G.animation_atli[i].name].image = love.graphics.newImage(G.animation_atli[i].path, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
        end
        G.ANIMATION_ATLAS[G.animation_atli[i].name].px = G.animation_atli[i].px
        G.ANIMATION_ATLAS[G.animation_atli[i].name].py = G.animation_atli[i].py
        G.ANIMATION_ATLAS[G.animation_atli[i].name].frames = G.animation_atli[i].frames
    end

    for i=1, #G.asset_atli do
        G.ASSET_ATLAS[G.asset_atli[i].name] = {}
        G.ASSET_ATLAS[G.asset_atli[i].name].name = G.asset_atli[i].name
        local file_data = NFS.newFileData( G.asset_atli[i].path )
        if file_data then
            local image_data = love.image.newImageData(file_data)
            if image_data then
                G.ASSET_ATLAS[G.asset_atli[i].name].image = love.graphics.newImage(image_data, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
            else
                G.ASSET_ATLAS[G.asset_atli[i].name].image = love.graphics.newImage(G.asset_atli[i].path, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
            end
        else
            G.ASSET_ATLAS[G.asset_atli[i].name].image = love.graphics.newImage(G.asset_atli[i].path, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
        end
        G.ASSET_ATLAS[G.asset_atli[i].name].type = G.asset_atli[i].type
        G.ASSET_ATLAS[G.asset_atli[i].name].px = G.asset_atli[i].px
        G.ASSET_ATLAS[G.asset_atli[i].name].py = G.asset_atli[i].py
    end

    for i=1, #G.asset_images do
        G.ASSET_ATLAS[G.asset_images[i].name] = {}
        G.ASSET_ATLAS[G.asset_images[i].name].name = G.asset_images[i].name
        local file_data = NFS.newFileData( G.asset_images[i].path )
        if file_data then
            local image_data = love.image.newImageData(file_data)
            if image_data then
                G.ASSET_ATLAS[G.asset_images[i].name].image = love.graphics.newImage(image_data, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
            else
                G.ASSET_ATLAS[G.asset_images[i].name].image = love.graphics.newImage(G.asset_images[i].path, {mipmaps = true, dpiscale = 1})
            end
        else
            G.ASSET_ATLAS[G.asset_images[i].name].image = love.graphics.newImage(G.asset_images[i].path, {mipmaps = true, dpiscale = 1})
        end
        G.ASSET_ATLAS[G.asset_images[i].name].type = G.asset_images[i].type
        G.ASSET_ATLAS[G.asset_images[i].name].px = G.asset_images[i].px
        G.ASSET_ATLAS[G.asset_images[i].name].py = G.asset_images[i].py
    end

    for _, v in pairs(G.I.SPRITE) do
        v:reset()
    end

    G.ASSET_ATLAS.Planet = G.ASSET_ATLAS.Tarot
    G.ASSET_ATLAS.Spectral = G.ASSET_ATLAS.Tarot

    sendInfoMessage("All the sprites have been loaded!", 'SpriteAPI')
end

gameset_render_settingsRef = Game.set_render_settings
function Game:set_render_settings()
    gameset_render_settingsRef(self)
    SMODS.injectSprites()
end

-- Allows Jokers to have custom atlases
local set_spritesref = Card.set_sprites
function Card:set_sprites(_center, _front)
    set_spritesref(self, _center, _front);
    if _center then
        if _center.set then
            if (_center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher') and _center.atlas then
                if self.params.bypass_discovery_center or (_center.unlocked and _center.discovered) then
                    self.children.center.atlas = G.ASSET_ATLAS
                    [(_center.atlas or (_center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher') and _center.set) or 'centers']
                    self.children.center:set_sprite_pos(_center.pos)
                elseif not _center.discovered then
                    self.children.center.atlas = G.ASSET_ATLAS[_center.set]
                    self.children.center:set_sprite_pos(
                    (_center.set == 'Joker' and G.j_undiscovered.pos) or 
                    (_center.set == 'Edition' and G.j_undiscovered.pos) or 
                    (_center.set == 'Tarot' and G.t_undiscovered.pos) or 
                    (_center.set == 'Planet' and G.p_undiscovered.pos) or 
                    (_center.set == 'Spectral' and G.s_undiscovered.pos) or 
                    (_center.set == 'Voucher' and G.v_undiscovered.pos) or 
                    (_center.set == 'Booster' and G.booster_undiscovered.pos))
                end
                if _center.soul_pos then
                    self.children.floating_sprite.atlas = G.ASSET_ATLAS[_center.atlas or _center.set]
                    self.children.floating_sprite:set_sprite_pos(_center.soul_pos)
                end
            end
        end
    end
    if _front then
        self.children.front.atlas = G.ASSET_ATLAS[_front.atlas] or
        G.ASSET_ATLAS[G.SETTINGS.colourblind_option and _front.card_atlas_high_contrast or _front.card_atlas_low_contrast] or
        G.ASSET_ATLAS["cards_" .. (G.SETTINGS.colourblind_option and 2 or 1)]
        self.children.front:set_sprite_pos(self.config.card.pos)
    end
end


-- ----------------------------------------------
-- ------------MOD CORE API SPRITE END-----------
-- ----------------------------------------------
-- ------------MOD CORE API CARDS----------------
SMODS.Card = {}
SMODS.Card.SUIT_LIST = { 'Spades', 'Hearts', 'Clubs', 'Diamonds' }
SMODS.Card.SUITS = {
	["Hearts"] = {
		name = 'Hearts',
		prefix = 'H',
		suit_nominal = 0.03,
		ui_pos = { x = 0, y = 1 },
		card_pos = { y = 0 },
	},
	["Diamonds"] = {
		name = 'Diamonds',
		prefix = 'D',
		suit_nominal = 0.01,
		ui_pos = { x = 1, y = 1 },
		card_pos = { y = 2 },
	},
	["Clubs"] = {
		name = 'Clubs',
		prefix = 'C',
		suit_nominal = 0.02,
		ui_pos = { x = 2, y = 1 },
		card_pos = { y = 1 },
	},
	["Spades"] = {
		name = 'Spades',
		prefix = 'S',
		suit_nominal = 0.04,
		ui_pos = { x = 3, y = 1 },
		card_pos = { y = 3 }
	},
}
SMODS.Card.MAX_SUIT_NOMINAL = 0.04
SMODS.Card.RANKS = {
	['2'] = { value = '2', pos = { x = 0 }, id = 2, nominal = 2, next = { '3' } },
	['3'] = { value = '3', pos = { x = 1 }, id = 3, nominal = 3, next = { '4' } },
	['4'] = { value = '4', pos = { x = 2 }, id = 4, nominal = 4, next = { '5' } },
	['5'] = { value = '5', pos = { x = 3 }, id = 5, nominal = 5, next = { '6' } },
	['6'] = { value = '6', pos = { x = 4 }, id = 6, nominal = 6, next = { '7' } },
	['7'] = { value = '7', pos = { x = 5 }, id = 7, nominal = 7, next = { '8' } },
	['8'] = { value = '8', pos = { x = 6 }, id = 8, nominal = 8, next = { '9' } },
	['9'] = { value = '9', pos = { x = 7 }, id = 9, nominal = 9, next = { '10' } },
	['10'] = { suffix = 'T', value = '10', pos = { x = 8 }, id = 10, nominal = 10, next = { 'Jack' } },
	['Jack'] = { suffix = 'J', value = 'Jack', pos = { x = 9 }, id = 11, nominal = 10, face_nominal = 0.1, face = true, next = { 'Queen' }, shorthand = 'J' },
	['Queen'] = { suffix = 'Q', value = 'Queen', pos = { x = 10 }, id = 12, nominal = 10, face_nominal = 0.2, face = true, next = { 'King' }, shorthand = 'Q' },
	['King'] = { suffix = 'K', value = 'King', pos = { x = 11 }, id = 13, nominal = 10, face_nominal = 0.3, face = true, next = { 'Ace', shorthand = 'K' } },
	['Ace'] = { suffix = 'A', value = 'Ace', pos = { x = 12 }, id = 14, nominal = 11, face_nominal = 0.4, next = { '2' }, straight_edge = true, shorthand = 'A' }
}
SMODS.Card.RANK_LIST = { '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A' }
SMODS.Card.RANK_SHORTHAND_LOOKUP = {
	['J'] = 'Jack',
	['Q'] = 'Queen',
	['K'] = 'King',
	['A'] = 'Ace',
}
SMODS.Card.MAX_ID = 14
function SMODS.Card.generate_prefix()
	local permutations
	permutations = function(list, len)
		len = len or 2
		if len <= 1 then return list end
		local t = permutations(list, len - 1)
		local o = {}
		for _, a in ipairs(list) do
			for _, b in ipairs(t) do
				table.insert(o, a .. b)
			end
		end
		return o
	end
	local possible_prefixes = { 'A', 'B', 'E', 'F', 'G', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'T', 'U', 'V',
		'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
		't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9' }
	local perm = permutations(possible_prefixes, 2)
	for _, a in ipairs(perm) do
		table.insert(possible_prefixes, a)
	end
	for _, v in pairs(SMODS.Card.SUITS) do
		for i, vv in ipairs(possible_prefixes) do
			if v.prefix == vv then
				table.remove(possible_prefixes, i)
			end
		end
	end
	return possible_prefixes[1]
end

function SMODS.Card.generate_suffix()
	local permutations
	permutations = function(list, len)
		len = len or 2
		if len <= 1 then return list end
		local t = permutations(list, len - 1)
		local o = {}
		for _, a in ipairs(list) do
			for _, b in ipairs(t) do
				table.insert(o, a .. b)
			end
		end
		return o
	end
	local possible_suffixes = { 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'L', 'M', 'N', 'O', 'P', 'R', 'S', 'T', 'U', 'V',
		'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
        't', 'u', 'v', 'w', 'x', 'y', 'z' }
	local perm = permutations(possible_suffixes, 2)
	for _, a in ipairs(perm) do
		table.insert(possible_suffixes, a)
	end
	for _, v in pairs(SMODS.Card.RANKS) do
		for i, vv in ipairs(possible_suffixes) do
			if v.suffix == vv then
				table.remove(possible_suffixes, i)
			end
		end
	end
	return possible_suffixes[1]
end

function SMODS.Card:new_suit(name, card_atlas_low_contrast, card_atlas_high_contrast, card_pos, ui_atlas_low_contrast,
							 ui_atlas_high_contrast, ui_pos, colour_low_contrast, colour_high_contrast, create_cards)
	if SMODS.Card.SUITS[name] then
		sendDebugMessage('Failed to register duplicate suit:' .. name)
		return nil
	end
	local prefix = SMODS.Card.generate_prefix()
	if not prefix then
		sendDebugMessage('Too many suits! Failed to assign valid prefix to:' .. name)
	end
	SMODS.Card.MAX_SUIT_NOMINAL = SMODS.Card.MAX_SUIT_NOMINAL + 0.01
	create_cards = not (create_cards == false)
	SMODS.Card.SUITS[name] = {
		name = name,
		prefix = prefix,
		suit_nominal = SMODS.Card.MAX_SUIT_NOMINAL,
		card_atlas_low_contrast = card_atlas_low_contrast,
		card_atlas_high_contrast = card_atlas_high_contrast,
		card_pos = { y = card_pos.y },
		ui_atlas_low_contrast = ui_atlas_low_contrast,
		ui_atlas_high_contrast = ui_atlas_high_contrast,
		ui_pos = ui_pos,
		disabled = not create_cards or nil
	}
	SMODS.Card.SUIT_LIST[#SMODS.Card.SUIT_LIST + 1] = name
	colour_low_contrast = colour_low_contrast or '000000'
	colour_high_contrast = colour_high_contrast or '000000'
	if not (type(colour_low_contrast) == 'table') then colour_low_contrast = HEX(colour_low_contrast) end
	if not (type(colour_high_contrast) == 'table') then colour_high_contrast = HEX(colour_high_contrast) end
	G.C.SO_1[name] = colour_low_contrast
	G.C.SO_2[name] = colour_high_contrast
	G.C.SUITS[name] = G.C["SO_" .. (G.SETTINGS.colourblind_option and 2 or 1)][name]
	G.localization.misc['suits_plural'][name] = name
	G.localization.misc['suits_singular'][name] = name:match("(.+)s$")
	if create_cards then
		SMODS.Card:populate_suit(name)
	end
	return SMODS.Card.SUITS[name]
end

-- DELETES ALL DATA ASSOCIATED WITH THE PROVIDED SUIT EXCEPT LOCALIZATION
function SMODS.Card:delete_suit(name)
	local suit_data = SMODS.Card.SUITS[name]
	if not suit_data then
		sendWarnMessage('Tried to delete non-existent suit: ' .. name, 'PlayingCardAPI')
		return false
	end
	local prefix = suit_data.prefix
	for _, v in pairs(SMODS.Card.RANKS) do
		G.P_CARDS[prefix .. '_' .. (v.suffix or v.value)] = nil
	end
	local i
	for j, v in ipairs(SMODS.Card.SUIT_LIST) do if v == suit_data.name then i = j end end
	table.remove(SMODS.Card.SUIT_LIST, i)
	SMODS.Card.SUITS[name] = nil
	return true
end

-- Deletes the playing cards of the provided suit from G.P_CARDS
function SMODS.Card:wipe_suit(name)
	local suit_data = SMODS.Card.SUITS[name]
	if not suit_data then
		sendWarnMessage('Tried to wipe non-existent suit: ' .. name, 'PlayingCardAPI')
		return false
	end
	local prefix = suit_data.prefix
	for _, v in pairs(SMODS.Card.RANKS) do
		G.P_CARDS[prefix .. '_' .. (v.suffix or v.value)] = nil
	end
	SMODS.Card.SUITS[name].disabled = true
	return true
end

-- Populates G.P_CARDS with cards of all ranks and the given suit
function SMODS.Card:populate_suit(name)
	local suit_data = SMODS.Card.SUITS[name]
	if not suit_data then
		sendWarnMessage('Tried to populate non-existent suit: ' .. name, 'PlayingCardAPI')
		return false
	end
	for _, v in pairs(SMODS.Card.RANKS) do
		if not v.disabled then
			G.P_CARDS[suit_data.prefix .. '_' .. (v.suffix or v.value)] = {
				name = v.value .. ' of ' .. name,
				value = v.value,
				suit = name,
				pos = { x = v.pos.x, y = (v.suit_map and v.suit_map[name]) and v.suit_map[name].y or suit_data.card_pos.y },
				card_atlas_low_contrast = (v.atlas_low_contrast and v.suit_map and v.suit_map[name]) and v
					.atlas_low_contrast or suit_data.card_atlas_low_contrast,
				card_atlas_high_contrast = (v.atlas_low_contrast and v.suit_map and v.suit_map[name]) and
					v.atlas_high_contrast or suit_data.card_atlas_high_contrast,
			}
		end
	end
	SMODS.Card.SUITS[name].disabled = nil
	return true
end

function SMODS.Card:new_rank(value, nominal, atlas_low_contrast, atlas_high_contrast, pos, suit_map, options,
							 create_cards)
	options = options or {}
	if SMODS.Card.RANKS[value] then
		sendWarnMessage('Failed to register duplicate rank: ' .. value, 'PlayingCardAPI')
		return nil
	end
	local suffix = SMODS.Card:generate_suffix()
	if not suffix then
		sendWarnMessage('Too many ranks! Failed to assign valid suffix to: ' .. value, 'PlayingCardAPI')
		return nil
	end
	SMODS.Card.MAX_ID = SMODS.Card.MAX_ID + 1
	create_cards = not (create_cards == false)
	local shorthand =
		options.shorthand.unique or
		options.shorthand.length and string.sub(value, 1, options.shorthand.length) or
		string.sub(value, 1, 1)
	SMODS.Card.RANK_LIST[#SMODS.Card.RANK_LIST + 1] = shorthand
    SMODS.Card.RANK_SHORTHAND_LOOKUP[shorthand] = value
	SMODS.Card.RANKS[value] = {
		value = value,
		suffix = suffix,
		pos = { x = pos.x },
		id = SMODS.Card.MAX_ID,
		nominal = nominal,
		atlas_low_contrast = atlas_low_contrast,
		atlas_high_contrast = atlas_high_contrast,
		suit_map = suit_map,
		face = options.face,
		face_nominal = options.face_nominal,
		strength_effect = options.strength_effect or {
			fixed = 1,
			random = false,
			ignore = false
		},
		next = options.next,
		straight_edge = options.straight_edge,
		disabled = not create_cards or nil,
		shorthand = shorthand,
    }
	local function nominal(v) 
        local rank_data = SMODS.Card.RANKS[SMODS.Card.RANK_SHORTHAND_LOOKUP[v] or v]
		return rank_data.nominal + (rank_data.face_nominal or 0)
	end
	table.sort(SMODS.Card.RANK_LIST, function(a, b) return nominal(a) < nominal(b) end)
	if create_cards then
		SMODS.Card:populate_rank(value)
	end
	G.localization.misc['ranks'][value] = value
	return SMODS.Card.RANKS[value]
end

-- DELETES ALL DATA ASSOCIATED WITH THE PROVIDED RANK EXCEPT LOCALIZATION
function SMODS.Card:delete_rank(value)
	local rank_data = SMODS.Card.RANKS[value]
	if not rank_data then
		sendWarnMessage('Tried to delete non-existent rank: ' .. value, 'PlayingCardAPI')
		return false
	end
	local suffix = rank_data.suffix or rank_data.value
	for _, v in pairs(SMODS.Card.SUITS) do
		G.P_CARDS[v.prefix .. '_' .. suffix] = nil
	end
	local i
    for j, v in ipairs(SMODS.Card.RANK_LIST) do if v == rank_data.shorthand or v == rank_data.value then i = j end end
	table.remove(SMODS.Card.RANK_LIST, i)
	SMODS.Card.RANKS[value] = nil
	return true
end

-- Deletes the playing cards of the provided rank from G.P_CARDS
function SMODS.Card:wipe_rank(value)
	local rank_data = SMODS.Card.RANKS[value]
	if not rank_data then
		sendWarnMessage('Tried to wipe non-existent rank: ' .. value, 'PlayingCardAPI')
		return false
	end
	local suffix = rank_data.suffix or rank_data.value
	for _, v in pairs(SMODS.Card.SUITS) do
		G.P_CARDS[v.prefix .. '_' .. suffix] = nil
	end
	SMODS.Card.RANKS[value].disabled = true
	return true
end

-- Populates G.P_CARDS with cards of all suits and the provided rank
function SMODS.Card:populate_rank(value)
	local rank_data = SMODS.Card.RANKS[value]
	if not rank_data then
		sendWarnMessage('Tried to populate non-existent rank: ' .. value, 'PlayingCardAPI')
		return false
	end
	local suffix = rank_data.suffix or rank_data.value
	for k, v in pairs(SMODS.Card.SUITS) do
		if not v.disabled then
			if rank_data.suit_map[k] then
				G.P_CARDS[v.prefix .. '_' .. suffix] = {
					name = value .. ' of ' .. v.name,
					value = value,
					pos = { x = rank_data.pos.x, y = rank_data.suit_map[k].y or v.card_pos.y },
					suit = v.name,
					card_atlas_low_contrast = rank_data.atlas_low_contrast,
					card_atlas_high_contrast = rank_data.atlas_high_contrast
				}
			else
				-- blank sprite
				G.P_CARDS[v.prefix .. '_' .. suffix] = {
					name = value .. ' of ' .. v.name,
					value = value,
					suit = v.name,
					pos = { x = 0, y = 5 }
				}
			end
		end
	end
	SMODS.Card.RANKS[value].disabled = nil
	return true
end

function SMODS.Card:new(suit, value, name, pos, atlas_low_contrast, atlas_high_contrast)
	local suit_data = SMODS.Card.SUITS[suit]
	local rank_data = SMODS.Card.RANKS[value]
	if not suit_data then
		sendWarnMessage('Suit does not exist: ' .. suit, 'PlayingCardAPI')
		return nil
	elseif not rank_data then
		sendWarnMessage('Rank does not exist: ' .. value, 'PlayingCardAPI')
		return nil
	end
	G.P_CARDS[suit_data.prefix .. '_' .. (rank_data.suffix or rank_data.value)] = {
		name = name or (value .. ' of ' .. suit),
		suit = suit,
		value = value,
		pos = pos or { x = rank_data.pos.x, y = suit_data.card_pos.y },
		card_atlas_low_contrast = atlas_low_contrast or rank_data.atlas_low_contrast or suit_data.atlas_low_contrast,
		card_atlas_high_contrast = atlas_high_contrast or rank_data.atlas_high_contrast or suit_data.atlas_high_contrast
	}
	return G.P_CARDS[suit_data.prefix .. '_' .. (rank_data.suffix or rank_data.value)]
end

function SMODS.Card:remove(suit, value)
	local suit_data = SMODS.Card.SUITS[suit]
	local rank_data = SMODS.Card.RANKS[value]
	if not suit_data then
		sendWarnMessage('Suit does not exist: ' .. suit, 'PlayingCardAPI')
		return false
	elseif not rank_data then
		sendWarnMessage('Rank does not exist: ' .. value, 'PlayingCardAPI')
		return false
	elseif not G.P_CARDS[suit_data.prefix .. '_' .. (rank_data.suffix or rank_data.value)] then
		sendWarnMessage('Card not found at index: ' .. suit_data.prefix .. '_' .. (rank_data.suffix or rank_data.value), 'PlayingCardAPI')
		return false
	end
	G.P_CARDS[suit_data.prefix .. '_' .. (rank_data.suffix or rank_data.value)] = nil
	return true
end

function SMODS.Card:_extend()
	local Game_init_game_object = Game.init_game_object
	function Game:init_game_object()
		local t = Game_init_game_object(self)
		t.cards_played = {}
		for k, v in pairs(SMODS.Card.RANKS) do
			t.cards_played[k] = { suits = {}, total = 0 }
		end
		return t
	end

	local loc_colour_ref = loc_colour
	function loc_colour(_c, _default)
		loc_colour_ref(_c, _default)
		for k, c in pairs(G.C.SUITS) do
			G.ARGS.LOC_COLOURS[k:lower()] = c
		end
		return G.ARGS.LOC_COLOURS[_c] or _default or G.C.UI.TEXT_DARK
	end

	function get_flush(hand)
		local ret = {}
		local four_fingers = next(find_joker('Four Fingers'))
		local suits = SMODS.Card.SUIT_LIST
		if #hand < (5 - (four_fingers and 1 or 0)) then
			return ret
		else
			for j = 1, #suits do
				local t = {}
				local suit = suits[j]
				local flush_count = 0
				for i = 1, #hand do
					if hand[i]:is_suit(suit, nil, true) then
						flush_count = flush_count + 1
						t[#t + 1] = hand[i]
					end
				end
				if flush_count >= (5 - (four_fingers and 1 or 0)) then
					table.insert(ret, t)
					return ret
				end
			end
			return {}
		end
	end

	function get_straight(hand)
		local ret = {}
		local four_fingers = next(find_joker('Four Fingers'))
		local can_skip = next(find_joker('Shortcut'))
		if #hand < (5 - (four_fingers and 1 or 0)) then return ret end
		local t = {}
		local RANKS = {}
		for i = 1, #hand do
			local rank = hand[i].base.value
			if RANKS[rank] then
				RANKS[rank][#RANKS[rank] + 1] = hand[i]
			else
				RANKS[rank] = { hand[i] }
			end
		end
		local straight_length = 0
		local straight = false
		local skipped_rank = false
		local vals = {}
		for k, v in pairs(SMODS.Card.RANKS) do
			if v.straight_edge then
				table.insert(vals, k)
			end
		end
		local init_vals = {}
		for _, v in ipairs(vals) do
			init_vals[v] = true
		end
		if not next(vals) then table.insert(vals, 'Ace') end
		local initial = true
		local br = false
		local end_iter = false
		local i = 0
		while 1 do
			end_iter = false
			if straight_length >= (5 - (four_fingers and 1 or 0)) then
				straight = true
			end
			i = i + 1
			if br or (i > #SMODS.Card.RANK_LIST + 1) then break end
			if not next(vals) then break end
			for _, val in ipairs(vals) do
				if init_vals[val] and not initial then br = true end
				if RANKS[val] then
					straight_length = straight_length + 1
					skipped_rank = false
					for _, vv in ipairs(RANKS[val]) do
						t[#t + 1] = vv
					end
					vals = SMODS.Card.RANKS[val].next
					initial = false
					end_iter = true
					break
				end
			end
			if not end_iter then
				local new_vals = {}
				for _, val in ipairs(vals) do
					for _, r in ipairs(SMODS.Card.RANKS[val].next) do
						table.insert(new_vals, r)
					end
				end
				vals = new_vals
				if can_skip and not skipped_rank then
					skipped_rank = true
				else
					straight_length = 0
					skipped_rank = false
					if not straight then t = {} end
					if straight then break end
				end
			end
		end
		if not straight then return ret end
		table.insert(ret, t)
		return ret
	end

    function get_X_same(num, hand)
        local vals = {}
        for i = 1, SMODS.Card.MAX_ID do
            vals[i] = {}
        end
        for i = #hand, 1, -1 do
            local curr = {}
            table.insert(curr, hand[i])
            for j = 1, #hand do
                if hand[i]:get_id() == hand[j]:get_id() and i ~= j then
                    table.insert(curr, hand[j])
                end
            end
            if #curr == num then
                vals[curr[1]:get_id()] = curr
            end
        end
        local ret = {}
        for i = #vals, 1, -1 do
            if next(vals[i]) then table.insert(ret, vals[i]) end
        end
        return ret
    end
	
	function Card:get_nominal(mod)
		local mult = 1
		if mod == 'suit' then mult = 10000 end
		if self.ability.effect == 'Stone Card' then mult = -10000 end
		return 10*self.base.nominal + self.base.suit_nominal*mult + (self.base.suit_nominal_original or 0)*0.0001*mult + 10*self.base.face_nominal + 0.000001*self.unique_val
	end

	function G.UIDEF.view_deck(unplayed_only)
		local deck_tables = {}
		remove_nils(G.playing_cards)
		G.VIEWING_DECK = true
		table.sort(G.playing_cards, function(a, b) return a:get_nominal('suit') > b:get_nominal('suit') end)
		local suit_list = SMODS.Card.SUIT_LIST
		local SUITS = {}
		for _, v in ipairs(suit_list) do
			SUITS[v] = {}
		end
		for k, v in ipairs(G.playing_cards) do
			table.insert(SUITS[v.base.suit], v)
		end
		local num_suits = 0
		for j = 1, #suit_list do
			if SUITS[suit_list[j]][1] then num_suits = num_suits + 1 end
		end
		for j = 1, #suit_list do
			if SUITS[suit_list[j]][1] then
				local view_deck = CardArea(
					G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
					6.5 * G.CARD_W,
					((num_suits > 8) and 0.2 or (num_suits > 4) and (1 - 0.1 * num_suits) or 0.6) * G.CARD_H,
					{
						card_limit = #SUITS[suit_list[j]],
						type = 'title',
						view_deck = true,
						highlight_limit = 0,
						card_w = G.CARD_W * 0.6,
						draw_layers = { 'card' }
					})
				table.insert(deck_tables,
					{
						n = G.UIT.R,
						config = { align = "cm", padding = 0 },
						nodes = {
							{ n = G.UIT.O, config = { object = view_deck } }
						}
					}
				)

				for i = 1, #SUITS[suit_list[j]] do
					if SUITS[suit_list[j]][i] then
						local greyed, _scale = nil, 0.7
						if unplayed_only and not ((SUITS[suit_list[j]][i].area and SUITS[suit_list[j]][i].area == G.deck) or SUITS[suit_list[j]][i].ability.wheel_flipped) then
							greyed = true
						end
						local copy = copy_card(SUITS[suit_list[j]][i], nil, _scale)
						copy.greyed = greyed
						copy.T.x = view_deck.T.x + view_deck.T.w / 2
						copy.T.y = view_deck.T.y

						copy:hard_set_T()
						view_deck:emplace(copy)
					end
				end
			end
		end

		local flip_col = G.C.WHITE

		local suit_tallies = {}
		local mod_suit_tallies = {}
		for _, v in ipairs(suit_list) do
			suit_tallies[v] = 0
			mod_suit_tallies[v] = 0
		end
		local rank_tallies = {}
		local mod_rank_tallies = {}
        local rank_name_mapping = SMODS.Card.RANK_LIST
		local id_index_mapping = {}
        for i, v in ipairs(SMODS.Card.RANK_LIST) do
			local rank_data = SMODS.Card.RANKS[SMODS.Card.RANK_SHORTHAND_LOOKUP[v] or v]
			id_index_mapping[rank_data.id] = i
			rank_tallies[i] = 0
			mod_rank_tallies[i] = 0
		end
		local face_tally = 0
		local mod_face_tally = 0
		local num_tally = 0
		local mod_num_tally = 0
		local ace_tally = 0
		local mod_ace_tally = 0
		local wheel_flipped = 0

		for _, v in ipairs(G.playing_cards) do
			if v.ability.name ~= 'Stone Card' and (not unplayed_only or ((v.area and v.area == G.deck) or v.ability.wheel_flipped)) then
				if v.ability.wheel_flipped and unplayed_only then wheel_flipped = wheel_flipped + 1 end
				--For the suits
				suit_tallies[v.base.suit] = (suit_tallies[v.base.suit] or 0) + 1
				for kk, vv in pairs(mod_suit_tallies) do
					mod_suit_tallies[kk] = (vv or 0) + (v:is_suit(kk) and 1 or 0)
				end

				--for face cards/numbered cards/aces
				local card_id = v:get_id()
				face_tally = face_tally + ((SMODS.Card.RANKS[v.base.value].face) and 1 or 0)
				mod_face_tally = mod_face_tally + (v:is_face() and 1 or 0)
				if not SMODS.Card.RANKS[v.base.value].face and card_id ~= 14 then
					num_tally = num_tally + 1
					if not v.debuff then mod_num_tally = mod_num_tally + 1 end
				end
				if card_id == 14 then
					ace_tally = ace_tally + 1
					if not v.debuff then mod_ace_tally = mod_ace_tally + 1 end
				end

				--ranks
				rank_tallies[id_index_mapping[card_id]] = rank_tallies[id_index_mapping[card_id]] + 1
				if not v.debuff then mod_rank_tallies[id_index_mapping[card_id]] = mod_rank_tallies[id_index_mapping[card_id]] + 1 end
			end
		end

		local modded = (face_tally ~= mod_face_tally)
		for kk, vv in pairs(mod_suit_tallies) do
			if vv ~= suit_tallies[kk] then modded = true end
		end

		if wheel_flipped > 0 then flip_col = mix_colours(G.C.FILTER, G.C.WHITE, 0.7) end

		local rank_cols = {}
		for i = #rank_name_mapping, 1, -1 do
			local mod_delta = mod_rank_tallies[i] ~= rank_tallies[i]
			rank_cols[#rank_cols + 1] = {
				n = G.UIT.R,
				config = { align = "cm", padding = 0.07 },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "cm", r = 0.1, padding = 0.04, emboss = 0.04, minw = 0.5, colour = G.C.L_BLACK },
						nodes = {
							{ n = G.UIT.T, config = { text = rank_name_mapping[i], colour = G.C.JOKER_GREY, scale = 0.35, shadow = true } },
						}
					},
					{
						n = G.UIT.C,
						config = { align = "cr", minw = 0.4 },
						nodes = {
							mod_delta and
							{ n = G.UIT.O, config = { object = DynaText({ string = { { string = '' .. rank_tallies[i], colour = flip_col }, { string = '' .. mod_rank_tallies[i], colour = G.C.BLUE } }, colours = { G.C.RED }, scale = 0.4, y_offset = -2, silent = true, shadow = true, pop_in_rate = 10, pop_delay = 4 }) } } or
							{ n = G.UIT.T, config = { text = rank_tallies[i] or 'NIL', colour = flip_col, scale = 0.45, shadow = true } },
						}
					}
				}
			}
		end

		local tally_ui = {
			-- base cards
			{
				n = G.UIT.R,
				config = { align = "cm", minh = 0.05, padding = 0.07 },
				nodes = {
					{ n = G.UIT.O, config = { object = DynaText({ string = { { string = localize('k_base_cards'), colour = G.C.RED }, modded and { string = localize('k_effective'), colour = G.C.BLUE } or nil }, colours = { G.C.RED }, silent = true, scale = 0.4, pop_in_rate = 10, pop_delay = 4 }) } }
				}
			},
			-- aces, faces and numbered cards
			{
				n = G.UIT.R,
				config = { align = "cm", minh = 0.05, padding = 0.1 },
				nodes = {
					tally_sprite({ x = 1, y = 0 },
						{ { string = '' .. ace_tally, colour = flip_col }, { string = '' .. mod_ace_tally, colour = G.C.BLUE } },
						{ localize('k_aces') }), --Aces
					tally_sprite({ x = 2, y = 0 },
						{ { string = '' .. face_tally, colour = flip_col }, { string = '' .. mod_face_tally, colour = G.C.BLUE } },
						{ localize('k_face_cards') }), --Face
					tally_sprite({ x = 3, y = 0 },
						{ { string = '' .. num_tally, colour = flip_col }, { string = '' .. mod_num_tally, colour = G.C.BLUE } },
						{ localize('k_numbered_cards') }), --Numbers
				}
			},
		}
		-- add suit tallies
		for i = 1, #suit_list, 2 do
			local n = {
				n = G.UIT.R,
				config = { align = "cm", minh = 0.05, padding = 0.1 },
				nodes = {
					tally_sprite(SMODS.Card.SUITS[suit_list[i]].ui_pos,
						{ { string = '' .. suit_tallies[suit_list[i]], colour = flip_col }, { string = '' .. mod_suit_tallies[suit_list[i]], colour = G.C.BLUE } },
						{ localize(suit_list[i], 'suits_plural') },
						suit_list[i]),
					suit_list[i + 1] and tally_sprite(SMODS.Card.SUITS[suit_list[i + 1]].ui_pos,
						{ { string = '' .. suit_tallies[suit_list[i + 1]], colour = flip_col }, { string = '' .. mod_suit_tallies[suit_list[i + 1]], colour = G.C.BLUE } },
						{ localize(suit_list[i + 1], 'suits_plural') },
						suit_list[i + 1]) or nil,
				}
			}
			table.insert(tally_ui, n)
		end

		local t =
		{
			n = G.UIT.ROOT,
			config = { align = "cm", colour = G.C.CLEAR },
			nodes = {
				{ n = G.UIT.R, config = { align = "cm", padding = 0.05 }, nodes = {} },
				{
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05 },
							nodes = {
								{
									n = G.UIT.C,
									config = { align = "cm", padding = 0.1 },
									nodes = {
										{
											n = G.UIT.R,
											config = { align = "cm", r = 0.1, colour = G.C.L_BLACK, emboss = 0.05, padding = 0.15 },
											nodes = {
												{
													n = G.UIT.R,
													config = { align = "cm" },
													nodes = {
														{ n = G.UIT.O, config = { object = DynaText({ string = G.GAME.selected_back.loc_name, colours = { G.C.WHITE }, bump = true, rotate = true, shadow = true, scale = 0.6 - string.len(G.GAME.selected_back.loc_name) * 0.01 }) } },
													}
												},
												{
													n = G.UIT.R,
													config = { align = "cm", r = 0.1, padding = 0.1, minw = 2.5, minh = 1.3, colour = G.C.WHITE, emboss = 0.05 },
													nodes = {
														{
															n = G.UIT.O,
															config = {
																object = UIBox {
																	definition = G.GAME.selected_back:generate_UI(nil, 0.7, 0.5, G.GAME.challenge),
																	config = { offset = { x = 0, y = 0 } }
																}
															}
														}
													}
												}
											}
										},
										{
											n = G.UIT.R,
											config = { align = "cm", r = 0.1, outline_colour = G.C.L_BLACK, line_emboss = 0.05, outline = 1.5 },
											nodes = tally_ui
										}
									}
								},
								{ n = G.UIT.C, config = { align = "cm" },    nodes = rank_cols },
								{ n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
							}
						},
						{ n = G.UIT.B, config = { w = 0.2, h = 0.1 } },
						{ n = G.UIT.C, config = { align = "cm", padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables }
					}
				},
				{
					n = G.UIT.R,
					config = { align = "cm", minh = 0.8, padding = 0.05 },
					nodes = {
						modded and {
							n = G.UIT.R,
							config = { align = "cm" },
							nodes = {
								{ n = G.UIT.C, config = { padding = 0.3, r = 0.1, colour = mix_colours(G.C.BLUE, G.C.WHITE, 0.7) },              nodes = {} },
								{ n = G.UIT.T, config = { text = ' ' .. localize('ph_deck_preview_effective'), colour = G.C.WHITE, scale = 0.3 } },
							}
						} or nil,
						wheel_flipped > 0 and {
							n = G.UIT.R,
							config = { align = "cm" },
							nodes = {
								{ n = G.UIT.C, config = { padding = 0.3, r = 0.1, colour = flip_col }, nodes = {} },
								{
									n = G.UIT.T,
									config = {
										text = ' ' .. (wheel_flipped > 1 and
											localize { type = 'variable', key = 'deck_preview_wheel_plural', vars = { wheel_flipped } } or
											localize { type = 'variable', key = 'deck_preview_wheel_singular', vars = { wheel_flipped } }),
										colour = G.C.WHITE,
										scale = 0.3
									}
								},
							}
						} or nil,
					}
				}
			}
		}
		return t
	end

	local UIDEF_challenge_description_tab_ref = G.UIDEF.challenge_description_tab
	function G.UIDEF.challenge_description_tab(args)
		if args._tab == 'Deck' then
			local challenge = G.CHALLENGES[args._id]
			local deck_tables = {}
			local SUITS = {}
			for _, v in pairs(SMODS.Card.SUITS) do
				SUITS[v.prefix] = {}
			end
			local suit_map = {}
			for i, v in ipairs(SMODS.Card.SUIT_LIST) do
				table.insert(suit_map, SMODS.Card.SUITS[v].prefix)
			end
			local card_protos = nil
			local _de = nil
			if challenge then
				_de = challenge.deck
			end

			if _de and _de.cards then
				card_protos = _de.cards
			end

			if not card_protos then
				card_protos = {}
				for k, v in pairs(G.P_CARDS) do
					local rank_data = SMODS.Card.RANKS[v.value]
					local suit_data = SMODS.Card.SUITS[v.suit]
					local _r, _s = (rank_data.suffix or rank_data.value), suit_data.prefix
					local keep, _e, _d, _g = true, nil, nil, nil
					if _de then
						if _de.yes_ranks and not _de.yes_ranks[_r] then keep = false end
						if _de.no_ranks and _de.no_ranks[_r] then keep = false end
						if _de.yes_suits and not _de.yes_suits[_s] then keep = false end
						if _de.no_suits and _de.no_suits[_s] then keep = false end
						if _de.enhancement then _e = _de.enhancement end
						if _de.edition then _d = _de.edition end
						if _de.seal then _g = _de.seal end
					end

					if keep then card_protos[#card_protos + 1] = { s = _s, r = _r, e = _e, d = _d, g = _g } end
				end
			end
			for k, v in ipairs(card_protos) do
				local _card = Card(0, 0, G.CARD_W * 0.45, G.CARD_H * 0.45, G.P_CARDS[v.s .. '_' .. v.r],
					G.P_CENTERS[v.e or 'c_base'])
				if v.d then _card:set_edition({ [v.d] = true }, true, true) end
				if v.g then _card:set_seal(v.g, true, true) end
				SUITS[v.s][#SUITS[v.s] + 1] = _card
			end
			local num_suits = 0
			for j = 1, #suit_map do
				if SUITS[suit_map[j]][1] then num_suits = num_suits + 1 end
			end
			for j = 1, #suit_map do
				if SUITS[suit_map[j]][1] then
					table.sort(SUITS[suit_map[j]], function(a, b) return a:get_nominal() > b:get_nominal() end)
					local view_deck = CardArea(
						0, 0,
						5.5 * G.CARD_W,
						(0.42 - (num_suits <= 4 and 0 or num_suits >= 8 and 0.28 or 0.07 * (num_suits - 4))) * G.CARD_H,
						{
							card_limit = #SUITS[suit_map[j]],
							type = 'title_2',
							view_deck = true,
							highlight_limit = 0,
							card_w =
								G.CARD_W * 0.5,
							draw_layers = { 'card' }
						})
					table.insert(deck_tables,
						{
							n = G.UIT.R,
							config = { align = "cm", padding = 0 },
							nodes = {
								{ n = G.UIT.O, config = { object = view_deck } }
							}
						}
					)

					for i = 1, #SUITS[suit_map[j]] do
						if SUITS[suit_map[j]][i] then
							view_deck:emplace(SUITS[suit_map[j]][i])
						end
					end
				end
			end
			return {
				n = G.UIT.ROOT,
				config = { align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 11.4, minh = 4.2 },
				nodes =
					deck_tables
			}
		else
			return UIDEF_challenge_description_tab_ref(args)
		end
	end

	function G.UIDEF.deck_preview(args)
		local _minh, _minw = 0.35, 0.5
		local suit_list = SMODS.Card.SUIT_LIST
		local suit_labels = {}
		local suit_counts = {}
		local mod_suit_counts = {}
		for _, v in ipairs(suit_list) do
			suit_counts[v] = 0
			mod_suit_counts[v] = 0
		end
		local mod_suit_diff = false
		local wheel_flipped, wheel_flipped_text = 0, nil
		local flip_col = G.C.WHITE
		local rank_counts = {}
		local deck_tables = {}
		remove_nils(G.playing_cards)
		table.sort(G.playing_cards, function(a, b) return a:get_nominal('suit') > b:get_nominal('suit') end)
		local SUITS = {}
		for _, v in ipairs(suit_list) do
			SUITS[v] = {}
		end

		for k, v in pairs(SUITS) do
			for i = 1, SMODS.Card.MAX_ID do
				SUITS[k][#SUITS[k] + 1] = {}
			end
		end

		local stones = nil
        local rank_name_mapping = {}
		local id_index_mapping = {}
        for i = #SMODS.Card.RANK_LIST, 1, -1 do
			local v = SMODS.Card.RANK_LIST[i]
			local rank_data = SMODS.Card.RANKS[SMODS.Card.RANK_SHORTHAND_LOOKUP[v] or v]
			id_index_mapping[rank_data.id] = #rank_name_mapping+1
			rank_name_mapping[#rank_name_mapping + 1] = v
		end

		for k, v in ipairs(G.playing_cards) do
			if v.ability.effect == 'Stone Card' then
				stones = stones or 0
			end
			if (v.area and v.area == G.deck) or v.ability.wheel_flipped then
				if v.ability.wheel_flipped then wheel_flipped = wheel_flipped + 1 end
				if v.ability.effect == 'Stone Card' then
					stones = stones + 1
				else
					for kk, vv in pairs(suit_counts) do
						if v.base.suit == kk then suit_counts[kk] = suit_counts[kk] + 1 end
						if v:is_suit(kk) then mod_suit_counts[kk] = mod_suit_counts[kk] + 1 end
					end
					if SUITS[v.base.suit][v.base.id] then
						table.insert(SUITS[v.base.suit][v.base.id], v)
					end
					rank_counts[id_index_mapping[v.base.id]] = (rank_counts[id_index_mapping[v.base.id]] or 0) + 1
				end
			end
		end

		wheel_flipped_text = (wheel_flipped > 0) and
			{ n = G.UIT.T, config = { text = '?', colour = G.C.FILTER, scale = 0.25, shadow = true } } or nil
		flip_col = wheel_flipped_text and mix_colours(G.C.FILTER, G.C.WHITE, 0.7) or G.C.WHITE

		suit_labels[#suit_labels + 1] = {
			n = G.UIT.R,
			config = { align = "cm", r = 0.1, padding = 0.04, minw = _minw, minh = 2 * _minh + 0.25 },
			nodes = {
				stones and
				{ n = G.UIT.T, config = { text = localize('ph_deck_preview_stones') .. ': ', colour = G.C.WHITE, scale = 0.25, shadow = true } }
				or nil,
				stones and
				{ n = G.UIT.T, config = { text = '' .. stones, colour = (stones > 0 and G.C.WHITE or G.C.UI.TRANSPARENT_LIGHT), scale = 0.4, shadow = true } }
				or nil,
			}
		}

		local _row = {}
		local _bg_col = G.C.JOKER_GREY
        for i = #SMODS.Card.RANK_LIST, 1, -1 do
			local v = SMODS.Card.RANK_LIST[i]
			local rank_data = SMODS.Card.RANKS[SMODS.Card.RANK_SHORTHAND_LOOKUP[v] or v]
			local _tscale = 0.3
			local _colour = G.C.BLACK
			local rank_col = v == 'A' and _bg_col or (v == 'K' or v == 'Q' or v == 'J') and G.C.WHITE or _bg_col
			rank_col = mix_colours(rank_col, _bg_col, 0.8)

			local _col = {
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "cm", r = 0.1, minw = _minw, minh = _minh, colour = rank_col, emboss = 0.04, padding = 0.03 },
						nodes = {
							{
								n = G.UIT.R,
								config = { align = "cm" },
								nodes = {
									{ n = G.UIT.T, config = { text = '' .. v, colour = _colour, scale = 1.6 * _tscale } },
								}
							},
							{
								n = G.UIT.R,
								config = { align = "cm", minw = _minw + 0.04, minh = _minh, colour = G.C.L_BLACK, r = 0.1 },
								nodes = {
									{ n = G.UIT.T, config = { text = '' .. (rank_counts[id_index_mapping[rank_data.id]] or 0), colour = flip_col, scale = _tscale, shadow = true } }
								}
							}
						}
					}
				}
			}
			table.insert(_row, _col)
		end
		table.insert(deck_tables, { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = _row })

		for j = 1, #suit_list do
			_row = {}
			_bg_col = mix_colours(G.C.SUITS[suit_list[j]], G.C.L_BLACK, 0.7)
			for i = SMODS.Card.MAX_ID, 2, -1 do
				local _tscale = #SUITS[suit_list[j]][i] > 0 and 0.3 or 0.25
				local _colour = #SUITS[suit_list[j]][i] > 0 and flip_col or G.C.UI.TRANSPARENT_LIGHT

				local _col = {
					n = G.UIT.C,
					config = { align = "cm", padding = 0.05, minw = _minw + 0.098, minh = _minh },
					nodes = {
						{ n = G.UIT.T, config = { text = '' .. #SUITS[suit_list[j]][i], colour = _colour, scale = _tscale, shadow = true, lang = G.LANGUAGES['en-us'] } },
					}
				}
				if id_index_mapping[i] then table.insert(_row, _col) end
			end
			table.insert(deck_tables,
				{
					n = G.UIT.R,
					config = { align = "cm", r = 0.1, padding = 0.04, minh = 0.4, colour = _bg_col },
					nodes =
						_row
				})
		end

		for _, v in ipairs(suit_list) do
			local suit_data = SMODS.Card.SUITS[v]
			local t_s = Sprite(0, 0, 0.3, 0.3, (suit_data.ui_atlas_low_contrast or suit_data.ui_atlas_high_contrast) and
				G.ASSET_ATLAS
				[G.SETTINGS.colourblind_option and suit_data.ui_atlas_high_contrast or suit_data.ui_atlas_low_contrast] or
				G.ASSET_ATLAS["ui_" .. (G.SETTINGS.colourblind_option and 2 or 1)],
				suit_data.ui_pos)
			t_s.states.drag.can = false
			t_s.states.hover.can = false
			t_s.states.collide.can = false

			if mod_suit_counts[v] ~= suit_counts[v] then mod_suit_diff = true end

			suit_labels[#suit_labels + 1] =
			{
				n = G.UIT.R,
				config = { align = "cm", r = 0.1, padding = 0.03, colour = G.C.JOKER_GREY },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "cm", minw = _minw, minh = _minh },
						nodes = {
							{ n = G.UIT.O, config = { can_collide = false, object = t_s } }
						}
					},
					{
						n = G.UIT.C,
						config = { align = "cm", minw = _minw * 2.4, minh = _minh, colour = G.C.L_BLACK, r = 0.1 },
						nodes = {
							{ n = G.UIT.T, config = { text = '' .. suit_counts[v], colour = flip_col, scale = 0.3, shadow = true, lang = G.LANGUAGES['en-us'] } },
							mod_suit_counts[v] ~= suit_counts[v] and
							{ n = G.UIT.T, config = { text = ' (' .. mod_suit_counts[v] .. ')', colour = mix_colours(G.C.BLUE, G.C.WHITE, 0.7), scale = 0.28, shadow = true, lang = G.LANGUAGES['en-us'] } } or
							nil,
						}
					}
				}
			}
		end


		local t =
		{
			n = G.UIT.ROOT,
			config = { align = "cm", colour = G.C.JOKER_GREY, r = 0.1, emboss = 0.05, padding = 0.07 },
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm", r = 0.1, emboss = 0.05, colour = G.C.BLACK, padding = 0.1 },
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "cm" },
							nodes = {
								{ n = G.UIT.C, config = { align = "cm", padding = 0.04 }, nodes = suit_labels },
								{ n = G.UIT.C, config = { align = "cm", padding = 0.02 }, nodes = deck_tables }
							}
						},
						mod_suit_diff and {
							n = G.UIT.R,
							config = { align = "cm" },
							nodes = {
								{ n = G.UIT.C, config = { padding = 0.3, r = 0.1, colour = mix_colours(G.C.BLUE, G.C.WHITE, 0.7) },              nodes = {} },
								{ n = G.UIT.T, config = { text = ' ' .. localize('ph_deck_preview_effective'), colour = G.C.WHITE, scale = 0.3 } },
							}
						} or nil,
						wheel_flipped_text and {
							n = G.UIT.R,
							config = { align = "cm" },
							nodes = {
								{ n = G.UIT.C, config = { padding = 0.3, r = 0.1, colour = flip_col }, nodes = {} },
								{
									n = G.UIT.T,
									config = {
										text = ' ' .. (wheel_flipped > 1 and
											localize { type = 'variable', key = 'deck_preview_wheel_plural', vars = { wheel_flipped } } or
											localize { type = 'variable', key = 'deck_preview_wheel_singular', vars = { wheel_flipped } }),
										colour = G.C.WHITE,
										scale = 0.3
									}
								},
							}
						} or nil,
					}
				}
			}
		}
		return t
	end

	function Card:set_base(card, initial)
		card = card or {}

		self.config.card = card
		for k, v in pairs(G.P_CARDS) do
			if card == v then self.config.card_key = k end
		end

		if next(card) then
			self:set_sprites(nil, card)
		end

		local suit_base_nominal_original = nil
		if self.base and self.base.suit_nominal_original then
			suit_base_nominal_original = self.base
				.suit_nominal_original
		end
		self.base = {
			name = self.config.card.name,
			suit = self.config.card.suit,
			value = self.config.card.value,
			nominal = 0,
			suit_nominal = 0,
			face_nominal = 0,
			colour = G.C.SUITS[self.config.card.suit],
			times_played = 0
		}
		local rank_data = SMODS.Card.RANKS[self.base.value] or {}
		local suit_data = SMODS.Card.SUITS[self.base.suit] or {}
		self.base.nominal = rank_data.nominal or 0
		self.base.id = rank_data.id or 0
		self.base.face_nominal = rank_data.face_nominal or 0

		if initial then self.base.original_value = self.base.value end

		self.base.suit_nominal = suit_data.suit_nominal or 0
		self.base.suit_nominal_original = suit_base_nominal_original or
			suit_data.suit_nominal and suit_data.suit_nominal / 10 or nil

		if not initial then G.GAME.blind:debuff_card(self) end
		if self.playing_card and not initial then check_for_unlock({ type = 'modify_deck' }) end
	end

	function Card:change_suit(new_suit)
		local new_code = SMODS.Card.SUITS[new_suit].prefix or ''
		local new_val = SMODS.Card.RANKS[self.base.value].suffix or SMODS.Card.RANKS[self.base.value].value
		local new_card = G.P_CARDS[new_code .. '_' .. new_val] or nil
		self:set_base(new_card)
		G.GAME.blind:debuff_card(self)
	end

	function Card:is_face(from_boss)
		if self.debuff and not from_boss then return end
		if self:get_id() < 0 then return end
		local val = self.base.value
		if next(find_joker('Pareidolia')) or (val and SMODS.Card.RANKS[val] and SMODS.Card.RANKS[val].face) then return true end
	end

	local Card_use_consumeable_ref = Card.use_consumeable
	function Card:use_consumeable(area, copier)
		if self.ability.name == 'Strength' or self.ability.name == 'Sigil' or self.ability.name == 'Ouija' or self.ability.name == 'Familiar' or self.ability.name == 'Grim' or self.ability.name == 'Incantation' then
			stop_use()
			if not copier then set_consumeable_usage(self) end
			if self.debuff then return nil end
			local used_tarot = copier or self

			if self.ability.consumeable.max_highlighted then
				update_hand_text({ immediate = true, nopulse = true, delay = 0 },
					{ mult = 0, chips = 0, level = '', handname = '' })
			end
			if self.ability.name == 'Strength' then
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.4,
					func = function()
						play_sound('tarot1')
						used_tarot:juice_up(0.3, 0.5)
						return true
					end
				}))
				for i = 1, #G.hand.highlighted do
					local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = 0.15,
						func = function()
							G.hand.highlighted[i]:flip(); play_sound('card1', percent); G.hand.highlighted[i]:juice_up(
								0.3,
								0.3); return true
						end
					}))
				end
				delay(0.2)
				for i = 1, #G.hand.highlighted do
					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = 0.1,
						func = function()
							local card = G.hand.highlighted[i]
							local suit_data = SMODS.Card.SUITS[card.base.suit]
							local suit_prefix = suit_data.prefix .. '_'
							local rank_data = SMODS.Card.RANKS[card.base.value]
							local behavior = rank_data.strength_effect or { fixed = 1, ignore = false, random = false }
							local rank_suffix = ''
							if behavior.ignore or not next(rank_data.next) then
								return true
							elseif behavior.random then
								local r = pseudorandom_element(rank_data.next, pseudoseed('strength'))
								rank_suffix = SMODS.Card.RANKS[r].suffix or SMODS.Card.RANKS[r].value
							else
								local ii = (behavior.fixed and rank_data.next[behavior.fixed]) and behavior.fixed or 1
								rank_suffix = SMODS.Card.RANKS[rank_data.next[ii]].suffix or
									SMODS.Card.RANKS[rank_data.next[ii]].value
							end
							card:set_base(G.P_CARDS[suit_prefix .. rank_suffix])
							return true
						end
					}))
				end
				for i = 1, #G.hand.highlighted do
					local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = 0.15,
						func = function()
							G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]
								:juice_up(
									0.3, 0.3); return true
						end
					}))
				end
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.2,
					func = function()
						G.hand:unhighlight_all(); return true
					end
				}))
				delay(0.5)
			elseif self.ability.name == 'Sigil' or self.ability.name == 'Ouija' then
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.4,
					func = function()
						play_sound('tarot1')
						used_tarot:juice_up(0.3, 0.5)
						return true
					end
				}))
				for i = 1, #G.hand.cards do
					local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = 0.15,
						func = function()
							G.hand.cards[i]:flip(); play_sound('card1', percent); G.hand.cards[i]:juice_up(0.3, 0.3); return true
						end
					}))
				end
				delay(0.2)
				if self.ability.name == 'Sigil' then
					local _suit = SMODS.Card.SUITS[pseudorandom_element(SMODS.Card.SUIT_LIST, pseudoseed('sigil'))]
						.prefix
					for i = 1, #G.hand.cards do
						G.E_MANAGER:add_event(Event({
							func = function()
								local card = G.hand.cards[i]
								local suit_prefix = _suit .. '_'
								local rank_data = SMODS.Card.RANKS[card.base.value]
								local rank_suffix = rank_data.suffix or rank_data.value
								card:set_base(G.P_CARDS[suit_prefix .. rank_suffix])
								return true
							end
						}))
					end
				end
				if self.ability.name == 'Ouija' then
					local rank_data = pseudorandom_element(SMODS.Card.RANKS, pseudoseed('ouija'))
					local _rank = rank_data.suffix or rank_data.value
					for i = 1, #G.hand.cards do
						G.E_MANAGER:add_event(Event({
							func = function()
								local card = G.hand.cards[i]
								local suit_data = SMODS.Card.SUITS[card.base.suit]
								local suit_prefix = suit_data.prefix .. '_'
								local rank_suffix = _rank
								card:set_base(G.P_CARDS[suit_prefix .. rank_suffix])
								return true
							end
						}))
					end
					G.hand:change_size(-1)
				end
				for i = 1, #G.hand.cards do
					local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = 0.15,
						func = function()
							G.hand.cards[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.cards[i]:juice_up(0.3, 0.3); return true
						end
					}))
				end
				delay(0.5)
			elseif self.ability.name == 'Familiar' or self.ability.name == 'Grim' or self.ability.name == 'Incantation' then
				local destroyed_cards = {}
				destroyed_cards[#destroyed_cards + 1] = pseudorandom_element(G.hand.cards, pseudoseed('random_destroy'))
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.4,
					func = function()
						play_sound('tarot1')
						used_tarot:juice_up(0.3, 0.5)
						return true
					end
				}))
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.1,
					func = function()
						for i = #destroyed_cards, 1, -1 do
							local card = destroyed_cards[i]
							if card.ability.name == 'Glass Card' then
								card:shatter()
							else
								card:start_dissolve(nil, i ~= #destroyed_cards)
							end
						end
						return true
					end
				}))
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.7,
					func = function()
						local cards = {}
						for i = 1, self.ability.extra do
							cards[i] = true
							local _suit, _rank = nil, nil
							if self.ability.name == 'Familiar' then
								local faces = {}
								for _, v in pairs(SMODS.Card.RANKS) do
									if v.face then table.insert(faces, v.suffix or v.value) end
								end
								_rank = pseudorandom_element(faces, pseudoseed('familiar_create'))
								_suit = SMODS.Card.SUITS
									[pseudorandom_element(SMODS.Card.SUIT_LIST, pseudoseed('familiar_create'))].prefix
							elseif self.ability.name == 'Grim' then
								_rank = 'A'
								_suit = SMODS.Card.SUITS
									[pseudorandom_element(SMODS.Card.SUIT_LIST, pseudoseed('grim_create'))].prefix
							elseif self.ability.name == 'Incantation' then
								local numbers = {}
								for k, v in pairs(SMODS.Card.RANKS) do
									if k ~= 'Ace' and not v.face then table.insert(numbers, v.suffix or v.value) end
								end
								_rank = pseudorandom_element(numbers, pseudoseed('incantation_create'))
								_suit = SMODS.Card.SUITS
									[pseudorandom_element(SMODS.Card.SUIT_LIST, pseudoseed('incantation_create'))]
									.prefix
							end
							_suit = _suit or 'S'; _rank = _rank or 'A'
							local cen_pool = {}
							for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
								if v.key ~= 'm_stone' then
									cen_pool[#cen_pool + 1] = v
								end
							end
							create_playing_card(
								{
									front = G.P_CARDS[_suit .. '_' .. _rank],
									center = pseudorandom_element(cen_pool,
										pseudoseed('spe_card'))
								}, G.hand, nil, i ~= 1, { G.C.SECONDARY_SET.Spectral })
						end
						playing_card_joker_effects(cards)
						return true
					end
				}))
				delay(0.3)
				for i = 1, #G.jokers.cards do
					G.jokers.cards[i]:calculate_joker({ remove_playing_cards = true, removed = destroyed_cards })
				end
			end
		else
			Card_use_consumeable_ref(self, area, copier)
		end
	end

	local Blind_set_blind_ref = Blind.set_blind
	function Blind:set_blind(blind, reset, silent)
		Blind_set_blind_ref(self, blind, reset, silent)
		if (self.name == "The Eye") and not reset then
			for _, v in ipairs(G.handlist) do
				self.hands[v] = false
			end
		end
	end

	local tally_sprite_ref = tally_sprite
	function tally_sprite(pos, value, tooltip, suit)
		local node = tally_sprite_ref(pos, value, tooltip)
		if not suit then return node end
		local suit_data = SMODS.Card.SUITS[suit]
		if suit_data.ui_atlas_low_contrast or suit_data.ui_atlas_high_contrast then
			local t_s = Sprite(0, 0, 0.5, 0.5,
				G.ASSET_ATLAS
				[G.SETTINGS.colourblind_option and suit_data.ui_atlas_high_contrast or suit_data.ui_atlas_low_contrast],
				{ x = suit_data.ui_pos.x or 0, y = suit_data.ui_pos.y or 0 })
			t_s.states.drag.can = false
			t_s.states.hover.can = false
			t_s.states.collide.can = false
			node.nodes[1].nodes[1].config.object = t_s
		end
		return node
	end
end

SMODS.Card:_extend()
-- ----------------------------------------------
-- ------------MOD CORE API SPRITE END-----------

SMODS.Tarots = {}
SMODS.Tarot = {
	name = "",
	slug = "",
	cost = 3,
	config = {},
	pos = {},
	loc_txt = {},
	discovered = false,
	consumeable = true,
	effect = "",
	cost_mult = 1.0,
}

function SMODS.Tarot:new(name, slug, config, pos, loc_txt, cost, cost_mult, effect, consumeable, discovered, atlas)
	o = {}
	setmetatable(o, self)
	self.__index = self

	o.loc_txt = loc_txt
	o.name = name
	o.slug = "c_" .. slug
	o.config = config or {}
	o.pos = pos or {
		x = 0,
		y = 0
	}
	o.cost = cost
	o.unlocked = true
	o.discovered = discovered or false
	o.consumeable = consumeable or true
	o.effect = effect or ""
	o.cost_mult = cost_mult or 1.0
	o.atlas = atlas
	o.mod_name = SMODS._MOD_NAME
	o.badge_colour = SMODS._BADGE_COLOUR
	return o
end

function SMODS.Tarot:register()
	if not SMODS.Tarots[self.slug] then
		SMODS.Tarots[self.slug] = self
		SMODS.BUFFERS.Tarots[#SMODS.BUFFERS.Tarots + 1] = self.slug
	end
end

function SMODS.injectTarots()
    local minId = table_length(G.P_CENTER_POOLS['Tarot']) + 1
    local id = 0
    local i = 0
    local tarot = nil
    for _, slug in ipairs(SMODS.BUFFERS.Tarots) do
        tarot = SMODS.Tarots[slug]
		if tarot.order then
            id = tarot.order
        else
			i = i + 1
        	id = i + minId
		end
        local tarot_obj = {
            unlocked = tarot.unlocked,
            discovered = tarot.discovered,
            consumeable = tarot.consumeable,
            name = tarot.name,
            set = "Tarot",
            order = id,
            key = tarot.slug,
            pos = tarot.pos,
            config = tarot.config,
            effect = tarot.effect,
            cost = tarot.cost,
            cost_mult = tarot.cost_mult,
            atlas = tarot.atlas,
            mod_name = tarot.mod_name,
            badge_colour = tarot.badge_colour
        }

        for _i, sprite in ipairs(SMODS.Sprites) do
            if sprite.name == tarot_obj.key then
                tarot_obj.atlas = sprite.name
            end
        end

        -- Now we replace the others
        G.P_CENTERS[tarot.slug] = tarot_obj
        if not tarot.taken_ownership then
			table.insert(G.P_CENTER_POOLS['Tarot'], tarot_obj)
		else
			for k, v in ipairs(G.P_CENTER_POOLS['Tarot']) do
				if v.key == slug then G.P_CENTER_POOLS['Tarot'][k] = tarot_obj end
			end
		end
        -- Setup Localize text
        G.localization.descriptions["Tarot"][tarot.slug] = tarot.loc_txt
        sendInfoMessage("Registered Tarot " .. tarot.name .. " with the slug " .. tarot.slug .. " at ID " .. id .. ".", 'ConsumableAPI')
    end
end

function SMODS.Tarot:take_ownership(slug)
    if not (string.sub(slug, 1, 2) == 'c_') then slug = 'c_' .. slug end
    local obj = G.P_CENTERS[slug]
    if not obj then
        sendWarnMessage('Tried to take ownership of non-existent Tarot: ' .. slug, 'ConsumableAPI')
        return nil
    end
    if obj.mod_name then
        sendWarnMessage('Can only take ownership of unclaimed vanilla Tarots! ' ..
            slug .. ' belongs to ' .. obj.mod_name, 'ConsumableAPI')
        return nil
    end
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.loc_txt = G.localization.descriptions['Tarot'][slug]
    o.slug = slug
    for k, v in pairs(obj) do
        o[k] = v
    end
	o.mod_name = SMODS._MOD_NAME
    o.badge_colour = SMODS._BADGE_COLOUR
	o.taken_ownership = true
	return o
end

function create_UIBox_your_collection_tarots()
	local deck_tables = {}

	G.your_collection = {}
	for j = 1, 2 do
		G.your_collection[j] = CardArea(
			G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
			(4.25 + j) * G.CARD_W,
			1 * G.CARD_H,
			{ card_limit = 4 + j, type = 'title', highlight_limit = 0, collection = true })
		table.insert(deck_tables,
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0, no_fill = true },
				nodes = {
					{ n = G.UIT.O, config = { object = G.your_collection[j] } }
				}
			}
		)
	end

	local tarot_options = {}
	for i = 1, math.ceil(#G.P_CENTER_POOLS.Tarot / 11) do
		table.insert(tarot_options,
			localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#G.P_CENTER_POOLS.Tarot / 11)))
	end

	for j = 1, #G.your_collection do
		for i = 1, 4 + j do
			local center = G.P_CENTER_POOLS["Tarot"][i + (j - 1) * (5)]
			local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G
				.CARD_W, G.CARD_H, nil, center)
			card:start_materialize(nil, i > 1 or j > 1)
			G.your_collection[j]:emplace(card)
		end
	end

	INIT_COLLECTION_CARD_ALERTS()

	local t = create_UIBox_generic_options({
		back_func = 'your_collection',
		contents = {
			{ n = G.UIT.R, config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables },
			{
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					create_option_cycle({
						options = tarot_options,
						w = 4.5,
						cycle_shoulders = true,
						opt_callback =
						'your_collection_tarot_page',
						focus_args = { snap_to = true, nav = 'wide' },
						current_option = 1,
						colour =
							G.C.RED,
						no_pips = true
					})
				}
			}
		}
	})
	return t
end

local generate_card_ui_ref = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
	local original_full_UI_table = full_UI_table
	local original_main_end = main_end
	local first_pass = nil
	if not full_UI_table then
		first_pass = true
		full_UI_table = {
			main = {},
			info = {},
			type = {},
			name = nil,
			badges = badges or {}
		}
	end

	local desc_nodes = (not full_UI_table.name and full_UI_table.main) or full_UI_table.info
	local name_override = nil
	local info_queue = {}

	local loc_vars = nil

	if not (card_type == 'Locked') and not hide_desc and not (specific_vars and specific_vars.debuffed) then
		local key = _c.key
		local center_obj = SMODS.Tarots[key] or SMODS.Planets[key] or SMODS.Spectrals[key] or SMODS.Vouchers[key]
		if center_obj and center_obj.loc_def and type(center_obj.loc_def) == 'function' then
			local o, m = center_obj.loc_def(_c, info_queue)
			if o then loc_vars = o end
			if m then main_end = m end
		end
		local joker_obj = SMODS.Jokers[key]
		if joker_obj and joker_obj.tooltip and type(joker_obj.tooltip) == 'function' then
			joker_obj.tooltip(_c, info_queue)
		end
	end

	if first_pass and not (_c.set == 'Edition') and badges and next(badges) then
		for _, v in ipairs(badges) do
			if SMODS.Seals[v] then info_queue[#info_queue + 1] = { key = v, set = 'Other' } end
		end
	end

	if loc_vars or next(info_queue) then
		if full_UI_table.name then
			full_UI_table.info[#full_UI_table.info + 1] = {}
			desc_nodes = full_UI_table.info[#full_UI_table.info]
		end
		if not full_UI_table.name then
			if specific_vars and specific_vars.no_name then
				full_UI_table.name = true
			elseif card_type == 'Locked' then
				full_UI_table.name = localize { type = 'name', set = 'Other', key = 'locked', nodes = {} }
			elseif card_type == 'Undiscovered' then
				full_UI_table.name = localize { type = 'name', set = 'Other', key = 'undiscovered_' .. (string.lower(_c.set)), name_nodes = {} }
			elseif specific_vars and (card_type == 'Default' or card_type == 'Enhanced') then
				if (_c.name == 'Stone Card') then full_UI_table.name = true end
				if (specific_vars.playing_card and (_c.name ~= 'Stone Card')) then
					full_UI_table.name = {}
					localize { type = 'other', key = 'playing_card', set = 'Other', nodes = full_UI_table.name, vars = { localize(specific_vars.value, 'ranks'), localize(specific_vars.suit, 'suits_plural'), colours = { specific_vars.colour } } }
					full_UI_table.name = full_UI_table.name[1]
				end
			elseif card_type == 'Booster' then

			else
				full_UI_table.name = localize { type = 'name', set = _c.set, key = _c.key, nodes = full_UI_table.name }
			end
			full_UI_table.card_type = card_type or _c.set
		end
		if main_start then
			desc_nodes[#desc_nodes + 1] = main_start
		end
		if loc_vars then
			localize { type = 'descriptions', key = _c.key, set = _c.set, nodes = desc_nodes, vars = loc_vars }
			if not ((specific_vars and not specific_vars.sticker) and (card_type == 'Default' or card_type == 'Enhanced')) then
				if desc_nodes == full_UI_table.main and not full_UI_table.name then
					localize { type = 'name', key = _c.key, set = _c.set, nodes = full_UI_table.name }
					if not full_UI_table.name then full_UI_table.name = {} end
				elseif desc_nodes ~= full_UI_table.main then
					desc_nodes.name = localize { type = 'name_text', key = name_override or _c.key, set = name_override and 'Other' or _c.set }
				end
			end
		end
		if _c.set == 'Joker' then
			if specific_vars and specific_vars.pinned then info_queue[#info_queue + 1] = { key = 'pinned_left', set =
				'Other' } end
			if specific_vars and specific_vars.sticker then info_queue[#info_queue + 1] = { key = string.lower(
				specific_vars.sticker) .. '_sticker', set = 'Other' } end
			localize { type = 'descriptions', key = _c.key, set = _c.set, nodes = desc_nodes, vars = specific_vars or {} }
		end
		if main_end then
			desc_nodes[#desc_nodes + 1] = main_end
		end

		for _, v in ipairs(info_queue) do
			generate_card_ui(v, full_UI_table)
		end
		return full_UI_table
	end
	return generate_card_ui_ref(_c, original_full_UI_table, specific_vars, card_type, badges, hide_desc, main_start,
		original_main_end)
end

local card_use_consumeable_ref = Card.use_consumeable
function Card:use_consumeable(area, copier)
	local key = self.config.center.key
	local center_obj = SMODS.Tarots[key] or SMODS.Planets[key] or SMODS.Spectrals[key]
	if center_obj and center_obj.use and type(center_obj.use) == 'function' then
		stop_use()
		if not copier then set_consumeable_usage(self) end
		if self.debuff then return nil end
		if self.ability.consumeable.max_highlighted then
			update_hand_text({ immediate = true, nopulse = true, delay = 0 },
				{ mult = 0, chips = 0, level = '', handname = '' })
		end
		center_obj.use(self, area, copier)
	else
		card_use_consumeable_ref(self, area, copier)
	end
end

local card_can_use_consumeable_ref = Card.can_use_consumeable
function Card:can_use_consumeable(any_state, skip_check)
    if not skip_check and ((G.play and #G.play.cards > 0) or
            (G.CONTROLLER.locked) or
            (G.GAME.STOP_USE and G.GAME.STOP_USE > 0))
    then
        return false
    end
    if (G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND or G.STATE == G.STATES.PLAY_TAROT) and not any_state then
        return false
    end
    local t = nil
    local key = self.config.center.key
    local center_obj = SMODS.Tarots[key] or SMODS.Planets[key] or SMODS.Spectrals[key]
    if center_obj and center_obj.can_use and type(center_obj.can_use) == 'function' then
        t = center_obj.can_use(self) or t
    end
    if not (t == nil) then
        return t
    else
        return card_can_use_consumeable_ref(self, any_state, skip_check)
    end
end

local card_h_popup_ref = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
	local t = card_h_popup_ref(card)
    if not card.config.center or -- no center
	(card.config.center.unlocked == false and not card.bypass_lock) or -- locked card
	card.debuff or -- debuffed card
	(not card.config.center.discovered and ((card.area ~= G.jokers and card.area ~= G.consumeables and card.area) or not card.area)) -- undiscovered card
	then return t end
	local badges = t.nodes[1].nodes[1].nodes[1].nodes[3]
	badges = badges and badges.nodes or nil
	local key = card.config.center.key
	local center_obj = SMODS.Jokers[key] or SMODS.Tarots[key] or SMODS.Planets[key] or SMODS.Spectrals[key] or
		SMODS.Vouchers[key]
	if center_obj then
		if center_obj.set_badges and type(center_obj.set_badges) == 'function' then
			center_obj.set_badges(card, badges)
		end
		if not G.SETTINGS.no_mod_tracking then
			local mod_name = string.sub(center_obj.mod_name, 1, 16)
			local len = string.len(mod_name)
			badges[#badges + 1] = create_badge(mod_name, center_obj.badge_colour or G.C.UI.BACKGROUND_INACTIVE, nil,
				len <= 6 and 0.9 or 0.9 - 0.02 * (len - 6))
		end
	end
	return t
end

local settings_ref = G.UIDEF.settings_tab
function G.UIDEF.settings_tab(tab)
	local t = settings_ref(tab)
	if tab == 'Game' then
		t.nodes[7] = create_toggle { label = 'Disable Mod Tracking', ref_table = G.SETTINGS, ref_value = 'no_mod_tracking' }
	end
	return t
end
SMODS.Vouchers = {}
SMODS.Voucher = {
  name = "",
  slug = "",
	cost = 10,
	config = {},
  pos = {},
	loc_txt = {},
	discovered = false, 
	unlocked = true, 
	available = true
}

function SMODS.Voucher:new(name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires,
    atlas)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.loc_txt = loc_txt
    o.name = name
    o.slug = "v_" .. slug
    o.config = config or {}
    o.pos = pos or {
        x = 0,
        y = 0
    }
    o.cost = cost
    o.unlocked = unlocked or true
    o.discovered = discovered or false
    o.available = available or true
	o.requires = requires
    o.atlas = atlas
    o.mod_name = SMODS._MOD_NAME
    o.badge_colour = SMODS._BADGE_COLOUR
	return o
end

function SMODS.Voucher:register()
    if not SMODS.Vouchers[self.slug] then
        SMODS.Vouchers[self.slug] = self
        SMODS.BUFFERS.Vouchers[#SMODS.BUFFERS.Vouchers + 1] = self.slug
    end
end

function SMODS.injectVouchers()
    local minId = table_length(G.P_CENTER_POOLS['Voucher']) + 1
    local id = 0
    local i = 0
    local voucher = nil
    for _, slug in ipairs(SMODS.BUFFERS.Vouchers) do
        voucher = SMODS.Vouchers[slug]
        if voucher.order then
            id = voucher.order
        else
            i = i + 1
            id = i + minId
        end
        local voucher_obj = {
            discovered = voucher.discovered,
            available = voucher.available,
            name = voucher.name,
            set = "Voucher",
            unlocked = voucher.unlocked,
            order = id,
            key = voucher.slug,
            pos = voucher.pos,
            config = voucher.config,
            cost = voucher.cost,
            atlas = voucher.atlas,
            requires = voucher.requires,
            mod_name = voucher.mod_name,
            badge_colour = voucher.badge_colour
        }

        for _i, sprite in ipairs(SMODS.Sprites) do
            if sprite.name == voucher_obj.key then
                voucher_obj.atlas = sprite.name
            end
        end

        -- Now we replace the others
        G.P_CENTERS[voucher.slug] = voucher_obj
        if voucher.taken_ownership then
            for k, v in ipairs(G.P_CENTER_POOLS['Voucher']) do
                if v.key == slug then G.P_CENTER_POOLS['Voucher'][k] = voucher_obj end
            end
        else
            table.insert(G.P_CENTER_POOLS['Voucher'], voucher_obj)
        end
        

        -- Setup Localize text
        G.localization.descriptions["Voucher"][voucher.slug] = voucher.loc_txt

        sendInfoMessage("Registered Voucher " .. voucher.name .. " with the slug " .. voucher.slug .. " at ID " .. id .. ".", 'VoucherAPI')
    end
end

function SMODS.Voucher:take_ownership(slug)
    if not (string.sub(slug, 1, 2) == 'v_') then slug = 'v_' .. slug end
    local obj = G.P_CENTERS[slug]
    if not obj then
        sendWarnMessage('Tried to take ownership of non-existent Voucher: ' .. slug, 'ConsumableAPI')
        return nil
    end
    if obj.mod_name then
        sendWarnMessage('Can only take ownership of unclaimed vanilla Vouchers! ' ..
            slug .. ' belongs to ' .. obj.mod_name, 'ConsumableAPI')
        return nil
    end
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.loc_txt = G.localization.descriptions['Voucher'][slug]
    o.slug = slug
    for k, v in pairs(obj) do
        o[k] = v
    end
	o.mod_name = SMODS._MOD_NAME
    o.badge_colour = SMODS._BADGE_COLOUR
	o.taken_ownership = true
	return o
end

local Card_apply_to_run_ref = Card.apply_to_run
function Card:apply_to_run(center)
    local center_table = {
        name = center and center.name or self and self.ability.name,
        extra = center and center.config.extra or self and self.ability.extra
    }
    local key = center and center.key or self and self.config.center.key
    local voucher_obj = SMODS.Vouchers[key]
    if voucher_obj and voucher_obj.redeem and type(voucher_obj.redeem) == 'function' then
        voucher_obj.redeem(center_table)
    end
    Card_apply_to_run_ref(self, center)
end
SMODS.Planets = {}
SMODS.Planet = {
    name = "",
    slug = "",
    cost = 3,
    config = {},
    pos = {},
    loc_txt = {},
    discovered = false,
    consumeable = true,
    effect = "Hand Upgrade",
    freq = 1,
    cost_mult = 1.0
}

function SMODS.Planet:new(name, slug, config, pos, loc_txt, cost, cost_mult, effect, freq, consumeable, discovered, atlas)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.loc_txt = loc_txt or {
        name = name,
        text = {
            [1] = '{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up',
            [2] = '{C:attention}#2#',
            [3] = '{C:mult}+#3#{} Mult and',
            [4] = '{C:chips}+#4#{} chips',
        }
    }
    o.name = name
    o.slug = "c_" .. slug
    o.config = config or {}
    o.pos = pos or {
        x = 0,
        y = 0
    }
    o.cost = cost
    o.unlocked = true
    o.discovered = discovered or false
    o.consumeable = consumeable or true
    o.effect = effect or "Hand Upgrade"
    o.freq = freq or 1
    o.cost_mult = cost_mult or 1.0
    o.atlas = atlas
    o.mod_name = SMODS._MOD_NAME
    o.badge_colour = SMODS._BADGE_COLOUR
    return o
end

function SMODS.Planet:register()
    if not SMODS.Planets[self.slug] then
        SMODS.Planets[self.slug] = self
        SMODS.BUFFERS.Planets[#SMODS.BUFFERS.Planets + 1] = self.slug
    end
end

function SMODS.injectPlanets()
    local minId = table_length(G.P_CENTER_POOLS['Planet']) + 1
    local id = 0
    local i = 0
    local planet = nil
    for _, slug in ipairs(SMODS.BUFFERS.Planets) do
        planet = SMODS.Planets[slug]
        if planet.order then
            id = planet.order
        else
            i = i + 1
            id = i + minId
        end

        local planet_obj = {
            unlocked = planet.unlocked,
            discovered = planet.discovered,
            consumeable = planet.consumeable,
            name = planet.name,
            set = "Planet",
            order = id,
            key = planet.slug,
            pos = planet.pos,
            cost = planet.cost,
            config = planet.config,
            effect = planet.effect,
            cost_mult = planet.cost_mult,
            freq = planet.freq,
            atlas = planet.atlas,
            mod_name = planet.mod_name,
            badge_colour = planet.badge_colour
        }

        for _i, sprite in ipairs(SMODS.Sprites) do
            if sprite.name == planet_obj.key then
                planet_obj.atlas = sprite.name
            end
        end

        -- Now we replace the others
        G.P_CENTERS[slug] = planet_obj
        if not planet.taken_ownership then
			table.insert(G.P_CENTER_POOLS['Planet'], planet_obj)
		else
			for k, v in ipairs(G.P_CENTER_POOLS['Planet']) do
				if v.key == slug then G.P_CENTER_POOLS['Planet'][k] = planet_obj end
			end
		end

        -- Setup Localize text
        G.localization.descriptions["Planet"][planet.slug] = planet.loc_txt

        sendInfoMessage("Registered Planet " .. planet.name .. " with the slug " .. planet.slug .. " at ID " .. id .. ".", 'ConsumableAPI')
    end
end

function SMODS.Planet:take_ownership(slug)
    if not (string.sub(slug, 1, 2) == 'c_') then slug = 'c_' .. slug end
    local obj = G.P_CENTERS[slug]
    if not obj then
        sendWarnMessage('Tried to take ownership of non-existent Planet: ' .. slug, 'ConsumableAPI')
        return nil
    end
    if obj.mod_name then
        sendWarnMessage('Can only take ownership of unclaimed vanilla Planets! ' ..
            slug .. ' belongs to ' .. obj.mod_name, 'ConsumableAPI')
        return nil
    end
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.loc_txt = G.localization.descriptions['Planet'][slug]
    o.slug = slug
    for k, v in pairs(obj) do
        o[k] = v
    end
	o.mod_name = SMODS._MOD_NAME
    o.badge_colour = SMODS._BADGE_COLOUR
	o.taken_ownership = true
	return o
end

function create_UIBox_your_collection_planets()
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(
            G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
            (3.25 + j) * G.CARD_W,
            1 * G.CARD_H,
            { card_limit = j + 3, type = 'title', highlight_limit = 0, collection = true })
        table.insert(deck_tables,
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0, no_fill = true },
                nodes = {
                    { n = G.UIT.O, config = { object = G.your_collection[j] } }
                }
            }
        )
    end

    for j = 1, #G.your_collection do
        for i = 1, 3 do
            local center = G.P_CENTER_POOLS["Planet"][i + (j - 1) * (3)]
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G
                .CARD_W,
                G.CARD_H, nil, center)
            card:start_materialize(nil, i > 1 or j > 1)
            G.your_collection[j]:emplace(card)
        end
    end

    local tarot_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Planet / 6) do
        table.insert(tarot_options,
            localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#G.P_CENTER_POOLS.Planet / 6)))
    end

    INIT_COLLECTION_CARD_ALERTS()

    local t = create_UIBox_generic_options({
        back_func = 'your_collection',
        contents = {
            { n = G.UIT.R, config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0 },
                nodes = {
                    create_option_cycle({
                        options = tarot_options,
                        w = 4.5,
                        cycle_shoulders = true,
                        opt_callback =
                        'your_collection_planet_page',
                        focus_args = { snap_to = true, nav = 'wide' },
                        current_option = 1,
                        colour = G
                            .C.RED,
                        no_pips = true
                    })
                }
            },
        }
    })
    return t
end

G.FUNCS.your_collection_planet_page = function(args)
    if not args or not args.cycle_config then return end
    for j = 1, #G.your_collection do
        for i = #G.your_collection[j].cards, 1, -1 do
            local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
            c:remove()
            c = nil
        end
    end

    for j = 1, #G.your_collection do
        for i = 1, 3 do
            local center = G.P_CENTER_POOLS["Planet"][i + (j - 1) * (3) + (6 * (args.cycle_config.current_option - 1))]
            if not center then break end
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G
                .CARD_W, G.CARD_H, G.P_CARDS.empty, center)
            card:start_materialize(nil, i > 1 or j > 1)
            G.your_collection[j]:emplace(card)
        end
    end
    INIT_COLLECTION_CARD_ALERTS()
end

SMODS.Spectrals = {}
SMODS.Spectral = {
    name = "",
    slug = "",
    cost = 4,
    config = {},
    pos = {},
    loc_txt = {},
    discovered = false,
    consumeable = true
}

function SMODS.Spectral:new(name, slug, config, pos, loc_txt, cost, consumeable, discovered, atlas)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.loc_txt = loc_txt
    o.name = name
    o.slug = "c_" .. slug
    o.config = config or {}
    o.pos = pos or {
        x = 0,
        y = 0
    }
    o.cost = cost
    o.discovered = discovered or false
    o.unlocked = true
    o.consumeable = consumeable or true
    o.atlas = atlas
    o.mod_name = SMODS._MOD_NAME
    o.badge_colour = SMODS._BADGE_COLOUR
    return o
end

function SMODS.Spectral:register()
    if not SMODS.Spectrals[self.slug] then
        SMODS.Spectrals[self.slug] = self
        SMODS.BUFFERS.Spectrals[#SMODS.BUFFERS.Spectrals + 1] = self.slug
    end
end

function SMODS.injectSpectrals()
    local minId = table_length(G.P_CENTER_POOLS['Spectral']) + 1
    local id = 0
    local i = 0
    local spectral = nil
    for _, slug in ipairs(SMODS.BUFFERS.Spectrals) do
        spectral = SMODS.Spectrals[slug]
        if spectral.order then
            id = spectral.order
        else
            i = i + 1
            id = i + minId
        end
        local tarot_obj = {
            unlocked = spectral.unlocked,
            discovered = spectral.discovered,
            consumeable = spectral.consumeable,
            name = spectral.name,
            set = "Spectral",
            order = id,
            key = spectral.slug,
            pos = spectral.pos,
            config = spectral.config,
            atlas = spectral.atlas,
            cost = spectral.cost,
            mod_name = spectral.mod_name,
            badge_colour = spectral.badge_colour,
            -- * currently unsupported
            hidden = spectral.hidden
        }

        for _i, sprite in ipairs(SMODS.Sprites) do
            if sprite.name == tarot_obj.key then
                tarot_obj.atlas = sprite.name
            end
        end

        -- Now we replace the others
        G.P_CENTERS[slug] = tarot_obj
        if not spectral.taken_ownership then
			table.insert(G.P_CENTER_POOLS['Spectral'], tarot_obj)
		else
			for k, v in ipairs(G.P_CENTER_POOLS['Spectral']) do
				if v.key == slug then G.P_CENTER_POOLS['Spectral'][k] = tarot_obj end
			end
		end

        -- Setup Localize text
        G.localization.descriptions["Spectral"][spectral.slug] = spectral.loc_txt

        sendInfoMessage("Registered Spectral " .. spectral.name .. " with the slug " .. spectral.slug .. " at ID " .. id .. ".", 'ConsumableAPI')
    end
end

function SMODS.Spectral:take_ownership(slug)
    if not (string.sub(slug, 1, 2) == 'c_') then slug = 'c_' .. slug end
    local obj = G.P_CENTERS[slug]
    if not obj then
        sendWarnMessage('Tried to take ownership of non-existent Spectral: ' .. slug, 'ConsumableAPI')
        return nil
    end
    if obj.mod_name then
        sendWarnMessage('Can only take ownership of unclaimed vanilla Spectrals! ' ..
            slug .. ' belongs to ' .. obj.mod_name, 'ConsumableAPI')
        return nil
    end
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.loc_txt = G.localization.descriptions['Spectral'][slug]
    o.slug = slug
    for k, v in pairs(obj) do
        o[k] = v
    end
	o.mod_name = SMODS._MOD_NAME
    o.badge_colour = SMODS._BADGE_COLOUR
	o.taken_ownership = true
	return o
end

function create_UIBox_your_collection_spectrals()
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(
            G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
            (3.25 + j) * G.CARD_W,
            1 * G.CARD_H,
            { card_limit = j + 3, type = 'title', highlight_limit = 0, collection = true })
        table.insert(deck_tables,
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0, no_fill = true },
                nodes = {
                    { n = G.UIT.O, config = { object = G.your_collection[j] } }
                }
            }
        )
    end

    for j = 1, #G.your_collection do
        for i = 1, 3 + j do
            local center = G.P_CENTER_POOLS["Spectral"][i + (j - 1) * 3 + j - 1]

            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G
                .CARD_W,
                G.CARD_H, nil, center)
            card:start_materialize(nil, i > 1 or j > 1)
            G.your_collection[j]:emplace(card)
        end
    end

    local spectral_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Spectral / 9) do
        table.insert(spectral_options,
            localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#G.P_CENTER_POOLS.Spectral / 9)))
    end

    INIT_COLLECTION_CARD_ALERTS()

    local t = create_UIBox_generic_options({
        back_func = 'your_collection',
        contents = {
            { n = G.UIT.R, config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0 },
                nodes = {
                    create_option_cycle({
                        options = spectral_options,
                        w = 4.5,
                        cycle_shoulders = true,
                        opt_callback =
                        'your_collection_spectral_page',
                        focus_args = { snap_to = true, nav = 'wide' },
                        current_option = 1,
                        colour = G
                            .C.RED,
                        no_pips = true
                    })
                }
            },
        }
    })
    return t
end

SMODS.Seals = {}
SMODS.Seal = {
  	name = "",
  	pos = {},
	loc_txt = {},
	discovered = false,
	atlas = "centers",
	label = "",
	full_name = "",
	color = HEX("FFFFFF")
}

function SMODS.Seal:new(name, label, full_name, pos, loc_txt, atlas, discovered, color)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.loc_txt = loc_txt
    o.name = name
    o.label = label
    o.full_name = full_name
    o.pos = pos or {
        x = 0,
        y = 0
    }
    o.discovered = discovered or false
    o.atlas = atlas or "centers"
    o.color = color or HEX("FFFFFF")
    return o
end

function SMODS.Seal:register()
    if not SMODS.Seals[self.label] then
        SMODS.Seals[self.label] = self
        SMODS.BUFFERS.Seals[#SMODS.BUFFERS.Seals+1] = self.label
    end
end

function SMODS.injectSeals()
    local seal = nil
    for _, label in ipairs(SMODS.BUFFERS.Seals) do
        seal = SMODS.Seals[label]
        local seal_obj = {
            discovered = seal.discovered,
            set = "Seal",
            order = #G.P_CENTER_POOLS.Seal + 1,
            key = seal.name
        }

        G.shared_seals[seal.name] = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS[seal.atlas], seal.pos)

        -- Now we replace the others
        G.P_SEALS[seal.name] = seal_obj
        table.insert(G.P_CENTER_POOLS.Seal, seal_obj)

        -- Setup Localize text
        G.localization.descriptions.Other[seal.label] = seal.loc_txt
        G.localization.misc.labels[seal.label] = seal.full_name

        sendDebugMessage("The Seal named " ..
        seal.name .. " have been registered at the id " .. #G.P_CENTER_POOLS.Seal .. ".")
    end
end

local get_badge_colourref = get_badge_colour
function get_badge_colour(key)
    local fromRef = get_badge_colourref(key)

	for k, v in pairs(SMODS.Seals) do
		if key == k then
			return v.color
		end
	end
    return fromRef
end
-- ----------------------------------------------
-- ----------MOD CORE API STACKTRACE-------------
-- NOTE: This is a modifed version of https://github.com/ignacio/StackTracePlus/blob/master/src/StackTracePlus.lua
-- Licensed under the MIT License. See https://github.com/ignacio/StackTracePlus/blob/master/LICENSE
-- The MIT License
-- Copyright (c) 2010 Ignacio Burgueño
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-- tables
function loadStackTracePlus()
    local _G = _G
    local string, io, debug, coroutine = string, io, debug, coroutine

    -- functions
    local tostring, print, require = tostring, print, require
    local next, assert = next, assert
    local pcall, type, pairs, ipairs = pcall, type, pairs, ipairs
    local error = error

    assert(debug, "debug table must be available at this point")

    local io_open = io.open
    local string_gmatch = string.gmatch
    local string_sub = string.sub
    local table_concat = table.concat

    local _M = {
        max_tb_output_len = 70 -- controls the maximum length of the 'stringified' table before cutting with ' (more...)'
    }

    -- this tables should be weak so the elements in them won't become uncollectable
    local m_known_tables = {
        [_G] = "_G (global table)"
    }
    local function add_known_module(name, desc)
        local ok, mod = pcall(require, name)
        if ok then
            m_known_tables[mod] = desc
        end
    end

    add_known_module("string", "string module")
    add_known_module("io", "io module")
    add_known_module("os", "os module")
    add_known_module("table", "table module")
    add_known_module("math", "math module")
    add_known_module("package", "package module")
    add_known_module("debug", "debug module")
    add_known_module("coroutine", "coroutine module")

    -- lua5.2
    add_known_module("bit32", "bit32 module")
    -- luajit
    add_known_module("bit", "bit module")
    add_known_module("jit", "jit module")
    -- lua5.3
    if _VERSION >= "Lua 5.3" then
        add_known_module("utf8", "utf8 module")
    end

    local m_user_known_tables = {}

    local m_known_functions = {}
    for _, name in ipairs { -- Lua 5.2, 5.1
    "assert", "collectgarbage", "dofile", "error", "getmetatable", "ipairs", "load", "loadfile", "next", "pairs",
    "pcall", "print", "rawequal", "rawget", "rawlen", "rawset", "require", "select", "setmetatable", "tonumber",
    "tostring", "type", "xpcall", -- Lua 5.1
    "gcinfo", "getfenv", "loadstring", "module", "newproxy", "setfenv", "unpack" -- TODO: add table.* etc functions
    } do
        if _G[name] then
            m_known_functions[_G[name]] = name
        end
    end

    local m_user_known_functions = {}

    local function safe_tostring(value)
        local ok, err = pcall(tostring, value)
        if ok then
            return err
        else
            return ("<failed to get printable value>: '%s'"):format(err)
        end
    end

    -- Private:
    -- Parses a line, looking for possible function definitions (in a very naïve way)
    -- Returns '(anonymous)' if no function name was found in the line
    local function ParseLine(line)
        assert(type(line) == "string")
        -- print(line)
        local match = line:match("^%s*function%s+(%w+)")
        if match then
            -- print("+++++++++++++function", match)
            return match
        end
        match = line:match("^%s*local%s+function%s+(%w+)")
        if match then
            -- print("++++++++++++local", match)
            return match
        end
        match = line:match("^%s*local%s+(%w+)%s+=%s+function")
        if match then
            -- print("++++++++++++local func", match)
            return match
        end
        match = line:match("%s*function%s*%(") -- this is an anonymous function
        if match then
            -- print("+++++++++++++function2", match)
            return "(anonymous)"
        end
        return "(anonymous)"
    end

    -- Private:
    -- Tries to guess a function's name when the debug info structure does not have it.
    -- It parses either the file or the string where the function is defined.
    -- Returns '?' if the line where the function is defined is not found
    local function GuessFunctionName(info)
        -- print("guessing function name")
        if type(info.source) == "string" and info.source:sub(1, 1) == "@" then
            local file, err = io_open(info.source:sub(2), "r")
            if not file then
                print("file not found: " .. tostring(err)) -- whoops!
                return "?"
            end
            local line
            for _ = 1, info.linedefined do
                line = file:read("*l")
            end
            if not line then
                print("line not found") -- whoops!
                return "?"
            end
            return ParseLine(line)
        elseif type(info.source) == "string" and info.source:sub(1, 1) == "=" then
            return "(Love2D Function)"
        else
            local line
            local lineNumber = 0
            for l in string_gmatch(info.source, "([^\n]+)\n-") do
                lineNumber = lineNumber + 1
                if lineNumber == info.linedefined then
                    line = l
                    break
                end
            end
            if not line then
                print("line not found") -- whoops!
                return "?"
            end
            return ParseLine(line)
        end
    end

    ---
    -- Dumper instances are used to analyze stacks and collect its information.
    --
    local Dumper = {}

    Dumper.new = function(thread)
        local t = {
            lines = {}
        }
        for k, v in pairs(Dumper) do
            t[k] = v
        end

        t.dumping_same_thread = (thread == coroutine.running())

        -- if a thread was supplied, bind it to debug.info and debug.get
        -- we also need to skip this additional level we are introducing in the callstack (only if we are running
        -- in the same thread we're inspecting)
        if type(thread) == "thread" then
            t.getinfo = function(level, what)
                if t.dumping_same_thread and type(level) == "number" then
                    level = level + 1
                end
                return debug.getinfo(thread, level, what)
            end
            t.getlocal = function(level, loc)
                if t.dumping_same_thread then
                    level = level + 1
                end
                return debug.getlocal(thread, level, loc)
            end
        else
            t.getinfo = debug.getinfo
            t.getlocal = debug.getlocal
        end

        return t
    end

    -- helpers for collecting strings to be used when assembling the final trace
    function Dumper:add(text)
        self.lines[#self.lines + 1] = text
    end
    function Dumper:add_f(fmt, ...)
        self:add(fmt:format(...))
    end
    function Dumper:concat_lines()
        return table_concat(self.lines)
    end

    ---
    -- Private:
    -- Iterates over the local variables of a given function.
    --
    -- @param level The stack level where the function is.
    --
    function Dumper:DumpLocals(level)
        local prefix = "\t "
        local i = 1

        if self.dumping_same_thread then
            level = level + 1
        end

        local name, value = self.getlocal(level, i)
        if not name then
            return
        end
        self:add("\tLocal variables:\r\n")
        while name do
            if type(value) == "number" then
                self:add_f("%s%s = number: %g\r\n", prefix, name, value)
            elseif type(value) == "boolean" then
                self:add_f("%s%s = boolean: %s\r\n", prefix, name, tostring(value))
            elseif type(value) == "string" then
                self:add_f("%s%s = string: %q\r\n", prefix, name, value)
            elseif type(value) == "userdata" then
                self:add_f("%s%s = %s\r\n", prefix, name, safe_tostring(value))
            elseif type(value) == "nil" then
                self:add_f("%s%s = nil\r\n", prefix, name)
            elseif type(value) == "table" then
                if m_known_tables[value] then
                    self:add_f("%s%s = %s\r\n", prefix, name, m_known_tables[value])
                elseif m_user_known_tables[value] then
                    self:add_f("%s%s = %s\r\n", prefix, name, m_user_known_tables[value])
                else
                    local txt = "{"
                    for k, v in pairs(value) do
                        txt = txt .. safe_tostring(k) .. ":" .. safe_tostring(v)
                        if #txt > _M.max_tb_output_len then
                            txt = txt .. " (more...)"
                            break
                        end
                        if next(value, k) then
                            txt = txt .. ", "
                        end
                    end
                    self:add_f("%s%s = %s  %s\r\n", prefix, name, safe_tostring(value), txt .. "}")
                end
            elseif type(value) == "function" then
                local info = self.getinfo(value, "nS")
                local fun_name = info.name or m_known_functions[value] or m_user_known_functions[value]
                if info.what == "C" then
                    self:add_f("%s%s = C %s\r\n", prefix, name,
                        (fun_name and ("function: " .. fun_name) or tostring(value)))
                else
                    local source = info.short_src
                    if source:sub(2, 7) == "string" then
                        source = source:sub(9) -- uno más, por el espacio que viene (string "Baragent.Main", por ejemplo)
                    end
                    -- for k,v in pairs(info) do print(k,v) end
                    fun_name = fun_name or GuessFunctionName(info)
                    if info.source and info.source:sub(1, 21) == "--- STEAMODDED HEADER" then
                        local modName, modID = info.source:match("%-%-%- MOD_NAME: ([^\n]+)\n%-%-%- MOD_ID: ([^\n]+)")
                        self:add_f("%s%s = Lua function '%s' (defined at line %d of mod %s (%s))\r\n", prefix, name,
                            fun_name, info.linedefined, modName, modID)
                    else
                        self:add_f("%s%s = Lua function '%s' (defined at line %d of chunk %s)\r\n", prefix, name,
                            fun_name, info.linedefined, source)
                    end
                end
            elseif type(value) == "thread" then
                self:add_f("%sthread %q = %s\r\n", prefix, name, tostring(value))
            end
            i = i + 1
            name, value = self.getlocal(level, i)
        end
    end

    ---
    -- Public:
    -- Collects a detailed stack trace, dumping locals, resolving function names when they're not available, etc.
    -- This function is suitable to be used as an error handler with pcall or xpcall
    --
    -- @param thread An optional thread whose stack is to be inspected (defaul is the current thread)
    -- @param message An optional error string or object.
    -- @param level An optional number telling at which level to start the traceback (default is 1)
    --
    -- Returns a string with the stack trace and a string with the original error.
    --
    function _M.stacktrace(thread, message, level)
        if type(thread) ~= "thread" then
            -- shift parameters left
            thread, message, level = nil, thread, message
        end

        thread = thread or coroutine.running()

        level = level or 1

        local dumper = Dumper.new(thread)

        local original_error

        if type(message) == "table" then
            dumper:add("an error object {\r\n")
            local first = true
            for k, v in pairs(message) do
                if first then
                    dumper:add("  ")
                    first = false
                else
                    dumper:add(",\r\n  ")
                end
                dumper:add(safe_tostring(k))
                dumper:add(": ")
                dumper:add(safe_tostring(v))
            end
            dumper:add("\r\n}")
            original_error = dumper:concat_lines()
        elseif type(message) == "string" then
            dumper:add(message)
            original_error = message
        end

        dumper:add("\r\n")
        dumper:add [[
Stack Traceback
===============
]]
        -- print(error_message)

        local level_to_show = level
        if dumper.dumping_same_thread then
            level = level + 1
        end

        local info = dumper.getinfo(level, "nSlf")
        while info do
            if info.what == "main" then
                if string_sub(info.source, 1, 1) == "@" then
                    dumper:add_f("(%d) main chunk of file '%s' at line %d\r\n", level_to_show,
                        string_sub(info.source, 2), info.currentline)
                elseif info.source and info.source:sub(1, 21) == "--- STEAMODDED HEADER" then
                    local modName, modID = info.source:match("%-%-%- MOD_NAME: ([^\n]+)\n%-%-%- MOD_ID: ([^\n]+)")
                    dumper:add_f("(%d) main chunk of mod %s (%s) at line %d\r\n", level_to_show, modName, modID,
                        info.currentline)
                else
                    dumper:add_f("(%d) main chunk of %s at line %d\r\n", level_to_show, info.short_src, info.currentline)
                end
            elseif info.what == "C" then
                -- print(info.namewhat, info.name)
                -- for k,v in pairs(info) do print(k,v, type(v)) end
                local function_name = m_user_known_functions[info.func] or m_known_functions[info.func] or info.name or
                                          tostring(info.func)
                dumper:add_f("(%d) %s C function '%s'\r\n", level_to_show, info.namewhat, function_name)
                -- dumper:add_f("%s%s = C %s\r\n", prefix, name, (m_known_functions[value] and ("function: " .. m_known_functions[value]) or tostring(value)))
            elseif info.what == "tail" then
                -- print("tail")
                -- for k,v in pairs(info) do print(k,v, type(v)) end--print(info.namewhat, info.name)
                dumper:add_f("(%d) tail call\r\n", level_to_show)
                dumper:DumpLocals(level)
            elseif info.what == "Lua" then
                local source = info.short_src
                local function_name = m_user_known_functions[info.func] or m_known_functions[info.func] or info.name
                if source:sub(2, 7) == "string" then
                    source = source:sub(9)
                end
                local was_guessed = false
                if not function_name or function_name == "?" then
                    -- for k,v in pairs(info) do print(k,v, type(v)) end
                    function_name = GuessFunctionName(info)
                    was_guessed = true
                end
                -- test if we have a file name
                local function_type = (info.namewhat == "") and "function" or info.namewhat
                if info.source and info.source:sub(1, 1) == "@" then
                    dumper:add_f("(%d) Lua %s '%s' at file '%s:%d'%s\r\n", level_to_show, function_type, function_name,
                        info.source:sub(2), info.currentline, was_guessed and " (best guess)" or "")
                elseif info.source and info.source:sub(1, 1) == '#' then
                    dumper:add_f("(%d) Lua %s '%s' at template '%s:%d'%s\r\n", level_to_show, function_type,
                        function_name, info.source:sub(2), info.currentline, was_guessed and " (best guess)" or "")
                elseif info.source and info.source:sub(1, 1) == "=" then
                    dumper:add_f("(%d) Love2D %s at file '%s:%d'%s\r\n", level_to_show, function_type,
                        info.source:sub(9, -3), info.currentline, was_guessed and " (best guess)" or "")
                elseif info.source and info.source:sub(1, 21) == "--- STEAMODDED HEADER" then
                    local modName, modID = info.source:match("%-%-%- MOD_NAME: ([^\n]+)\n%-%-%- MOD_ID: ([^\n]+)")
                    dumper:add_f("(%d) Lua %s '%s' at line %d of mod %s (%s) %s\r\n", level_to_show, function_type,
                        function_name, info.currentline, modName, modID, was_guessed and " (best guess)" or "")
                else
                    dumper:add_f("(%d) Lua %s '%s' at line %d of chunk '%s'\r\n", level_to_show, function_type,
                        function_name, info.currentline, source)
                end
                dumper:DumpLocals(level)
            else
                dumper:add_f("(%d) unknown frame %s\r\n", level_to_show, info.what)
            end

            level = level + 1
            level_to_show = level_to_show + 1
            info = dumper.getinfo(level, "nSlf")
        end

        return dumper:concat_lines(), original_error
    end

    --
    -- Adds a table to the list of known tables
    function _M.add_known_table(tab, description)
        if m_known_tables[tab] then
            error("Cannot override an already known table")
        end
        m_user_known_tables[tab] = description
    end

    --
    -- Adds a function to the list of known functions
    function _M.add_known_function(fun, description)
        if m_known_functions[fun] then
            error("Cannot override an already known function")
        end
        m_user_known_functions[fun] = description
    end

    return _M
end


-- Note: The below code is not from the original StackTracePlus.lua
local stackTraceAlreadyInjected = false
function injectStackTrace()
    if(stackTraceAlreadyInjected) then
        return
    end
    stackTraceAlreadyInjected = true
    local STP = loadStackTracePlus()

    local crashHandler = love.errhand
    function love.errhand(msg)
        sendErrorMessage("Oops! The game crashed\n" .. STP.stacktrace(msg), 'StackTrace')
        if _RELEASE_MODE then
            msg = STP.stacktrace(msg .. "\n", 3) -- The game shows the stack for me if release mode is false
        end
        return crashHandler(msg)
    end
    debug.traceback = STP.stacktrace -- For when the game itself calls it
end

-- ----------------------------------------------
-- --------MOD CORE API STACKTRACE END-----------

----------------------------------------------
------------MOD DEBUG SOCKET------------------

function initializeSocketConnection()
    local socket = require("socket")
    client = socket.connect("localhost", 12345)
    if not client then
        print("Failed to connect to the debug server")
    end
end

-- message, logger in this order to preserve backward compatibility
function sendTraceMessage(message, logger)
	sendMessageToConsole("TRACE", logger, message)
end

function sendDebugMessage(message, logger)
    sendMessageToConsole("DEBUG", logger, message)
end

function sendInfoMessage(message, logger)
	-- space in info string to align the logs in console
    sendMessageToConsole("INFO ", logger, message)
end

function sendWarnMessage(message, logger)
	-- space in warn string to align the logs in console
	sendMessageToConsole("WARN ", logger, message)
end

function sendErrorMessage(message, logger)
    sendMessageToConsole("ERROR", logger, message)
end

function sendFatalMessage(message, logger)
    sendMessageToConsole("FATAL", logger, message)
end

function sendMessageToConsole(level, logger, message)
    level = level or "DEBUG"
    logger = logger or "DefaultLogger"
    message = message or "Default log message"
    date = os.date('%Y-%m-%d %H:%M:%S')
    print(date .. " :: " .. level .. " :: " .. logger .. " :: " .. message)
    if client then
        -- naive way to separate the logs if the console receive multiple logs at the same time
        client:send(date .. " :: " .. level .. " :: " .. logger .. " :: " .. message .. "ENDOFLOG")
    end
end

initializeSocketConnection()

-- Use the function to send messages
sendDebugMessage("Steamodded Debug Socket started !", "DebugConsole")

----------------------------------------------
------------MOD DEBUG SOCKET END--------------

----------------------------------------------
------------MOD LOADER------------------------

SMODS.INIT = {}
SMODS._MOD_PRIO_MAP = {}
SMODS._INIT_PRIO_MAP = {}
SMODS._INIT_KEYS = {}
SMODS._MOD_FROM_INIT = {}
SMODS._MOD_NAME = ''
SMODS._BADGE_COLOUR = {}

-- Attempt to require nativefs
local nfs_success, nativefs = pcall(require, "nativefs")
local lovely_success, lovely = pcall(require, "lovely")

if nfs_success then
    if lovely_success then
        SMODS.MODS_DIR = lovely.mod_dir
    else
        sendErrorMessage("Error loading lovely library!", 'Loader')
        SMODS.MODS_DIR = "Mods"
    end
else
    sendErrorMessage("Error loading nativefs library!", 'Loader')
    SMODS.MODS_DIR = "Mods"
    nativefs = love.filesystem
end

NFS = nativefs

function loadMods(modsDirectory)
    local mods = {}
    local modIDs = {}

    -- Function to process each directory (including subdirectories) with depth tracking
    local function processDirectory(directory, depth)
        if depth > 3 then
            return  -- Stop processing if the depth is greater than 3
        end

        for _, filename in ipairs(NFS.getDirectoryItems(directory)) do
            local filePath = directory .. "/" .. filename

            -- Check if the current file is a directory
            if NFS.getInfo(filePath).type == "directory" then
                -- If it's a directory and depth is within limit, recursively process it
                processDirectory(filePath, depth + 1)
            elseif filename:match("%.lua$") then  -- Check if the file is a .lua file
                local fileContent = NFS.read(filePath)

                -- Convert CRLF in LF
                fileContent = fileContent:gsub("\r\n", "\n")

                -- Check the header lines using string.match
                local headerLine, secondaryLine = fileContent:match("^(.-)\n(.-)\n")
                if headerLine == "--- STEAMODDED HEADER" and secondaryLine == "--- SECONDARY MOD FILE" then
                    sendTraceMessage("Skipping secondary mod file: " .. filename, 'Loader')
                elseif headerLine == "--- STEAMODDED HEADER" then
                    -- Extract individual components from the header
                    local modName, modID, modAuthorString, modDescription = fileContent:match("%-%-%- MOD_NAME: ([^\n]+)\n%-%-%- MOD_ID: ([^\n]+)\n%-%-%- MOD_AUTHOR: %[(.-)%]\n%-%-%- MOD_DESCRIPTION: ([^\n]+)")
                    local priority = fileContent:match("%-%-%- PRIORITY: (%-?%d+)")
                    priority = priority and priority + 0 or 0
                    local badge_colour = fileContent:match("%-%-%- BADGE_COLO[U?]R: (%x-)\n")
                    badge_colour = HEX(badge_colour or '666666FF')
                    local display_name = fileContent:match("%-%-%- DISPLAY_NAME: (.-)\n")
                    -- Validate MOD_ID to ensure it doesn't contain spaces
                    if modID and string.find(modID, " ") then
                        sendWarnMessage("Invalid mod ID: " .. modID, 'Loader')
                    elseif modIDs[modID] then
                        sendWarnMessage("Duplicate mod ID: " .. modID, 'Loader')
                    else
                        if modName and modID and modAuthorString and modDescription then
                            -- Parse MOD_AUTHOR array
                            local modAuthorArray = {}
                            for author in string.gmatch(modAuthorString, "([^,]+)") do
                                table.insert(modAuthorArray, author:match("^%s*(.-)%s*$")) -- Trim spaces
                            end

                            -- Store mod information in the global table, including the directory path
                            local mod = {
                                name = modName,
                                id = modID,
                                author = modAuthorArray,
                                description = modDescription,
                                path = directory .. "/", -- Store the directory path
                                priority = priority,
                                badge_colour = badge_colour,
                                display_name = display_name or modName
                            }
                            table.insert(mods, mod)
                            modIDs[modID] = true  -- Mark this ID as used

                            SMODS._MOD_PRIO_MAP[priority] = SMODS._MOD_PRIO_MAP[priority] or {}
                            table.insert(SMODS._MOD_PRIO_MAP[priority], { content = fileContent, mod = mod })
                        end
                    end
                else
                    sendTraceMessage("Skipping non-Lua file or invalid header: " .. filename, 'Loader')
                end
            end
        end
    end

    -- Start processing with the initial directory at depth 1
    processDirectory(modsDirectory, 1)
    
    -- sort by priority
    local keyset = {}
    for k, _ in pairs(SMODS._MOD_PRIO_MAP) do
        keyset[#keyset + 1] = k
    end
    table.sort(keyset)

    -- load the mod files
    for _,priority in ipairs(keyset) do
        for _,v in ipairs(SMODS._MOD_PRIO_MAP[priority]) do
            assert(load(v.content))()
            -- set priority of added init functions
            for modName, initFunc in pairs(SMODS.INIT) do
                if type(initFunc) == 'function' and SMODS._INIT_KEYS[modName] == nil then
                    SMODS._INIT_PRIO_MAP[priority] = SMODS._INIT_PRIO_MAP[priority] or {}
                    table.insert(SMODS._INIT_PRIO_MAP[priority], modName)
                    SMODS._INIT_KEYS[modName] = true
                    SMODS._MOD_FROM_INIT[modName] = v.mod
                end
            end
        end
    end

    return mods
end

function initMods()
    local keyset = {}
    for k, _ in pairs(SMODS._INIT_PRIO_MAP) do
        keyset[#keyset + 1] = k
    end
    table.sort(keyset)
    for _,k in ipairs(keyset) do
        for _, modName in ipairs(SMODS._INIT_PRIO_MAP[k]) do
            SMODS._MOD_NAME = SMODS._MOD_FROM_INIT[modName].display_name
            SMODS._BADGE_COLOUR = SMODS._MOD_FROM_INIT[modName].badge_colour
            sendInfoMessage("Launch Init Function for: " .. modName .. ".")
            SMODS.INIT[modName]()
        end
    end
end

function initSteamodded()
    injectStackTrace()
    SMODS.MODS = loadMods(SMODS.MODS_DIR)

    sendInfoMessage(inspectDepth(SMODS.MODS, 0, 0), 'Loader')

    initGlobals()

    if SMODS.MODS then
        initializeModUIFunctions()
        initMods()
    end
    SMODS.injectSprites()
    SMODS.injectDecks()
    SMODS.injectJokers()
    SMODS.injectTarots()
    SMODS.injectPlanets()
    SMODS.injectSpectrals()
    SMODS.injectVouchers()
    SMODS.injectBlinds()
    SMODS.injectSeals()
    SMODS.LOAD_LOC()
    SMODS.SAVE_UNLOCKS()
    --sendTraceMessage(inspectDepth(G.P_CENTER_POOLS.Back), 'Loader')
end

-- retain added objects on profile reload
local init_item_prototypes_ref = Game.init_item_prototypes
function Game:init_item_prototypes()
	init_item_prototypes_ref(self)
	SMODS.injectSprites()
	SMODS.injectDecks()
    SMODS.injectJokers()
    SMODS.injectTarots()
    SMODS.injectPlanets()
    SMODS.injectSpectrals()
    SMODS.injectVouchers()
    SMODS.injectBlinds()
    SMODS.injectSeals()
    SMODS.LOAD_LOC()
    SMODS.SAVE_UNLOCKS()
    for _, v in pairs(SMODS.Card.SUITS) do
        if not v.disabled then
            SMODS.Card:populate_suit(v.name)
        end
    end
end

----------------------------------------------
------------MOD LOADER END--------------------
local lovely = require("lovely")
local nativefs = require("nativefs")

if not nativefs.getInfo(lovely.mod_dir .. "/Talisman") then
    error(
        'Could not find proper Talisman folder.\nPlease make sure the folder for Talisman is named exactly "Talisman" and not "Talisman-main" or anything else.')
end

Talisman = {config_file = {disable_anims = true, break_infinity = "omeganum", score_opt_id = 2}}
if nativefs.read(lovely.mod_dir.."/Talisman/config.lua") then
    Talisman.config_file = STR_UNPACK(nativefs.read(lovely.mod_dir.."/Talisman/config.lua"))

    if Talisman.config_file.break_infinity and type(Talisman.config_file.break_infinity) ~= 'string' then
      Talisman.config_file.break_infinity = "omeganum"
    end
end
if not SMODS or not JSON then
  local createOptionsRef = create_UIBox_options
  function create_UIBox_options()
  contents = createOptionsRef()
  local m = UIBox_button({
  minw = 5,
  button = "talismanMenu",
  label = {
  "Talisman"
  },
  colour = G.C.GOLD
  })
  table.insert(contents.nodes[1].nodes[1].nodes[1].nodes, #contents.nodes[1].nodes[1].nodes[1].nodes + 1, m)
  return contents
  end
end

Talisman.config_tab = function()
                tal_nodes = {{n=G.UIT.R, config={align = "cm"}, nodes={
                  {n=G.UIT.O, config={object = DynaText({string = "Select features to enable:", colours = {G.C.WHITE}, shadow = true, scale = 0.4})}},
                }},create_toggle({label = "Disable Scoring Animations", ref_table = Talisman.config_file, ref_value = "disable_anims",
                callback = function(_set_toggle)
	                nativefs.write(lovely.mod_dir .. "/Talisman/config.lua", STR_PACK(Talisman.config_file))
                end}),
                create_option_cycle({
                  label = "Score Limit (requires game restart)",
                  scale = 0.8,
                  w = 6,
                  options = {"Vanilla (e308)", "BigNum (ee308)", "OmegaNum (e10##1000)"},
                  opt_callback = 'talisman_upd_score_opt',
                  current_option = Talisman.config_file.score_opt_id,
                })}
                return {
                n = G.UIT.ROOT,
                config = {
                    emboss = 0.05,
                    minh = 6,
                    r = 0.1,
                    minw = 10,
                    align = "cm",
                    padding = 0.2,
                    colour = G.C.BLACK
                },
                nodes = tal_nodes
            }
              end
G.FUNCS.talismanMenu = function(e)
  local tabs = create_tabs({
      snap_to_nav = true,
      tabs = {
          {
              label = "Talisman",
              chosen = true,
              tab_definition_function = Talisman.config_tab
          },
      }})
  G.FUNCS.overlay_menu{
          definition = create_UIBox_generic_options({
              back_func = "options",
              contents = {tabs}
          }),
      config = {offset = {x=0,y=10}}
  }
end
G.FUNCS.talisman_upd_score_opt = function(e)
  Talisman.config_file.score_opt_id = e.to_key
  local score_opts = {"", "bignumber", "omeganum"}
  Talisman.config_file.break_infinity = score_opts[e.to_key]
  nativefs.write(lovely.mod_dir .. "/Talisman/config.lua", STR_PACK(Talisman.config_file))
end
if Talisman.config_file.break_infinity then
  Big, err = nativefs.load(lovely.mod_dir.."/Talisman/big-num/"..Talisman.config_file.break_infinity..".lua")
  if not err then Big = Big() else Big = nil end
  Notations = nativefs.load(lovely.mod_dir.."/Talisman/big-num/notations.lua")()
  -- We call this after init_game_object to leave room for mods that add more poker hands
  Talisman.igo = function(obj)
      for _, v in pairs(obj.hands) do
          v.chips = to_big(v.chips)
          v.mult = to_big(v.mult)
          v.s_chips = to_big(v.s_chips)
          v.s_mult = to_big(v.s_mult)
          v.l_chips = to_big(v.l_chips)
          v.l_mult = to_big(v.l_mult)
      end
      return obj
  end

  local nf = number_format
  function number_format(num, e_switch_point)
      if type(num) == 'table' then
          num = to_big(num)
          G.E_SWITCH_POINT = G.E_SWITCH_POINT or 100000000000
          if num < to_big(e_switch_point or G.E_SWITCH_POINT) then
              return nf(num:to_number(), e_switch_point)
          else
            return Notations.Balatro:format(num, 3)
          end
      else return nf(num, e_switch_point) end
  end

  local mf = math.floor
  function math.floor(x)
      if type(x) == 'table' then return x:floor() end
      return mf(x)
  end

  local l10 = math.log10
  function math.log10(x)
      if type(x) == 'table' then return l10(math.min(x:to_number(),1e300)) end--x:log10() end
      return l10(x)
  end

  local lg = math.log
  function math.log(x, y)
      if not y then y = 2.718281828459045 end
      if type(x) == 'table' then return lg(math.min(x:to_number(),1e300),y) end --x:log(y) end
      return lg(x,y)
  end

  if SMODS then
    function SMODS.get_blind_amount(ante)
      local k = to_big(0.75)
      local scale = G.GAME.modifiers.scaling
      local amounts = {
          to_big(300),
          to_big(700 + 100*scale),
          to_big(1400 + 600*scale),
          to_big(2100 + 2900*scale),
          to_big(15000 + 5000*scale*math.log(scale)),
          to_big(12000 + 8000*(scale+1)*(0.4*scale)),
          to_big(10000 + 25000*(scale+1)*((scale/4)^2)),
          to_big(50000 * (scale+1)^2 * (scale/7)^2)
      }
      
      if ante < 1 then return to_big(100) end
      if ante <= 8 then 
        local amount = amounts[ante]
        if (amount:lt(R.E_MAX_SAFE_INTEGER)) then
          local exponent = to_big(10)^(math.floor(amount:log10() - to_big(1))):to_number()
          amount = math.floor(amount / exponent):to_number() * exponent
        end
        amount:normalize()
        return amount
       end
      local a, b, c, d = amounts[8], amounts[8]/amounts[7], ante-8, 1 + 0.2*(ante-8)
      local amount = math.floor(a*(b + (b*k*c)^d)^c)
      if (amount:lt(R.E_MAX_SAFE_INTEGER)) then
        local exponent = to_big(10)^(math.floor(amount:log10() - to_big(1))):to_number()
        amount = math.floor(amount / exponent):to_number() * exponent
      end
      amount:normalize()
      return amount
    end
  end
  -- There's too much to override here so we just fully replace this function
  -- Note that any ante scaling tweaks will need to manually changed...
  local gba = get_blind_amount
  function get_blind_amount(ante)
    if G.GAME.modifiers.scaling and G.GAME.modifiers.scaling > 3 then return SMODS.get_blind_amount(ante) end
    if type(to_big(1)) == 'number' then return gba(ante) end
      local k = to_big(0.75)
      if not G.GAME.modifiers.scaling or G.GAME.modifiers.scaling == 1 then 
        local amounts = {
          to_big(300),  to_big(800), to_big(2000),  to_big(5000),  to_big(11000),  to_big(20000),   to_big(35000),  to_big(50000)
        }
        if ante < 1 then return to_big(100) end
        if ante <= 8 then return amounts[ante] end
        local a, b, c, d = amounts[8],1.6,ante-8, 1 + 0.2*(ante-8)
        local amount = a*(b+(k*c)^d)^c
        if (amount:lt(R.E_MAX_SAFE_INTEGER)) then
          local exponent = to_big(10)^(math.floor(amount:log10() - to_big(1))):to_number()
          amount = math.floor(amount / exponent):to_number() * exponent
        end
        amount:normalize()
        return amount
      elseif G.GAME.modifiers.scaling == 2 then 
        local amounts = {
          to_big(300),  to_big(900), to_big(2600),  to_big(8000), to_big(20000),  to_big(36000),  to_big(60000),  to_big(100000)
          --300,  900, 2400,  7000,  18000,  32000,  56000,  90000
        }
        if ante < 1 then return to_big(100) end
        if ante <= 8 then return amounts[ante] end
        local a, b, c, d = amounts[8],1.6,ante-8, 1 + 0.2*(ante-8)
        local amount = a*(b+(k*c)^d)^c
        if (amount:lt(R.E_MAX_SAFE_INTEGER)) then
          local exponent = to_big(10)^(math.floor(amount:log10() - to_big(1))):to_number()
          amount = math.floor(amount / exponent):to_number() * exponent
        end
        amount:normalize()
        return amount
      elseif G.GAME.modifiers.scaling == 3 then 
        local amounts = {
          to_big(300),  to_big(1000), to_big(3200),  to_big(9000),  to_big(25000),  to_big(60000),  to_big(110000),  to_big(200000)
          --300,  1000, 3000,  8000,  22000,  50000,  90000,  180000
        }
        if ante < 1 then return to_big(100) end
        if ante <= 8 then return amounts[ante] end
        local a, b, c, d = amounts[8],1.6,ante-8, 1 + 0.2*(ante-8)
        local amount = a*(b+(k*c)^d)^c
        if (amount:lt(R.E_MAX_SAFE_INTEGER)) then
          local exponent = to_big(10)^(math.floor(amount:log10() - to_big(1))):to_number()
          amount = math.floor(amount / exponent):to_number() * exponent
        end
        amount:normalize()
        return amount
      end
    end

  function check_and_set_high_score(score, amt)
    if G.GAME.round_scores[score] and to_big(math.floor(amt)) > to_big(G.GAME.round_scores[score].amt) then
      G.GAME.round_scores[score].amt = to_big(math.floor(amt))
    end
    if  G.GAME.seeded  then return end
    --[[if G.PROFILES[G.SETTINGS.profile].high_scores[score] and math.floor(amt) > G.PROFILES[G.SETTINGS.profile].high_scores[score].amt then
      if G.GAME.round_scores[score] then G.GAME.round_scores[score].high_score = true end
      G.PROFILES[G.SETTINGS.profile].high_scores[score].amt = math.floor(amt)
      G:save_settings()
    end--]] --going to hold off on modifying this until proper save loading exists
  end

  local sn = scale_number
  function scale_number(number, scale, max, e_switch_point)
    if not Big then return sn(number, scale, max, e_switch_point) end
    scale = to_big(scale)
    G.E_SWITCH_POINT = G.E_SWITCH_POINT or 100000000000
    if not number or not is_number(number) then return scale end
    if not max then max = 10000 end
    if to_big(number).e and to_big(number).e == 10^1000 then
      scale = scale*math.floor(math.log(max*10, 10))/7
    end
    if to_big(number) >= to_big(e_switch_point or G.E_SWITCH_POINT) then
      if (to_big(to_big(number):log10()) <= to_big(999)) then
        scale = scale*math.floor(math.log(max*10, 10))/math.floor(math.log(1000000*10, 10))
      else
        scale = scale*math.floor(math.log(max*10, 10))/math.floor(math.max(7,string.len(number_format(number))-1))
      end
    elseif to_big(number) >= to_big(max) then
      scale = scale*math.floor(math.log(max*10, 10))/math.floor(math.log(number*10, 10))
    end
    return math.min(3, scale:to_number())
  end

  local tsj = G.FUNCS.text_super_juice
  function G.FUNCS.text_super_juice(e, _amount)
    if _amount > 2 then _amount = 2 end
    return tsj(e, _amount)
  end

  local max = math.max
  --don't return a Big unless we have to - it causes nativefs to break
  function math.max(x, y)
    if type(x) == 'table' or type(y) == 'table' then
    x = to_big(x)
    y = to_big(y)
    if (x > y) then
      return x
    else
      return y
    end
    else return max(x,y) end
  end

  local min = math.min
  function math.min(x, y)
    if type(x) == 'table' or type(y) == 'table' then
    x = to_big(x)
    y = to_big(y)
    if (x < y) then
      return x
    else
      return y
    end
    else return min(x,y) end
  end

  local sqrt = math.sqrt
  function math.sqrt(x)
    if type(x) == 'table' then
      if getmetatable(x) == BigMeta then return x:sqrt() end
      if getmetatable(x) == OmegaMeta then return x:pow(0.5) end
    end
    return sqrt(x)
  end

 

  local old_abs = math.abs
  function math.abs(x)
    if type(x) == 'table' then
    x = to_big(x)
    if (x < to_big(0)) then
      return -1 * x
    else
      return x
    end
    else return old_abs(x) end
  end
end

function is_number(x)
  if type(x) == 'number' then return true end
  if type(x) == 'table' and ((x.e and x.m) or (x.array and x.sign)) then return true end
  return false
end

function to_big(x, y)
  if Big and Big.m then
    return Big:new(x,y)
  elseif Big and Big.array then
    local result = Big:create(x)
    result.sign = y or result.sign or x.sign or 1
    return result
  elseif is_number(x) then
    return x * 10^(y or 0)

  elseif type(x) == "nil" then
    return 0
  else
    if ((#x>=2) and ((x[2]>=2) or (x[2]==1) and (x[1]>308))) then
      return 1e309
    end
    if (x[2]==1) then
      return math.pow(10,x[1])
    end
    return x[1]*(y or 1);
  end
end
function to_number(x)
  if type(x) == 'table' and (getmetatable(x) == BigMeta or getmetatable(x) == OmegaMeta) then
    return x:to_number()
  else
    return x
  end
end

--patch to remove animations
local cest = card_eval_status_text
function card_eval_status_text(a,b,c,d,e,f)
    if not Talisman.config_file.disable_anims then cest(a,b,c,d,e,f) end
end
local jc = juice_card
function juice_card(x)
    if not Talisman.config_file.disable_anims then jc(x) end
end
function tal_uht(config, vals)
    local col = G.C.GREEN
    if vals.chips and G.GAME.current_round.current_hand.chips ~= vals.chips then
        local delta = (is_number(vals.chips) and is_number(G.GAME.current_round.current_hand.chips)) and (vals.chips - G.GAME.current_round.current_hand.chips) or 0
        if to_big(delta) < to_big(0) then delta = number_format(delta); col = G.C.RED
        elseif to_big(delta) > to_big(0) then delta = '+'..number_format(delta)
        else delta = number_format(delta)
        end
        if type(vals.chips) == 'string' then delta = vals.chips end
        G.GAME.current_round.current_hand.chips = vals.chips
        if G.hand_text_area.chips.config.object then
          G.hand_text_area.chips:update(0)
        end
    end
    if vals.mult and G.GAME.current_round.current_hand.mult ~= vals.mult then
        local delta = (is_number(vals.mult) and is_number(G.GAME.current_round.current_hand.mult))and (vals.mult - G.GAME.current_round.current_hand.mult) or 0
        if to_big(delta) < to_big(0) then delta = number_format(delta); col = G.C.RED
        elseif to_big(delta) > to_big(0) then delta = '+'..number_format(delta)
        else delta = number_format(delta)
        end
        if type(vals.mult) == 'string' then delta = vals.mult end
        G.GAME.current_round.current_hand.mult = vals.mult
        if G.hand_text_area.mult.config.object then
          G.hand_text_area.mult:update(0)
        end
    end
    if vals.handname and G.GAME.current_round.current_hand.handname ~= vals.handname then
        G.GAME.current_round.current_hand.handname = vals.handname
    end
    if vals.chip_total then G.GAME.current_round.current_hand.chip_total = vals.chip_total;G.hand_text_area.chip_total.config.object:pulse(0.5) end
    if vals.level and G.GAME.current_round.current_hand.hand_level ~= ' '..localize('k_lvl')..tostring(vals.level) then
        if vals.level == '' then
            G.GAME.current_round.current_hand.hand_level = vals.level
        else
            G.GAME.current_round.current_hand.hand_level = ' '..localize('k_lvl')..tostring(vals.level)
            if type(vals.level) == 'number' then 
                G.hand_text_area.hand_level.config.colour = G.C.HAND_LEVELS[math.min(vals.level, 7)]
            else
                G.hand_text_area.hand_level.config.colour = G.C.HAND_LEVELS[1]
            end
        end
    end
    return true
end
local uht = update_hand_text
function update_hand_text(config, vals)
    if Talisman.config_file.disable_anims then
        if G.latest_uht then
          local chips = G.latest_uht.vals.chips
          local mult = G.latest_uht.vals.mult
          if not vals.chips then vals.chips = chips end
          if not vals.mult then vals.mult = mult end
        end
        G.latest_uht = {config = config, vals = vals}
    else uht(config, vals)
    end
end
local upd = Game.update
function Game:update(dt)
    upd(self, dt)
    if G.latest_uht and G.latest_uht.config and G.latest_uht.vals then
        tal_uht(G.latest_uht.config, G.latest_uht.vals)
        G.latest_uht = nil
    end
    if Talisman.dollar_update then
      G.HUD:get_UIE_by_ID('dollar_text_UI').config.object:update()
      G.HUD:recalculate()
      Talisman.dollar_update = false
    end
end
--scoring coroutine
local oldplay = G.FUNCS.evaluate_play

function G.FUNCS.evaluate_play()
    G.SCORING_COROUTINE = coroutine.create(oldplay)
    G.LAST_SCORING_YIELD = love.timer.getTime()
    G.CARD_CALC_COUNTS = {} -- keys = cards, values = table containing numbers
    local success, err = coroutine.resume(G.SCORING_COROUTINE)
    if not success then
      error(err)
    end
end


local oldupd = love.update
function love.update(dt, ...)
    oldupd(dt, ...)
    if G.SCORING_COROUTINE then
      if collectgarbage("count") > 1024*1024 then
        collectgarbage("collect")
      end
        if coroutine.status(G.SCORING_COROUTINE) == "dead" then
            G.SCORING_COROUTINE = nil
            G.FUNCS.exit_overlay_menu()
            local totalCalcs = 0
            for i, v in pairs(G.CARD_CALC_COUNTS) do
              totalCalcs = totalCalcs + v[1]
            end
            G.GAME.LAST_CALCS = totalCalcs
        else
            G.SCORING_TEXT = nil
            if not G.OVERLAY_MENU then
                G.scoring_text = {"Calculating...", "", "", ""}
                G.SCORING_TEXT = { 
                  {n = G.UIT.C, nodes = {
                    {n = G.UIT.R, config = {padding = 0.1, align = "cm"}, nodes = {
                    {n=G.UIT.O, config={object = DynaText({string = {{ref_table = G.scoring_text, ref_value = 1}}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 1, silent = true})}},
                    }},{n = G.UIT.R,  nodes = {
                    {n=G.UIT.O, config={object = DynaText({string = {{ref_table = G.scoring_text, ref_value = 2}}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4, silent = true})}},
                    }},{n = G.UIT.R,  nodes = {
                    {n=G.UIT.O, config={object = DynaText({string = {{ref_table = G.scoring_text, ref_value = 3}}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4, silent = true})}},
                    }},{n = G.UIT.R,  nodes = {
                    {n=G.UIT.O, config={object = DynaText({string = {{ref_table = G.scoring_text, ref_value = 4}}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4, silent = true})}},
                }}}}}
                G.FUNCS.overlay_menu({
                    definition = 
                    {n=G.UIT.ROOT, minw = G.ROOM.T.w*5, minh = G.ROOM.T.h*5, config={align = "cm", padding = 9999, offset = {x = 0, y = -3}, r = 0.1, colour = {G.C.GREY[1], G.C.GREY[2], G.C.GREY[3],0.7}}, nodes= G.SCORING_TEXT}, 
                    config = {align="cm", offset = {x=0,y=0}, major = G.ROOM_ATTACH, bond = 'Weak'}
                })
            else

                if G.OVERLAY_MENU and G.scoring_text then
                  local totalCalcs = 0
                  for i, v in pairs(G.CARD_CALC_COUNTS) do
                    totalCalcs = totalCalcs + v[1]
                  end
                  local jokersYetToScore = #G.jokers.cards + #G.play.cards - #G.CARD_CALC_COUNTS
                  G.scoring_text[1] = "Calculating..."
                  G.scoring_text[2] = "Elapsed calculations: "..tostring(totalCalcs)
                  G.scoring_text[3] = "Cards yet to score: "..tostring(jokersYetToScore)
                  G.scoring_text[4] = "Calculations last played hand: " .. tostring(G.GAME.LAST_CALCS or "Unknown")
                end

            end
			--this coroutine allows us to stagger GC cycles through
			--the main source of waste in terms of memory (especially w joker retriggers) is through local variables that become garbage
			--this practically eliminates the memory overhead of scoring
			--event queue overhead seems to not exist if Talismans Disable Scoring Animations is off.
			--event manager has to wait for scoring to finish until it can keep processing events anyways.

            
	          G.LAST_SCORING_YIELD = love.timer.getTime()
            
            local success, msg = coroutine.resume(G.SCORING_COROUTINE)
            if not success then
              error(msg)
            end
        end
    end
end



TIME_BETWEEN_SCORING_FRAMES = 0.03 -- 30 fps during scoring
-- we dont want overhead from updates making scoring much slower
-- originally 10 fps, I think 30 fps is a good way to balance it while making it look smooth, too
--wrap everything in calculating contexts so we can do more things with it
Talisman.calculating_joker = false
Talisman.calculating_score = false
Talisman.calculating_card = false
Talisman.dollar_update = false
local ccj = Card.calculate_joker
function Card:calculate_joker(context)
  --scoring coroutine
  G.CURRENT_SCORING_CARD = self
  G.CARD_CALC_COUNTS = G.CARD_CALC_COUNTS or {}
  if G.CARD_CALC_COUNTS[self] then
    G.CARD_CALC_COUNTS[self][1] = G.CARD_CALC_COUNTS[self][1] + 1
  else
    G.CARD_CALC_COUNTS[self] = {1, 1}
  end


  if G.LAST_SCORING_YIELD and ((love.timer.getTime() - G.LAST_SCORING_YIELD) > TIME_BETWEEN_SCORING_FRAMES) and coroutine.running() then
        coroutine.yield()
  end
  Talisman.calculating_joker = true
  local ret = ccj(self, context)

  if ret and type(ret) == "table" and ret.repetitions then
    G.CARD_CALC_COUNTS[ret.card] = G.CARD_CALC_COUNTS[ret.card] or {1,1}
    G.CARD_CALC_COUNTS[ret.card][2] = G.CARD_CALC_COUNTS[ret.card][2] + ret.repetitions
  end
  Talisman.calculating_joker = false
  return ret
end
local cuc = Card.use_consumable
function Card:use_consumable(x,y)
  Talisman.calculating_score = true
  local ret = cuc(self, x,y)
  Talisman.calculating_score = false
  return ret
end
local gfep = G.FUNCS.evaluate_play
G.FUNCS.evaluate_play = function(e)
  Talisman.calculating_score = true
  local ret = gfep(e)
  Talisman.calculating_score = false
  return ret
end
--[[local ec = eval_card
function eval_card()
  Talisman.calculating_card = true
  local ret = ec()
  Talisman.calculating_card = false
  return ret
end--]]
local sm = Card.start_materialize
function Card:start_materialize(a,b,c)
  if Talisman.config_file.disable_anims and (Talisman.calculating_joker or Talisman.calculating_score or Talisman.calculating_card) then return end
  return sm(self,a,b,c)
end
local sd = Card.start_dissolve
function Card:start_dissolve(a,b,c,d)
  if Talisman.config_file.disable_anims and (Talisman.calculating_joker or Talisman.calculating_score or Talisman.calculating_card) then self:remove() return end
  return sd(self,a,b,c,d)
end
local ss = Card.set_seal
function Card:set_seal(a,b,immediate)
  return ss(self,a,b,Talisman.config_file.disable_anims and (Talisman.calculating_joker or Talisman.calculating_score or Talisman.calculating_card) or immediate)
end

function Card:get_chip_x_bonus()
    if self.debuff then return 0 end
    if self.ability.set == 'Joker' then return 0 end
    if (self.ability.x_chips or 0) <= 1 then return 0 end
    return self.ability.x_chips
end

function Card:get_chip_e_bonus()
    if self.debuff then return 0 end
    if self.ability.set == 'Joker' then return 0 end
    if (self.ability.e_chips or 0) <= 1 then return 0 end
    return self.ability.e_chips
end

function Card:get_chip_ee_bonus()
    if self.debuff then return 0 end
    if self.ability.set == 'Joker' then return 0 end
    if (self.ability.ee_chips or 0) <= 1 then return 0 end
    return self.ability.ee_chips
end

function Card:get_chip_eee_bonus()
    if self.debuff then return 0 end
    if self.ability.set == 'Joker' then return 0 end
    if (self.ability.eee_chips or 0) <= 1 then return 0 end
    return self.ability.eee_chips
end

function Card:get_chip_hyper_bonus()
    if self.debuff then return {0,0} end
    if self.ability.set == 'Joker' then return {0,0} end
	if type(self.ability.hyper_chips) ~= 'table' then return {0,0} end
    if (self.ability.hyper_chips[1] <= 0 or self.ability.hyper_chips[2] <= 0) then return {0,0} end
    return self.ability.hyper_chips
end

function Card:get_chip_e_mult()
    if self.debuff then return 0 end
    if self.ability.set == 'Joker' then return 0 end
    if (self.ability.e_mult or 0) <= 1 then return 0 end
    return self.ability.e_mult
end

function Card:get_chip_ee_mult()
    if self.debuff then return 0 end
    if self.ability.set == 'Joker' then return 0 end
    if (self.ability.ee_mult or 0) <= 1 then return 0 end
    return self.ability.ee_mult
end

function Card:get_chip_eee_mult()
    if self.debuff then return 0 end
    if self.ability.set == 'Joker' then return 0 end
    if (self.ability.eee_mult or 0) <= 1 then return 0 end
    return self.ability.eee_mult
end

function Card:get_chip_hyper_mult()
    if self.debuff then return {0,0} end
    if self.ability.set == 'Joker' then return {0,0} end
	if type(self.ability.hyper_mult) ~= 'table' then return {0,0} end
    if (self.ability.hyper_mult[1] <= 0 or self.ability.hyper_mult[2] <= 0) then return {0,0} end
    return self.ability.hyper_mult
end

--Easing fixes
--Changed this to always work; it's less pretty but fine for held in hand things
local edo = ease_dollars
function ease_dollars(mod, instant)
  if Talisman.config_file.disable_anims then--and (Talisman.calculating_joker or Talisman.calculating_score or Talisman.calculating_card) then
    mod = mod or 0
    if mod < 0 then inc_career_stat('c_dollars_earned', mod) end
    G.GAME.dollars = G.GAME.dollars + mod
    Talisman.dollar_update = true
  else return edo(mod, instant) end
end

local su = G.start_up
function safe_str_unpack(str)
  local chunk, err = loadstring(str)
  if chunk then
    setfenv(chunk, {Big = Big, BigMeta = BigMeta, OmegaMeta = OmegaMeta, to_big = to_big, inf = 1.79769e308})  -- Use an empty environment to prevent access to potentially harmful functions
    local success, result = pcall(chunk)
    if success then
    return result
    else
    print("Error unpacking string: " .. result)
    return nil
    end
  else
    print("Error loading string: " .. err)
    return nil
  end
  end
function G:start_up()
  STR_UNPACK = safe_str_unpack
  su(self)
  STR_UNPACK = safe_str_unpack
end

--Skip round animation things
local gfer = G.FUNCS.evaluate_round
function G.FUNCS.evaluate_round()
    if Talisman.config_file.disable_anims then
      if to_big(G.GAME.chips) >= to_big(G.GAME.blind.chips) then
          add_round_eval_row({dollars = G.GAME.blind.dollars, name='blind1', pitch = 0.95})
      else
          add_round_eval_row({dollars = 0, name='blind1', pitch = 0.95, saved = true})
      end
      local arer = add_round_eval_row
      add_round_eval_row = function() return end
      local dollars = gfer()
      add_round_eval_row = arer
      add_round_eval_row({name = 'bottom', dollars = Talisman.dollars})
    else
        return gfer()
    end
end

--some debugging functions
--[[local callstep=0
function printCallerInfo()
  -- Get debug info for the caller of the function that called printCallerInfo
  local info = debug.getinfo(3, "Sl")
  callstep = callstep+1
  if info then
      print("["..callstep.."] "..(info.short_src or "???")..":"..(info.currentline or "unknown"))
  else
      print("Caller information not available")
  end
end
local emae = EventManager.add_event
function EventManager:add_event(x,y,z)
  printCallerInfo()
  return emae(self,x,y,z)
end--]]
