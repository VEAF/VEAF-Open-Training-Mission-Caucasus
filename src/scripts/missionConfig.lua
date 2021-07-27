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
if veaf then
    VeafQRA.new()
    :setName("QRA_Minevody")
    :addGroup("QRA_Minevody")
    :setRadius(106680) -- 350,000 feet
    :setCoalition(coalition.side.RED)
    :addEnnemyCoalition(coalition.side.BLUE)
    :setReactOnHelicopters()
    :start()

    VeafQRA.new()
    :setName("QRA_Krasnodar")
    :addGroup("QRA_Krasnodar")
    :setRadius(106680) -- 350,000 feet
    :setCoalition(coalition.side.RED)
    :addEnnemyCoalition(coalition.side.BLUE)
    :setReactOnHelicopters()
    :start()
end

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
		-- list the assets common to all missions below
		{sort=1, name="CSG-01 Tarawa", description="Tarawa (LHA)", information="Tacan 11X TAA\nU226 (11)"},  
		{sort=2, name="CSG-74 Stennis", description="Stennis (CVN)", information="Tacan 10X STS\nICLS 10\nU225 (10)"},  
		{sort=2, name="CSG-71 Roosevelt", description="Roosevelt (CVN)", information="Tacan 12X RHR\nICLS 11\nU227 (12)"},  
		{sort=3, name="T1-Arco-1", description="Arco-1 (KC-135)", information="Tacan 64Y\nU290.50 (20)\nZone OUEST", linked="T1-Arco-1 escort"}, 
		{sort=4, name="T2-Shell-1", description="Shell-1 (KC-135 MPRS)", information="Tacan 62Y\nU290.30 (18)\nZone EST", linked="T2-Shell-1 escort"},  
		{sort=5, name="T3-Texaco-1", description="Texaco-1 (KC-135 MPRS)", information="Tacan 60Y\nU290.10 (17)\nZone OUEST", linked="T3-Texaco-1 escort"},  
		{sort=6, name="T4-Shell-2", description="Shell-2 (KC-135)", information="Tacan 63Y\nU290.40 (19)\nZone EST", linked="T4-Shell-2 escort"},  
		{sort=6, name="T5-Petrolsky", description="900 (IL-78M, RED)", information="U267", linked="T5-Petrolsky escort"},  
		{sort=7, name="CVN-74 Stennis S3B-Tanker", description="Texaco-7 (S3-B)", information="Tacan 75X\nU290.90\nZone PA"},  
		{sort=7, name="CVN-71 Roosevelt S3B-Tanker", description="Texaco-8 (S3-B)", information="Tacan 76X\nU290.80\nZone PA"},  
		{sort=8, name="Bizmuth", description="Colt-1 AFAC Bizmuth (MQ-9)", information="L1688 V118.80 (18)", jtac=1688, freq=118.80, mod="am"},
		{sort=9, name="Agate", description="Dodge-1 AFAC Agate (MQ-9)", information="L1687 V118.90 (19)", jtac=1687, freq=118.90, mod="am"},  
		{sort=10, name="A1-Magic", description="Magic (E-2D)", information="Datalink 315.3 Mhz\nU282.20 (13)", linked="A1-Magic escort"},  
		{sort=11, name="A2-Overlordsky", description="Overlordsky (A-50, RED)", information="V112.12"},  
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

		-- points of interest
		{name="RANGE Kobuleti",point={x=-328289,y=0,z=631228}},
	}

    veaf.loggers.get(veaf.Id):info("Loading configuration")

    veaf.loggers.get(veaf.Id):info("init - veafNamedPoints")
    veafNamedPoints.initialize()
    if theatre == "syria" then
        veafNamedPoints.addAllSyriaCities()
    elseif theatre == "caucasus" then
        veafNamedPoints.addAllCaucasusCities()
    elseif theatre == "persiangulf" then
        veafNamedPoints.addAllPersianGulfCities()
    elseif theatre == "thechannel" then
        veafNamedPoints.addAllTheChannelCities()
    elseif theatre == "marianaislands" then
        veafNamedPoints.addAllMarianasIslandsCities()
    else
        veaf.loggers.get(veaf.Id):warn(string.format("theatre %s is not yet supported by veafNamedPoints", theatre))
    end
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
    ctld.pickupZones = {
        { "pickzone1", "none", -1, "yes", 0 },
        { "pickzone2", "none", -1, "yes", 0 },
        { "pickzone3", "none", -1, "yes", 0 },
        { "pickzone4", "none", -1, "yes", 0 },
        { "pickzone5", "none", -1, "yes", 0 },
        { "pickzone6", "none", -1, "yes", 0 },
        { "pickzone7", "none", -1, "yes", 0 },
        { "pickzone8", "none", -1, "yes", 0 },
        { "pickzone9", "none", -1, "yes", 0 }, 
        { "pickzone10", "none", -1, "yes", 0 },
        { "pickzone11", "none", -1, "yes", 0 }, 
        { "pickzone12", "none", -1, "yes", 0 }, 
        { "pickzone13", "none", -1, "yes", 0 }, 
        { "pickzone14", "none", -1, "yes", 0 },
        { "pickzone15", "none", -1, "yes", 0 },
        { "pickzone16", "none", -1, "yes", 0 },
        { "pickzone17", "none", -1, "yes", 0 },
        { "pickzone18", "none", -1, "yes", 0 },
        { "pickzone19", "none", 5, "yes", 0 },
        { "pickzone20", "none", 10, "yes", 0, 1000 }, -- optional extra flag number to store the current number of groups available in

        { "CVN-74 Stennis", "none", 10, "yes", 0, 1001 }, -- instead of a Zone Name you can also use the UNIT NAME of a ship
        { "LHA-1 Tarawa", "none", 10, "yes", 0, 1002 }, -- instead of a Zone Name you can also use the UNIT NAME of a ship
    }

    -- ******************** Transports names **********************

    -- Use any of the predefined names or set your own ones
    ctld.transportPilotNames = {}

    for i = 1, 24 do
        table.insert(ctld.transportPilotNames, string.format("yak #%03d",i))
    end

    for i = 1, 10 do
        table.insert(ctld.transportPilotNames, string.format("transport #%03d",i))
    end

    for i = 1, 79 do
        table.insert(ctld.transportPilotNames, string.format("helicargo #%03d",i))
    end

    -- ************** Logistics UNITS FOR CRATE SPAWNING ******************

    -- Use any of the predefined names or set your own ones
    -- When a logistic unit is destroyed, you will no longer be able to spawn crates

    ctld.logisticUnits = {
        "logistic #001",
        "logistic #002",
        "logistic #003",
        "logistic #004",
        "logistic #005",
        "logistic #006",
        "logistic #007",
        "logistic #008",
        "logistic #009",
        "logistic #010",
        "logistic #011",
        "logistic #012",
        "logistic #013",
        "logistic #014",
        "logistic #015",
        "logistic #016",
        "logistic #017",
        "logistic #018",
        "logistic #019",
        "logistic #020",
    }

    if veafTransportMission then

        -- automatically add all the human-manned transport helicopters to ctld.transportPilotNames
        veafTransportMission.initializeAllHelosInCTLD()

        -- automatically add all the carriers and FARPs to ctld.logisticUnits
        veafTransportMission.initializeAllLogisticInCTLD()
    end
    
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
-- initialize the interpreter
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafInterpreter then
    veaf.loggers.get(veaf.Id):info("init - veafInterpreter")
    veafInterpreter.initialize()
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
if veafHoundElint then
    veaf.loggers.get(veaf.Id):info("init - veafHoundElint")
    veafHoundElint.initialize(
        "ELINT", -- prefix
        { -- red
            admin = false,
            markers = true,
            atis = false,
            controller = false
        },
        { -- blue
            admin = false,
            markers = true,
            atis = {
                freq = 282.125,
                interval = 15,
                speed = 1,
                reportEWR = false
            },
            controller = {
                freq = 282.225,
                voiceEnabled = true
            }
        }
    )
end

-- automatically activate the Maykop Defenses zone
veafCombatZone.ActivateZone("combatZone_MaykopDefenses", true)

-- automatically start the two ELINT missions
veafCombatMission.ActivateMission("ELINT-Mission-East", true)
veafCombatMission.ActivateMission("ELINT-Mission-West", true)

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
