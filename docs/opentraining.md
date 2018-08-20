# Mission ouverte d'entrainement de la VEAF

La [VEAF](http://www.veaf.org/) propose à ses membres une mission d'entrainement ouverte qui permet de voler dans un des appareils de DCS et de rejoindre des ateliers variés.

Elle est disponible en temps normal sur le serveur DCS dédié (sauf jours de mission et entrainements particuliers), et peut également être utilisée en solo.

Sa particularité est d'être ouverte, ce qui nécessite de nombreuses personnalisations et programmes (sous forme de scripts lua) qui sont hébergé(e)s sur ce dépot.

## 1. Utilisation générale

Lors du lancement de la mission, ou de la connexion au serveur de la VEAF, je peux choisir un slot qui me place généralement dans un aéronef mais également dans un véhicule (JTAC) ou dans l'uniforme bien repassé d'un général (Game Master).  

Le côté Bleu est celui des alliés, alors que le côté Rouge représente les ennemis.  

Ce dernier côté est surtout utilisé pour s'exercer contre des pilotes humains en participant à des missions de défense aérienne ou de contrôle tactique.

## 2. Date et Météo

La mission se déroule en juin, par une température clémente. L'heure varie bien évidemment.  
La météo de la mission est dynamique : 
- une zone globale englobe la région de l'exercice dans laquelle règne un assez beau temps. La zone d'entrainement au Close Air Support bénéficie de cette météo clémente.
- une seconde zone de perturbations légères (nuages, pluie, petite brise) entoure les aéroports de Tbilissi, d'où décollent une majorité des forces aériennes Bleues.
- une dernière zone de perturbations, plus forte, pose quelques soucis de vent et de pluie aux appareils qui évoluent à l'ouest de Tbilissi (zone d'entrainement à la défense aérienne)

Il est possible d'utiliser la librairie WeatherMark pour obtenir la météo en un point donné de la carte.

Voici quelques exemples de son utilisation, et [une documentation plus détaillée](weathermark.md).

WeatherMark, à l'instar de nombreuses autres fonctions de cette mission d'entrainement, nécessite qu'on crée un marqueur sur la carte pour y saisir une commande. Voici une [explication détaillée](creation_marqueur.md) de la création d'un marqueur.

Dans ce marqueur, on peut saisir une commande parmi celles qui sont reconnues par WeatherMark ; par exemple :

- `weather report` pour obtenir la météo au sol, en système métrique
- `weather report, units imperial, alt 1000` pour obtenir la météo à 10000 pieds, en système impérial

## 3. Opérations aéronavales

Un groupe de porte-aéronefs vogue dans la Mer Noire. On y trouve, outre des navires d'escorte, le [USS Tarawa (LHA-1)](https://en.wikipedia.org/wiki/USS_Tarawa_(LHA-1)) et le [USS John C. Stennis (CVN-74)](https://en.wikipedia.org/wiki/USS_John_C._Stennis).

Il est possible de déplacer les navires, et en particulier les porte-aéronefs, en utilisant la commande suivante dans un marqueur (voir une [explication détaillée](creation_marqueur.md) de la création d'un marqueur) :

`MOVE(LHA-1 Tarawa, 15)`  
 où l'on peut remplacer *LHA-1 Tarawa* par le nom du groupe de navires à déplacer, et *15* par la vitesse (en m/s) de déplacement souhaitée.

Une fois que le groupe de navires a atteint le point matérialisé par le marqueur, il s'arrête en conservant son cap.

## 4. Artillerie

Le script [arty_opentraining.lua](../scripts/arty_opentraining.lua) permet de gérer des batteries d'artillerie.  
Il utilise le module *arty* de l'excellent [*Moose*](https://github.com/FlightControl-Master/MOOSE).  
Vous trouverez la documentation complète du module [ici](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Arty.html).

### 4.1. Principe

La fonction *arty*, à l'instar de nombreuses autres fonctions de cette mission d'entrainement, nécessite qu'on crée un marqueur sur la carte pour y saisir une commande. Voici une [explication détaillée](creation_marqueur.md) de la création d'un marqueur.

Dans ce marqueur, on peut saisir une commande parmi celles qui sont reconnues par le script, parmi :

- `arty engage`
- `arty move`
- `arty request`
- `arty cancel`

Les paramètres sont de la forme *paramètre* *valeur*, séparés les uns des autres (et de la commande) par des virgules. Par exemple :

`arty engage, everyone, shots 50`

### 4.2. Liste des unités disponibles

- Alpha 1 ; artillerie de campagne [2S19 Msta](https://en.wikipedia.org/wiki/2S19_Msta) ; clusters Alpha et Short
- Alpha 2 ; artillerie de campagne [2S19 Msta](https://en.wikipedia.org/wiki/2S19_Msta) ; clusters Alpha et Short
- Bravo 1 ; artillerie de campagne [2S19 Msta](https://en.wikipedia.org/wiki/2S19_Msta) ; clusters Bravo et Short
- Bravo 2 ; artillerie de campagne [2S19 Msta](https://en.wikipedia.org/wiki/2S19_Msta) ; clusters Bravo et Short
- Long 1 ; lance roquettes multiples [BM-30 Smerch](https://en.wikipedia.org/wiki/BM-30_Smerch) ; cluster Long
- Long 2 ; lance roquettes multiples [BM-30 Smerch](https://en.wikipedia.org/wiki/BM-30_Smerch) ; cluster Long
- Perry 1 ; Frégate [Oliver Hazard Perry](https://en.wikipedia.org/wiki/Oliver_Hazard_Perry-class_frigate) ; cluster Perry
- Perry 2 ; Frégate [Oliver Hazard Perry](https://en.wikipedia.org/wiki/Oliver_Hazard_Perry-class_frigate) ; cluster Perry

### 4.3. Liste des commandes et de leurs paramètres (non exhaustive)

#### a. destination : paramètre commun à toutes les commandes

Toutes les commandes acceptent un paramètre qui détermine les unités qui vont répondre à la commande.

Il peut valoir *everyone* (ou *allbatteries*) pour utiliser toutes les batteries disponibles.

On peut aussi préciser un cluster (groupement de batteries, voir liste des batteries) en précisant *cluster* "*nom du cluster*". Par exemple :   `arty engage, cluster "long"`

Il est également possible de choisir une batterie (voir liste des batteries) en précisant *battery* "*nom de la batterie*". Par exemple : `arty engage, battery "Alpha 1"`

#### b. arty engage

Déclenche une frappe d'artillerie sur l'emplacement du marqueur (ou ailleurs, voir paramètre *lldms*).

##### time 

Ce paramètre permet de différer l'engagement.  
`arty engage, time 23:17`

##### shots

Nombre de munitions tirées (globalement, par toutes les unités participant à l'engagement).  
`arty engage, shots 28`

##### maxengage

Nombre de fois que la cible sera engagée (par défaut 1).  
`arty engage, maxengage 4`

##### radius

Rayon de dispersion des munitions, en mètres (par défaut 100).  
`arty engage, radius 500`

##### weapon 

Arme employée. Permet de choisir entre les différentes armes et munitions disponibles.  
`arty engage, weapon smokeshells`  
`arty engage, weapon missile`

##### lldms

Permet de spécifier les coordonnées de l'engagement. Le marker d'origine disparait et un nouveau marker apparait à l'emplacement spécifié.  
`arty engage, lldms 41:15:10N 44:17:22E`

#### d. arty move

Fait se déplacer la batterie vers le marker.

##### time 

Ce paramètre permet de différer le déplacement.  
`arty move, time 23:17`

##### speed 

Vitesse de déplacement en km/h.

##### lldms

Permet de spécifier les coordonnées du déplacement. Le marker d'origine disparait et un nouveau marker apparait à l'emplacement spécifié.  
`arty move, lldms 41:15:10N 44:17:22E`

#### e. arty request

Permet d'obtenir des informations sur l'état des batteries.

##### target

Demande des informations sur la cible actuelle des batteries.

##### move  

Demande des informations sur le déplacement des batteries.

##### ammo

Demande des informations sur les stocks de munitions.

#### f. arty cancel

Permet d'annuler la commande actuelle. Il est également possible de simplement supprimer le marker.

## 5. Entraînement au combat air-sol - Close Air Support (CAS)

Le script [CAS Infinity VEAF.lua](../scripts/CAS Infinity VEAF.lua) permet de générer facilement des zones de combat aléatoires, pour permettre un entrainement sur mesure.

En fonction du type d'entrainement souhaité et d'appareil piloté, il est possible de choisir des cibles faciles à abattre, ou très fortement défendues.

### 5.1. Principe

La création de zone de CAS, à l'instar de nombreuses autres fonctions de cette mission d'entrainement, nécessite qu'on crée un marqueur sur la carte pour y saisir une commande. Voici une [explication détaillée](creation_marqueur.md) de la création d'un marqueur.

Dans ce marqueur, on doit saisir la commande `create ao`

Les paramètres sont de la forme *paramètre* *valeur*, séparés les uns des autres (et de la commande) par des virgules. Par exemple :

`create ao, size 3, sam 1, armor 0`

### 5.2. Liste des paramètres et valeurs par défaut

Chacun des paramètres possède une valeur par défaut. Si le paramètre est omis, c'est cette valeur qui sera utilisée.

#### a. size

Règle la taille du groupe  

Valeur par défaut : 1  
Champ d'application : 1 à 5  

En modifiant ce paramètre, on peut créer des groupes de 2 à 5 fois plus grand que la taille par défaut.

Attention : comme les groupes sont générés aléatoirement, la taille réelle peut différer de ce que le paramètre signifie.

#### b. sam

Règle la difficulté de la mission en changeant les défenses anti-aériennes du groupe.  
Attention : pour les pilotes d'hélicoptère, voir aussi le paramètre *armor*

Valeur par défaut : 1  
Champ d'application : 0 à 5  
*A zéro, aucune défense n'est générée.*

Entre 1 et 3, on augmente progressivement le nombre de défenses sans changer la fréquence de distribution statistique (qui gouverne le type de défense généré).  
En passant à 4, puis 5, on augmente également la probabilité que les défenses soient plus coriaces (par exemple il devient moins rare de voir des SA-15)

#### c. armor

Règle le type de blindés générés. 

Valeur par défaut : 1  
Champ d'application : 0 à 5  
*A zéro, aucun blindé n'est généré.*

En augmentant la valeur, les blindés générés sont de plus en plus lourds et dangereux.  
Attention : comme les groupes sont générés aléatoirement, il est possible (quoi que peu probable) d'avoir des T90 dans un groupe *armor 1* ou de n'avoir que des BRDM dans un groupe *armor 5*. 

#### d. spacing

Règle l'espacement des unités et la taille de la zone.

Valeur par défaut : 3  
Champ d'application : 1 à 5

Pour chaque type d'unité (fantassin, transport, blindé, défense), la taille par défaut de la zone de placement diffère.   
En modifiant ce paramètre, il est possible de réduire (2, voire 1) ou d'augmenter (4, ou 5) la taille de cette zone, et donc d'espacer moins ou plus les unités.

### 5.3. Règles de génération

Les unités sont générées aléatoirement, en tenant compte des paramètres saisis dans la commande.

Voici les règles qui gouvernent cette création.

> TODO

## 6. Random Air Traffic

> TODO

## 7. VEAF Grass Runways

> TODO