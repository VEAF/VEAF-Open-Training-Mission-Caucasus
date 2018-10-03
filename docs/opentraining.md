# Mission ouverte d'entrainement de la VEAF

La [VEAF](http://www.veaf.org/) propose à ses membres une mission d'entrainement ouverte qui permet de voler dans un des appareils de DCS et de rejoindre des ateliers variés.

Elle est disponible en temps normal sur le serveur DCS dédié (sauf jours de mission et entrainements particuliers), et peut également être utilisée en solo.

Sa particularité est d'être ouverte, ce qui nécessite de nombreuses personnalisations et programmes (sous forme de scripts lua) qui sont hébergé(e)s sur ce dépot.

## 0. Notes

La mission d'entrainement est susceptible de changer ; les explications ci-dessous ne sont pas garanties à 100%.

Il est possible de télécharger la dernière version de la mission sur [la page des releases du dépot GitHub](https://github.com/VEAF/VEAF-Open-Training-Mission/releases).  
Les toutes dernières versions de développement sont également disponibles sur les sites d'intégration continue, où elles sont générées automatiquement à chaque changement dans le code ; c'est [ici](https://ci.appveyor.com/project/davidp57/veaf-mission-library-oqtmw/build/artifacts) quand les scripts changent, et [ici](https://ci.appveyor.com/project/davidp57/veaf-open-training-mission-or3q1/build/artifacts) quand la mission change.

Elle peut être utilisée en solo.

Le menu radio F10 donne accès à un sous-menu VEAF qui montre les options de toutes les commandes.
En particulier, une aide en ligne succinte liste les commandes et leurs options.

## 1. Utilisation générale

Lors du lancement de la mission, ou de la connexion au serveur de la VEAF, le joueur peut choisir un slot qui le place généralement dans un aéronef mais également dans un véhicule (JTAC) ou dans l'uniforme bien repassé d'un général (Game Master).  

Le côté Bleu est celui des alliés, alors que le côté Rouge représente les ennemis.  

Ce dernier côté est surtout utilisé pour s'exercer contre des pilotes humains en participant à des missions de défense aérienne ou de contrôle tactique.

## 2. Date et Météo

La mission se déroule en automne, par une température clémente. L'heure varie bien évidemment.  
~~La météo de la mission est dynamique :~~

- ~~une zone globale englobe la région de l'exercice dans laquelle règne un assez beau temps. La zone d'entrainement au Close Air Support bénéficie de cette météo clémente.~~
- ~~une seconde zone de perturbations légères (nuages, pluie, petite brise) entoure les aéroports de Tbilissi, d'où décollent une majorité des forces aériennes Bleues.~~
- ~~une dernière zone de perturbations, plus forte, pose quelques soucis de vent et de pluie aux appareils qui évoluent à l'ouest de Tbilissi (zone d'entrainement à la défense aérienne)~~

En attendant de corriger les soucis de la météo dynamique, nous sommes passé à une météo statique ; il fait beau avec quelques petits nuages pour faire joli.

Il est possible d'utiliser la librairie WeatherMark pour obtenir la météo en un point donné de la carte.

Voici quelques exemples de son utilisation, et [une documentation plus détaillée](weathermark.md).

WeatherMark, à l'instar de nombreuses autres fonctions de cette mission d'entrainement, nécessite qu'on crée un marqueur sur la carte pour y saisir une commande. Voici une [explication détaillée](creation_marqueur.md) de la création d'un marqueur.

Dans ce marqueur, on peut saisir une commande parmi celles qui sont reconnues par WeatherMark ; par exemple :

- `weather report` pour obtenir la météo au sol, en système métrique
- `weather report, units imperial, alt 1000` pour obtenir la météo à 10000 pieds, en système impérial

## 3. Opérations aéronavales

Un groupe de porte-aéronefs vogue dans la Mer Noire. On y trouve, outre des navires d'escorte, le [USS Tarawa (LHA-1)](https://en.wikipedia.org/wiki/USS_Tarawa_(LHA-1)) et le [USS John C. Stennis (CVN-74)](https://en.wikipedia.org/wiki/USS_John_C._Stennis).

Il est possible de demander aux porte-aéronefs de prendre le vent pour faciliter le lancement et la récupération d'aéronefs.  
Cela se passe dans le menu radio dédié.

A la réception de la commande "Start carrier air operations", le porte-aéronefs se déplacera de manière à avoir un vent relatif face à la piste, entre 25 et 30 noeuds.  
Il continuera sur cette trajectoire pendant 30 minutes, avant de retourner à toute vapeur à son point de départ.

Il est possible (voire nécessaire, après le retour automatique du porte-aéronef à son point de départ) de stopper les opérations aériennes en envoyant la commande "End air operations" du menu radio.

## 4. Artillerie

~~Le script [arty_opentraining.lua](../scripts/arty_opentraining.lua) permet de gérer des batteries d'artillerie.~~  
~~Il utilise le module *arty* de l'excellent [*Moose*](https://github.com/FlightControl-Master/MOOSE).~~  
~~Vous trouverez la documentation complète du module [ici](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Arty.html).~~

**Note :** Ce script a été temporairement désactivé, pour cause d'erreur sur le serveur multijoueur ; en effet, après un certain nombre d'heures, les menus radio étaient remplacés par des menus spécifiques à Moose et toute la dynamique de la mission d'entrainement était compromise.

## 5. Entraînement au combat air-sol - Close Air Support (CAS)

Le script [veafCasMission.lua](https://github.com/VEAF/VEAF_mission_library/blob/master/scripts/veafCasMission.lua) permet de générer facilement des zones de combat aléatoires, pour permettre un entrainement sur mesure.

Dans ces zones de combat, le script génère des ensembles d'unités ennemies.

### 5.0. Composition

|Groupe|Nombre|Force|Défenses|
|--|--|--|--|
|Sections d'infanterie|Entre *size* - 2 et *size* + 1|3 à 7 fantassins, accompagnés d'un véhicule de transport (blindé, sauf si *armor 0*)|Un manpad plus ou moins moderne (en fonction de *defense*) (sauf si *defense 0*)|
|Escadres de blindés|entre *size* - 2 et *size* + 1|3 à 6 blindés (dont la composition varie en fonction du paramètre *armor*)|Aucune si *defense 0*, une Shilka si *defense 1-3*, une Tunguska si *defense 4-5*)|
|Companies de transport|Entre 1 et *size*|2 à 5 véhicules de transport (non armés)|Aucune si *defense 0*, un ZU-23 monté sur plateau si *defense 1-2*, une Shilka si *defense 3-5*|
|Groupes de défense anti-aérienne|Un (si *defense 1-2*) ou deux|Un parmi SA-15, SA-8, Tunguska, SA-13, SA-9 (en fonction de *defense*)|Entre 1 et 3 parmi Tunguska, SA-13, SA-99, Shilka ZU-23 sur plateau (en fonction de *defense*)|

En fonction du type d'entrainement souhaité et d'appareil piloté, il est possible de choisir des cibles faciles à abattre, ou très fortement défendues.

### 5.1. Principe

La création de zone de CAS, à l'instar de nombreuses autres fonctions de cette mission d'entrainement, nécessite qu'on crée un marqueur sur la carte pour y saisir une commande. Voici une [explication détaillée](creation_marqueur.md) de la création d'un marqueur.

Dans ce marqueur, on doit saisir la commande `veaf cas mission`

Les paramètres sont de la forme *paramètre* *valeur*, séparés les uns des autres (et de la commande) par des virgules. Par exemple :

`veaf cas mission, size 3, defense 1, armor 0`

### 5.2. Liste des paramètres et valeurs par défaut

Chacun des paramètres possède une valeur par défaut. Si le paramètre est omis, c'est cette valeur qui sera utilisée.

#### a. size

Règle le nombre de groupes de combat et affecte indirectement la taille de la zone  

Valeur par défaut : 1  
Champ d'application : 1 à 5  

En modifiant ce paramètre, on peut des groupes plus ou moins nombreux (voir [tableau en tête](#5.0.-Composition)).

Attention : comme les groupes sont générés aléatoirement, leur nombre et le volume ennemi total peuvent varier.

#### b. defense

Règle la difficulté de la mission en changeant les défenses anti-aériennes des groupes.  
Attention : pour les pilotes d'hélicoptère, voir aussi le paramètre *armor*

Valeur par défaut : 1  
Champ d'application : 0 à 5  
*A zéro, aucune défense n'est générée.*

Voir [tableau en tête](#5.0.-Composition)).

Plus précisement, voici la répartition statistique de la composition du (des) groupe(s) de défense anti-aérienne :

##### Groupe principal

Sur un jet aléatoire entre 1 et 100, en descendant dans la table, on sélectionne le type dont la *limite basse* est inférieure au jet.

|Limite basse|En pratique|Type|
|--|--|--|
|90 - (3 * (*defense* - 1)|> 78/90|SA-15|
|75 - (4 * (*defense* - 1)|> 61/75|SA-8|
|60 - (4 * (*defense* - 1)|> 44/60|Tunguska|
|40 - (5 * (*defense* - 1)|> 20/40|SA-13|
|1|> 1|SA-9|

##### Groupe secondaire

On place entre 1 et 3 unités.  
Sur un jet aléatoire entre 1 et 100, on sélectionne le type dont la *limite basse* est inférieure au jet et dont celle de la ligne suivante lui est supérieure.

|Limite basse|En pratique|Type|
|--|--|--|
|75 - (4 * (*defense* - 1))|> 59/75|Tunguska|
|65 - (5 * (*defense* - 1))|> 45/65|SA-13|
|50 - (5 * (*defense* - 1))|> 30/50|SA-9|
|30 - (5 * (*defense* - 1))|> 10/30|Shilka|
|1|> 1|ZU-23 sur plateau|

#### c. armor

Règle le type de blindés générés. 

Valeur par défaut : 1  
Champ d'application : 0 à 5  
*A zéro, aucun blindé n'est généré.*

Voir [tableau en tête](#5.0.-Composition)).

Plus précisement, voici la répartition statistique de la composition des escadres de blindés :

|*armor*|types possibles|
|--|--|
|1-2|BRDM-2, BMD-1, BMP-1|
|3|BMP-1, BMP-2, T-55|
|4|BMP-1, BMP-2, T-55, T-72B|
|5|BMP-2, BMP-3, T-80UD, T-90|

#### d. spacing

Règle l'espacement des unités et la taille de la zone.

Valeur par défaut : 1
Champ d'application : 1 à 5

La dispersion des unités au sein d'un groupe dépend de ce paramètre et de la définition du groupe.

En modifiant ce paramètre, il est possible de réduire (0) ou d'augmenter la taille de la zone et l'espacement entre les groupes.

## 6. Création d'unités, de groupes, de fumées et de cargo

### 6.1. Principe

Cette fonction, à l'instar de nombreuses autres fonctions de cette mission d'entrainement, nécessite qu'on crée un marqueur sur la carte pour y saisir une commande. Voici une [explication détaillée](creation_marqueur.md) de la création d'un marqueur.

Dans ce marqueur, on doit saisir la commande `veaf spawn [unit|smoke|flare|cargo|group]`

Les paramètres sont de la forme *paramètre* *valeur*, séparés les uns des autres (et de la commande) par des virgules. Par exemple :  
`veaf spawn cargo, name oiltank`  
ou  
`veaf spawn smoke, color red`

### 6.2. Création d'unités

En utilisant la commande `veaf spawn unit` on peut créer des unités ennemies ou alliées controlables.  

#### a. name

Permet de spécifier le type de l'unité à créer. 

Valeur par défaut : BTR-80
Champ d'application : toutes les unités de DCS (voir [liste des unités](unit-list.md))

#### b. country

Permet de choisir le pays de l'unité. Attention : les unités créées dans la coalition adverse ne seront pas visibles sur la carte...

#### c. hdg

L'unité sera générée face à ce cap.

#### d. speed

Génère l'unité déjà en déplacement à la vitesse indiquée

#### e. alt

L'unité sera générée en l'air à l'altitude précisée.

### 6.3. Génération de fumée

La commande `veaf spawn smoke` permet de générer des fumigènes de couleur.

#### a. color

Permet de spécifier la couleur de la fumée

Valeur par défaut : red  
Champ d'application : red, green, orange, blue, white

### 6.4. Eclairage de zone

La commande `veaf spawn flare` lance une fusée d'éclairage.

#### a. alt

Règle l'altitude initiale (en mètres, au dessus du sol) de la fusée.

Valeur par défaut : 1000 m  
Champ d'application : 0 à très très très haut.

### 6.5. Transport sous élingue

La commande `veaf spawn cargo` place une cargaison prédéfinie et permet son emport sous élingue par un hélicoptère.  
Une fois la cargo placée, il faut encore utiliser les menus radio standards de DCS pour la sélectionner et l'activer.

#### a. name

Permet de choisir le type de cargaison.

Valeur par défaut : aucune  
Champ d'application : cette table :  

|Type|Masse médiane|
|--|--|
|ammo|1500 lbs|
|barrels|480 lbs|
|container|1200 lbs|
|fueltank|2400 lbs|
|f_bar|823 lbs|
|iso_container|4500 lbs|
|iso_container_small|3200 lbs|
|m117|840 lbs|
|oiltank|2300 lbs|
|pipes_big|4815 lbs|
|pipes_small|4350 lbs|
|tetrapod|5000 lbs|
|trunks_long|4747 lbs|
|trunks_small|5000 lbs|
|uh1h|1000 lbs|

La masse réelle de la cargaison sera aléatoire, et comprise entre 0.5 fois et 1.5 fois la masse médiane.

#### b. smoke

Si cette option est présente, un fumigène vert sera activé près de la cargaison.

Valeur par défaut : non
Champ d'application : oui (présente), non (absente)

### 6.6. Création de groupes d'unités

En utilisant la commande `veaf spawn group` on peut créer des groupes d'unités ennemies ou alliées controlables.  

#### a. name

Permet de spécifier le nom du groupe à créer. 
Il est nécessairement défini dans la bibliothèque de groupes ; la liste (pas forcément toujours très à jour) est accessible [ici](group-list.md)

Valeur par défaut : aucune
Champ d'application : touts les groupes d'unités définis [ici](group-list.md)

#### b. country

Permet de choisir le pays du groupe. Attention : les groupes créés dans la coalition adverse ne seront pas visibles sur la carte...

#### c. hdg

Le groupe sera généré face à ce cap. Les unités seront tournées également, en fonction de la définition.

#### d. spacing

Règle l'espacement des unités dans le groupe, en ajustant la taille des cellules composant la grille qui est utilisée dans la définition du groupe de *spacing* fois la taille de l'unité contenue dans la cellule.

Valeur par défaut : 5
Champ d'application : >= 0

#### e. speed

Génère le groupe déjà en déplacement à la vitesse indiquée

#### f. alt

Le groupe sera généré en l'air à l'altitude précisée.

## 7. Déplacement d'unités

Il est possible de déplacer les navires et les ravitailleurs.

### 7.1. Principe

Le déplacement d'unités, à l'instar de nombreuses autres fonctions de cette mission d'entrainement, nécessite qu'on crée un marqueur sur la carte pour y saisir une commande. Voici une [explication détaillée](creation_marqueur.md) de la création d'un marqueur.

Dans ce marqueur, on doit saisir la commande `veaf move [group|tanker]`

Une fois que le groupe de navires (`veaf move group`) a atteint le point matérialisé par le marqueur, il s'arrête en conservant son cap. 
Le ravitailleur (`veaf move tanker`) entamera un hippodrome de ravitaillement.

Les paramètres sont de la forme *paramètre* *valeur*, séparés les uns des autres (et de la commande) par des virgules. Par exemple :

`veaf move group, name LHA-1 Tarawa, speed 15`

### .2. Liste des paramètres et valeurs par défaut

#### a. name

Ce paramètre est **obligatoire** et doit correspondre précisemment au nom du groupe à déplacer.

Valeur par défaut : aucune (erreur si non présent)  
Champ d'application : doit correspondre au nom d'un groupe existant sur la carte.

#### b. speed

Vitesse de déplacement du groupe (en noeuds)

Valeur par défaut : 20  
Champ d'application : numérique

#### c. alt

*Spécifique au ravitailleur*  
Altitude de l'hippodrome de ravitaillement (en pieds).

Valeur par défaut : 20000  
Champ d'application : numérique

#### d. dist

*Spécifique au ravitailleur*  
Longueur de la partie linéaire de l'hippodrome de ravitaillement (en miles nautiques).

Valeur par défaut : 20  
Champ d'application : numérique

#### e. hdg

*Spécifique au ravitailleur*  
Cap de la partie linéaire de l'hippodrome de ravitaillement (en degrés).

Valeur par défaut : 0  
Champ d'application : 0 à 359

## 8. Random Air Traffic

**Note :** Ce script a été temporairement désactivé, pour cause d'erreur sur le serveur multijoueur ; en effet, après un certain nombre d'heures, les menus radio étaient remplacés par des menus spécifiques à Moose et toute la dynamique de la mission d'entrainement était compromise.

## 9. VEAF Grass Runways

> TODO