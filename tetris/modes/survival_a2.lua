require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local History6RollsRandomizer = require 'tetris.randomizers.history_6rolls'

local SurvivalA2Game = GameMode:extend()

SurvivalA2Game.name = "Survival A2"
SurvivalA2Game.hash = "SurvivalA2"
SurvivalA2Game.tagline = "The game starts fast and only gets faster!"

SurvivalA2Game.arr = 1
SurvivalA2Game.drop_speed = 1

function SurvivalA2Game:new()
	SurvivalA2Game.super:new()
	self.roll_frames = 0
	self.combo = 1
	self.randomizer = History6RollsRandomizer()

	self.lock_drop = true
end

function SurvivalA2Game:getARE()
		if self.level < 100 then return 18
	elseif self.level < 300 then return 14
	elseif self.level < 400 then return 8
	elseif self.level < 500 then return 7
	else return 6 end
end

function SurvivalA2Game:getLineARE()
		if self.level < 100 then return 14
	elseif self.level < 400 then return 8
	elseif self.level < 500 then return 7
	else return 6 end
end

function SurvivalA2Game:getDasLimit()
		if self.level < 200 then return 11
	elseif self.level < 300 then return 10
	elseif self.level < 400 then return 9
	else return 7 end
end

function SurvivalA2Game:getLineClearDelay()
	return self:getLineARE() - 2
end

function SurvivalA2Game:getLockDelay()
		if self.level < 100 then return 30
	elseif self.level < 200 then return 26
	elseif self.level < 300 then return 22
	elseif self.level < 400 then return 18
	else return 15 end
end

function SurvivalA2Game:getGravity()
	return 20
end

function SurvivalA2Game:hitTorikan(old_level, new_level)
	if old_level < 500 and new_level >= 500 and self.frames > sp(3,25) then
		self.level = 500
		return true
	end
	return false
end

function SurvivalA2Game:advanceOneFrame()
	if self.clear then
		self.roll_frames = self.roll_frames + 1
		if self.roll_frames > 2968 then
			self.completed = true
		end
	elseif self.ready_frames == 0 then
		self.frames = self.frames + 1
	end
	return true
end

function SurvivalA2Game:onPieceEnter()
	if (self.level % 100 ~= 99 or self.level == 998) and not self.clear and self.frames ~= 0 then
		self.level = self.level + 1
	end
end

function SurvivalA2Game:onLineClear(cleared_row_count)
	if not self.clear then
		local new_level = math.min(self.level + cleared_row_count, 999)
		if self.level == 999 or self:hitTorikan(self.level, new_level) then
			self.clear = true
		else
			self.level = new_level
		end
	end
end

function SurvivalA2Game:updateScore(level, drop_bonus, cleared_lines)
	if cleared_lines > 0 then
		self.score = self.score + (
			(math.ceil((level + cleared_lines) / 4) + drop_bonus) *
			cleared_lines * (cleared_lines * 2 - 1) * self.combo
		)
		self.lines = self.lines + cleared_lines
		self.combo = self.combo + (cleared_lines - 1) * 2
	else
		self.drop_bonus = 0
		self.combo = 1
	end
end

function SurvivalA2Game:getLetterGrade()
		if self.level >= 999 then return "GM"
	elseif self.level >= 500 then return "M" 
	else return "" end
end

function SurvivalA2Game:drawGrid()
	self.grid:draw()
end

function SurvivalA2Game:drawScoringInfo()
	SurvivalA2Game.super.drawScoringInfo(self)
	love.graphics.setColor(1, 1, 1, 1)

	local text_x = config["side_next"] and 320 or 240
	
	love.graphics.setFont(font_3x5_2)
	love.graphics.print(
		self.das.direction .. " " ..
		self.das.frames .. " " ..
		st(self.prev_inputs)
	)
	love.graphics.printf("NEXT", 64, 40, 40, "left")
	love.graphics.printf("GRADE", text_x, 120, 40, "left")
	love.graphics.printf("SCORE", text_x, 200, 40, "left")
	love.graphics.printf("LEVEL", text_x, 320, 40, "left")

	love.graphics.setFont(font_3x5_3)
	love.graphics.printf(self.score, text_x, 220, 90, "left")
	love.graphics.printf(self:getLetterGrade(), text_x, 140, 90, "left")
	love.graphics.printf(self.level, text_x, 340, 40, "right")
	love.graphics.printf(self:getSectionEndLevel(), text_x, 370, 40, "right")
end

function SurvivalA2Game:getSectionEndLevel()
	if self.clear then return self.level
	elseif self.level > 900 then return 999
	else return math.floor(self.level / 100 + 1) * 100 end
end

function SurvivalA2Game:getBackground()
	return math.floor(self.level / 100)
end

function SurvivalA2Game:getHighscoreData()
	return {
		level = self.level,
		frames = self.frames,
	}
end

return SurvivalA2Game
