---
toc: Pathfinder Second Edition
summary: Starting character generation - ability boosts.
order: 3
---

# Pathfinder 2E Chargen - Abilities

Now you can start assigning ability boosts to your stats. Some of your stats will have boosts already assigned by one of the properties selected in the previous step, some you will need to choose.

Two main rules apply to assigning ability boosts:

1. You begin at a score of 10, which represents human average. Many races have an "ability flaw", which means that that score begins at an 8. Each boost increases the score by 2. No score may start play at higher than 18, and only one score may start play at 18.
2. When you receive multiple ability boosts from a single source, each boost must be applied to a different score. For example, a Lucht character receives from their ancestry ability boosts to Dexterity and Wisdom, and an additional boost to assign as they wish. That boost cannot go into whichever one they picked. It has to go somewhere else.

## Commands

Remember: <ability> is always one of: Strength, Dexterity, Constitution, Intelligence, Wisdom, or Charisma. See the PRD for more information on what these abilities say about your character, and what they do.

`cg/review`: See what boosts needs to be assigned still. If you see a number, you can assign it to anything. If you see a list, those are your choices.
`assign <type>=<ability>`: Assigns a type of boost to <ability>.
`unassign <type>=<ability>`: Unassigns that ability for that type only. Does not affect other boost types you may have assigned.
`commit abilities`: When you are happy with your scores, type this to lock down your scores to continue. If you need to change them, you will need to reset them using `cg/resetabil`.
