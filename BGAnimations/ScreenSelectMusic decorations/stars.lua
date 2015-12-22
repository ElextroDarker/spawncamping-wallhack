local update = false
local t = Def.ActorFrame{
	BeginCommand=cmd(queuecommand,"Set");
	OffCommand=cmd(bouncebegin,0.2;xy,-500,0;diffusealpha,0;); -- visible(false) doesn't seem to work with sleep
	OnCommand=cmd(bouncebegin,0.2;xy,0,0;diffusealpha,1;);
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 0 then
			self:queuecommand("On");
			update = true
		else 
			self:queuecommand("Off");
			update = false
		end;
	end;
	TabChangedMessageCommand=cmd(queuecommand,"Set");
	PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
};

-- ohlookpso2stars
-- this became a mess rather quickly

local starsX = 10
local starsY = 110+capWideScale(get43size(120),120)
local maxStars = 18
local starDistX = capWideScale(get43size(23)-1,23)
local starDistY = 0
local starSize = 0.55
local playerDistY = 95
local frameWidth = capWideScale(get43size(455),455)
	
local song

local stepsP1
local stepsP2

local profileP1
local profileP2

local topScoreP1
local topScoreP2

local hsTableP1
local hsTableP2

function stars(ind,pn)
	return LoadActor("ossstar")..{
		InitCommand=cmd(xy,starsX+43+(ind*starDistX),starsY+2+(ind*starDistY););
		SetCommand=function(self)
			if update then
				local diff = 0;
				local steps = GAMESTATE:GetCurrentSteps(pn);
				local enabled = GAMESTATE:IsPlayerEnabled(pn);
				self:finishtweening();
				self:stopeffect();
				if enabled and pn == PLAYER_2 then
					self:y(starsY+(ind*starDistY)+playerDistY+2);
				end;
				if enabled and steps ~= nil then
					diff = steps:GetMeter() or 0;
					self:visible(true);
					self:zoom(0);
					self:rotationz(0);
					self:diffuse(color("#FFFFFF"))
					if ind < diff then
						self:sleep((ind/math.min(diff,maxStars))/2);
						self:decelerate(0.5);
						self:zoom(starSize);
						self:rotationz(360);
					else
						self:visible(false);
					end;
					if ind < 3 then
						self:diffuse(getVividDifficultyColor('Difficulty_Beginner'))
					elseif ind < 6 then
						self:diffuse(getVividDifficultyColor('Difficulty_Easy'))
					elseif ind < 9 then
						self:diffuse(getVividDifficultyColor('Difficulty_Medium'))
					elseif ind < 12 then
						self:diffuse(getVividDifficultyColor('Difficulty_Hard'))
					elseif ind < 15 then
						self:diffuseshift()
						self:effectcolor1(color("#eeddff"))
						self:effectcolor2(color("#EE82EE"))
						self:effectperiod(2)
					else
						self:diffuse(color("#FFFFFF"))
						self:effectcolor1(color("#FFFFFF"))
						self:effectcolor2(color('Difficulty_Challenge'))
						self:glowshift()
						self:effectperiod(0.5)
					end;
				else
					self:visible(false);
				end;
			else
				self:visible(false);
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		CurrentStepsP1ChangedMessageCommand=function(self)
			if pn == PLAYER_1 then
				self:playcommand("Set")
			end;
		end;
		CurrentStepsP2ChangedMessageCommand=function(self)
			if pn == PLAYER_2 then
				self:playcommand("Set")
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Set")
			end;
		end;
		PlayerUnjoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:visible(false);
			end;
		end;
	};
end;



--Things i need: 
-- Grades, Clearlamp, 3 scores, max score 
t[#t+1] = Def.Actor{
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
		if update then
			song = GAMESTATE:GetCurrentSong()
			if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
				profileP1 = GetPlayerOrMachineProfile(PLAYER_1)
				stepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1)
				hsTableP1 = getScoreList(PLAYER_1)
				if hsTableP1 ~= nil then
					topScoreP1 = getScoreFromTable(hsTableP1,1)
				end;
			end;
			if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
				profileP2 = GetPlayerOrMachineProfile(PLAYER_2)
				stepsP2 = GAMESTATE:GetCurrentSteps(PLAYER_2)
				hsTableP2 = getScoreList(PLAYER_2)
				if hsTableP2 ~= nil then
					topScoreP2 = getScoreFromTable(hsTableP2,1)
				end;
			end;
		end;
	end;
	CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(playcommand,"Set");
	CurrentStepsP2ChangedMessageCommand=cmd(playcommand,"Set");
}

t[#t+1] = Def.ActorFrame{
	Name="StatFrame1P";
	BeginCommand=function(self)
		if GAMESTATE:IsHumanPlayer(PLAYER_1) then
			self:visible(true)
		else
			self:visible(false)
		end;
	end;
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_1 then
			self:visible(true);
		end;
	end;
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_1 then
			self:visible(false);
		end;
	end;
	--Upper Bar
	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY-18;zoomto,frameWidth,30;halign,0;valign,0;diffuse,color("#333333CC"));
	};
	--Lower Bar
	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY+18;zoomto,frameWidth,50;halign,0;valign,0;diffuse,color("#333333CC"));
	};

	--OverBar
	Def.Quad{
		Name = "FrameMouseOver1P";
		InitCommand=cmd(xy,starsX+5,starsY+18;zoomto,110,35;halign,0;valign,0;diffusealpha,0);
	};

	--===Upper Bar Stuff===--

	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY-18;zoomto,8,30;halign,0;valign,0;diffuse,color("#FFFFFF"));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				self:diffuse(getHighestClearType(PLAYER_1,0,2))
			end
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};

	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY-18;zoomto,8,30;halign,0;valign,0;diffuse,color("#FFFFFF"));
		BeginCommand=function(self)
			self:diffuseramp()
			self:effectcolor2(color("1,1,1,0.6"))
			self:effectcolor1(color("1,1,1,0"))
			self:effecttiming(2,1,0,0)
		end;
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+13,starsY-12;zoom,0.3;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local diff;
				local stype;
				local notes = 0
				local holds = 0
				local rolls = 0
				local mines = 0
				local lifts = 0
				local test1,test2
				if stepsP1 ~= nil then
					notes = stepsP1:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Notes")
					holds = stepsP1:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Holds")
					rolls = stepsP1:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Rolls")
					mines = stepsP1:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Mines")
					lifts = stepsP1:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Lifts")
					diff = getDifficulty(stepsP1:GetDifficulty())
					stype = ToEnumShortString(stepsP1:GetStepsType()):gsub("%_"," ")

					self:settextf("%s %s // Notes:%s // Holds:%s // Rolls:%s // Mines:%s // Lifts:%s",stype,diff,notes,holds,rolls,mines,lifts);
				else
					self:settext("Disabled");
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+frameWidth-5,starsY-12;zoom,0.3;halign,1);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local text = "Player 1"
			if profileP1 ~= nil then
				text = profileP1:GetDisplayName()
			end
			self:settext(text)
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+21,starsY+2;zoom,0.6;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local diff = 0;
				local enabled = GAMESTATE:IsPlayerEnabled(PLAYER_1);
				if enabled and stepsP1 ~= nil then
					diff = stepsP1:GetMeter() or 0;
					self:settext(diff);
				else
					self:settext(0);
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};

	--Grades
	LoadFont("Common Large")..{
		InitCommand=cmd(xy,starsX+60,starsY+35;zoom,0.6;maxwidth,110/0.6);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				self:settext(THEME:GetString("Grade",ToEnumShortString(getBestGrade(PLAYER_1,0))))
				self:diffuse(getGradeColor(getBestGrade(PLAYER_1,0)))
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--ClearType
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+60,starsY+58;zoom,0.5;maxwidth,110/0.5);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				self:settext(getHighestClearType(PLAYER_1,0,0))
				self:diffuse(getHighestClearType(PLAYER_1,0,2))
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	-- Percentage Score
	LoadFont("Common Large")..{
		InitCommand=cmd(xy,starsX+195,starsY+30;zoom,0.45;halign,1;maxwidth,75/0.45);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local score = getBestScore(PLAYER_1,0,0)
				local maxscore = getMaxScore(PLAYER_1,0)
				if maxscore == 0 or maxscore == nil then
					maxscore = 1
				end;
				local pscore = (score/maxscore)

				self:settextf("%05.2f%%",math.floor((pscore)*10000)/100)
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--Player DP/Exscore / Max DP/Exscore
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+182,starsY+48;zoom,0.5;halign,1;maxwidth,60/0.5);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local score = string.format("%04d",getBestScore(PLAYER_1,0,0))
				local maxscore = string.format("%04d",getMaxScore(PLAYER_1,0))
				self:settext(score.."/"..maxscore)
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--ScoreType superscript(?)
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+183,starsY+47;zoom,0.3;halign,0;);
		BeginCommand=function(self)
			self:settext(getScoreTypeText(0))
		end;
	};

	--MaxCombo
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+210,starsY+25;zoom,0.4;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local maxCombo = getBestMaxCombo(PLAYER_1,0)
				self:settextf("Max Combo: %d",maxCombo)
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--MissCount
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+210,starsY+37;zoom,0.4;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local missCount = getBestMissCount(PLAYER_1,0)
				if missCount ~= nil then
					self:settext("Miss Count: "..missCount)
				else
					self:settext("Miss Count: -")
				end
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--Score Date
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+210,starsY+49;zoom,0.4;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				if IsUsingWideScreen() then
					self:settext("Date Achieved: "..getScoreDate(topScoreP1))
				else
					self:settext(getScoreDate(topScoreP1))
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};

};

 
------------------------------------------
------------------------------------------2P

t[#t+1] = Def.ActorFrame{
	Name="StatFrame2P";
	BeginCommand=function(self)
		if GAMESTATE:IsHumanPlayer(PLAYER_2) then
			self:visible(true)
		else
			self:visible(false)
		end;
	end;
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_2 then
			self:visible(true);
		end;
	end;
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_2 then
			self:visible(false);
		end;
	end;
	--Upper Bar
	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY-18+playerDistY;zoomto,frameWidth,30;halign,0;valign,0;diffuse,color("#333333CC"));
	};
	--Lower Bar
	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY+18+playerDistY;zoomto,frameWidth,50;halign,0;valign,0;diffuse,color("#333333CC"));
	};

	--OverBar
	Def.Quad{
		Name = "FrameMouseOver2P";
		InitCommand=cmd(xy,starsX+5,starsY+18+playerDistY;zoomto,110,35;halign,0;valign,0;diffusealpha,0);
	};

	--===Upper Bar Stuff===--

	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY-18+playerDistY;zoomto,8,30;halign,0;valign,0;diffuse,color("#FFFFFF"));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				self:diffuse(getHighestClearType(PLAYER_2,0,2))
			end
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	};

	Def.Quad{
		InitCommand=cmd(xy,starsX,starsY-18+playerDistY;zoomto,8,30;halign,0;valign,0;diffuse,color("#FFFFFF"));
		BeginCommand=function(self)
			self:diffuseramp()
			self:effectcolor2(color("1,1,1,0.6"))
			self:effectcolor1(color("1,1,1,0"))
			self:effecttiming(2,1,0,0)
		end;
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+13,starsY-12+playerDistY;zoom,0.3;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local diff;
				local stype;
				local notes = 0
				local holds = 0
				local rolls = 0
				local mines = 0
				local lifts = 0
				if stepsP2 ~= nil then
					notes = stepsP2:GetRadarValues(PLAYER_2):GetValue("RadarCategory_Notes")
					holds = stepsP2:GetRadarValues(PLAYER_2):GetValue("RadarCategory_Holds")
					rolls = stepsP2:GetRadarValues(PLAYER_2):GetValue("RadarCategory_Rolls")
					mines = stepsP2:GetRadarValues(PLAYER_2):GetValue("RadarCategory_Mines")
					lifts = stepsP2:GetRadarValues(PLAYER_2):GetValue("RadarCategory_Lifts")
					diff = getDifficulty(stepsP2:GetDifficulty())
					stype = ToEnumShortString(stepsP2:GetStepsType()):gsub("%_"," ")
					self:settextf("%s %s // Notes:%s // Holds:%s // Rolls:%s // Mines:%s // Lifts:%s",stype,diff,notes,holds,rolls,mines,lifts);
				else
					self:settext("Disabled");
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+frameWidth-5,starsY-12+playerDistY;zoom,0.3;halign,1);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			local text = "Player 2"
			if profileP2 ~= nil then
				text = profileP2:GetDisplayName()
			end
			self:settext(text)
		end;
		PlayerJoinedMessageCommand=cmd(queuecommand,"Set");
	};

	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+21,starsY+2+playerDistY;zoom,0.6;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local diff = 0;
				local enabled = GAMESTATE:IsPlayerEnabled(PLAYER_2);
				if enabled and stepsP2 ~= nil then
					diff = stepsP2:GetMeter() or 0;
					self:settext(diff);
				else
					self:settext(0);
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	};

	--===Lower Bar Stuff===--

	--Grades
	LoadFont("Common Large")..{
		InitCommand=cmd(xy,starsX+60,starsY+35+playerDistY;zoom,0.6;maxwidth,110/0.6);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				self:settext(THEME:GetString("Grade",ToEnumShortString(getBestGrade(PLAYER_2,0))))
				self:diffuse(getGradeColor(getBestGrade(PLAYER_2,0)))
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--ClearType
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+60,starsY+58+playerDistY;zoom,0.5;maxwidth,110/0.5);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				self:settext(getHighestClearType(PLAYER_2,0,0))
				self:diffuse(getHighestClearType(PLAYER_2,0,2))
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	-- Percentage Score
	LoadFont("Common Large")..{
		InitCommand=cmd(xy,starsX+195,starsY+30+playerDistY;zoom,0.45;halign,1;maxwidth,75/0.45);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local score = getBestScore(PLAYER_2,0,0)
				local maxscore = getMaxScore(PLAYER_2,0)
				if maxscore == 0 or maxscore == nil then
					maxscore = 1
				end;
				local pscore = (score/maxscore)

				self:settextf("%05.2f%%",math.floor((pscore)*10000)/100)
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--Player DP/Exscore / Max DP/Exscore
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+182,starsY+48+playerDistY;zoom,0.5;halign,1;maxwidth,60/0.5);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local score = string.format("%04d",getBestScore(PLAYER_2,0,0))
				local maxscore = string.format("%04d",getMaxScore(PLAYER_2,0))
				self:settext(score.."/"..maxscore)
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--ScoreType superscript(?)
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+183,starsY+47+playerDistY;zoom,0.3;halign,0;);
		BeginCommand=function(self)
			self:settext(getScoreTypeText(0))
		end;
	};

	--MaxCombo
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+210,starsY+25+playerDistY;zoom,0.4;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local maxCombo = getBestMaxCombo(PLAYER_2,0)
				self:settextf("Max Combo: %d",maxCombo)
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--MissCount
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+210,starsY+37+playerDistY;zoom,0.4;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local missCount = getBestMissCount(PLAYER_2,0)
				if missCount ~= nil then
					self:settext("Miss Count: "..missCount)
				else
					self:settext("Miss Count: -")
				end
			end;	
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	--MissCount
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,starsX+210,starsY+49+playerDistY;zoom,0.4;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				if IsUsingWideScreen() then
					self:settext("Date Achieved: "..getScoreDate(topScoreP2))
				else
					self:settext(getScoreDate(topScoreP2))
				end;
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
	};
};

t[#t+1] = LoadActor("bargraph");

local index = 0
while index < maxStars do
	t[#t+1] = stars(index,PLAYER_1)
	t[#t+1] = stars(index,PLAYER_2)
	index = index + 1
end;

--1P
t[#t+1] = Def.ActorFrame{
	Name="NearbyGrade";
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_CENTER_Y);
	Def.Quad{
		Name="NearbyGradeQuad";
		InitCommand=cmd(zoomto,50,20;halign,0;valign,0;diffuse,color("#33333366"));
	};
	LoadFont("Common Normal")..{
		Name="NearbyGradeP1";
		InitCommand=cmd(xy,25,10;zoom,0.3;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local test1,test2 = getNearbyGrade(PLAYER_1,getBestScore(PLAYER_1,0,1),getBestGrade(PLAYER_1,0))
				if test2 >= 0 then
					test2 = tostring("+"..test2)
				else
					test2 = tostring(test2)
				end;	
				self:settextf("%s %s",THEME:GetString("Grade",ToEnumShortString(test1)),test2)
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
	LoadFont("Common Normal")..{
		Name="NearbyGradeP2";
		InitCommand=cmd(xy,25,10;zoom,0.3;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			if update then
				local test1,test2 = getNearbyGrade(PLAYER_2,getBestScore(PLAYER_2,0,1),getBestGrade(PLAYER_2,0))
				if test2 >= 0 then
					test2 = tostring("+"..test2)
				else
					test2 = tostring(test2)
				end;
				self:settextf("%s %s",THEME:GetString("Grade",ToEnumShortString(test1)),test2)
			end;
		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
	};
};


local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
	if update then
		if (isOver(self:GetChildren().StatFrame1P:GetChildren().FrameMouseOver1P) and self:GetChildren().StatFrame1P:GetVisible()) then
			self:GetChild("NearbyGrade"):visible(true)
			self:GetChild("NearbyGrade"):GetChild("NearbyGradeP1"):visible(true)
			self:GetChild("NearbyGrade"):GetChild("NearbyGradeP2"):visible(false)
	    	self:GetChild("NearbyGrade"):xy(INPUTFILTER:GetMouseX(),INPUTFILTER:GetMouseY())
		elseif (isOver(self:GetChildren().StatFrame2P:GetChildren().FrameMouseOver2P) and self:GetChildren().StatFrame2P:GetVisible()) then
			self:GetChild("NearbyGrade"):GetChild("NearbyGradeP1"):visible(false)
			self:GetChild("NearbyGrade"):GetChild("NearbyGradeP2"):visible(true)
			self:GetChild("NearbyGrade"):visible(true)
	    	self:GetChild("NearbyGrade"):xy(INPUTFILTER:GetMouseX(),INPUTFILTER:GetMouseY())
	    else
	    	self:GetChild("NearbyGrade"):visible(false)
	    end;
    else
    	self:GetChild("NearbyGrade"):visible(false)
    end;
end; 

t.InitCommand=cmd(SetUpdateFunction,Update);

return t