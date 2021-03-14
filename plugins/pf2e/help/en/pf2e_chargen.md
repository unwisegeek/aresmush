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
* specialize_info: A few classes need to choose an option for their specialty. Choose it with this keyword.
* faith*: The character's general philosophy and how they view the world.
* alignment*: Your character's alignment, expressed as a two-letter code. See [PRD](https://2e.aonprd.com/Rules.aspx?ID=95) for how alignment works in PF2E.
* deity: Does your character venerate a specific deity above all others?

_An element marked with the * character is a mandatory element._

`cg/review`: This command is your friend and guidebook through the sheet generation process. Watch especially the warning messages at the bottom - if you see something in red, you'll need to correct that before approval. Items in yellow may be okay depending on your concept. Remember that your prologue should reflect your sheet.

`commit info`: Once you're happy with what you have, type this to finalize it and set up the next phase of chargen. **BEWARE**: If you change your mind on these later, you'll have to `cg/reset` and start your sheet over from the beginning.
