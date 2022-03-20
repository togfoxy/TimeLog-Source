GAME_VERSION = "0.04"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

cf = require 'lib.commonfunctions'


Slab = require 'lib.Slab.Slab'
-- https://github.com/coding-jackalope/Slab/wiki

Nativefs = require 'lib.nativefs'
-- https://github.com/megagrump/nativefs

SCREEN_WIDTH = 500	-- 500
SCREEN_HEIGHT = 350	-- 350

TIMER_SETTING = 1200 -- 20 mins * 60 seconds = 1200
TIMER = 0			-- timer counts up from zero

savefile = love.filesystem.getSourceBaseDirectory( ) .. "/recent.dat"

local function SaveData()
	-- local savefile
	local savedir = love.filesystem.getSourceBaseDirectory( )

	savestring = PERSON_NAME .. ";" .. ACTIVITY .. ";" .. FOLDER
    -- savefile = savedir .. "/recent.dat"
    success, message = Nativefs.write(savefile, savestring)

	logfile = FOLDER .. "\\" .. PERSON_NAME .. "TimeLog"
	logfile = logfile .. ".csv"

	local timespent = cf.round(TIMER)
	if OVERRIDE ~= nil then timespent = OVERRIDE end

	savestring = os.date() .. "," .. PERSON_NAME .. "," .. ACTIVITY .. "," .. timespent
	if Checked100 then
		savestring = savestring .. "," .. timespent
	elseif Checked75 then
		savestring = savestring .. "," .. timespent * 0.75
	elseif Checked50 then
		savestring = savestring .. "," .. timespent * 0.50
	elseif Checked25 then
		savestring = savestring .. "," .. timespent * 0.25
	elseif Checked0 then
		savestring = savestring .. "," .. timespent * 0
	else
		error()
	end

	savestring = savestring .. "\n"
	success, message = Nativefs.append(logfile, savestring)

	if not success then wrongsound:play() end

	TIMER = 0
	OVERRIDE = nil
end

local function LoadData()
	-- local savedir = love.filesystem.getSourceBaseDirectory( )
    local contents

    -- savefile = savedir .. "/recent.dat"
    contents, _ = Nativefs.read(savefile)

	if contents ~= nil then

		local pos1 = string.find(contents, ";")
		local pos2 = string.find(contents, ";", pos1 + 1)

		PERSON_NAME = string.sub(contents, 1, pos1 - 1)
		ACTIVITY = string.sub(contents, pos1 + 1, pos2 - 1)
		FOLDER = string.sub(contents, pos2 + 1)
	end
end

function CheckBoxActive()
	if Checked100 or Checked75 or Checked50 or Checked25 or Checked0 then
		return true
	else
		return false
	end
end

function DrawForm()

	local intSlabWidth = SCREEN_WIDTH * 0.9 -- the width of the main menu slab. Change this to change appearance.
	local intSlabHeight = SCREEN_HEIGHT * 0.9	-- the height of the main menu slab
	local fltSlabWindowX = love.graphics.getWidth() / 2 - intSlabWidth / 2
	local fltSlabWindowY = love.graphics.getHeight() / 2 - intSlabHeight / 2

	local FormOptions = {
		Title = "Main menu " .. GAME_VERSION,
		X = fltSlabWindowX,
		Y = fltSlabWindowY,
		W = intSlabWidth,
		H = intSlabHeight,
		Border = 5,
		AutoSizeWindow=false,
		AllowMove=false,
		AllowResize=false,
		NoSavedSettings=true
	}

	Slab.BeginWindow('MainMenu', FormOptions)

	Slab.BeginLayout("MMLayout",{AlignX="right",AlignY="top",AlignRowY="center",ExpandW=false,Columns = 2})
	Slab.SetLayoutColumn(1)

	Slab.Text("Seconds:")

	Slab.Text("Your name:")

	Slab.Text("Recent activity:")

	Slab.Text("Source folder:")

	Slab.Text("Over-ride:")

	Slab.SetLayoutColumn(2)

	Slab.Textf(cf.round(TIMER), {Align="center"})

	if Slab.Input('Name', {Text = PERSON_NAME, W=200}) then
		PERSON_NAME = Slab.GetInputText()
	end

	if Slab.Input('Activity', {Text = ACTIVITY, W=200}) then
		ACTIVITY = Slab.GetInputText()
	end
	if Slab.Input('Folder', {Text = FOLDER, W=200}) then
		FOLDER = Slab.GetInputText()
	end

	if Slab.Input('override', {Text = OVERRIDE}) then
		OVERRIDE = Slab.GetInputText()
	end

	Slab.EndLayout()

	Slab.BeginLayout("ButtonLayout",{AlignX="center",AlignY="top",AlignRowY="center",ExpandW=false,Columns = 1})

	Slab.Text("Productivity")

	if Slab.CheckBox(Checked100, "100%") then
		Checked100 = not Checked100
		Checked75 = false
		Checked50 = false
		Checked25 = false
		Checked0 = false
	end

	-- Slab.Text("75%")
	if Slab.CheckBox(Checked75, "75%") then
		Checked75 = not Checked75
		Checked100 = false
		Checked50 = false
		Checked25 = false
		Checked0 = false
	end

	-- Slab.Text("50%")
	if Slab.CheckBox(Checked50, "50%") then
		Checked50 = not Checked50
		Checked75 = false
		Checked100 = false
		Checked25 = false
		Checked0 = false
	end

	-- Slab.Text("25%")
	if Slab.CheckBox(Checked25, "25%") then
		Checked25 = false
		Checked75 = false
		Checked50 = false
		Checked100 = false
		Checked0 = false
	end

	-- Slab.Text("0%")
	if Slab.CheckBox(Checked0, "0%") then
		Checked0 = not Checked0
	end

	if Slab.Button("Save",{W=155}) then
		if CheckBoxActive() then
			SaveData()
		end
	end

	if Slab.Button("Save and quit",{W=155}) then
		if CheckBoxActive() then
			SaveData()
			love.event.quit()
		end
	end

	Slab.EndLayout()
	Slab.EndWindow()
end

function love.load()

	res.setGame(SCREEN_WIDTH, SCREEN_HEIGHT)

    if love.filesystem.isFused( ) then
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
        gbolDebug = false
    else
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
		TIMER_SETTING = 5
    end

	love.window.setTitle("Time Log " .. GAME_VERSION)
	love.graphics.setBackgroundColor(0, 0, 0)

	-- cf.AddScreen("MainMenu", SCREEN_STACK)

	-- Initalize GUI Library
	Slab.Initialize()

	sound = love.audio.newSource("ding.ogg", "static")
	wrongsound = love.audio.newSource("wrong.mp3", "static")

	LoadData()

end


function love.draw()

    res.start()
	love.graphics.setColor(1,1,1,1)
	love.graphics.print(logfile or "",30,50)
	love.graphics.print(savestring or "",30,70)
	love.graphics.print(tostring(success) or "",30,90)
	love.graphics.print(message or "",30,110)


	Slab.Draw()
    res.stop()
end

function love.update(dt)

	res.update()
	Slab.Update(dt)

	DrawForm()

	TIMER = TIMER + dt
	if TIMER >= TIMER_SETTING then
		--! make sound
		sound:play()
	end
end
