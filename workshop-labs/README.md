# Workshop Lab Content
The workshop lab content is delivered via `GitBook` and takes in the markdown content hosted in `docs` using the `SUMMARY.md` file to render the appropriate content. 

## Slow Release of Worksho Lab Content
It is common to `slow-release` labs during a workshop to keep students focused on the labs that relate to the appropriate lecture material. In order to slow release the content: 
- Update `docs/SUMMARY.md` with the desired labs
- Commit and push the change to GitHub
- Redeploy the application in OpenShift

```
oc rollout latest labs -n devops-platform-workshops
```

Note: The `docs/MASTER_SUMMARY.md` file is used to keep a record of all labs available for use. 


## Build Notes

### Environment Variables
The `GitBook` based lab application can take 2 environment variables, used for motifying content as required. These enviroment variables and their current values are: 

```
GIT_URL: git@github.com:bcgov-c/devops-platform-workshops.git
WORKSHOP_FOLDER: devops-platform-workshops/workshop-labs
```

See the `bin/run.sh` file for more details on the clone process. 

### Private Repos
To speed up deployment, add an ssh deploy key as a secret to `/opt/ssh/ssh_key`