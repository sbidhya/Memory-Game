-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
--setting the screen width and height to variable
width  = display.contentWidth
height = display.contentHeight
display.setDefault( "background", 0.1,0.1,0.2,0.4)
display.setStatusBar(display.HiddenStatusBar)

--defines gap between rectangles
gap = 10
scorebarGap =0
--finding height and width of each 
--rectangle using gap and number 
--of total rectangles
rectH = (height-3*gap-scorebarGap)/4
rectW = (width-2*gap)/3

--table to store x,y of each rectangles
rectTable = {}
local index=1
--filling the x, y of each rectangles
for i=1,4 do
	for j=1,3 do
		rectTable[index] = {}
		rectTable[index]["x"] = rectW/2 + (j-1)*(rectW + 10)
		rectTable[index]["y"] = rectH/2 + (i-1)*(rectH + 10)
		index = index + 1
	end
end

--Creates the welcome screen
--The welcome screen consists of
--button and three text
function welcomeScreen()
	--Button rectangle
	local buttonRect = display.newRoundedRect( width/2, height/2, 120, 50, 10 ) 
	--displays the text "Start"
	local startText = display.newText( "Start", width/2, height/2, native.systemFontBold, 25) 
	-- displays game name
	local welcomeText = display.newText("Memory Game", width/2, height/2-100, native.systemFont, 45) 
	-- displays Bid Sharma at the bottom
	local myName = display.newText("Bid Sharma \nSarvagya Pant", width/2, height, native.systemFontBold, 15) 

	--adding colors to above rect and text
	buttonRect:setFillColor( 144/255,12/255,63/255)
	welcomeText:setFillColor( 238/255,200/255,210/255 )
	myName:setFillColor( 238/255,200/255,210/255)

	--Tap listener that indicates the beginning of game play
	buttonRect:addEventListener( "tap", beginGamePlay)

	--Creating a group called welcomegroup and adding all above display object to it
	welcomeGroup = display.newGroup()
	welcomeGroup:insert( 1, buttonRect)
	welcomeGroup:insert( 2, startText)
	welcomeGroup:insert( 3, welcomeText)
	welcomeGroup:insert( 4, myName)
end

--Makes every display object in welcomgroup invisible
--and starts the game
function beginGamePlay(event)
	--Makes every display object in welcomgroup invisible
	welcomeGroup.isVisible = false
	drawRect()
	return true
end

--This function displays score if shapesleft count is zero
--After displaying for 2 secs it goes to home screen
function display_score(shapesLeft, retry)
	-- body
	if(shapesLeft == 0) then
		cardGroup.isVisible = false
		local msg = "Congratulations !!!\n           You won. \n\n Total time played: " .. timerText.text
		local tText = display.newText( msg,width/2,height/2,native.systemFontBold,20)
		tText:setFillColor( 238/255,200/255,210/255 )
		local holdTime = timer.performWithDelay(2000,
		function ()
			timer.cancel(timeKeeper)
			tText:removeSelf()
			welcomeGroup:removeSelf()
			cardGroup:removeSelf()
			welcomeScreen()
		end,1)
	end
end

--Card click event handler
function cardEvent(event)
	if("began" == event.phase and shapesLeft > 0) then
		--current clicked index value
		local clickedIndex = event.target.selectedIndex
		--currnect clicked name value
		local clickedName = event.target.name
		local fname = clickedIndex..".png"	
		local scaleV = 0.05
		--check if previous and current clicked are different cards 
		--if they have same shape then make them dissapper
		--else set the current clicked properties as previous 
		if (clickedIndex == previousSelection and previousName ~= clickedName) then

			event.target.fill = { type = "image",filename = fname}
			local to_remove = previousTarget
			previousSelection = -1
			previousName = -1
			previousTarget = nil
			score = score + 1
			shapesLeft = shapesLeft - 2

			local pauseT = timer.performWithDelay(500,
			function ()
				event.target:removeSelf()
				to_remove:removeSelf()
				display_score(shapesLeft, retry)
			end,1)

		else 
			--if different cards are selected
			--fill the new clicked card with image
			--and then scale back the previous card to orginal size
			event.target.fill = { type = "image",filename = fname}
			transition.scaleBy(event.target, { xScale=0.05, yScale=0.05, time=600})

			if (previousSelection > -1) then
				transition.scaleBy(previousTarget, { xScale=-0.05, yScale=-0.05, time=300})
				previousTarget.fill = {214/255,112/255,66/255}
			end
			--save current state for next use
			previousSelection = clickedIndex
			previousName = clickedName
			previousTarget = event.target
			retry = retry + 1
		end

	end
	-- return true
end


--This function draws card and assigns each of them to a
--random shape
function drawRect()
	--group holding all the display object in play scene
	cardGroup = display.newGroup()
	--all shapes 
	local shapes = {1,1,2,2,3,3,4,4,5,5,6,6}
	--initialize variables for gameplay
	previousSelection = -1
	previousTarget = nil
	previousName = -1
	retry = 0
	score = 0
	shapesLeft = 12

	-- body
	--draw rect and assign random shapes to each
	for i=1,12 do
		local rect = display.newRect( rectTable[i]["x"], rectTable[i]["y"], rectW, rectH )
		rect:setFillColor(214/255,112/255,66/255)
		local shapesLen = table.getn(shapes)
		local randomIndex = math.random(1,shapesLen)
		local shape = shapes[randomIndex]
		table.remove(shapes, randomIndex)
		rect.selectedIndex = shape
		rect.name = i
		rect:addEventListener( "touch", cardEvent )
		cardGroup:insert( i, rect)
	end
	--Displays Time : text
	local tText = display.newText( "Time:", 25,-25,native.systemFontBold,20)
	tText:setFillColor( 238/255,200/255,210/255 )
	cardGroup:insert(tText)
	--Displays the actual time of game play
	timerText = display.newText( "00", 80,-25,native.systemFontBold,20)
	timerText:setFillColor( 238/255,200/255,210/255 )
	cardGroup:insert(timerText)
	--Timer function that keeps the time ticking
	timeKeeper = timer.performWithDelay( 1000, 
	function ()
		timerText.text = timerText.text + 1;
	end,0)

end

welcomeScreen()

