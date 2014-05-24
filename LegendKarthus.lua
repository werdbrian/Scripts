local version = 0.001
if not VIP_USER or myHero.charName ~= "Karthus" then return end
--{ Initiate Script (Checks for updates)
	function Initiate()
		local scriptName = "LegendKarthus"
		printMessage = function(message) print("<font color=\"#00A300\"><b>"..scriptName..":</b></font> <font color=\"#FFFFFF\">"..message.."</font>") end
		if FileExist(LIB_PATH.."SourceLib.lua") then
			require 'SourceLib'
		else
			printMessage("Downloading SourceLib, please wait whilst the required library is being downloaded.")
			DownloadFile("https://raw.githubusercontent.com/TheRealSource/public/master/common/SourceLib.lua",LIB_PATH.."SourceLib.lua", function() printMessage("SourceLib successfully downloaded, please reload (double [F9]).") end)
			return true
		end
		local libDownloader = Require(scriptName)
		libDownloader:Add("Selector",	 "https://raw.github.com/LegendBot/Scripts/master/Selector.lua")
		libDownloader:Add("VPrediction", "https://raw.github.com/honda7/BoL/master/Common/VPrediction.lua")
		libDownloader:Add("SOW",		 "https://raw.github.com/honda7/BoL/master/Common/SOW.lua")
		libDownloader:Check()
		if libDownloader.downloadNeeded then printMessage("Downloading required libraries, please wait whilst the required files are being downloaded.") return true end
	    SourceUpdater(scriptName, version, "raw.github.com", "/LegendBot/Scripts/master/LegendKennen.lua", SCRIPT_PATH..GetCurrentEnv().FILE_NAME, "/LegendBot/Scripts/master/Versions/LegendKarthus.version"):CheckUpdate()
		return false
	end
	if Initiate() then return end
	printMessage("Loaded")
--}
--{ Initiate Data Load
	local Karthus = {
		Q = {range = 875, speed = 20, delay = 0.5, width = 100, collision = false, DamageType = _MAGIC, BaseDamage = 40, DamagePerLevel = 20, ScalingStat = _MAGIC, PercentScaling = _AP, Condition = 0.30, Extra = function() return (myHero:CanUseSpell(_Q) == READY) end},
		W = {range = 1000, speed = 1600, delay = 0.5, width = 450, collision = false, DamageType = _MAGIC, BaseDamage = 0, DamagePerLevel = 0, ScalingStat = _MAGIC, PercentScaling = _AP, Condition = 0.0, Extra = function() return (myHero:CanUseSpell(_W) == READY) end},
		E = {range = 550, speed = 1000, delay = 0.5, collision = false, DamageType = _MAGIC, BaseDamage = 30, DamagePerLevel = 20, ScalingStat = _MAGIC, PercentScaling = _AP, Condition = 0.2, Extra = function() return (myHero:CanUseSpell(_E) == READY) end},
		R = {range = math.huge, speed = math.huge, delay = 3.0, DamageType = _MAGIC, BaseDamage = 250, DamagePerLevel = 150, ScalingStat = _MAGIC, PercentScaling = _AP, Condition = .6, Extra = function() return (myHero:CanUseSpell(_R) == READY) end}
	}
--}
--{ Script Load
	function OnLoad()
		--{ Variables
			VP = VPrediction(true)
			OW = SOW(VP)
			OW:RegisterAfterAttackCallback(AutoAttackReset)
			TS = SimpleTS(STS_LESS_CAST_MAGIC)
			Selector.Instance()
			SpellQ = Spell(_Q, Karthus.Q["range"]):SetSkillshot(VP, SKILLSHOT_CIRCULAR, Karthus.Q["width"], Karthus.Q["delay"], Karthus.Q["speed"], Karthus.Q["collision"])
			SpellW = Spell(_W, Karthus.W["range"]):SetSkillshot(VP, SKILLSHOT_CIRCULAR, Karthus.Q["width"], Karthus.Q["delay"], Karthus.Q["speed"], Karthus.Q["collision"])
			SpellE = Spell(_E, Karthus.E["range"])
			SpellR = Spell(_R, Karthus.R["range"])
			EnemyMinions = minionManager(MINION_ENEMY, Karthus.Q["range"], myHero, MINION_SORT_MAXHEALTH_DEC)
		--}
		--{ DamageCalculator
			DamageCalculator = DamageLib()
			DamageCalculator:RegisterDamageSource(_Q, Karthus.Q["DamageType"], Karthus.Q["BaseDamage"], Karthus.Q["DamagePerLevel"], Karthus.Q["ScalingStat"], Karthus.Q["PercentScaling"], Karthus.Q["Condition"], Karthus.Q["Extra"])
			DamageCalculator:RegisterDamageSource(_W, Karthus.W["DamageType"], Karthus.W["BaseDamage"], Karthus.W["DamagePerLevel"], Karthus.W["ScalingStat"], Karthus.W["PercentScaling"], Karthus.W["Condition"], Karthus.W["Extra"])
			DamageCalculator:RegisterDamageSource(_E, Karthus.E["DamageType"], Karthus.E["BaseDamage"], Karthus.E["DamagePerLevel"], Karthus.E["ScalingStat"], Karthus.E["PercentScaling"], Karthus.E["Condition"], Karthus.E["Extra"])
			DamageCalculator:RegisterDamageSource(_R, Karthus.R["DamageType"], Karthus.R["BaseDamage"], Karthus.R["DamagePerLevel"], Karthus.R["ScalingStat"], Karthus.R["PercentScaling"], Karthus.R["Condition"], Karthus.R["Extra"])
		--}
				--{ Initiate Menu
			Menu = scriptConfig("Karthus","LegendKarthus")
			Menu:addParam("Author","Author: Turtle",5,"")
			Menu:addParam("Version","Version: "..version,5,"")
			--{ General/Key Bindings
				Menu:addSubMenu("Karthus: General","General")
				Menu.General:addParam("Combo","Combo",2,false,32)
				Menu.General:addParam("Harass","Harass",2,false,string.byte("C"))
				Menu.General:addParam("LastHit","Last Hit Creeps",2,false,string.byte("X"))
			--}
			--{ Target Selector			
				Menu:addSubMenu("Karthus: Target Selector","TS")
				Menu.TS:addParam("TS","Target Selector",7,2,{ "AllClass", "SourceLib", "Selector (Disabled)", "SAC:Reborn", "MMA" })
				ts = TargetSelector(8,Karthus.R["range"],1,false)
				ts.name = "AllClass TS"
				Menu.TS:addTS(ts)				
			--}
			--{ Orbwalking
				Menu:addSubMenu("Karthus: Orbwalking","Orbwalking")
				OW:LoadToMenu(Menu.Orbwalking)
				Menu.Orbwalking.Mode0 = false
			--}
			--{	Combo Settings
				Menu:addSubMenu("Karthus: Combo","Combo")
				Menu.Combo:addParam("Q","Use Q in 'Combo'",1,true)
				Menu.Combo:addParam("W","Use W in 'Combo'",1,true)
				Menu.Combo:addParam("E","Use E in 'Combo'",1,true)
				Menu.Combo:addParam("R","Use R in 'Combo'",1,true)
			--}
			--{ Harass Settings
				Menu:addSubMenu("Karthus: Harass","Harass")
				Menu.Harass:addParam("Q","Use Q in 'Harass'",1,true)
				Menu.Harass:addParam("W","Use W in 'Harass'",1,true)
				Menu.Harass:addParam("E","Use E in 'Harass'",1,false)
			--}
			--{ Farm Settings
				Menu:addSubMenu("Karthus: Farm","Farm")
				Menu.Farm:addParam("Energy","Minimum Energy Percentage",4,70,0,100,0)
				Menu.Farm:addParam("Q","Use Q in 'Farm'",1,true)
			--}
			--{ Extra Settings
				Menu:addSubMenu("Karthus: Extra","Extra")
				Menu.Extra:addParam("Tick","Tick Suppressor (Tick Delay)",4,20,1,50,0)
				Menu.Extra:addParam("RCount","Enemies to Kill w/ Ulti",7,2,{"One Enemy","Two Enemies","Three Enemies","Four Enemies","Five Enemies"})
			--}
			--{ Draw Settings
				Menu:addSubMenu("Karthus: Draw","Draw")
				DrawHandler = DrawManager()
				DrawHandler:CreateCircle(myHero,Karthus.Q["range"],1,{255, 255, 255, 255}):AddToMenu(Menu.Draw, "Q Range", true, true, true):LinkWithSpell(SpellQ, true)
				DrawHandler:CreateCircle(myHero,Karthus.W["range"],1,{255, 255, 255, 255}):AddToMenu(Menu.Draw, "W Range", true, true, true):LinkWithSpell(SpellW, true)
				DrawHandler:CreateCircle(myHero,Karthus.E["range"],1,{255, 255, 255, 255}):AddToMenu(Menu.Draw, "E Range", true, true, true):LinkWithSpell(SpellE, true)
				DamageCalculator:AddToMenu(Menu.Draw,{_Q,_W,_E,_R,_AA})
			--}
						--{ Perma Show Settings
				Menu:addSubMenu("Karthus: Perma Show","Perma")
				Menu.Perma:addParam("INFO","The following options require a restart [F9 x2] to take effect",5,"")
				Menu.Perma:addParam("GC","Perma Show 'General > Combo'",1,true)				
				Menu.Perma:addParam("GF","Perma Show 'General > Farm'",1,true)
				Menu.Perma:addParam("GH","Perma Show 'General > Harass'",1,true)
				if Menu.Perma.GC then Menu.General:permaShow("Combo") end
				if Menu.Perma.GF then Menu.General:permaShow("LastHit") end
				if Menu.Perma.GH then Menu.General:permaShow("Harass") end
				Menu.Perma:addParam("CQ","Perma Show 'Combo > Q'",1,false)
				Menu.Perma:addParam("CW","Perma Show 'Combo > W'",1,false)
				Menu.Perma:addParam("CE","Perma Show 'Combo > E'",1,false)
				Menu.Perma:addParam("CR","Perma Show 'Combo > R'",1,false)
				if Menu.Perma.CQ then Menu.Combo:permaShow("Q") end
				if Menu.Perma.CW then Menu.Combo:permaShow("W") end
				if Menu.Perma.CE then Menu.Combo:permaShow("E") end
				if Menu.Perma.CR then Menu.Combo:permaShow("R") end
				Menu.Perma:addParam("HQ","Perma Show 'Harass > Q'",1,false)
				Menu.Perma:addParam("HW","Perma Show 'Harass > W'",1,false)
				Menu.Perma:addParam("HE","Perma Show 'Harass > E'",1,false)
				if Menu.Perma.HQ then Menu.Harass:permaShow("Q") end
				if Menu.Perma.HW then Menu.Harass:permaShow("W") end
				if Menu.Perma.HE then Menu.Harass:permaShow("E") end
				Menu.Perma:addParam("FQ","Perma Show 'Farm > Q'",1,false)
				if Menu.Perma.FQ then Menu.Farm:permaShow("Q") end
				Menu.Perma:addParam("ET","Perma Show 'Extra > Tick Delay'",1,false)
				Menu.Perma:addParam("ER","Perma Show 'Extra > R Count'",1,false)
				if Menu.Perma.ET then Menu.Extra:permaShow("Tick") end
				if Menu.Perma.ER then Menu.Extra:permaShow("RCount") end
			--}
		--}
	end
--}
--{ Script Loop
	function OnTick()
		--{ Tick Manager
			if GetTickCount() < (TickSuppressor or 0) then return end
			TickSuppressor = GetTickCount() + Menu.Extra.Tick
		--}
		--{ Variables
			QMANA = GetSpellData(_Q).mana
			WMANA = GetSpellData(_W).mana
			EMANA = GetSpellData(_E).mana
			RMANA = GetSpellData(_R).mana
			Farm = Menu.General.LastHit and Menu.Farm.Energy <= myHero.mana / myHero.maxMana * 100
			Combat = Menu.General.Combo or Menu.General.Harass
			QREADY = (SpellQ:IsReady() and ((Menu.General.Combo and Menu.Combo.Q) or (Menu.General.Harass and Menu.Harass.Q) or (Farm and Menu.Farm.Q) ))
			WREADY = IsMarked and (SpellW:IsReady() and ((Menu.General.Combo and Menu.Combo.W) or (Menu.General.Harass and Menu.Harass.W) or (Farm and Menu.Farm.W) ))
			EREADY = not EActive and (SpellE:IsReady() and ((Menu.General.Combo and Menu.Combo.E) or (Menu.General.Harass and Menu.Harass.E) or (Farm and Menu.Farm.E) ))
			RREADY = (SpellR:IsReady() and ((Menu.General.Combo and Menu.Combo.R) ) and Menu.Extra.RCount <= CountEnemyHeroInRange(Karthus.R["range"], myHero))
			Target = GrabTarget()
		--}	
		--{ Combo and Harass
			if Combat and Target then				
				if DamageCalculator:IsKillable(Target,{_Q,_E,_W,_R,_AA}) then
					if DamageCalculator:IsKillable(Target,{_Q}) and QREADY then
						SpellQ:Cast(Target) 
					elseif DamageCalculator:IsKillable(Target,{_Q,_W}) and QREADY and WREADY then
						SpellQ:Cast(Target) 
						SpellW:Cast(Target)
						--
					elseif DamageCalculator:IsKillable(Target,{_Q,_W,_E}) and QREADY and WREADY and EREADY then
				    	SpellQ:Cast(Target) 
					    SpellW:Cast(Target)
						SpellE:Cast(Target)
						--
					elseif DamageCalculator:IsKillable(Target,{_Q,_W,_E,_R}) and QREADY and WREADY and RREADY then
				    	SpellQ:Cast(Target) 
					    SpellW:Cast(Target)
					    SpellE:Cast(Target)
						SpellR:Cast(Target)
					else
						if QREADY then
							SpellQ:Cast(Target) 
						end
						if WREADY then
							SpellW:Cast(Target)
						end
						if EREADY then
							SpellE:Cast(Target)
						end
						if RREADY then
							SpellR:Cast(Target)
						end
					end
				else
					if QREADY then
						SpellQ:Cast(Target) 
					end
					if WREADY then
						SpellW:Cast(Target)
					end
					if EREADY then
						SpellE:Cast(Target)
					end
					if RREADY then
						SpellR:Cast(Target)
					end
				end
				if Menu.Orbwalking.Enabled and (Menu.Orbwalking.Mode0 or Menu.Orbwalking.Mode1) then
					OW:ForceTarget(Target)
				end
			end
		--}
		--{ Farming
			if Farm then
				EnemyMinions:update()
				for i, Minion in pairs(EnemyMinions.objects) do
					if ValidTarget(Minion) then
						if QREADY and DamageCalculator:IsKillable(Minion,{_Q}) then
							SpellQ:Cast(Minion)
						end
					end
				end
			end
		--}
	end
--}

--{ Target Selector
	function GrabTarget()
		if _G.MMA_Loaded and Menu.TS.TS == 5 then
			return _G.MMA_ConsideredTarget(MaxRange()) 
		elseif _G.AutoCarry and Menu.TS.TS == 4 then
			return _G.AutoCarry.Crosshair:GetTarget()
		elseif _G.Selector_Enabled and Menu.TS.TS == 3 then
			return Selector.GetTarget(SelectorMenu.Get().mode, 'AP', {distance = MaxRange()})
		elseif Menu.TS.TS == 2 then
			return TS:GetTarget(MaxRange())
		elseif Menu.TS.TS == 1 then
			ts.range = MaxRange()
			ts:update()
			return ts.target
		end
	end
--}
--{ Target Selector Range
	function MaxRange()
		if QREADY then
			return Karthus.Q["range"]
		end
		if WREADY then
			return Karthus.W["range"]
		end
		if EREADY then
			return Karthus.E["range"]
		end		
		if RREADY then
			return Karthus.R["range"]
		end
		return myHero.range + 50
	end
--}
