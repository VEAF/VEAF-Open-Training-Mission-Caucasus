
# Créer une QRA réarmable

Pré-requis:
- MIST

## Editeur - créer une zone

Créer une zone de déclenchement, et la nommer (ex: QRA Minevody). Elle servira à déterminer quand la QRA s'active, et une fois détruite, quand la QRA peut être de nouveau prête.

## Editeur - créer un groupe

Créer un groupe ennemi (ex: 2 mig 21, Rouge) et le nommer (ex: QRA Minevody 21)

## Editeur - créer les triggers

### Créer le trigger d'initialisation

Il doit être créé avant les autres triggers gérant la QRA.

#### Trigger
* Type: une fois
* Nom: QRA Init
* Evénement: n/a

#### Règles

n/a

#### Actions

* EXECUTER SCRIPT:

```lua
qraMinevody="ready";
qraMinevodyTimer=0;
```

* GROUPE - DESACTIVER:
  GROUPE: QRA Minevody 21

### Créer le trigger de début de QRA

#### Trigger
* Type: une fois
* Nom: QRA Minevody Start
* Evénement: n/a

#### Règles

* Type: coalition en partie dans la zone
Coalition: Bleu
Zone: QRA Minevody

* Type: LUA PREDICATE
```lua
return qraMinevody=="ready"
```

#### Actions

* EXECUTER SCRIPT:

```lua
qraMinevody="doing";
qraMinevodyTimer=0;
mist.respawnGroup("QRA Minevody 21", true);
```

* MESSAGE A LA COALITION:

Texte: QRA detected near Minevody
Secondes: 30

### Créer le trigger de fin de QRA

#### Trigger
Type: en continu
Nom: QRA Minevody Finished
Evénement: n/a

#### Règles

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

* EXECUTER SCRIPT:

```lua
qraMinevody="dead";
```

* MESSAGE A LA COALITION:

Coalition: Bleu
Texte: QRA destroyed near Minevody 
Secondes: 30

### Créer le trigger de réactivation de la QRA

Ce trigger permet de réactiver la QRA pour qu'elle soit à nouveau disponible dans la zone.

#### Trigger
Type: en continu
Nom: QRA Minevody Reload
Evénement: n/a


#### Règles

* Type: toute la coalition en dehors de la zone
Coalition: Bleu
Zone: QRA Minevody

* Type: LUA PREDICATE
```lua
return qraMinevody=="dead"
```

#### Actions

* EXECUTER SCRIPT:

```lua
qraMinevody="ready";
```

* MESSAGE A LA COALITION:

Coalition: Bleu
Texte: QRA near Minevody is ready again.
Secondes: 30
