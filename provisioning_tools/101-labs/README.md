# Purpose

This playbook will create / delete the namespaces required for the OpenShift 101 workshop.  2 namespaces will be created for the shared lab environment.

## Requirements

- ansible
- `oc` binary on the local host, already logged into the target cluster
- permissions to create projects as the service account

## Instructions

Edit `vars.yaml` to modify:

- The instructor list (by GitHub ID)
- The list of environments to create
- The workshop name
- The project suffix (uniq ID for each running course - eg: a|b|c)
- The service account
- Settings for RocketChat

Run the playbook with a desired action (create/delete)

``` bash
ansible-playbook workshop_projects.yaml -e action=create
```

*Note* The deletion process will take some time.

#### Changing the Unique ID

When creating projects for the first time, a file called `unique_id` is created locally to hold the random generated ID. If you require a new ID, simply delete this file.
*Note* this file is used in the cleanup process as well. If the file no longer exists, you can simply regenerate it with the unique id in the prefix of the project label: workshop.
