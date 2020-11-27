---
toc: Alt Tracking
summary: Admin commands for managing alts.
---

# Managing Alts

All commands in this section may only be performed by those with the view_alts permission.

`alts <name or email>`: View all alts of <name> or all alts associated to <email>.
`alt <name to add>=<existing alt>`: Establishes <name to add> as an alt of <existing alt>.

These two should only be done in the event of an error in the tracker, as the idle sweep code will do this automatically.

`alt/remove <name>`: Dissociates <name> from existing email address.
`alt/destroy <email address>`: Removes <email address> as a player and dissociates all alts.
