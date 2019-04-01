
# Create an infinite QRA on a trigger zone

Requirements:
- [MIST](https://github.com/mrSkortch/MissionScriptingTools)

## Editor - create a trigger zone

Create a trigger zone, and name it (ex: QRA Minevody). It should be used to enable QRA and, when destroyed, used to grant a new QRA group.

## Mission Editor - Create a group

Create a enemy group (ex: 2 mig 21, Red) and name it (ex: QRA Minevody 21)

## Mission Editor - Create all (3) triggers

### Create the Init trigger

It should be created before others QRA triggers.

#### Trigger
* Type: ONCE
* Name: QRA Init
* Event: n/a

#### Rules

n/a

#### Actions

* DO SCRIPT:

```lua
qraMinevody="ready";
qraMinevodyTimer=0;
```

* GROUPE - DEACTIVATE:
  GROUPE: QRA Minevody 21

### Create the QRA start trigger

#### Trigger
* Type: CONTINUOUS ACTION
* Name: QRA Minevody Start
* Event: n/a

#### Rules

* Type: PART OF COALITION IN ZONE
  Coalition: Blue
  Zone: QRA Minevody

* Type: LUA PREDICATE
  Text:
```lua
return qraMinevody=="ready"
```

#### Actions

* DO SCRIPT:

```lua
qraMinevody="doing";
qraMinevodyTimer=0;
mist.respawnGroup("QRA Minevody 21", true);
```

* MESSAGE TO COALITION:

Text: QRA detected near Minevody
Seconds: 30

### Create the QRA end trigger

#### Trigger
Type: CONTINUOUS ACTION
Name: QRA Minevody Finished
Event: n/a

#### Rules

Type: LUA PREDICATE
Texte:

```lua
return qraMinevody=="doing"
```

Type: LUA PREDICATE
Texte:

```lua
return not Group.getByName("QRA Minevody 21")
```

#### Actions

* DO SCRIPT:

```lua
qraMinevody="dead";
```

* MESSAGE TO COALITION:

Coalition: Bleu
Text: QRA destroyed near Minevody 
Seconds: 30

### Create the QRA reactivate trigger

This trigger prepare the QRA ready again in the trigger zone.

#### Trigger
Type: CONTINUOUS ACTION
Name: QRA Minevody Reload
Event: n/a

#### Rules

* Type: ALL OF COALITION OUT OF ZONE
Coalition: Blue
Zone: QRA Minevody

* Type: LUA PREDICATE
```lua
return qraMinevody=="dead"
```

#### Actions

* DO SCRIPT:

```lua
qraMinevody="ready";
```

* MESSAGE TO COALITION:

Coalition: Blue
Text: QRA near Minevody is ready again.
Seconds: 30
