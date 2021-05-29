---
toc: Pathfinder Second Edition
summary: Viewing, preparing, and casting spells.
aliases:
- spells
- cast spells
---

# Magic in Pathfinder 2E

Casting a spell in Pathfinder 2E depends on what type of spell it is. Spellcasters, both prepared and spontaneous, cast spells from their daily allotment of spells, and even those who are not technically spellcasters may have certain spells available to them as innate spells granted by a feat or by ancestry, and/or may have focus spells granted by their class or by a feat.

Commands for casting:

`cast[/<metamagic>] <tradition>/<level> = <spell name>[ at <target>]`: Casts a spell from a spellcaster's daily spell allotment. If _at <target>_ is included, <target> is a string, a character or NPC name. It may be a list of names.

* <tradition> is one of: arcane, divine, occult, or primal. Which it is depends on the source where you learned it.
* <level> is an integer, or the word _cantrip_.
* The <metamagic> switch denotes the use of a metamagic feat immediately prior to the spell casting.

`cast/focus <type>/<level> = <spell name>[ at <target>]`: Casts a focus spell. <type> depends on the class.
`cast/innate <level> = <spell name>[ at <target>]`: Casts an innate spell, if you have one.

Some classes are required to, or may wish to, record spells in a spellbook.

`prepare <level> = <spell name>`: Prepares <spell name> at <level>. Preparing at a higher level than a spell's base level heightens the spell to that level. See the PRD rules on heightening for how this works.
`unprepare <level> = <spell name>`: Removes a spell from your prepared list.
`prepare/list`: Shows your currently prepared spell list.

Prepared casters may also choose to prepare standard sets, or many spells at once.

`prepare/addset <set name> = <spell name>/<level>`: Adds a spell to a set with name <set name>. <set name> may contain spaces or special characters except for = or /. If <set name> does not exist, this command will create it, otherwise it will add that spell to the list.
`prepare/listset [<set name>]`: If <set name> is provided, shows the prepared spells in set <set name>. If not, shows a list of available sets.
`prepare/clearset <set name>`: Deletes the set <set name>.
`prepare/remset <set name> = <spell name>/<level>`: Removes <spell name> from set <set name>.
`prepare/set <set name>`: Clears all existing prepared spells and replaces it with the contents of <set name>.

Note that this does not load these spells into your spells for the day, it merely makes the list available to the `daily` command. The `daily` command, when run, will load the given prepared list into your spells available to cast that day.

`refocus`: Runs the code for the Refocus activity. This may be done only once every ten minutes.
