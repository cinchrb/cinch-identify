# Identify plugin

This plugin allows Cinch to automatically identify with services.
Currently, QuakeNet, KreyNet and all networks using NickServ are
supported.

For QuakeNet, both the normal _auth_ and the more secure
_challengeauth_ commands are supported.

## Installation
First install the gem by running:
    [sudo] gem install cinch-identify

Then load it in your bot:

    require "cinch"
    require "cinch/plugins/identify"

    bot = Cinch::Bot.new do
      configure do |c|
        # add all required options here
        c.plugins.plugins = [Cinch::Plugins::Identify] # optionally add more plugins
        c.plugins.options[Cinch::Plugins::Identify] = {
          :username => "my_username",
          :password => "my secret password",
          :type     => :nickserv,
        }
      end
    end

    bot.start

## Commands
None.

## Options
### :type
The type of authentication. `:nickserv` for NickServ, `:quakenet` for
the insecure _auth_ command on QuakeNet and `:secure_quakenet` or
`:challengeauth` for the more secure _challengeauth_. `:kreynet` for
KreyNet.

### :username
The username to use for authentication. Do not set this when using
NickServ on a network that only supports identifying as the current
nick (e.g. dancer-ircd.)

### :password
The password to use for authentication

### Example configuration
Check the install instructions for an example configuration.

## Warning
Be warned that, when using the `:nickserv`, `:quakenet` or `:kreynet`
types, the password will show up in the logs.
