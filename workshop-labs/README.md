# Workshop Lab Content

The workshop lab content is delivered via `GitBook` and takes in the markdown content hosted in `docs` using the `SUMMARY-${WORKSHOP_NAME}.md` file to render the appropriate content.

Content built from `GitBook` is then hosted by a `Caddy` v2 server.


## Slow Release of Workshop Lab Content

It is common to `slow-release` labs during a workshop to keep students focused on the labs that relate to the appropriate lecture material. In order to slow release the content:

- Update the summary list (comment/uncomment the items in list) in the corresponding workshop's summary file configmap
- Redeploy the application in OpenShift

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

## Local Building

1. [View Caddyfile](workshop-labs/config/Caddyfile) and ensure the root directive is pointing to the
correct place

2. Build the Docker Container from `workshop-labs` run `docker build -t labs:{workshop-name} .`

3. Run the docker image locally, mounting the Caddyfile as a volume
  `docker run -v $(pwd)/config/Caddyfile:/opt/app-root/config/Caddyfile -p 4000:4000 labs:{workshop-name}`

