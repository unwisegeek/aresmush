---
toc: Pathfinder Second Edition
summary: Starting character generation - choosing skills and lores.
order: 4
---

# Pathfinder 2E Chargen - Skills and Lores

Next, choose your open skills. Your choice of ancestry, heritage, character class, and background will have offered you a set of base skills. Things to remember:

1. Some backgrounds will offer a choice of skills. You may want to make this selection before you assign your open skills, so that you do not duplicate skills.
2. If you get the same skill from multiple sources, you will still only be trained in it at chargen. Instead, you will be able to select another open skill to replace the duplicate.
3. Lores (knowledges) count towards your skills pool, but will be chosen separately (see below).

## Commands

`cg/review`: Lists the base skills you have available to you.
`sheet`: Shows your sheet so far.

### Skills
`skill/set <type>=<skill>`: Sets an open skill. Types are **background** or **free**.
`skill/unset <type>=<skill>`: Deletes a skill selected with `skill/set`. You cannot delete skills granted by your base info.

### Lores
`lore/set <type>=<skill>`: Selects a lore. If <type> is **free**, it draws from your open pool of skills. If <type> is **background**, it sets which lore you get from your background, if you have this option.
`lore/unset <type>=<skill>`: Deletes a skill selected with `lore/set`. You cannot delete lores granted by your base info.
`lore/info [<type>]`: Shows what lores are available. If you specify a type, it will show you only lores under that category. Types are _deity_, _creature_, _city_, _terrain_, _crafting_, or _general_. If <type> is not specified, it will show all available lores.
