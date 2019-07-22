---
# Database Backups

Note:
Note Placeholder


---
#### What could go wrong?
![](content/08_db_backups/what_could_go_wrong.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
### Hmmm...
![](content/08_db_backups/what_went_wrong.png)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note: 
Talk about the seriousness of not testing recoveries


---
#### Don't start with a backup

Define your recovery scenarios, and then let those scenarios drive the backup requirements

- **Service failover**: When a service fails, have another copy ready to go immediately
- **Change rollback**: When our rollout goes bad, be able to rollback to the last known good
- **Migration**: Moving somewhere else, be able to take our service with us
- **Disaster recovery**: When a disaster strikes, have the ability to get some amount of functionality back
- **Archive Retrieval**: Have the ability to look back in time

Note:
Note Placeholder


---
#### Example Backup types

- **Service failover**: synchronized copy used as a failover target (HA Databases)
- **Change rollback**: Short term backup used as a rollback point. (Single Version export)
- **Migration**: Used to move data from one system into another.  Can be made up of multiple backup/restore moments and generally lives a bit longer than a change rollback. (Single Version + deltas for time delayed changes)
- **Disaster recovery**: Copy retained in another location. (Single Version export stored remotely)
- **Archival**: Complete application snapshot to deploy as a copy from a different time (1 copy per time travel)

Note:
Note Placeholder


---
#### I'm sure it's fine

It sucks when your backup plan falls flat.

![](content/08_db_backups/01_Flat-spare-tire.jpg)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
### Backup, and immediately test the restore

Design and implement your recovery tests at the same time that you are implementing your backup functions

![](content/08_db_backups/the-more-you-know-300x300.jpg)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
Note Placeholder


---
#### Pathfinder Opinionated Best Practices

- Build resilient databases using HA DB clusters (eg: patroni stateful sets with postgres)
    - **Service Failover**: HA Failover Testing with each re-deployment

- Automate DB backup and add automated restore tests for each backup taken
    - **Database exports/imports**: Recover into temporary DB to allow immediate content validation

- Keep at least one copy of your tested DB backup outside of the cluster
    - **StorageClass nfs-backup**: External storage that is designed for self-serve integration with BCGov Enterprise backup
    - **Push to an external service**: Push/pull from your own external service

Note:
Note Placeholder


---
#### Lab: Backup your postgres

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
- Create backup application
- Run active backup
- Run test restore


---
#### Lab: Failover Scenarios

![Lab Time](content/07_stateful_sets/lab_01.gif)<!-- .element style="border: 0; background: None; box-shadow: None" -->

Note:
- Stateful set failure testing
- Replica set failure testing

