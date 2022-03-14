GAME_VERSION = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

cf = require 'lib.commonfunctions'


Slab = require 'lib.Slab.Slab'
-- https://github.com/coding-jackalope/Slab/wiki

Nativefs = require 'lib.nativefs'
-- https://github.com/megagrump/nativefs

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

TIMER_SETTING = 5 -- 30 mins * 60 seconds = 1800
TIMER = TIMER_SETTING

local function SaveRecent()
	local savefile
	local success, message
	local savedir = love.filesystem.getSource()

	local savestring = PERSON_NAME .. ";" .. ACTIVITY .. ";" .. FOLDER
    savefile = savedir .. "/recent.dat"
    success, message = Nativefs.write(savefile, savestring)
end

local function LoadRecent()
	local savedir = love.filesystem.getSource()
    love.filesystem.setIdentity( savedir )

    local savefile, contents

    savefile = savedir .. "/recent.dat"
    contents, _ = Nativefs.read(savefile)

	local pos1 = string.find(contents, ";")
	local pos2 = string.find(contents, ";", pos1 + 1)

	PERSON_NAME = string.sub(contents, 1, pos1 - 1)
	ACTIVITY = string.sub(contents, pos1 + 1, pos2 - 1)
	FOLDER = string.sub(contents, pos2 + 1)

	print("Just loaded " .. PERSON_NAME, ACTIVITY, FOLDER)
end

function DrawForm()

	local intSlabWidth = 300 -- the width of the main menu slab. Change this to change appearance.
	local intSlabHeight = 300 	-- the height of the main menu slab
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
	Slab.BeginLayout("MMLayout",{AlignX="center",AlignY="center",AlignRowY="center",ExpandW=false,Columns = 1})

	Slab.SetLayoutColumn(1)

	Slab.Text("Your name:")
	Slab.SameLine()
	if Slab.Input('Name', {Text = PERSON_NAME}) then
		PERSON_NAME = Slab.GetInputText()
	end

	Slab.Text("Recent activity:")
	Slab.SameLine()
	if Slab.Input('Activity', {Text = ACTIVITY}) then
		ACTIVITY = Slab.GetInputText()
	end

	Slab.Text("Source folder:")
	Slab.SameLine()
	if Slab.Input('Folder', {Text = FOLDER}) then
		FOLDER = Slab.GetInputText()
	end

	Slab.Text("Productivity")
	-- Slab.Text("100%")
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
		Checked25 = not Checked25
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
		SaveRecent()
	end


	if Slab.Button("Save and quit",{W=155}) then
		SaveRecent()
		love.event.quit()
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
    end

	love.window.setTitle("Time Log " .. GAME_VERSION)
	love.graphics.setBackgroundColor(0.4, 0.88, 1.0)

	-- cf.AddScreen("MainMenu", SCREEN_STACK)

	-- Initalize GUI Library
	Slab.Initialize()

	LoadRecent()

end


function love.draw()

    res.start()
	Slab.Draw()
    res.stop()
end

function love.update(dt)

	res.update()
	Slab.Update(dt)

	TIMER = TIMER - dt
	if TIMER <= 0 then
		DrawForm()
	end
end
