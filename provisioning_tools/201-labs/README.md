# Purpose

This playbook will create / delete the projects required for the OpenShift 201 workshop. Each student get's their own project set with the appropriate permissions for Jenkins to deploy to any project in the set.

## Requirements

- ansible
- `oc` binary on the local host, already logged into the target cluster
- permissions to create projects as the service account

## Instructions

Edit `vars.yaml` to modify:

- The student list (by GitHub ID) (include the instructors if they want their own environment)
- The instructor list (by GitHub ID)
- The list of environments to create
- The project suffix
- The service account

Run the playbook with a desired action (create/delete)

``` bash
ansible-playbook workshop_projects.yaml -e action=create
```

*Note* The deletion process will take some time.

#### Changing the Unique ID

When creating projects for the first time, a file called `unique_id` is created locally to hold the random generated ID. If you require a new ID, simply delete this file.
*Note* this file is used in the cleanup process as well. If the file no longer exists, you can simply regenerate it with the unique id in the prefix of the project names.
