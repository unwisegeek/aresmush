---
toc: Pathfinder Second Edition
summary: Roleplay Points and Perks
aliases:
- rpp admin
- admin rpp
- rpp/add
- rpp/spend
---

# Roleplay Points and Perks (RPP)-Related Admin Commands

To understand what these commands are for, please refer to [[[rules:rpp|RPP Rules]]] on the wiki.

`rpp <name>`: Shows currently available RPP and total RPP for a player. You can specify any alt of a player to see that player's RPP. 
`rpphist <name>` (alias: `listrpp`) Shows the history of RPP received and spent for the named player in reverse chronological order. You can specify any alt of a player to see information for that player.

Note that this is a paginated command, and you can go back further by specifying a page number. For example, to 
see the third page of the history, you'd type `rpphist3 <name>`. 

`rpp/award <name>=<award>[/<reason>]`: Awards a PC RPP. Note that RPP is tracked per player, not per character.
`rpp/spend <name>=<spend>[/<reason>]`: Spends RPP for a player.