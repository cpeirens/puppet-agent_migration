# MCollective Agent For Migrating Puppet Agents to a New Puppet Master

## High level process to use this module
* Ensure the "to be" master does not have a cert signed for the nodes you are migrating.
* Test your mcollective node filters
* Test one run of the `migrate` command on a single node
* Confirm the cert request appeared on the new master
    * this takes ~2 minutes.
* Slowly progress through the rest of your nodes in small batches, always checking that certs have been requested.

To follow that process, read through the warnings and command help in the Usage section below.

## Usage

Include this module on all nodes.
`include agent_migration`

Run it.
`mco migrate agent <options>`

### Learn MCollective Basics

Familiarize yourself with running mCollective on the command line:
https://docs.puppetlabs.com/mcollective/reference/basic/basic_cli_usage.html

You must run mCollective from a user authorized to do so.  On PE, out of the box, the only user that has this
capability is the peadmin user.   All commands should be run as that user.

Ex: `runuser -l peadmin -c 'mco <subcommand>'`.   This document assumes you will do this for all mco commands.

### View documentation on the command line

Familiarize yourself with the documentation of this module"
`runuser -l peadmin -c 'mco plugin doc migrate'`

Example output of `plugin doc` for this plugin:

```
ACTIONS:
========
   agent, agent_from_3_to_4

   agent action:
   -------------
          - to be implemented -
   agent_from_3_to_4 action:
   -------------------------
       Uninstalls puppet, reinstalls from designated master curl script

       INPUT:
           to_fqdn:
              Description: Master FQDN to direct the agent to
                   Prompt: new master fqdn
                     Type: string
                 Optional: false
               Validation: .*
                   Length: 1024

           to_ip:
              Description: Master IP Address to direct the agent to
                   Prompt: new master ip
                     Type: string
                 Optional: false
               Validation: .*
                   Length: 1024


       OUTPUT:
           msg:
              Description: error output if it failed
               Display As: errors or messages from client
            Default Value: unknown
```

### Warning
The subcommand `agent_from_3_to_4` will uninstall puppet and reinstall puppet from the master you supply. This will fail if any of the following conditions exist:

* the new master isn't available
* there is an existing cert on the new master.
    * to clean this: run `puppet node clean <client_cert_here>` on the "to be" master.

If it fails, you will have to log into the machine you tried to migrate.  In other words, be careful.


### Executing commands

As always with mcollective, **first test your node filter**.  You probably don't want to run this command against every agent!

This command: `mco find -I /hostname_regex/` is one example of how to test a filter.

*Note: these commands will filter out the puppet master itself, as migrating the masters agent to another master would be bad.   Therefore, when testing your filter - you can ignore the puppet master node if it shows up.*

Take the filter above (`-I /hostname_regex/`) and use it in running the migration:

`mco rpc migrate agent_from_3_to_4 to_fqdn=devcorepptl918.matrix.sjrb.ad to_ip=10.15.185.90  -I /hostname_regex/ -v`

Be sure to add the -v to get verbose results.

### Commands
* `agent_from_3_to_4`
    * this command is asynchronous
    * it uninstalls puppet, and curls the version of puppet from the new master.  It is **important** to test one node at a time, and do this in a controlled manner, as if your node fails, you will have to intervene manually.
* `agent` ##TODO  IMPLEMENT
    * is synchronous
    * migrates a puppet 4 agent to another puppet 4 agent.
