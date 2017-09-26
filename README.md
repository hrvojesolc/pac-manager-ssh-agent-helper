# pac-manager-ssh-agent-helper

# IMPORTANT - I no longer use PAC Manager as the software is no longer updated. This is for historical purpose only.

**Using this program has all the risks associated with running ssh-agent. Please ensure your are familiar with ssh-agent and associated risks.**

This program is created to be able to easily integrate use of ssh-agent with PAC Manager. This script ensures that only one ssh-agent process is running and that appropriate socket is registered. It helps removing agents and sockets if there are too many started and checks validity. It also creates a temporary file that can be easily sourced from PAC Manager's individual connection settings and used without prompting a passphrase or expensive key checking time.

I've wrote this for two reasons:
  * All servers I personally administer only use ed25519 or rsa keys. Loading them for each sessions takes ~4-5 seconds.
  * My private key passphrases are in KeePass (Xubuntu) and cut/paste and auto-key isn't reliable at times.

Installing:
  * Download `ssh-agent-helper.sh` to your home directory and rename it to `.ssh-agent-helper.sh`
  * In PAC Manager pererences (global options) under `Local Shell Options`, `Initial Directory` enter `; . ./.ssh-agent-helper.sh <key_location>;` (for example `; . ./.ssh-agent-helper.sh ~/.ssh/id_rsa;`).
  * In PAC Manager, for any connection which is configured to use above private key, open `Advanced Parameters` tab and in `Prepend command` enter `if [ -f ~/.ssh-agent-helper-env.sh ]; then . ~/.ssh-agent-helper-env.sh; fi;`

Using:
  * Open PAC Manager and run a local shell first. This will trigger sourcing ./.ssh-agent-helper.sh to help configure ssh-agent. It also creates ~/.ssh-agent-helper-env.sh file that contains ssh-agent environment variables containing PID and socket location.
  * As long as ssh-agent is running, socket in /tmp not removed and ~/.ssh-agent-helper-env.sh is available you will be able to connect any connection using configured private key.

Currently, this script is designed to handle configuration of one key into the ssh-agent.
