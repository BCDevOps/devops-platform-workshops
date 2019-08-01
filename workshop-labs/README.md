# Workshop Lab Content

The workshop lab content is delivered via `GitBook` and takes in the markdown content hosted in `docs` using the `SUMMARY-${WORKSHOP_NAME}.md` file to render the appropriate content.

## Slow Release of Workshop Lab Content

It is common to `slow-release` labs during a workshop to keep students focused on the labs that relate to the appropriate lecture material. In order to slow release the content:

- Update `docs/SUMMARY-${WORKSHOP_NAME}.md` with the desired labs
- Commit and push the change to GitHub
- Redeploy the application in OpenShift

``` bash
oc rollout latest labs -n devops-platform-workshops
```

Note: The `docs/MASTER-${WORKSHOP_NAME}.md` file is used to keep a record of all labs available for use.

## Build Notes

### Environment Variables

The `GitBook` based lab application can take up to 4 environment variables, used for modifying content as required. These enviroment variables and their current values are:

``` bash
GIT_URL: git@github.com:bcdevops/devops-platform-workshops.git
WORKSHOP_FOLDER: devops-platform-workshops/workshop-labs
WORKSHOP_NAME: [openshift101|openshift201]
WORKSHOP_BRANCH: master
```

See the `bin/run.sh` file for more details on the clone process.

### Private Repos

To speed up deployment, add an ssh deploy key as a secret to `/opt/ssh/ssh_key`


## Local Building

To run locally the git clone stage is completely skipped (since you're running off a local repo). In this case, mount the appropriate git folder into the container and specify the environent vatiables to match. If running on linux, selinux will block direct access, add the appropriate selinux policy to the desired git folder:

- Set the selinux policy if required (for example)

``` bash
chcon -Rt svirt_sandbox_file_t /home/sheastewart/GIT
```

- Build the conatiner

``` bash
docker build -t labs .
```

- Run the image locally

``` bash
docker run -v /home/sheastewart/GIT/ArctiqTeam-private/p-bcgov/training:/opt/app-root/training -e WORKSHOP_FOLDER=training/workshop-labs -e WORKSHOP_NAME=openshift201 -p 4000:4000 labs
```

- Killing the container

``` bash
docker kill $(docker ps  | grep labs | awk '{print $1}')
```

- Custom CSS - Add the following to book.json with your own CSS file (untested)

``` css
     "styles": {
         "website": "docs/styles/website.css"
       }
```
