---
toc: Alt Tracking
summary: How to register new or existing alts.
---
# Registering Alts

This game requires that players disclose their alts to game admins. This disclosure is visible only to you, to game admins, and possibly to app staff depending on your game configuration. Games that require disclosure of alts will normally explain the reason for the requirement in their policies. This is entirely separate from the AresMUSH [handles system](https://aresmush.com/handles), and should not be confused in any way with AresCentral.

Each alt must be associated to an email address in order to be approved for play. You must also provide a code word of your choice. This word may be a word or a phrase and may be of any length and include any UTF-8-compatible character. Should you require a manual password reset for any reason, game admins will ask you for your email and your code word before performing the reset. You will also need to know your code word to register an alt.

If you are a new player registering an alt for the first time:

`register/new <email>=<code word>`: Registers yourself as a new player.

If you already have an alt and want to register another:

`register/alt <name or email>=<codeword>`: Registers yourself as an alt of <name>.

`alts` will show you which characters are registered to you, and your registered email and code word.

You can also change your email address or code word at any time.

`email <new email>`: Changes your email for all registered alts.
`codeword <new code word>`: Changes your code word for all registered alts.
