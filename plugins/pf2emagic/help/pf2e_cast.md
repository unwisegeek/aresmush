---
toc: Pathfinder Second Edition
summary: Casting spells.
aliases:
- spells
- cast
- refocus
---

# Casting Spells in Pathfinder Second Edition

Casting a spell in Pathfinder 2E depends on what type of spell it is. Spellcasters, both prepared and spontaneous, cast spells from their daily allotment of spells, and even those who are not technically spellcasters may have certain spells available to them as innate spells granted by a feat or by ancestry, and/or may have focus spells granted by their class or by a feat.

Commands for casting:

`cast[/<metamagic>] <casting class>[/<level>] = <spell name>[ at <target>]`: Casts a spell from a spellcaster's daily spell allotment. If `at <target>` is included, `<target>` is a string, a character or NPC name. It may be a list of names.

* `<casting class>` is the class from which the spell pool comes.
* `<level>`, if present, is an integer, or the word _cantrip_. If the spell is to be cast at its base level, you may omit this term. 
* The `<metamagic>` switch denotes the use of a metamagic feat immediately prior to the spell casting.

`cast/focus <type>/<level> = <spell name>[ at <target>]`: Casts a focus spell. `<type>` depends on the class.
`cast/innate <level> = <spell name>[ at <target>]`: Casts an innate spell, if you have one.

`refocus`: Runs the code for the Refocus activity. This may be done only your focus pool is zero, and then only once an hour in OOC time. 
