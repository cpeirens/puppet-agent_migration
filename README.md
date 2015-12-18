# MCollective Agent For Migrating Agents to a New Master


## Usage

Include this module on all nodes.
`include agent_migration`


## Advised Procedure
* Ensure the "to be" master does not have a cert signed for the nodes you are migrating.
* Test your mcollective node filters
* Test one run of the `migrate` command on a single node
* Confirm the cert request appeared on the new master
    * this takes ~2 minutes.
* Slowly progress through the rest of your nodes in small batches, always checking that certs have been requested.

To follow that process, read through the warnings and command help below. 

### View documentation on the command line
 (as the peadmin user)
`runuser -l peadmin -c 'mco plugin doc migrate'`

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
the subcommand agent_from_3_to_4 will uninstall puppet and reinstall it from the master you supply. This will fail if any of the following conditions exist:

* the new master isn't available
* there is an existing cert on the new master.
    * to clean this: run `puppet node clean <client_cert_here>` on the "to be" master.



### Executing commands

As always with mcollective, **first test your node filter**.  You probably don't want to run this command against every agent!

This command: `mco find -I /hostname_regex/` is one example of how to test a filter.

Take the filter above (`-I /hostname_regex/`) and use it in running the migration:

`mco rpc migrate agent_from_3_to_4 to_fqdn=devcorepptl918.matrix.sjrb.ad to_ip=10.15.185.90  -I /hostname_regex/ -v`

Be sure to add the -v to get verbose results.


### Commands
* `agent_from_3_to_4` - uninstalls puppet, and curls the version of puppet from the new master.  It is **important** to test one node at a time, and do this in a controlled manner, as if your node fails, you will have to intervene manually.
