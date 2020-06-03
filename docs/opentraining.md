# Playing in the OpenTraining mission

## Documentation

Please refer to the [OpenTraining documentation](https://tinyurl.com/veaf-ot) (in french) or to the [VEAF-Mission-Creation-Tools documentation](https://veaf.github.io/VEAF-Mission-Creation-Tools/) (in english) to get additional details.

Basically, you need to add a marker to the map and use a quick command.

![f10-map-usermark-01](f10-map-usermark-01.png?raw=true "f10-map-usermark-01")

![f10-map-usermark-02](f10-map-usermark-02.png?raw=true "f10-map-usermark-02")

Here is a quick recap of a few possible commands. All these commands accept the following optional parameters (add to the command `, <parameter> [value]`) :

- `side` (either *blue* or *red*; defaults to the opposing coalition): the coalition that the unit/group will belong to ; e.g. `-sam, side blue`
- `country` (default *RUSSIA*): the name of the country this unit/group will belong to; e.g. `-sam, country USA`
- `dest` (default none, a named point or a town name): the destination of the unit/group; e.g. `-armor, dest TBILISI`
- `speed` (default 25): the speed in km/h if a destination has been set; e.g. `-armor, dest TBILISI, speed 40`
- `offroad` (default not set): if set, the unit/group will not use roads; e.g. `-armor, dest TBILISI, offroad`
- `patrol` (default not set): if set, the unit/group will patrol between its spawn and destination points; e.g. `-armor, dest TBILISI, patrol`
- `size` (default depending on the type of spawn): the number of units that will be spawned in a group, or the number of groups (`-cas`, `-combatgroup`); e.g. `-transport, size 25`
- `defense` (from 0 to 5; default depending on the type of spawn): with 0 the group will not be defended, while 5 will almost certainly spawn SA15s and SA8s; e.g. `-transport, defense 0`
- `armor` (from 0 to 5; default depending on the type of spawn): with 0 the group will not include any armored vehicles, while 5 will almost certainly spawn heavy tanks; e.g. `-transport, armor 3`

They can be combined; e.g. `-armor, size 20, armor 5, defense 0, dest TBILISI, offroad, speed 15`

### Spawning defenses

- `-sam` : Random SAM battery
- `-samLR` : Random long range SAM battery
- `-samSR` : Random short range SAM battery
- `-sa2` : SA-2 Guideline (S-75 Dvina) battery
- `-sa3` : SA-3 Goa (S-125 Neva/Pechora) battery
- `-sa6` : SA-6 Gainful (2K12 Kub) battery
- `-sa8` : SA-8 Osa (9K33 Osa) sam vehicle
- `-sa9` : SA-9 Strela-1 (9K31 Strela-1) sam vehicle
- `-sa10` : SA-10 Grumble (S-300) battery
- `-sa11` : SA-11 Gadfly (9K37 Buk) battery
- `-sa13` : SA-13 Strela (9A35M3) sam vehicle
- `-sa15` : SA-15 Gauntlet (9K330 Tor) sam vehicle
- `-sa18` : SA-18 manpad soldier
- `-sa19` : SA-19 Tunguska (2K22 Tunguska) sam vehicle
- `-shilka` : ZSU-23-4 Shilka AAA vehicle
- `-zu23` : ZU-23 AAA vehicle

### Spawning troops

- `-mortar` : Mortar team
- `-arty` : M-109 artillery battery
- `-armor` : Dynamic armor group
- `-infantry` : Dynamic infantry section
- `-transport` : Dynamic transport company
- `-combat` : Dynamic combat group
- `-cas` : Generate a random CAS group for training
- `-convoy` : Convoy - needs \", dest POINTNAME\"
- `-jtac` : JTAC humvee

## Examples of improvised missions

### CAS - from TKIBULI to HOTEVI

**Goal : escort the BLUE1 convoy.**

#### Map

![CAS_from_TKIBULI_to_HOTEVI-map](CAS_from_TKIBULI_to_HOTEVI-map.png?raw=true "CAS_from_TKIBULI_to_HOTEVI-map")

#### Commands

Simply enter the following commands into the markers shown on the map:

1. `-point BLUE1`
2. `-combat, spacing 2, defense 1`
3. `-armor`
4. `-convoy, dest BLUE1, side blue`

#### Explanations

1. creation of a point named *BLUE1*
2. spawn a RED combat group (with light air defenses)
3. spawn a RED armored group
4. spawn a standard BLUE convoy, going to the BLUE1 point

#### Notes

- BLUE1 named point coordinates are available from the F10 radio menu (F10 → VEAF → NAMED POINTS → List all points)
- You can spawn a BLUE JTAC with `-jtac, laser [code]` where [code] is the laser code (defaults to 1688).
