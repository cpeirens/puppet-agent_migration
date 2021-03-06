# agent-migration

#### Table of Contents

1. [Overview](#overview)
2. [Description](#module-description)
3. [Setup](#setup)
* [What agent-migration affects](#what-[agent-migration]-affects)
* [Setup requirements](#setup-requirements)
* [Beginning with this module](#beginning-with-agent-migration)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

`agent-migration` helps in migrating puppet agents to a new Puppet master

## Description

This module contains puppet manifests to install the mcollective agent files.
It contains a simple rpc agent and an mcollective subcommand (ie: application)
## Setup

`include agent-migration`

### Setup requirements

* Puppet Enterprise

## Beginning with this module

### Usage

#### High level process to use this module
* Ensure the "to be" master does not have a cert signed for the nodes you are migrating.
* Test your mcollective node filters
* Test one run of the `migrate` command on a single node
* Confirm the cert request appeared on the new master
    * this takes ~2 minutes.
* Slowly progress through the rest of your nodes in small batches, always checking that certs have been requested.

To follow that process, read through the warnings and command help in the Usage section below.


#### RPC Commands Available

Supplementary command documentation to that on the `plugin doc` command documentation.

* `agent_from_3_to_4`
    * use this if you want to upgrade an agent node from a puppet 3 master to a puppet 4 master.
    * this command is asynchronous
    * this command uninstalls puppet, and curls the version of puppet from the new master.  It is **important** to test one node at a time, and do this in a controlled manner, as if your node fails, you will have to intervene manually.
    * Example: `mco rpc migrate agent_from_3_to_4 to_fqdn=newmaster.domain.com to_ip=10.1.1.10 -v -I /filter/`
* `puppet_agent`
    * once you are on puppet 4, you can use this command.
    * migrates a puppet 4 agent to another puppet 4 agent.
    * Example: `mco rpc migrate puppet_agent to_fqdn=newmaster.domain.com to_ip=10.1.1.10 -v -I /filter/`
* `test_activation`
    * `mco find <filter>` is useful to test a query, but rpc agents can still refuse to activate.
    * if this agent isn't active on a node, this command will tell you.
    * use this in conjunction with your mcollective node filter for a definitive test before running * Example:  `mco rpc migrate test_activation -v -I /filter/`

#### `migrate` mco subcommand

***This is the recommended way to use this mco agent***

`mco help migrate` will show you current usage documentation.

This command **requires puppet 4** as it wraps around the `puppet_agent` rpc plugin.

An example of how to run the migrate subcommand.
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
    * to ensure there isn't: run `puppet node clean <client_cert_name_here>` on the new master.

If the migration fails, you will have to log into the machine you tried to migrate.  In other words, be careful.

As the `agent_from_3_to_4` command is asynchronous, it is helpful to know the reinstall typically takes 2-3 minutes to complete.


### Executing commands

As always with mcollective, **first test your node filter**.  You probably don't want to run this command against every agent!

This command: `mco rpc migrate test_activation -I /hostname_regex/` will tell you what nodes would run on an activate command.
* if a node doesn't appear in the list and you expect it to,  the plugin may not be deployed.
    * ensure the module is included in this nodes profile.
    * ensure puppet has run to place the plugin on the node.

*Note: these commands will filter out the puppet master itself, as migrating the masters agent to another master would be bad.   Therefore, when testing your filter - you can ignore the puppet master node if it shows up.*

Take the filter above (`-I /hostname_regex/`) and use it in running the migration:

`mco rpc migrate agent_from_3_to_4 to_fqdn=devcorepptl918.matrix.sjrb.ad to_ip=10.15.185.90  -I /hostname_regex/ -v`

Be sure to add the -v to get verbose results.

#### Summary of commands you may wish to use
If your new master is devcorepptl918.matrix.sjrb.ad, at ip 10.15.185.90, and you are migrating a vm called vm_001:

1. `sudo runuser -l peadmin -c 'mco rpc migrate test_activation -I /vm_001/'`
2. `sudo runuser -l peadmin -c 'mco rpc migrate agent_from_3_to_4 to_fqdn=devcorepptl918.matrix.sjrb.ad to_ip=10.15.185.90  -I /vm_001/ -v'`

## Limitations

* Puppet Enteprise
* Tested On:
    * RHEL 6.4
    * CentOS 6.4
* the `agent_from_3_to_4` currently has a hard coded url to a puppet tar. It won't work outside our firewall .. yet.
    * TODO: allow injecting url for tarball to uninstall puppet 3.

## Development

Pull Requests are welcome.  Please rebase and squash before submitting, and use a feature branch.

For more details: CONTRIBUTING.md.

## Release Notes/Contributors/Etc

See the `CHANGELOG`.
