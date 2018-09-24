# Create a basic Docker Image
On `bastion-01` start and validate docker; 

- Start docker

```
systemctl start docker
```

- Validate docker is running

```
docker run hello-world
```

- Explore docker info

```
docker info
```

Create a simple docker image; 
- Create a working directory

```
mkdir new-docker-image
```

- Using an editor such as `vi` create a Dockerfile with 
the following contents

```
FROM centos
RUN yum install -y httpd
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
```

- Build the docker image

```
docker build -t httpd .
```

- Validate that the image is built

```
docker images
```