GAME_VERSION = "0.02"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

cf = require 'lib.commonfunctions'


Slab = require 'lib.Slab.Slab'
-- https://github.com/coding-jackalope/Slab/wiki

Nativefs = require 'lib.nativefs'
-- https://github.com/megagrump/nativefs

SCREEN_WIDTH = 230
SCREEN_HEIGHT = 280

TIMER_SETTING = 1200 -- 20 mins * 60 seconds = 1200
TIMER = 0			-- timer counts up from zero

local function SaveData()
	local savefile
	local success, message
	local savedir = love.filesystem.getSource()

	local savestring = PERSON_NAME .. ";" .. ACTIVITY .. ";" .. FOLDER
    savefile = savedir .. "/recent.dat"
    success, message = Nativefs.write(savefile, savestring)

	local logfile = FOLDER .. "/" .. PERSON_NAME .. "TimeLog.csv"
	local savestring = os.date() .. "," .. PERSON_NAME .. "," .. ACTIVITY .. "," .. cf.round(TIMER)
	if Checked100 then
		savestring = savestring .. "," .. cf.round(TIMER)
	elseif Checked75 then
		savestring = savestring .. "," .. cf.round(TIMER * 0.75)
	elseif Checked50 then
		savestring = savestring .. "," .. cf.round(TIMER * 0.50)
	elseif Checked25 then
		savestring = savestring .. "," .. cf.round(TIMER * 0.25)
	elseif Checked0 then
		savestring = savestring .. "," .. cf.round(TIMER * 0)
	else
		error()
	end

	savestring = savestring .. "\n"
	success, message = Nativefs.append(logfile, savestring)

	TIMER = 0
end

local function LoadData()
	local savedir = love.filesystem.getSource()
    love.filesystem.setIdentity( savedir )

    local savefile, contents

    savefile = savedir .. "/recent.dat"
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

	local intSlabWidth = 225 -- the width of the main menu slab. Change this to change appearance.
	local intSlabHeight = 275 	-- the height of the main menu slab
	local fltSlabWindowX = love.graphics.getWidth() / 2 - intSlabWidth / 2
	local fltSlabWindowY = love.graphics.getHeight() / 2 - intSlabHeight / 2

	local FormOptions = {
		Title = "Main menu " .. GAME_VERSION,
		X = fltSlabWindowX,
		Y = fltSlabWindowY,
		W = intSlabWidth,
		H = intSlabHeight,
		Border = 0,
		AutoSizeWindow=false,
		AllowMove=false,
		AllowResize=false,
		NoSavedSettings=true
	}

	Slab.BeginWindow('MainMenu', FormOptions)
	Slab.BeginLayout("TimerLayout",{AlignX="center",AlignY="top",AlignRowY="center",ExpandW=false,Columns = 1})

	Slab.Textf(cf.round(TIMER), {Align="center"})
	--Slab.NewLine()

	Slab.EndLayout()

	Slab.BeginLayout("MMLayout",{AlignX="center",AlignY="top",AlignRowY="center",ExpandW=false,Columns = 2})
	Slab.SetLayoutColumn(1)

	Slab.Text("Your name:")

	Slab.Text("Recent activity:")

	Slab.Text("Source folder:")

	Slab.SetLayoutColumn(2)
	if Slab.Input('Name', {Text = PERSON_NAME}) then
		PERSON_NAME = Slab.GetInputText()
	end

	if Slab.Input('Activity', {Text = ACTIVITY}) then
		ACTIVITY = Slab.GetInputText()
	end
	if Slab.Input('Folder', {Text = FOLDER}) then
		FOLDER = Slab.GetInputText()
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
	love.graphics.setBackgroundColor(0.4, 0.88, 1.0)

	-- cf.AddScreen("MainMenu", SCREEN_STACK)

	-- Initalize GUI Library
	Slab.Initialize()

	sound = love.audio.newSource("ding.ogg", "static")

	LoadData()

end


function love.draw()

    res.start()
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
