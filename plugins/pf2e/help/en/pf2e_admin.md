---
toc: Pathfinder Second Edition
summary: Starting character generation - ability boosts.
aliases: 
- pf2e staff
- pf2 staff
---

# Pathfinder 2E -- Admin Commands

Game admins and those they designate can make some modifications to characters' sheets. 

`admin/set <character>/<item> = <value>`

Item can be one of: feat skill spell ability feature

Value varies by <item>.

For feats: `<feat type> [add|delete] <feat name>`

where feat type is one of: ancestry charclass skill general archetype dedication

For skills: `<skill name> <proficiency level>`

where proficiency level is one of: untrained trained expert master legendary

For spells: `<charclass> <spell level> <spell name>`

For ability: `<ability name> <new value>` Value needs to be an integer, command will charf if not

For feature: `<character class> [add|delete] <feature name>`

(Validate all data)

`admin/reset <character>`: Resets the character sheet, sets them to unapproved, forces them back through chargen, and wipes level / XP / gold back to starting default. 

`admin/respec <character>`: Resets the character sheet, sets them to unapproved, forces them back through chargen, but preserves level / XP / money / inventory. 

