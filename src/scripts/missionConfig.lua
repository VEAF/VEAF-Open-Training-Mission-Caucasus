-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mission configuration file for the VEAF framework
-- see https://github.com/VEAF/VEAF-Mission-Creation-Tools
--
-- This configuration is tailored for the Caucasus OpenTraining mission
-- see https://github.com/VEAF/VEAF-Open-Training-Mission
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veaf.config.MISSION_NAME = "OpenTraining_Caucasus"
veaf.config.MISSION_EXPORT_PATH = nil -- use default folder

-- play the radio beacons (for the public OT mission)
veafBeacons = false

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize QRA
-------------------------------------------------------------------------------------------------------------------------------------------------------------
VeafQRA.ToggleAllSilence(false) --this will set all QRA messages ON if the argument is "true" and all QRA messages to OFF is the argument is "false".

if veaf then
    --red
    QRA_Minevody = VeafQRA.new()
    :setName("QRA_Minevody")
    :setTriggerZone("QRA_Minevody")
    :setZoneRadius(106680) -- 350,000 feet
    :addGroup("QRA_Minevody")

        --NOTE 1 : Remember that only one aircraft group at a time is deployed for each QRA

    --:setQRAcount(QRAcount) --Superior or equal to -1 : Current number of aircraft groups available for deployement. By default this is set to -1 meaning an infinite amount of groups are available, no warehousing is done. -> This is you master arm for the rest of these options.
    --:setQRAmaxCount(maxQRAcount) --Superior or equal to -1 : Maximum number of aircraft groups deployable at any time for the QRA. By default this is set to -1 meaning an infinite amount of aircrafts can be accumulated for deployement. -> Example: a QRA has 2 out of 6 groups ready for deployement, 6 is your maxQRAcount, 2 is your current QRAcount.
    --:setQRAmaxResupplyCount(maxResupplyCount) --Superior or equal to -1 : Total number of aircraft groups which can be resupplied to the QRA. By default this is set to -1 meaning an infinite amount of stock is available. 0 means no stock is available, no resupplies will occur, this is your master arm for resupplies  -> Take the previous example : We are missing 4 groups but only have 3 in stock to resupply the QRA, 3 is your QRAmaxResupplyCount
    --:setQRAminCountforResupply(minCountforResupply) --Equal to -1 or superior to 0 : Number of aircraft groups which the QRA needs to have at all times, otherwise a resupply will be started. By default this is set at -1 which means that a resupply will be started as soon as an aircraft group is lost. -> Take the previous example : This minimum number of deployable groups we desire at all times for our QRA is 1, but we have 2, so no resupply will happen for now. 1 is your minCountforResupply.
    --:setResupplyAmount(resupplyAmount) --Superior or equal to 1 : Number of aircraf groups that will be resupplied to the QRA when a resupply happens. By default it is equal to 1. -> Take the previous example : We just lost both of our groups meaning we only have none left, this will trigger a resupply, a resupply the desired amount of aircraft groups or of however many aircrafts we have in stock if this amount is less. The resupply will also be constrained by the maximum number of groups we can have ready for deployement at once.
    --:setQRAresupplyDelay(resupplyDelay) --Superior or equal to 0 : Time that a resupply will need in order to happen.

        --NOTE 2 : only one resupply can happen at a time, they may be scheduled at every possible occasion but will happen one at a time.
        --NOTE 3 : QRA groups that have just arrived from the supply chain will need to be rearmed (see associated delay and constraints)

    --:setAirportLink(airbase_name) --Unit name of the airbase in between " " : QRA will be linked to this airport and will stop operating if the airport is lost (This can be a FARP (use the FARP's unit name), a Ship (use the ship's unit name), an airfield or a building (oil rigs etc.))
    --:setAirportMinLifePercent(value) --Ranges from 0 to 1 : minimum life percentage of the linked airport for the QRA to operate. Airports (runways) and Ships only should lose life when bombed, this needs manual testing to know what works best. Not currently functional due to a DCS bug.
    :setAirportLink("Mineralnye Vody")

        --NOTE 1 : QRA that are just being recomissioned after an airbase is retaken will need to be rearmed (see associated delay and constraints)

    --:setDelayBeforeRearming(value) --Delay between the death of a QRA and it being ready for action
    --:setNoNeedToLeaveZoneBeforeRearming() --QRA will be rearmed (and later deployed) even though players are still in the area
    --:setResetWhenLeavingZone() --The QRA will be despawned (and ready-ed up again immediatly) when all players leave the zone. Otherwise the QRA will patrol until they RTB at which point they will despawn on landing and be ready immediatly.
    --:setDelayBeforeActivating(value) --activation delay between units entering the QRA zone and the QRA actually deploying

    :setCoalition(coalition.side.RED)
    :addEnnemyCoalition(coalition.side.BLUE)
    :setReactOnHelicopters() --Sets if the QRA reacts to helicopters entering the zone
    --:setSilent() --mutes this QRA only, VeafQRA.AllSilence has to be false for this to have an effect
    :start()

    QRA_Krasnodar = VeafQRA.new()
    :setName("QRA_Krasnodar")
    :setTriggerZone("QRA_Krasnodar")
    :setZoneRadius(106680) -- 350,000 feet
    :addGroup("QRA_Krasnodar")
    :setAirportLink("Krasnodar-Pashkovsky")
    :setCoalition(coalition.side.RED)
    :addEnnemyCoalition(coalition.side.BLUE)
    :setReactOnHelicopters() --Sets if the QRA reacts to helicopters entering the zone
    :start()


    --blue
    QRA_Kutaisi = VeafQRA.new()
    :setName("QRA_Kutaisi")
    :setTriggerZone("QRA_Kutaisi")
    :setZoneRadius(106680) -- 350,000 feet
    :addGroup("QRA_Kutaisi")
    :setAirportLink("Kutaisi")
    :setCoalition(coalition.side.BLUE)
    :addEnnemyCoalition(coalition.side.RED)
    :start()

    QRA_Gudauta = VeafQRA.new()
    :setName("QRA_Gudauta")
    :setTriggerZone("QRA_Gudauta")
    :setZoneRadius(106680) -- 350,000 feet
    :addGroup("QRA_Gudauta")
    :setAirportLink("Gudauta")
    :setCoalition(coalition.side.BLUE)
    :addEnnemyCoalition(coalition.side.RED)
    :start()
end

--if QRA_Minevody then QRA_Minevody:stop() end --use this if you wish to stop the QRA from operating at any point. It can be restarted with : if QRA_Minevody then QRA_Minevody:start() end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize all the scripts
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafRadio then
    veaf.loggers.get(veaf.Id):info("init - veafRadio")
    veafRadio.initialize(true)

    if veafBeacons then
        -- add the beacons
        veafRadio.startBeacon("Bienvenue-blue", 15, 120, "251.0,124.0,121.5,30.0", "am,am,am,fm", nil, "bienvenue-veaf-fr.mp3", 1.0, 2)
        --veafRadio.startBeacon("Bienvenue-red", 45, 120, "251.0,124.0,121.5,30.0", "am,am,am,fm", nil, "bienvenue-veaf-fr.mp3", 1.0, 1)
        veafRadio.startBeacon("Welcome-blue", 75, 120, "251.0,124.0,121.5,30.0", "am,am,am,fm", nil, "bienvenue-veaf-en.mp3", 1.0, 2)
        --veafRadio.startBeacon("Welcome-red", 105, 120, "251.0,124.0,121.5,30.0", "am,am,am,fm", nil, "bienvenue-veaf-en.mp3", 1.0, 1)

        veafRadio.startBeacon("Batumi", 5, 90, "122.5,131.0", "am,am", nil, "Batumi.mp3", 1.0, 2)
        veafRadio.startBeacon("Beslan", 15, 90, "128.225,141.0", "am,am", nil, "Beslan.mp3", 1.0, 2)
        veafRadio.startBeacon("Gudauta", 25, 90, "122.225,130.0", "am,am", nil, "Gudauta.mp3", 1.0, 2)
        --veafRadio.startBeacon("Kobuleti", 35, 90, "122.3,133.0", "am,am", nil, "Kobuleti.mp3", 1.0, 2)
        veafRadio.startBeacon("Kutaisi", 45, 90, "122.1,134.0", "am,am", nil, "Kutaisi.mp3", 1.0, 2)
        --veafRadio.startBeacon("Nalchik", 55, 90, "128.525,136.0", "am,am", nil, "Nalchik.mp3", 1.0, 2)
        veafRadio.startBeacon("Sochi", 65, 90, "126.2,127.0", "am,am", nil, "Sochi.mp3", 1.0, 2)
        --veafRadio.startBeacon("Sukhumi", 75, 90, "122.7,129.0", "am,am", nil, "Sukhumi.mp3", 1.0, 2) -- attention ATIS = Batumi
        veafRadio.startBeacon("Tbilisi", 85, 90, "132.8,138.0", "am,am", nil, "Tbilisi.mp3", 1.0, 2)
        veafRadio.startBeacon("Vaziani", 95, 90, "122.6,140.0", "am,am", nil, "Vaziani.mp3", 1.0, 2)
        --veafRadio.startBeacon("Anapa", 15, 30, "125.4,121.0", "am,am", nil, "Anapa.mp3", 1.0, 2)
        --veafRadio.startBeacon("Gelendzhik", 15, 30, "134.875,126.0", "am,am", nil, "Gelendzhik.mp3", 1.0, 2)
        --veafRadio.startBeacon("Krasnodar-Ctr", 15, 30, "128.3,122.0", "am,am", nil, "Krasnodar-Ctr.mp3", 1.0, 2)
        --veafRadio.startBeacon("Krasnodar-Pshk", 15, 30, "122.45,128.0", "am,am", nil, "Krasnodar-Pshk.mp3", 1.0, 2)
        --veafRadio.startBeacon("Krymsk", 15, 30, "128.6,124.0", "am,am", nil, "Krymsk.mp3", 1.0, 2)
        --veafRadio.startBeacon("Maykop", 15, 30, "128.7,125.0", "am,am", nil, "Maykop.mp3", 1.0, 2)
        --veafRadio.startBeacon("Mineralnye-Vody", 15, 30, "125.25,135", "am,am", nil, "Mineralnye-Vody.mp3", 1.0, 2)
        --veafRadio.startBeacon("Mozdok", 15, 30, "128.55,137.0", "am,am", nil, "Mozdok.mp3", 1.0, 2)
        --veafRadio.startBeacon("Novorossiysk", 15, 30, "128.2,123.0", "am,am", nil, "Novorossiysk.mp3", 1.0, 2)
        --veafRadio.startBeacon("Senaki", 15, 30, "122.525,132.0", "am,am", nil, "Senaki.mp3", 1.0, 2)
        --veafRadio.startBeacon("Soganlung", 15, 30, "122.6,139.0", "am,am", nil, "Soganlung.mp3", 1.0, 2)
    end
end
if veafSpawn then
    veaf.loggers.get(veaf.Id):info("init - veafSpawn")
    veafSpawn.initialize()
end
if veafGrass then
    veaf.loggers.get(veaf.Id):info("init - veafGrass")
    veafGrass.initialize()
end
if veafCasMission then
    veaf.loggers.get(veaf.Id):info("init - veafCasMission")
    veafCasMission.initialize()
end
if veafTransportMission then
    veaf.loggers.get(veaf.Id):info("init - veafTransportMission")
    veafTransportMission.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- change some default parameters
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veaf.DEFAULT_GROUND_SPEED_KPH = 25

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize SHORTCUTS
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafShortcuts then
    veaf.loggers.get(veaf.Id):info("init - veafShortcuts")
    veafShortcuts.initialize()
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure ASSETS
-------------------------------------------------------------------------------------------------------------------------------------------------------------

if veafAssets then
    veaf.loggers.get(veaf.Id):info("Loading configuration")
    veafAssets.Assets = {
		-- list the assets in the mission below
		{sort=1, name="CSG-01 Tarawa", description="Tarawa (LHA)", information="Tacan 11X TAA\nICLS 11\nU226 (11)\n"},
		{sort=2, name="CSG-74 Stennis", description="Stennis (CVN)", information="Tacan 10X STS\nICLS 10\nU225 (10)\nLink4 225MHz\nACLS available"},  
		{sort=3, name="CSG-71 Roosevelt", description="Roosevelt (CVN)", information="Tacan 12X RHR\nICLS 12\nU227 (12)\nLink4 227MHz\nACLS available"},
		{sort=4, name="CSG-59 Forrestal", description="Forrestal (CV)", information="Tacan 13X FRT\nICLS 13\nU228 (13)\nLink4 228MHz\nACLS available"},  		
		{sort=5, name="T1-Arco-1", description="Arco-1 (KC-135)", information="Tacan 64Y\nU290.50 (20)\nZone OUEST", linked="T1-Arco-1 escort"}, 
		{sort=6, name="T2-Shell-1", description="Shell-1 (KC-135 MPRS)", information="Tacan 62Y\nU290.30 (18)\nZone EST", linked="T2-Shell-1 escort"},  
		{sort=7, name="T3-Texaco-1", description="Texaco-1 (KC-135 MPRS)", information="Tacan 60Y\nU290.10 (17)\nZone OUEST", linked="T3-Texaco-1 escort"},  
		{sort=8, name="T4-Shell-2", description="Shell-2 (KC-135)", information="Tacan 63Y\nU290.40 (19)\nZone EST", linked="T4-Shell-2 escort"},  
		{sort=9, name="T5-Petrolsky", description="900 (IL-78M, RED)", information="U290.1 (17)", linked="T5-Petrolsky escort"},  
		{sort=10, name="CVN-74 Stennis S3B-Tanker", description="Texaco-7 (S3-B)", information="Tacan 75X T74\nU290.90\nZone PA"},  
		{sort=11, name="CVN-71 Roosevelt S3B-Tanker", description="Texaco-8 (S3-B)", information="Tacan 76X T71\nU290.80\nZone PA"},  
		{sort=12, name="CV-59 Forrestal S3B-Tanker", description="Texaco-9 (S3-B)", information="Tacan 77X T59\nU290.80\nZone PA"}, 
		{sort=13, name="Bizmuth", description="Colt-1 AFAC Bizmuth (MQ-9)", information="L1688 V118.80 (18)", jtac=1688, freq=118.80, mod="am"},
		{sort=14, name="Agate", description="Dodge-1 AFAC Agate (MQ-9)", information="L1687 V118.90 (19)", jtac=1687, freq=118.90, mod="am"},  
		{sort=15, name="A1-Magic", description="Magic (E-3A)", information="Datalink 315.3 Mhz\nU282.20 (13)", linked="A1-Magic escort"},  
		{sort=16, name="A2-Overlordsky", description="Overlordsky (A-50, RED)", information="U282.2 (13)", linked="A2-Overlordsky escort"},  
    }

    veaf.loggers.get(veaf.Id):info("init - veafAssets")
    veafAssets.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure MOVE
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafMove then
    veaf.loggers.get(veaf.Id):info("Setting move tanker radio menus")
    -- keeping the veafMove.Tankers table empty will force veafMove.initialize() to browse the units, and find the tankers
    veaf.loggers.get(veaf.Id):info("init - veafMove")
    veafMove.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure COMBAT MISSION
-------------------------------------------------------------------------------------------------------------------------------------------------------------

if veafCombatMission then 
    veaf.loggers.get(veaf.Id):info("Loading configuration")
    
    veafCombatMission.addCapMission("training-radar-tu22-FL300", "Crimea - Tu22 FL300", "Russian TU-22 patrols at FL300 west of the Crimea peninsula", false, true)
    veafCombatMission.addCapMission("training-radar-bear-FL200", "Crimea - Bear FL200", "Russian TU-95 patrols at FL200 west of the Crimea peninsula ; ECM on", false, false)
    veafCombatMission.addCapMission("training-radar-mig23-FL300", "Crimea - Mig23 FL300", "Mig-23MLD on CAP (R-24R = Fox1 MR) at FL300 west of the Crimea peninsula", false, false)
    veafCombatMission.addCapMission("training-radar-mig29-FL300", "Crimea - Mig29 FL300", "Mig-29S on CAP (R-77 = Fox 3 MR) at FL300 west of the Crimea peninsula", false, true)
    veafCombatMission.addCapMission("training-radar-mig31-FL300", "Crimea - Mig31 FL300", "Mig-31 on CAP (R-33 = Fox 3 LR) at FL300 west of the Crimea peninsula", false, false)
    veafCombatMission.addCapMission("training-radar-mig23-FL300-notch", "Crimea - Mig23 notching", "Mig-23MLD on CAP (R-24R = Fox1 MR) notching W-E at FL300 west of the Crimea peninsula", false, false)
    veafCombatMission.addCapMission("l39c-intercept-FL100", "Khashuri - L-39C heading north", "L-39C patrol heading N at 15 min of Kahshuri", false, true)
    
    veafCombatMission.AddMissionsWithSkillAndScale(
		VeafCombatMission.new()
		:setSecured(true)
		:setRadioMenuEnabled(true)
		:setName("Intercept-Kraznodar-1")
		:setFriendlyName("Intercept a transport / KRAZNODAR - MINVODY")
		:setBriefing([[
A Russian transport plane is taking off from Kraznodar and will transport a VIP to Mineralnye Vody.
It is escorted by a fighter patrol.
]]
)
		:addElement(
			VeafCombatMissionElement.new()
			:setName("OnDemand-Intercept-Transport-Krasnodar-Mineral-Transport")
            :setGroups({"OnDemand-Intercept-Transport-Krasnodar-Mineral-Transport"})
            :setScalable(false)
		)
		:addElement(
			VeafCombatMissionElement.new()
			:setName("OnDemand-Intercept-Transport-Krasnodar-Mineral-Escort")
            :setGroups({"OnDemand-Intercept-Transport-Krasnodar-Mineral-Escort"})
            :setSkill("Random")
		)
		:addObjective(
			VeafCombatMissionObjective.new()
			:setName("Destroy the transport")
			:setDescription("you must destroy the transport and kill the VIP")
			:setMessage("%d transport planes destroyed !")
			:configureAsKillEnemiesObjective() -- TODO
		)
		:initialize()
	)

    veafCombatMission.AddMission(
		VeafCombatMission.new()
        :setSecured(true)
        :setRadioMenuEnabled(true)
		:setName("Red-attack-Gudauta")
		:setFriendlyName("Red attack On Gudauta")
		:setBriefing([[
Alert ! This is not a drill !
Tactical and strategic bombers have been detected at the russian border, to the north of Gudauta.
Their course will lead them to the Gudauta airbase, which is probably their mission.
Destroy all the bombers before they hit the base !
]]
)
		:addElement(
			VeafCombatMissionElement.new()
			:setName("SEAD")
			:setGroups({
				"Red Attack On Gudauta - Wave 1-1", 
				"Red Attack On Gudauta - Wave 1-2", 
				"Red Attack On Gudauta - Wave 1-3", 
				"Red Attack On Gudauta - Wave 1-4" })
			:setSkill("Random")
		)
		:addElement(
			VeafCombatMissionElement.new()
			:setName("Bombers")
			:setGroups({
				"Red Attack On Gudauta - Wave 2-1",
                "Red Attack On Gudauta - Wave 2-2", 
                "Red Attack On Gudauta - Wave 2-3" })
			:setSkill("Random")
		)
		:addObjective(
			VeafCombatMissionObjective.new()
			:setName("HVT Gudauta")
			:setDescription("the mission will be failed if any of the HVT on Gudauta are destroyed")
			:setMessage("HVT target(s) destroyed : %s !")
			:configureAsPreventDestructionOfSceneryObjectsInZone(
				{
					"Gudauta - Tower", 
					"Gudauta - Kerosen", 
					"Gudauta - Mess"},
				{
					[156696667] = "Gudauta Tower", 
					[156735615] = "Gudauta Kerosen tankers", 
					[156729386] = "Gudauta mess"
				}
			)
		)
		:addObjective(
			VeafCombatMissionObjective.new()
			:setName("Kill all the bombers")
			:setDescription("you must kill all of the bombers")
			:setMessage("%d bombers destroyed !")
			:configureAsKillEnemiesObjective()
		)
		:initialize()
	)

	veafCombatMission.AddMission(
		VeafCombatMission.new()
		:setName("Training-Bomber-1-slow")
		:setFriendlyName("Training - Bomber Scenario 1 - slow Tu-160")
		:setBriefing([[
You're head-on at 25nm with 11 Tu-160, FL200, Mach 0.8.
Destroy them all in less than 10 minutes !]])
		:addElement(
			VeafCombatMissionElement.new()
			:setName("Bombers")
			:setGroups({
				"Red Tu-160 Bomber Wave1-1",
				"Red Tu-160 Bomber Wave1-2",
				"Red Tu-160 Bomber Wave1-3",
				"Red Tu-160 Bomber Wave1-4",
				"Red Tu-160 Bomber Wave1-5",
				"Red Tu-160 Bomber Wave1-6",
				"Red Tu-160 Bomber Wave1-7",
				"Red Tu-160 Bomber Wave1-8",
                "Red Tu-160 Bomber Wave1-9",
                "Red Tu-160 Bomber Wave1-10",
                "Red Tu-160 Bomber Wave1-11",
            })
			:setSkill("Good")
		)
		:addObjective(
			VeafCombatMissionObjective.new()
			:setName("< 15 minutes")
			:setDescription("the mission will be over after 15 minutes")
			:setMessage("the 15 minutes have passed !")
			:configureAsTimedObjective(900)
		)
		:addObjective(
			VeafCombatMissionObjective.new()
			:setName("Kill all the bombers")
			:setDescription("you must kill or route all bombers")
			:setMessage("%d bombers destroyed or routed !")
			:configureAsKillEnemiesObjective(-1, 50)
		)
        :setSecured(false)
		:initialize()
	)

    veafCombatMission.AddMission(
		VeafCombatMission.new()
		:setName("ELINT-Mission-West")
		:setFriendlyName("ELINT gathering over the West zone")
		:setBriefing([[
ATIS on 282.125, SAM CONTROL on 282.225
A C-130 pair will fly reciprocical headings, trying to pinpoint enemy SAMS.
Don't let them be destroyed by the enemy !]])
		:addElement(
			VeafCombatMissionElement.new()
			:setName("ELINT-W")
			:setGroups({
				"ELINT-C-130-W-1",
				"ELINT-C-130-W-2"
            })
			:setSkill("Good")
		)
        :setSecured(true)
		:initialize()
	)

    veafCombatMission.AddMission(
		VeafCombatMission.new()
		:setName("ELINT-Mission-East")
		:setFriendlyName("ELINT gathering over the East zone")
		:setBriefing([[
ATIS on 282.125, SAM CONTROL on 282.225
A C-130 pair will fly reciprocical headings, trying to pinpoint enemy SAMS.
Don't let them be destroyed by the enemy !]])
		:addElement(
			VeafCombatMissionElement.new()
			:setName("ELINT-E")
			:setGroups({
				"ELINT-C-130-E-1",
				"ELINT-C-130-E-2"
            })
			:setSkill("Good")
		)
        :setSecured(true)
		:initialize()
	)

    veaf.loggers.get(veaf.Id):info("init - veafCombatMission")
    veafCombatMission.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure COMBAT ZONE
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafCombatZone then 
    veaf.loggers.get(veaf.Id):info("Loading configuration")

	veafCombatZone.AddZone(
		VeafCombatZone.new()
			:setMissionEditorZoneName("combatZone_Psebay_Factory")
			:setFriendlyName("Psebay chemical weapons factory")
			:setBriefing("This factory manufactures chemical weapons for a terrorits group\n" ..
                        "You must destroy both factory buildings, and the bunker where the scientists work\n" ..
                        "The other enemy units are secondary targets\n")
	)

	veafCombatZone.AddZone(
		VeafCombatZone.new()
			:setMissionEditorZoneName("combatZone_BattleOfBeslan")
			:setFriendlyName("Battle of Beslan")
			:setBriefing("This zone is the place of a battle between red and blue armies.\n" ..
                        "You must do what you can to help your side win\n" ..
                        "Please note that there is an enemy convoy coming from the west and going to Sheripova, that can be ambushed by the blue forces at Malgobek in 15-30 minutes. Be wary of the SAM that can hide anywhere in the cities or the forests !\n" ..
                        "Warning : there are air defenses lurking about, you should be cautious !")
	)

	veafCombatZone.AddZone(
		VeafCombatZone.new()
			:setMissionEditorZoneName("combatZone_EasyPickingsTerek")
			:setFriendlyName("Terek logistics parking")
			:setBriefing("The enemy has parked a lot of logistics at Terek\n" ..
                        "You must destroy all the trucks to impend the advance of their army on Beslan\n" ..
                        "The other enemy units are secondary targets\n"..
                        "This is a more easy zone, with few air defenses. But beware that there is a chance of manpad in the area !")
            :setTraining(true)
	)

	veafCombatZone.AddZone(
		VeafCombatZone.new()
			:setMissionEditorZoneName("combatZone_rangeKobuletiEasy")
			:setFriendlyName("Training at Kobuleti RANGE")
			:setBriefing("The Kobuleti RANGE (located 6 nm south-west of Kobuleti airbase) is set-up for training")
            :setTraining(true)
	)

	veafCombatZone.AddZone(
		VeafCombatZone.new()
			:setMissionEditorZoneName("combatZone_SaveTheHostages")
			:setFriendlyName("Hostages at Prohladniy")
			:setBriefing("Hostages are being held in a fortified hotel in the city of Prohladniy.\n" ..
                        "Warning : there are air defenses lurking about, you should be cautious !")
	)

    veafCombatZone.AddZone(
		VeafCombatZone.new()
			:setMissionEditorZoneName("combatZone_Antiship-Training-Easy")
			:setFriendlyName("Antiship Training - Easy")
			:setBriefing("Undefended cargo ships ready for plunder; Arrrrr! Shiver me timbers!")
	)

    veafCombatZone.AddZone(
		VeafCombatZone.new()
			:setMissionEditorZoneName("combatZone_Antiship-Training-Hard")
			:setFriendlyName("Antiship Training - Hard")
			:setBriefing("Cargo ships defended by escort ships; warning, an FFG 11540 Neustrashimy may escort them as well...")
	)

    veafCombatZone.AddZone(
		VeafCombatZone.new()
			:setMissionEditorZoneName("combatZone_roadBlock")
			:setFriendlyName("Road Block KM91")
			:setBriefing("38T KM946122 - 6300ft - KOB 67X 115/35\nRussia is blocking a main road between Batumi and Tbilisi.\nDestroy bunkers and vehicles.\nENI convoy is comming from the East.")
	)

	veafCombatZone.AddZone(
		VeafCombatZone.new()
			:setMissionEditorZoneName("combatZone_MaykopDefenses")
			:setFriendlyName("Maykop airbase defenses")
			:setBriefing("The Maykop airbase is defended by a SA10 battalion, point-defense SHORAD and AAA, and armored vehicles\n" ..
                        "You must incapacitate the defenses in order to prepare a land invasion")
    )

	veafCombatZone.AddZone(
		VeafCombatZone.new()
			:setMissionEditorZoneName("CombatZone_MountainHike")
			:setFriendlyName("Mountain hike")
            :setCompletable(false)
            :setTraining(true)
			:setBriefing("A friendly Mi-8MTV2 has crashed in the mountains, near the russian border, 45nm north-east of Sukhumi.\n" ..
                        "You can takeoff from the Kodori FARP or grass runway, follow the valley to the northeast until you pass the border and locate the crash site\n" ..
                        "There are beacons in the mountains to guide you : \n" ..
                        " - MH01 on 31.00 FM\n" ..
                        " - MH02 on 32.00 FM\n" ..
                        " - MH03 on 33.00 FM\n" ..
                        "The crashed helicopter's crew transmits on their pocket radio : SOS on 34.00 FM")
    )

    veaf.loggers.get(veaf.Id):info("init - veafCombatZone")
    veafCombatZone.initialize()

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure WW2 settings based on loaded theatre
-------------------------------------------------------------------------------------------------------------------------------------------------------------
local theatre = string.lower(env.mission.theatre)
veaf.loggers.get(veaf.Id):info(string.format("theatre is %s", theatre))
veaf.config.ww2 = false
if theatre == "thechannel" then
    veaf.config.ww2 = true
elseif theatre == "normandy" then
    veaf.config.ww2 = true
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure NAMEDPOINTS
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafNamedPoints then

    veaf.loggers.get(veaf.Id):info("Loading configuration")

    veaf.loggers.get(veaf.Id):info("init - veafNamedPoints")
    if theatre == "syria" then
        veafNamedPoints.Points = {
            -- Turkish Airports
            {name="INCIRLIK AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("37.001944", "35.425833"), {atc=true, tower="V129.40, U360.10", tacan="21X", runways={{name="05", hdg=50, ils="109.30"}, {name="23", hdg=230, ils="111.70"}}})},
            {name="ADANA SAKIRPASA INTL", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("36.981944", "35.280278"), {atc=true, tower="V121.10, U251.00", runways={{name="05", hdg=51, ils="108.70"}, {name="23", hdg=231}}})},
            {name="HATAY AIRPORT", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("36.360278", "36.285000"), {atc=true, tower="V128.50, U250.25", runways={{name="04", hdg=40, ils="108.90"}, {name="22", hdg=220, ils="108.15"}}})},
            {name="GANZIANTEP",point=veafNamedPoints.addDataToPoint(coord.LLtoLO("36.947057", "37.478579"), {atc=true, tower="V120.10, U250.05", runways={{name="10", hdg=100}, {name="28", hdg=280, ils="109.10"}}})},

            -- Syrian Airports
            {name="MINAKH HELIPT", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("36.521944", "37.041111"), {atc=true, tower="V120.60, U250.80", runways={{name="10", hdg=97}, {name="28", hdg=277}}})},
            {name="ALEPPO INTL", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("36.180556", "37.224167"), {atc=true, tower="V119.10, U250.85", runways={{name="09", hdg=93}, {name="27", hdg=273}}})},
            {name="KUWEIRES AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("36.186944", "37.583056"), {atc=true, tower="V120.50, U251.10", runways={{name="10", hdg=97}, {name="28", hdg=277}}})},
            {name="JIRAH AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("36.097500", "37.940278"), {atc=true, tower="V118.10, U250.30", runways={{name="10", hdg=96}, {name="28", hdg=276}}})},
            {name="TAFTANAZ HELIPT", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("35.972222", "36.783056"), {atc=true, tower="V122.80, U251.45", runways={{name="10", hdg=100}, {name="28", hdg=280}}})},
            {name="ABU AL DUHUR AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("35.732778", "37.101667"), {atc=true, tower="V122.20, U250.45", runways={{name="09", hdg=89}, {name="27", hdg=269}}})},
            {name="TABQA AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("35.754444", "38.566667"), {atc=true, tower="V118.50, U251.40", runways={{name="09", hdg=88}, {name="27", hdg=268}}})}, 
            {name="BASSEL AL ASSAD (KHMEIMIM)", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("35.400833", "35.948611"), {atc=true, tower="V118.10, U250.55", runways={{name="17R", hdg=174, ils="109.10"}, {name="17L", hdg=174}, {name="35R", hdg=354}, {name="35L", hdg=354}}})}, 
            {name="HAMA AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("35.118056", "36.711111"), {atc=true, tower="V118.05, U250.20", runways={{name="09", hdg=96}, {name="27", hdg=276}}})},
            {name="AL QUSAYR AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("34.570833", "36.571944"),  {atc=true, tower="V119.20, U251.55", runways={{name="10", hdg=98}, {name="28", hdg=278}}})}, 
            {name="PALYMYRA AIRPORT", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("34.557222", "38.316667"), {atc=true, tower="V121.90, U250.90", runways={{name="08", hdg=80}, {name="26", hdg=260}}})}, 
            {name="AN NASIRIYAH AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.918889", "36.866389"), {atc=true, tower="V122.30, U251.65", runways={{name="04", hdg=41}, {name="22", hdg=221}}})},
            {name="AL DUMAYR AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.609444", "36.748889"), {atc=true, tower="V120.30, U251.95", runways={{name="06", hdg=62}, {name="24", hdg=242}}})}, 
            {name="MEZZEH AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.477500", "36.223333"), {atc=true, tower="V120.70, U250.75", runways={{name="06", hdg=57}, {name="24", hdg=237}}})}, 
            {name="MARJ AS SULTAN NTH HELIPT", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.500278", "36.466944"), {atc=true, tower="V122.70, U250.60", runways={{name="08", hdg=80}, {name="26", hdg=260}}})}, 
            {name="MARJ AS SULTAN STH HELIPT", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.486944", "36.475278"), {atc=true, tower="V122.90, U251.90", runways={{name="09", hdg=90}, {name="27", hdg=270}}})}, 
            {name="QABR AS SITT HELIPT", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.458611", "36.357500"), {atc=true, tower="V122.60, U250.95", runways={{name="05", hdg=50}, {name="23", hdg=230}}})},
            {name="DAMASCUS INTL", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.415000", "36.519444"), {atc=true, tower="V118.50, U251.85", runways={{name="05R", hdg=46}, {name="05L", hdg=46}, {name="23R", hdg=226, ils="109.90"}, {name="23L", hdg=226}}})},
            {name="MARJ RUHAYYIL AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.286389", "36.457222"), {atc=true, tower="V120.80, U250.65", runways={{name="06", hdg=59}, {name="24", hdg=239}}})},
            {name="KHALKHALAH AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.077222", "36.558056"), {atc=true, tower="V122.50, U250.35", runways={{name="07", hdg=72}, {name="15", hdg=147}, {name="25", hdg=252}, {name="33", hdg=327}}})},
            {name="SAYQUAL AB",point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.679816", "37.218204"), {atc=true, tower="V120.40, U251.30", runways={{name="08", hdg=80}, {name="26", hdg=260}}})},
            {name="SHAYRAT AB",point=veafNamedPoints.addDataToPoint(coord.LLtoLO("34.494819", "36.903173"), {atc=true, tower="V120.20, U251.35", runways={{name="11", hdg=110}, {name="29", hdg=290}}})},
            {name="TIYAS AB",point=veafNamedPoints.addDataToPoint(coord.LLtoLO("34.522645", "37.627498"), {atc=true, tower="V120.50, U251.50", runways={{name="09", hdg=90}, {name="27", hdg=270}}})},

            -- Lebanese Airports
            {name="RENE MOUAWAD AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("34.589444", "36.011389"), {atc=true, tower="V121.00, U251.20", runways={{name="06", hdg=59}, {name="24", hdg=239}}})},
            {name="HAJAR AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("34.283333", "35.680278"),  {atc=true, tower="V121.50, U251.60", runways={{name="02", hdg=25}, {name="20", hdg=205}}})},
            {name="BEIRUT INTL", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.821111", "35.488333"), {atc=true, tower="V118.90, U251.80", runways={{name="03", hdg=30, ils="110.70"}, {name="16", hdg=164, ils="110.10"}, {name="17", hdg=175, ils="109.50"}, {name="21", hdg=210}, {name="34", hdg=344}, {name="35", hdg=355}}})},
            {name="RAYAK AB", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.852222", "35.990278"),  {atc=true, tower="V124.40, U251.15", runways={{name="04", hdg=42}, {name="22", hdg=222}}})},
            {name="NAQOURA HELIPT",point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.107877", "35.127728"), {atc=true, tower="V122.00, U251.70"})},

            -- Israeli Airports
            {name="KIRYAT SHMONA AIRPORT", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("33.216667", "35.596667"), {atc=true, tower="V118.40, U250.50", runways={{name="03", hdg=34}, {name="21", hdg=214}}})},
            {name="HAIFA INTL", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("32.809167", "35.043056"), {atc=true, tower="V127.80, U250.15", runways={{name="16", hdg=158}, {name="34", hdg=338}}})},
            {name="RAMAT DAVID INTL", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("32.665000", "35.179444"), {atc=true, tower="V118.60, U251.05", runways={{name="09", hdg=85}, {name="11", hdg=107}, {name="15", hdg=143}, {name="27", hdg=265}, {name="29", hdg=287}, {name="33", hdg=323}}})}, 
            {name="MEGIDDO AIRFIELD", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("32.597222", "35.228611"), {atc=true, tower="V119.90, U250.70", runways={{name="09", hdg=89}, {name="27", hdg=269}}})}, 
            {name="EYN SHEMER AIRFIELD", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("32.440556", "35.007500"), {atc=true, tower="V123.40, U250.00", runways={{name="09", hdg=96}, {name="27", hdg=276}}})}, 

            -- Jordan Airports
            {name="KING HUSSEIN AIR COLLEGE", point=veafNamedPoints.addDataToPoint(coord.LLtoLO("32.356389", "36.259167"), {atc=true, tower="V118.30, U250.40", runways={{name="13", hdg=128}, {name="31", hdg=308}}})},
            {name="H4",point=veafNamedPoints.addDataToPoint(coord.LLtoLO("32.539122", "38.195841"), {atc=true, tower="V122.60, U250.10", runways={{name="10", hdg=100}, {name="28", hdg=280}}})}, 
        }
        veafNamedPoints.addAllSyriaCities()
    elseif theatre == "caucasus" then
        veafNamedPoints.Points = {
            -- airbases in Georgia
            {name="AIRBASE Batumi",  point={x=-356437,y=0,z=618211, atc=true, tower="V131, U260", tacan="16X BTM", runways={{name="13", hdg=125, ils="110.30"}, {name="31", hdg=305}}}},
            {name="AIRBASE Gudauta", point={x=-196850,y=0,z=516496, atc=true, tower="V130, U259", runways={ {name="15", hdg=150}, {name="33", hdg=330}}}},
            {name="AIRBASE Kobuleti",point={x=-318000,y=0,z=636620, atc=true, tower="V133, U262", tacan="67X KBL", runways={ {name="07", hdg=69, ils="111.50"}}}},
            {name="AIRBASE Kutaisi", point={x=-284860,y=0,z=683839, atc=true, tower="V134, U264", tacan="44X KTS", runways={ {name="08", hdg=74, ils="109.75"}, {name="26", hdg=254}}}},
            {name="AIRBASE Senaki",  point={x=-281903,y=0,z=648379, atc=true, tower="V132, U261", tacan="31X TSK", runways={ {name="09", hdg=94, ils="108.90"}, {name="27", hdg=274}}}},
            {name="AIRBASE Sukhumi", point={x=-221382,y=0,z=565909, atc=true, tower="V129, U258", runways={{name="12", hdg=116}, {name="30", hdg=296}}}},
            {name="AIRBASE Tbilisi", point={x=-314926,y=0,z=895724, atc=true, tower="V138, U267", tacan="25X GTB", runways={{name="13", hdg=127, ils="110.30"},{name="31", hdg=307, ils="108.90"}}}},
            {name="AIRBASE Vaziani", point={x=-319000,y=0,z=903271, atc=true, tower="V140, U269", tacan="22X VAS", runways={ {name="13", hdg=135, ils="108.75"}, {name="31", hdg=315, ils="108.75"}}}},
            -- airbases in Russia
            {name="AIRBASE Anapa - Vityazevo",   point={x=-004448,y=0,z=244022, atc=true, tower="V121, U250" , runways={ {name="22", hdg=220}, {name="04", hdg=40}}}},
            {name="AIRBASE Beslan",              point={x=-148472,y=0,z=842252, atc=true, tower="V141, U270", runways={ {name="10", hdg=93, ils="110.50"}, {name="28", hdg=273}}}},
            {name="AIRBASE Krymsk",              point={x=-007349,y=0,z=293712, atc=true, tower="V124, U253", runways={ {name="04", hdg=39}, {name="22", hdg=219}}}},
            {name="AIRBASE Krasnodar-Pashkovsky",point={x=-008707,y=0,z=388986, atc=true, tower="V128, U257", runways={ {name="23", hdg=227}, {name="05", hdg=47}}}},
            {name="AIRBASE Krasnodar-Center",    point={x=-011653,y=0,z=366766, atc=true, tower="V122, U251", runways={ {name="09", hdg=86}, {name="27", hdg=266}}}},
            {name="AIRBASE Gelendzhik",          point={x=-050996,y=0,z=297849, atc=true, tower="V126, U255", runways={ {hdg=40}, {hdg=220}}}},
            {name="AIRBASE Maykop",              point={x=-027626,y=0,z=457048, atc=true, tower="V125, U254", runways={ {name="04", hdg=40}, {name="22", hdg=220}}}},
            {name="AIRBASE Mineralnye Vody",     point={x=-052090,y=0,z=707418, atc=true, tower="V135, U264", runways={ {name="12", hdg=115, ils="111.70"}, {name="30", hdg=295, ils="109.30"}}}},
            {name="AIRBASE Mozdok",              point={x=-083330,y=0,z=835635, atc=true, tower="V137, U266", runways={ {name="08", hdg=82}, {name="26", hdg=262}}}},
            {name="AIRBASE Nalchik",             point={x=-125500,y=0,z=759543, atc=true, tower="V136, U265", runways={ {name="06", hdg=55}, {name="24", hdg=235, ils="110.50"}}}},
            {name="AIRBASE Novorossiysk",        point={x=-040299,y=0,z=279854, atc=true, tower="V123, U252", runways={ {name="04", hdg=40}, {name="22", hdg=220}}}},
            {name="AIRBASE Sochi",               point={x=-165163,y=0,z=460902, atc=true, tower="V127, U256", runways={ {name="06", hdg=62, ils="111.10"}, {name="24", hdg=242}}}},
        }
        veafNamedPoints.addAllCaucasusCities()
    elseif theatre == "persiangulf" then
        veafNamedPoints.Points = {
        }
        veafNamedPoints.addAllPersianGulfCities()
    elseif theatre == "thechannel" then
        veafNamedPoints.Points = {
        }
        veafNamedPoints.addAllTheChannelCities()
    elseif theatre == "marianaislands" then
        veafNamedPoints.Points = {
            -- airbases in Blue Island
            {name="AIRBASE Andersen AFB",  point={x=-010688,y=0,z=014822, atc=true, tower="V126.2, U250.1", tacan="54X", runways={{name="06", hdg=66}, {name="24", hdg=246}}}},
            {name="AIRBASE Antonio B. Won Pat Intl", point={x=-000068,y=0,z=-000109, atc=true, tower="V118.1, U340.2", runways={ {name="6", hdg=65, ils="110.30"}, {name="24", hdg=245}}}},
            {name="AIRBASE Olf Orote",point={x=-005047,y=0,z=-016913, atc=false}},
            {name="AIRBASE Santa Rita",point={x=-013576,y=0,z=-009925, atc=false}},
            
            -- airbases in Neutral Island
            {name="AIRBASE Rota Intl", point={x=-075886,y=0,z=048612, atc=true, tower="V123.6, U250", tacan="44X KTS", runways={ {name="09", hdg=92, ils="109.75"}, {name="27", hdg=272}}}},
            
            -- airbases in Red Island
            {name="AIRBASE Tinian Intl",  point={x=-166865,y=0,z=090027, atc=true, tower="V123.65, U250.05", tacan="31X TSK", runways={ {name="0", hdg=94, ils="108.90"}, {name="27", hdg=274}}}},
            {name="AIRBASE Saipan Intl", point={x=180074,y=0,z=101921, atc=true, tower="V125.7, U256.9", runways={{name="07", hdg=68, ils="109.90"}, {name="25", hdg=248}}}},
        }
        veafNamedPoints.addAllMarianasIslandsCities()
    else
        veaf.loggers.get(veaf.Id):warn(string.format("theatre %s is not yet supported by veafNamedPoints", theatre))
    end
    -- points of interest
    table.insert(veafNamedPoints.Points,
        {name="RANGE Kobuleti",point={x=-328289,y=0,z=631228}}
    )
    veafNamedPoints.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure SECURITY
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafSecurity then
    veafSecurity.password_L9["6ade6629f9219d87a011e7b8fbf8ef9584f2786d"] = true -- set the L9 password (the lowest possible security)
    veaf.loggers.get(veaf.Id):info("Loading configuration")
    veaf.loggers.get(veaf.Id):info("init - veafSecurity")
    veafSecurity.initialize()

    -- force security in order to test it when dynamic loading is in place (change to TRUE)
    if (false) then
        veaf.SecurityDisabled = false
        veafSecurity.authenticated = false
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure CARRIER OPERATIONS
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafCarrierOperations then
    veaf.loggers.get(veaf.Id):info("init - veafCarrierOperations")
    veafCarrierOperations.initialize(true)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure CTLD
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if ctld then
    veaf.loggers.get(veaf.Id):info("init - ctld")
    ctld.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize the remote interface
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafRemote then
    veaf.loggers.get(veaf.Id):info("init - veafRemote")
    veafRemote.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize Skynet-IADS
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafSkynet then
    veaf.loggers.get(veaf.Id):info("init - veafSkynet")
    veafSkynet.initialize(
        false, --includeRedInRadio=true
        false, --debugRed
        false, --includeBlueInRadio
        false --debugBlue
    )
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize the interpreter
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafInterpreter then
    veaf.loggers.get(veaf.Id):info("init - veafInterpreter")
    veafInterpreter.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize veafSanctuary
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafSanctuary then
    veaf.loggers.get(veaf.Id):info("init - veafSanctuary")
    veafSanctuary.addZone(
        VeafSanctuaryZone.new()
        :setName("Blue Sanctuary")
        :setPolygonFromUnitsInSequence("BlueSanctuary", true)
        :setCoalition(coalition.side.BLUE)
        :setDelayWarning(0)    -- warning when the plane is detected in the zone 
        :setDelaySpawn(-1)     -- start spawning defense systems
        :setDelayInstant(60)  -- instant death 
        :setMessageWarning("Warning, %s : you've entered a sanctuary zone and will be destroyed in %d seconds if you don't leave IMMEDIATELY")
        :setProtectFromMissiles() 
    )
    veafSanctuary.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize Hound Elint
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafHoundElint and false then -- don't use Hound Elint
    veaf.loggers.get(veaf.Id):info("init - veafHoundElint")
    veafHoundElint.initialize(
        "ELINT", -- prefix
        { -- red
            --global parameters
            markers = true, --enables or disables markers on the map for detected radars
            disableBDA = false, --disables notifications that a radar has dropped off scope
            platformPositionErrors = true, --enables INS drift / GPS errors for ELINT platforms
            NATOmessages = false, --provides positions relative to the bullseye
            NATO_SectorCallsigns = false, --uses a different pool for sector callsigns
            ATISinterval = 180, --refresh delay of the ATIS, beware that this has an impact on performance
            preBriefedContacts = {
                --"Stuff",
                --"Thing",
            }, --contains the name of units placed in the ME which will be designated as pre-briefed (exact location) and who's position will be indicated exactly by Hound until the unit moved 100m away
            debug = false, --set this to true to make sure your configuration is correct and working as intended
        },
        { -- blue
            sectors = {
                --Global sector, mandatory inclusion if you want a global ATIS/controller etc., encompasses the whole map so it'll be very crowded in terms of comms
                [veafHoundElint.globalSectorName] = {
                    callsign = "Global Sector", --defines a specific callsign for the sector which will be used by the ATIS etc., if absent or nil Hound will assign it a callsign automatically, NATO format of regular Hound format. If true, callsign will be equal to the sector name
                    atis = {
                        freq = 282.175,
                        speed = 1,
                        --additional params
                        reportEWR = false --enables or disables the ATIS announcing EWRs as threats instead of it giving a very short message for such radars
                    },
                    controller = {
                        freq = 282.225,
                        --additional params
                        voiceEnabled = true --enables or disables voice for the controller which will otherwise be text only
                    },
                    notifier = {
                        freq = 282.2,
                        --additional params
                    },
                    disableAlerts = false, --disables alerts on the ATIS/Controller when a new radar is detected or destroyed
                    transmitterUnit = nil, --use the Unit/Pilot name to set who the transmitter is for the ATIS etc. This can be a static, and aircraft or a vehicule/ship
                    disableTTS = false,
                },
                --sector named "Maykop", will be geofenced to the mission editor drawing called "Maykop" (case sensitive)
                ["Maykop"] = {
                    callsign = true, --defines a specific callsign for the sector which will be used by the ATIS etc., if absent or nil Hound will assign it a callsign automatically, NATO format of regular Hound format. If true, callsign will be equal to the sector name
                    atis = {
                        freq = 281.075,
                        speed = 1,
                        --additional params
                        reportEWR = false --enables or disables the ATIS announcing EWRs as threats instead of it giving a very short message for such radars
                    },
                    controller = {
                        freq = 281.125,
                        --additional params
                        voiceEnabled = true --enables or disables voice for the controller which will otherwise be text only
                    },
                    notifier = {
                        freq = 281.1,
                        --additional params
                    },
                    disableAlerts = false, --disables alerts on the ATIS/Controller when a new radar is detected or destroyed
                    transmitterUnit = nil, --use the Unit/Pilot name to set who the transmitter is for the ATIS etc. This can be a static, and aircraft or a vehicule/ship
                    disableTTS = false,
                },
            },
            --global parameters
            markers = true, --enables or disables markers on the map for detected radars
            disableBDA = false, --disables notifications that a radar has dropped off scope
            platformPositionErrors = true, --enables INS drift / GPS errors for ELINT platforms
            NATOmessages= true, --provides positions relative to the bullseye
            NATO_SectorCallsigns = true, --uses a different pool for sector callsigns
            ATISinterval = 180, --refresh delay of the ATIS, beware that this has an impact on performance
            preBriefedContacts = {
                "RED-EWR-NW",
                "RED-EWR-S",
                "RED-EWR-NE",
                "RED-EWR-E",
                --"Stuff",
                --"Thing",
            }, --contains the name of units or groups placed in the ME which will be designated as pre-briefed (exact location) and who's position will be indicated exactly by Hound until the unit moved 100m away. If multiple radars are within a specified group, they'll all be added as pre-briefed targets
            debug = false, --set this to true to make sure your configuration is correct and working as intended
        }
        --this is the entire range of possible entries for the notifier, the controller and the ATIS settings
        -- args = {
        --     freq = 250.000,
        --     modulation = "AM",
        --     volume = "1.0",
        --     speed = <speed> -- number default is 0/1 for controller/atis. range is -10 to +10 on windows TTS. for google it's 0.25 to 4.0
        --     gender = "male"|"female",
        --     culture = "en-US"|"en-UK" -- (any installed on your system)
        --     isGoogle = true/false -- use google TTS (requires additional STTS config)
        --     voiceEnabled = true/false (for the controller only) -- to set if the controllers uses text or TTS
        --     reportEWR = true/false (for ATIS only) -- set to tell the ATIS to report EWRs as threats
        --     enableBDA = true/false (true by default) -- set to enable BDA/emissions drop on radars
        -- }
    )

    -- automatically start the two ELINT missions
    veafCombatMission.ActivateMission("ELINT-Mission-East", true)
    veafCombatMission.ActivateMission("ELINT-Mission-West", true)
end   


-- Silence ATC on all the airdromes
veaf.silenceAtcOnAllAirbases()

-- automatically activate the Maykop Defenses zone
veafCombatZone.ActivateZone("combatZone_MaykopDefenses", true)

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mission C002 - Neutralisation des lacs de Tkibuli - https://github.com/VEAF/VEAF-Open-Training-Mission/wiki/Mission-C002
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veafShortcuts.AddAlias(
    VeafAlias:new()
        :setName("-c002-1")
        :setDescription("Mission C002 - 1 - before mission start")
        :setBatchAliases({
            "-shell#U38TLM3120086100",
            "-shell#U38TLM3155087960",
            "-point#U38TLM3167086723 C503-1",
        })
        :setPassword("5990da82192566a785187a8276a2ccf61c2b5819") -- briefingcaucasus21
)

veafShortcuts.AddAlias(
    VeafAlias:new()
        :setName("-c002-2")
        :setDescription("Mission C002 - 2 - before takeoff")
        :setBatchAliases({
            "-transport#U38TLM3167086723, side red, size 5, defense 1, dest haristvala, patrol, spacing 0.5",
            "-transport#U38TLM3894597626, side red, size 7, defense 0, dest C503-1, patrol, spacing 0.5",
            "-infantry#U38TLM3129085430, side red, size 10, defense 0, spacing 0.5",
            "-zu23#U38TLM3314088860, side red, radius 1000",
            "-transport#U38TLM3342089320, side red, size 10, defense 0, spacing 0.5",
        })
        :setPassword("5990da82192566a785187a8276a2ccf61c2b5819") -- briefingcaucasus21
)

veafShortcuts.AddAlias(
    VeafAlias:new()
        :setName("-c002-3")
        :setDescription("Mission C002 - 3 - optional (more defenses)")
        :setBatchAliases({
            "-zu23#U38TLM3314088860, side red, radius 1000",
            "-zu23#U38TLM3314088860, side red, radius 1000",
            "-infantry#U38TLM3129085430, side red, size 10, defense 4, spacing 0.5",
        })
        :setPassword("5990da82192566a785187a8276a2ccf61c2b5819") -- briefingcaucasus21
)

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mission C003 - Frappe d'une usine en profondeur - https://github.com/VEAF/VEAF-Open-Training-Mission/wiki/Mission-C003
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veafShortcuts.AddAlias(
    VeafAlias:new()
        :setName("-c003")
        :setDescription("Mission C003 - before takeoff")
        :setBatchAliases({
            "-sa8#U37TGJ3229065410!2400, radius 1500",
            "-sa13#U37TGJ3229065410!2400, radius 1500",
            "-sa6#U37TGJ3263068240!2400",
            "-sa13#U37TGJ3263068240!2400, radius 2000",
            "-sa6#U37TGJ1513065710!2400",
            "-sa8#U37TGJ3200067600!2400",
            "-sa8#U37TGJ3405061500!2400 ",
        })
        :setPassword("5990da82192566a785187a8276a2ccf61c2b5819") -- briefingcaucasus21
)

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mission C004 - Strike sur ponts et FOB - https://github.com/VEAF/VEAF-Open-Training-Mission/wiki/Mission-C004
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veafShortcuts.AddAlias(
    VeafAlias:new()
        :setName("-c004")
        :setDescription("Mission C004 - before mission start")
        :setBatchAliases({
            "-infantry#U38TMN2703021480, side red, size 10, defense 2, spacing 0.5, armor 1",
            "-infantry#U38TMN2529820390, side red, size 10, defense 2, spacing 0.5, armor 1",
            "-armor#U38TMN1520028060, side red, size 5, defense 5",
            "-transport#U38TMN1512028000, side red, size 5, defense 0, spacing 0.5",
            "-transport#U38TMN1845038290, side red, defense 4",
            "-transport#U38TMN2703021480, side red, dest U38TMN1644527965, patrol, size 7, defense 2",
            "-transport#U38TMN1845038290, side red, dest U38TMN2529820390, patrol, size 10, spacing 0.5",
        })
        :setPassword("5990da82192566a785187a8276a2ccf61c2b5819") -- briefingcaucasus21
)

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mission C102 - Projection rapide de troupes - https://github.com/VEAF/VEAF-Open-Training-Mission/wiki/Mission-C102
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veafShortcuts.AddAlias(
    VeafAlias:new()
        :setName("-c102")
        :setDescription("Mission C102 - before mission start")
        :setBatchAliases({
            "-transport#U38TMN2898519805!1200, side red, size 10, defense 0, dest kvemosba, spacing 0.5",
            "-armor#U38TMN2900019800!1200, side red, size 2, defense 0, dest kvemosba, spacing 0.5, armor 1",
        })
        :setPassword("5990da82192566a785187a8276a2ccf61c2b5819") -- briefingcaucasus21
)

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mission C501 - EVASAN d'urgence - https://github.com/VEAF/VEAF-Open-Training-Mission/wiki/Mission-C501
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veafShortcuts.AddAlias(
    VeafAlias:new()
        :setName("-c501")
        :setDescription("Mission C501 - before takeoff")
        :setBatchAliases({
            "-longsmoke#U38TLM1300041700, repeat 10, color blue", -- 60 minutes of blue smoke
            "-infantry#U38TLM1301041710, side blue, size 5",
            "-convoy#U38TLM2040053930, side red, size 7, defense 2, dest kursairme",
            "-convoy#U38TLM2738549911, side red, size 5, defense 1, dest kursairme",          
        })
        :setPassword("5990da82192566a785187a8276a2ccf61c2b5819") -- briefingcaucasus21
)

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mission C502 - Escorter le convoi - https://github.com/VEAF/VEAF-Open-Training-Mission/wiki/Mission-C502
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veafShortcuts.AddAlias(
    VeafAlias:new()
        :setName("-c502")
        :setDescription("Mission C502 - before takeoff")
        :setBatchAliases({
            "-infantry#U37TEJ78702220, armor 0, defense 0, multiplier 3, side red",
            "-infantry#U37TEJ81432718, defense 0, multiplier 3, side red",
            "-infantry#U37TEJ84873017, defense 0, multiplier 3, side red",
            "-infantry#U37TEJ87673163, defense 1, armor 2, multiplier 2, side red",
            "-armor#U37TEJ90003260, defense 1, side red",
            "-infantry#U37TEJ90003260, side red",
            "-convoy#U37TEJ74911126, side blue, armor 0, defense 0, dest FARP KRASNAYA EJ93",
        })
        :setPassword("5990da82192566a785187a8276a2ccf61c2b5819") -- briefingcaucasus21
)

veafShortcuts.AddAlias(
    VeafAlias:new()
        :setName("-c502-help")
        :setDescription("Mission C502 - smoke markers (if needed)")
        :setBatchAliases({
            "-smoke#U37TEJ78702220, color red",
            "-smoke#U37TEJ81432718, color red",
            "-smoke#U37TEJ84873017, color red",
            "-smoke#U37TEJ87673163, color red",
            "-smoke#U37TEJ90003260, color red",
        })
        :setPassword("5990da82192566a785187a8276a2ccf61c2b5819") -- briefingcaucasus21
)
