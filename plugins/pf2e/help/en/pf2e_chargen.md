---
toc: Pathfinder Second Edition
summary: Starting character generation - basic information.
order: 2
---
# Pathfinder 2E Chargen - Basic Character Information

The first thing you'll need to do is set your basic character information. You will only be able to use this command in chargen, and nothing you set here can be changed after approval. To set a property:

`cg/set <element> = <value>`: Sets basic character information.

<element> may be one of:

* ancestry*: Genetic racial traits. Choose this before choosing heritage.
* background*: Your character's life before they became an adventurer.
* charclass*: Your character's class, their field of expertise.
* heritage*: A subset of ancestry, determines what ancestry feats are available.
* lineage: Some heritages offer optional lineage feats. If yours does, choose it using this element.
* specialize: Some classes have specialties. If yours does, choose it using this element.
* faith*: The character's general philosophy and how they view the world.
* alignment*: Your character's alignment, expressed as a two-letter code. See [PRD](https://2e.aonprd.com/Rules.aspx?ID=95) for how alignment works in PF2E.
* deity: Does your character venerate a specific deity above all others?

_An element marked with the * character is a mandatory element._

`cg/review`: Reviews what you have so far. This command will alert you to missing elements. A missing in red means that this is required, while a missing in yellow might be okay depending on what else you have set.

`cg/commit`: Once you're happy with what you have, type this to finalize it and set up the next phase of chargen. **BEWARE**: If you change your mind on these later, you'll have to `cg/reset` and start your sheet over from the beginning.

When you are ready to continue to ability boosts, type `cg/next`.
