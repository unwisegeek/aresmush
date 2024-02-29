---
toc: Pathfinder Second Edition
summary: Use of character notes commands.
aliases:
- note
- cnotes
- cnote
---

# Character Notes

Character notes are used for things like familiar stat blocks, long-term plot effects, special abilities, and other things that staff and the player need to know about, but generally should be kept between the player and staff. Only those with the manage_alts permission can see or edit another character's cnotes, but any character can edit their own. For all commands, if <character> is not specified, the code assumes the person who typed the command.

This is generally not useful for unapproved characters, and the presence of cnotes prior to approval will be flagged in your application, so don't add a cnote before character approval unless instructed to do so by your appstaffer. 

## Commands

`cnotes [<character]`: Shows all cnotes on a character. 
`cnote [<character>/]<notename>`: Shows all notes whose name matches <notename> on the character.
`cnote/add [<character>/]<notename>=<text>`: Adds a cnote <notename> to the character with the specified text. This can accept ANSI formatting.

**NOTE**: Duplicate note names are not allowed. If you specify a note name you have already used, the code will overwrite the existing note with the new one. It will warn you if it did this, but it will not stop you from doing so.

`cnote/remove [<character>/]<notename>`: Removes <notename> from the character.