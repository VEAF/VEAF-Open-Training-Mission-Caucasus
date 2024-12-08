-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mission configuration file for the VEAF framework
-- see https://github.com/VEAF/VEAF-Mission-Creation-Tools
--
-- This configuration is tailored for the Caucasus OpenTraining mission
-- see https://github.com/VEAF/VEAF-Open-Training-Mission
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veaf.config.MISSION_NAME = "OpenTraining_Caucasus"
veaf.config.MISSION_EXPORT_PATH = nil -- use default folder

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize QRA
-------------------------------------------------------------------------------------------------------------------------------------------------------------

if veafQraManager then
VeafQRA.ToggleAllSilence(true) --this will set all QRA messages ON if the argument is "true" and all QRA messages to OFF is the argument is "false".

    --red

    if veaf then
        QRA_Minevody = VeafQRA:new()
        :setName("QRA_Minevody")
        :setCoalition(coalition.side.RED)
        :addEnnemyCoalition(coalition.side.BLUE)
        :setTriggerZone("QRA_Minevody")
        :setRandomGroupsToDeployByEnemyQuantity(1, { "QRA_Minevody-1", "QRA_Minevody-2", "QRA_Minevody-3" }, 1) -- 1 human in the zone
        :setRandomGroupsToDeployByEnemyQuantity(2, { "QRA_Minevody-4", "QRA_Minevody-5", "QRA_Minevody-6" }, 1) -- 1 human in the zone
        :setDelayBeforeRearming(10) -- seconds before the QRA is rearmed
        :setDelayBeforeActivating(60) -- seconds before the QRA is activated, since the first enemy enters the zone
        :setReactOnHelicopters() --Sets if the QRA reacts to helicopters entering the zone
        :start()
    end
    
    if veaf then
        QRA_Krasnodar = VeafQRA:new()
        :setName("QRA_Krasnodar")
        :setCoalition(coalition.side.RED)
        :addEnnemyCoalition(coalition.side.BLUE)
        :setTriggerZone("QRA_Krasnodar")
        :setRandomGroupsToDeployByEnemyQuantity(1, { "QRA_Krasnodar-1", "QRA_Krasnodar-2", "QRA_Krasnodar-3" }, 1) -- 1 human in the zone
        :setRandomGroupsToDeployByEnemyQuantity(2, { "QRA_Krasnodar-4", "QRA_Krasnodar-5", "QRA_Krasnodar-6" }, 1) -- 1 human in the zone
        :setDelayBeforeRearming(10) -- seconds before the QRA is rearmed
        :setDelayBeforeActivating(60) -- seconds before the QRA is activated, since the first enemy enters the zone
        :setReactOnHelicopters() --Sets if the QRA reacts to helicopters entering the zone
        :setAirportLink("Krasnodar-Pashkovsky")
        :start()
    end

    --blue
    
    QRA_Kutaisi = VeafQRA:new()
    :setName("QRA_Kutaisi")
    :setTriggerZone("QRA_Kutaisi")
    :setZoneRadius(106680) -- 350,000 feet
    :addGroup("QRA_Kutaisi")
    :setAirportLink("Kutaisi")
    :setCoalition(coalition.side.BLUE)
    :addEnnemyCoalition(coalition.side.RED)
    :start()

    QRA_Gudauta = VeafQRA:new()
    :setName("QRA_Gudauta")
    :setTriggerZone("QRA_Gudauta")
    :setZoneRadius(106680) -- 350,000 feet
    :addGroup("QRA_Gudauta")
    :setAirportLink("Gudauta")
    :setCoalition(coalition.side.BLUE)
    :addEnnemyCoalition(coalition.side.RED)
    :start()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize all the scripts
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafRadio then
    -- the RADIO module is mandatory as it is used by many other modules
    veaf.loggers.get(veaf.Id):info("init - veafRadio")
    veafRadio.initialize(true)
end
if veafSpawn then
    -- the SPAWN module is mandatory as it is used by many other modules
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
if veafWeather then
    veaf.loggers.get(veaf.Id):info("init - veafWeather")
    veafWeather.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- change some default parameters
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veaf.DEFAULT_GROUND_SPEED_KPH = 25

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize SHORTCUTS
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafShortcuts then
    -- the SHORTCUTS module is mandatory as it is used by many other modules
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
		{sort=1, name="CSG-01 Tarawa", description="Tarawa (LHA)", information="Tacan 11X TAA\nICLS 11\nU226 (11)"},
		{sort=2, name="CSG-74 Stennis", description="Stennis (CVN)", information="Tacan 10X STS\nICLS 10\nU225 (10)\nLink4 225MHz\nACLS available"},  
		{sort=3, name="CSG-71 Roosevelt", description="Roosevelt (CVN)", information="Tacan 12X RHR\nICLS 12\nU227 (12)\nLink4 227MHz\nACLS available"},
		{sort=4, name="CSG-59 Forrestal", description="Forrestal (CV)", information="Tacan 13X FRT\nICLS 13\nU228 (13)\nLink4 228MHz\nACLS available"},
        {sort=6, name="CSG Kuznetsov", description="Kuznetsov (CV)", information="V121.5 (1)"},

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
    -- keeping the veafMove.Tankers table empty will force veafMove.initialize() to browse the units, and find the tankers automatically
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
		VeafCombatMission:new()
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
			VeafCombatMissionElement:new()
			:setName("OnDemand-Intercept-Transport-Krasnodar-Mineral-Transport")
            :setGroups({"OnDemand-Intercept-Transport-Krasnodar-Mineral-Transport"})
            :setScalable(false)
		)
		:addElement(
			VeafCombatMissionElement:new()
			:setName("OnDemand-Intercept-Transport-Krasnodar-Mineral-Escort")
            :setGroups({"OnDemand-Intercept-Transport-Krasnodar-Mineral-Escort"})
            :setSkill("Random")
		)
		:addObjective(
			VeafCombatMissionObjective:new()
			:setName("Destroy the transport")
			:setDescription("you must destroy the transport and kill the VIP")
			:setMessage("%d transport planes destroyed !")
			:configureAsKillEnemiesObjective() -- TODO
		)
		:initialize()
	)

    veafCombatMission.AddMission(
		VeafCombatMission:new()
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
			VeafCombatMissionElement:new()
			:setName("SEAD")
			:setGroups({
				"Red Attack On Gudauta - Wave 1-1", 
				"Red Attack On Gudauta - Wave 1-2", 
				"Red Attack On Gudauta - Wave 1-3", 
				"Red Attack On Gudauta - Wave 1-4" })
			:setSkill("Random")
		)
		:addElement(
			VeafCombatMissionElement:new()
			:setName("Bombers")
			:setGroups({
				"Red Attack On Gudauta - Wave 2-1",
                "Red Attack On Gudauta - Wave 2-2", 
                "Red Attack On Gudauta - Wave 2-3" })
			:setSkill("Random")
		)
		:addObjective(
			VeafCombatMissionObjective:new()
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
			VeafCombatMissionObjective:new()
			:setName("Kill all the bombers")
			:setDescription("you must kill all of the bombers")
			:setMessage("%d bombers destroyed !")
			:configureAsKillEnemiesObjective()
		)
		:initialize()
	)

	veafCombatMission.AddMission(
		VeafCombatMission:new()
		:setName("Training-Bomber-1-slow")
		:setFriendlyName("Training - Bomber Scenario 1 - slow Tu-160")
		:setBriefing([[
You're head-on at 25nm with 11 Tu-160, FL200, Mach 0.8.
Destroy them all in less than 10 minutes !]])
		:addElement(
			VeafCombatMissionElement:new()
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
			VeafCombatMissionObjective:new()
			:setName("< 15 minutes")
			:setDescription("the mission will be over after 15 minutes")
			:setMessage("the 15 minutes have passed !")
			:configureAsTimedObjective(900)
		)
		:addObjective(
			VeafCombatMissionObjective:new()
			:setName("Kill all the bombers")
			:setDescription("you must kill or route all bombers")
			:setMessage("%d bombers destroyed or routed !")
			:configureAsKillEnemiesObjective(-1, 50)
		)
        :setSecured(false)
		:initialize()
	)

    veafCombatMission.AddMission(
		VeafCombatMission:new()
		:setName("ELINT-Mission-West")
		:setFriendlyName("ELINT gathering over the West zone")
		:setBriefing([[
ATIS on 282.125, SAM CONTROL on 282.225
A C-130 pair will fly reciprocical headings, trying to pinpoint enemy SAMS.
Don't let them be destroyed by the enemy !]])
		:addElement(
			VeafCombatMissionElement:new()
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
		VeafCombatMission:new()
		:setName("ELINT-Mission-East")
		:setFriendlyName("ELINT gathering over the East zone")
		:setBriefing([[
ATIS on 282.125, SAM CONTROL on 282.225
A C-130 pair will fly reciprocical headings, trying to pinpoint enemy SAMS.
Don't let them be destroyed by the enemy !]])
		:addElement(
			VeafCombatMissionElement:new()
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
		VeafCombatZone:new()
			:setMissionEditorZoneName("combatZone_Psebay_Factory")
			:setFriendlyName("Psebay chemical weapons factory")
			:setBriefing("This factory manufactures chemical weapons for a terrorits group\n" ..
                        "You must destroy both factory buildings, and the bunker where the scientists work\n" ..
                        "The other enemy units are secondary targets\n")
            :setRadioGroupName("Missions")
	)

	veafCombatZone.AddZone(
		VeafCombatZone:new()
			:setMissionEditorZoneName("combatZone_BattleOfBeslan")
			:setFriendlyName("Battle of Beslan")
			:setBriefing("This zone is the place of a battle between red and blue armies.\n" ..
                        "You must do what you can to help your side win\n" ..
                        "Please note that there is an enemy convoy coming from the west and going to Sheripova, that can be ambushed by the blue forces at Malgobek in 15-30 minutes. Be wary of the SAM that can hide anywhere in the cities or the forests !\n" ..
                        "Warning : there are air defenses lurking about, you should be cautious !")
            :setRadioGroupName("Missions")
	)

	veafCombatZone.AddZone(
		VeafCombatZone:new()
			:setMissionEditorZoneName("combatZone_SaveTheHostages")
			:setFriendlyName("Hostages at Prohladniy")
			:setBriefing("Hostages are being held in a fortified hotel in the city of Prohladniy.\n" ..
                        "Warning : there are air defenses lurking about, you should be cautious !")
            :setRadioGroupName("Missions")
	)

    veafCombatZone.AddZone(
		VeafCombatZone:new()
			:setMissionEditorZoneName("combatZone_roadBlock")
			:setFriendlyName("Road Block KM91")
			:setBriefing("38T KM946122 - 6300ft - KOB 67X 115/35\nRussia is blocking a main road between Batumi and Tbilisi.\nDestroy bunkers and vehicles.\nENI convoy is comming from the East.")
            :setRadioGroupName("Missions")
	)

	veafCombatZone.AddZone(
		VeafCombatZone:new()
			:setMissionEditorZoneName("combatZone_MaykopDefenses")
			:setFriendlyName("Maykop airbase defenses")
			:setBriefing("The Maykop airbase is defended by a SA10 battalion, point-defense SHORAD and AAA, and armored vehicles\n" ..
                        "You must incapacitate the defenses in order to prepare a land invasion")
            :setRadioGroupName("Missions")
    )

	veafCombatZone.AddZone(
		VeafCombatZone:new()
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
            :setRadioGroupName("Missions")
    )

    -- Training operations
   veafCombatZone.AddZone(
        VeafCombatZone:new()
            :setMissionEditorZoneName("combatZone_EasyPickingsTerek")
            :setFriendlyName("Terek logistics parking")
            :setBriefing("The enemy has parked a lot of logistics at Terek\n" ..
                        "You must destroy all the trucks to impend the advance of their army on Beslan\n" ..
                        "The other enemy units are secondary targets\n"..
                        "This is a more easy zone, with few air defenses. But beware that there is a chance of manpad in the area !")
            :setTraining(true)
            :setRadioGroupName("Training CAS")
    )

    veafCombatZone.AddZone(
        VeafCombatZone:new()
            :setMissionEditorZoneName("combatZone_rangeKobuletiEasy")
            :setFriendlyName("Training at Kobuleti RANGE")
            :setBriefing("The Kobuleti RANGE (located 6 nm south-west of Kobuleti airbase) is set-up for training")
            :setTraining(true)
            :setRadioGroupName("Training CAS")
    )

    veafCombatZone.AddZone(
        VeafCombatZone:new()
            :setMissionEditorZoneName("combatZone_Antiship-Training-Easy")
            :setFriendlyName("Antiship Training - Easy")
            :setBriefing("Undefended cargo ships ready for plunder; Arrrrr! Shiver me timbers!")
            :setRadioGroupName("Training antiship")
    )

    veafCombatZone.AddZone(
        VeafCombatZone:new()
            :setMissionEditorZoneName("combatZone_Antiship-Training-Hard")
            :setFriendlyName("Antiship Training - Hard")
            :setBriefing("Cargo ships defended by escort ships; warning, an FFG 11540 Neustrashimy may escort them as well...")
            :setRadioGroupName("Training antiship")
    )

    veafCombatZone.AddZone(
        VeafCombatZone:new()
            :setMissionEditorZoneName("combatZone_trainingSamAttack_SA15_N")
            :setFriendlyName("Training - SA-15 site - North")
            :setBriefing("There is a static SA-15 in a well-defended zone\n" ..
                            "Its coordinates are : 37T FJ 403 944\n" ..
                            "The training consists on attacking and destroying it without any SEAD support\n" ..
                            "All other units are considered secondary targets")
            :setTraining(true)
            :setRadioGroupName("Training SAM attack")
    )
    
    veafCombatZone.AddZone(
        VeafCombatZone:new()
            :setMissionEditorZoneName("combatZone_trainingSamAttack_SA15_S")
            :setFriendlyName("Training - SA-15 site - South")
            :setBriefing("There is a static SA-15 in a well-defended zone\n" ..
                            "Its coordinates are : 37T FJ 398 933\n" ..
                            "The training consists on attacking and destroying it without any SEAD support\n" ..
                            "All other units are considered secondary targets")
            :setTraining(true)
            :setRadioGroupName("Training SAM attack")
    )

    veafCombatZone.AddZone(
        VeafCombatZone:new()
            :setMissionEditorZoneName("combatZone_trainingSamAttack_SA6")
            :setFriendlyName("Training - SA-6 site")
            :setBriefing("There is a static SA-6 in a well-defended zone\n" ..
                            "Its coordinates are : 37T FJ 404 934\n" ..
                            "The training consists on attacking and destroying it ; it'll be hard without any SEAD support !\n" ..
                            "All other units are considered secondary targets")
            :setTraining(true)
            :setRadioGroupName("Training SAM attack")
    )

    veafCombatZone.AddZone(
        VeafCombatZone:new()
            :setMissionEditorZoneName("combatZone_trainingSamAttack_SA2")
            :setFriendlyName("Training - SA-2 site")
            :setBriefing("There is a static SA-2 in a well-defended zone\n" ..
                            "Its coordinates are : 37T FJ 402 930\n" ..
                            "The training consists on attacking and destroying it ; it'll be hard without any SEAD support !\n" ..
                            "All other units are considered secondary targets")
            :setTraining(true)
            :setRadioGroupName("Training SAM attack")
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
    -- the NAMED POINTS module is mandatory as it is used by many other modules
    veaf.loggers.get(veaf.Id):info("Loading configuration")

    
    -- here you can add points of interest, that will be added to the default points
    local customPoints = {
    	{name="RANGE Kobuleti",point={x=-328289,y=0,z=631228}}
    }
    veaf.loggers.get(veaf.Id):info("init - veafNamedPoints")
    veafNamedPoints.initialize(customPoints)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure SECURITY
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafSecurity then
    -- the SECURITY module is mandatory as it is used by many other modules
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
    function configurationCallback()
        veaf.loggers.get(veaf.Id):info("configuring CTLD for %s", veaf.config.MISSION_NAME)
        -- do what you have to do in CTLD before it is initialized
        -- ctld.hoverPickup = false
        -- ctld.slingLoad = true
      end
    ctld.initialize(configurationCallback)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure CSAR
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if csar then
    veaf.loggers.get(veaf.Id):info("init - csar")
    function configurationCallback()
        veaf.loggers.get(veaf.Id):info("configuring CSAR for %s", veaf.config.MISSION_NAME)
    end
    csar.initialize(configurationCallback)
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
function DeactivateSkynetRed()
    veaf.loggers.get(veaf.Id):info("Deactivate Skynet for RED IADS")
    veafSkynet.monitorDynamicSpawn(false)
    veafSkynet.deactivateNetworkOfCoalition(coalition.side.RED)
end

if veafSkynet then -- don't use
    veafSkynet.PointDefenceMode = veafSkynet.PointDefenceModes.Skynet
    veafSkynet.DynamicSpawn = true
    veafSkynet.addCommandCenterOfCoalition(coalition.side.RED, "Centre de commandement")
    veafSkynet.DelayForStartup = 85
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
    -- the INTERPRETER module is mandatory as it is used by many other modules
    veaf.loggers.get(veaf.Id):info("init - veafInterpreter")
    veafInterpreter.initialize()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize veafSanctuary
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafSanctuary then
    veaf.loggers.get(veaf.Id):info("init - veafSanctuary")
    veafSanctuary.addZone(
        VeafSanctuaryZone:new()
        :setName("Blue Sanctuary")
        :setCoalition(coalition.side.BLUE)
        :setPolygonFromUnitsInSequence("BlueSanctuary", true)
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
if veafHoundElint then
    -- uncomment (and adapt) the following lines to enable Hound Elint
    --[[
    veaf.loggers.get(veaf.Id):info("init - veafHoundElint")
    veafHoundElint.initialize(
        "ELINT", -- prefix
        { -- red
            --global parameters
            sectors = {},
            markers = true,
            disableBDA = false, --disables notifications that a radar has dropped off scope
            platformPositionErrors = true,
            NATOmessages = false, --provides positions relative to the bullseye
            NATO_SectorCallsigns = false, --uses a different pool for sector callsigns
            ATISinterval = 180,
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
                        reportEWR = false
                    },
                    controller = {
                        freq = 282.225,
                        --additional params
                        voiceEnabled = true
                    },
                    notifier = {
                        freq = 282.2,
                        --additional params
                    },
                    disableAlerts = false, --disables alerts on the ATIS/Controller when a new radar is detected or destroyed
                    transmitterUnit = nil, --use the Unit/Pilot name to set who the transmitter is for the ATIS etc. This can be a static, and aircraft or a vehicule/ship
                    disableTTS = false,
                },
                --sector named "Maykop", will be geofenced to the mission editor polygon drawing (free or rectangle) called "Maykop" (case sensitive)
                ["Maykop"] = {
                    callsign = true, --defines a specific callsign for the sector which will be used by the ATIS etc., if absent or nil Hound will assign it a callsign automatically, NATO format of regular Hound format. If true, callsign will be equal to the sector name
                    atis = {
                        freq = 281.075,
                        speed = 1,
                        --additional params
                        reportEWR = false
                    },
                    controller = {
                        freq = 281.125,
                        --additional params
                        voiceEnabled = true
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
            markers = true,
            disableBDA = false, --disables notifications that a radar has dropped off scope
            platformPositionErrors = true,
            NATOmessages= true, --provides positions relative to the bullseye
            NATO_SectorCallsigns = true, --uses a different pool for sector callsigns
            ATISinterval = 180,
            preBriefedContacts = {
                --"Stuff",
                --"Thing",
            }, --contains the name of units or groups placed in the ME which will be designated as pre-briefed (exact location) and who's position will be indicated exactly by Hound until the unit moved 100m away. If multiple radars are within a specified group, they'll all be added as pre-briefed targets
            debug = false, --set this to true to make sure your configuration is correct and working as intended
        }
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
        -- }
    )
    ]]
    -- automatically start the two ELINT missions
    -- veafCombatMission.ActivateMission("ELINT-Mission-East", true)
    -- veafCombatMission.ActivateMission("ELINT-Mission-West", true)
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
