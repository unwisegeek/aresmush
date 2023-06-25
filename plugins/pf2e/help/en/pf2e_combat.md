---
toc: Pathfinder Second Edition
summary: Encounter-related commands.
aliases:
- initiative
- init
- damage
- heal
- encounter
- combat
---
# Pathfinder 2E Encounters

Invoking encounter mode (or, for the grognards out there, initiative rounds) changes the time flow of a scene. It is used when time must be closely tracked in order to understand the outcome.

The following commands are used to manage encounter mode in a scene. Note that all participants in an encounter must also be participants in the associated scene to use these commands. 

## For Participants

`init <encounter ID>[=<stat>]`: Joins an encounter in progress, using the stat specified by the organizer by default. If the organizer tells you that you should use a different stat, specify <stat>. 
`initlist <encounter ID>`: View the initiative table for the encounter in question. 

## For Organizers

`initiative [<stat>]`: If an encounter is not active in the scene, this command starts an encounter, with you as the organizer. <stat> is optional and will default to Perception if not specified.
`heal <player list> = <amount>`: Heals each character in <player list> for <amount>, up to their maximum HP.
`damage[/ndc] <player list> = <amount>`: Damages each character in <player list> for <amount>. The optional `/ndc` is for DM's and admins only, and disables the check to see if a character is dead. It has no effect for organizers without admin or DM roles.
`condition/set <player>=<condition>[/<value>]`: Sets <condition> on <player>.
