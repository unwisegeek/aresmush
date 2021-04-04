---
toc: Pathfinder Second Edition
summary: Searching for and reviewing details of feats.
order: 4
aliases:
- feats
---

# Feats

Feats in Pathfinder are special abilities that are tied to a character's development and offer customization of a character's abilities. They can be gained as a character gains levels, and a few are available at chargen. There are a _lot_ of them, and no character will qualify for every feat available.

These commands can be used to review the feats you have or determine which ones you qualify for.

`feat/info`: Shows details for all feats the character currently possesses.
`feat <name>`: Shows details for the named feat.
`feat/qualify <category>`: Shows all feats matching <category> for which the character meets all prerequisites.
`feat/search <category> = <term>`: Shows all feats in <category> matching <term>.
`feat/chain <name>`: Shows all feats for which <name> is a prerequisite, or which lead to that feat.

Feat category may be one of:

* %xgGeneral%xn - General feats that are open to any character who meets the prerequisites.
* %xgSkill%xn - As with general, but these feats apply specifically to a skill.
* %xgAncestry%xn - These feats are available only to members of that ancestry.
* %xgCharclass%xn - These feats are specific to a character class.
* %xgDedication%xn - These feats relate to multiclassing and archetypes.
