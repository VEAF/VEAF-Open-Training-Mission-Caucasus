-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF COMBAT MISSION configuration script
-- By zip (2020)
--
-- Load the script:
-- ----------------
-- load it in a trigger after loading veafCombatMission and before calling veafCombatMission.initialize()
-------------------------------------------------------------------------------------------------------------------------------------------------------------
if veafCombatMission then 
	veafCombatMission.logInfo("Loading configuration")
	
	veafCombatMission.AddMission(
		VeafCombatMission.new()
		:setSecured(true)
		:setName("Red attack On Gudauta")
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
			:setSpawnRadius(50000)
		)
		:addElement(
			VeafCombatMissionElement.new()
			:setName("Bombers")
			:setGroups({
				"Red Attack On Gudauta - Wave 2-1",
			 	"Red Attack On Gudauta - Wave 2-2", 
			 	"Red Attack On Gudauta - Wave 2-3" })
			:setSkill("Random")
			:setSpawnRadius(50000)
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
--[[ 		:addObjective(
			VeafCombatMissionObjective.new()
			:setName("Kill everyone")
			:setDescription("you must kill all the bombers")
			:configureAsKillEnemiesObjective()
		)
 ]]		:initialize()
	)

	veafCombatMission.AddMission(
		VeafCombatMission.new()
		:setName("Training - Bomber Scenario 1 - slow Tu-160")
		:setFriendlyName("Training - Bomber Scenario 1 - slow Tu-160")
		:setBriefing([[
You're head-on at 25nm with 9 Tu-160, FL200, Mach 0.8.
Destroy them as quickly as possible !]])
		:addElement(
			VeafCombatMissionElement.new()
			:setName("SEAD")
			:setGroups({
				"Red Tu-160 Bomber Wave1-1",
				"Red Tu-160 Bomber Wave1-2",
				"Red Tu-160 Bomber Wave1-3",
				"Red Tu-160 Bomber Wave1-4",
				"Red Tu-160 Bomber Wave1-5",
				"Red Tu-160 Bomber Wave1-6",
				"Red Tu-160 Bomber Wave1-7",
				"Red Tu-160 Bomber Wave1-8",
				"Red Tu-160 Bomber Wave1-9" })
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
			:setName("Kill 5 bombers")
			:setDescription("you must kill 5 bombers")
			:setMessage("%d bombers destroyed !")
			:configureAsKillEnemiesObjective(5)
		)
		:initialize()
	)

end