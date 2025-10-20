# Dockerized Web Application

## Overview

This represents a Docker implementation of the 'Just Task It!' web application.

## How to Use

To execute the application, Docker must be installed on your system. Additionally, certain environment variables need to be set for the application to function correctly. These include:

1. DOCKER_HOST_PORT: This variable should be set to the port number on which your application will be accessible.
2. SESSION_SECRET: This variable is used for session management in your application. It should be set to a secret passphrase.
3. DOCKER_HOST: If a using a remote server, this variable should be set to the address of the remote server. Docker uses this variable to determine the host on which its commands should be executed.

### Local Machine

If you're running on a local machine with [Docker Desktop](https://www.docker.com/) installed, you can execute the following commands:

For development environment:

```bash
npm run docker:dev
```

For production environment:

```bash
npm run docker:prod
```

### Cloud Machine (Ubuntu 24.04 LTS with Docker, and NGINX Installed)

While automated deployment through a CI/CD pipeline like GitLab is the recommended approach for production environments, there might be scenarios where manual deployment is necessary. For instance, you might want to deploy manually to a remote server for initial testing purposes.

#### Manual deployment

To test your dockerized application, you can manually deploy and run it on your remote server.

Docker uses the DOCKER_HOST environment variable to determine the host on which its commands should be executed. By assigning an SSH URL to this variable, Docker can be directed to perform operations on a specified remote server.  In this case, you also need to add your private SSH key to the SSH agent using the ssh-add command.

> The process of adding your private SSH key to the SSH agent does differ between MacOS, Unix-like systems, and Windows.
>
> On MacOS, you can add your private SSH key to the SSH agent using the ssh-add command directly in the terminal:
>
> ```bash
> ssh-add -K /path/to/your/private/key.pem
> ```
>
> On Unix-like systems, the command would look like this:
>
> ```bash
> eval $(ssh-agent)
> ssh-add /path/to/your/private/key.pem
> ```
>
> On Windows, if you're using PowerShell, you can start the SSH agent and add your private key with the following commands:
>
> ```powershell
># Open PowerShell as Administrator
>
># Start the SSH agent with admin privileges
>Start-Service ssh-agent
>Set-Service -Name ssh-agent -StartupType Automatic
>
># Open a new PowerShell window without admin privileges
>
># Add your private key to the SSH agent
>ssh-add 'C:\path\to\your\private\key.pem'
> ```

For Unix-like systems, the command would look like this:

```bash
DOCKER_HOST=ssh://ubuntu@<remote servers IP number> DOCKER_HOST_PORT=8080 SESSION_SECRET="june-compost-sniff8" docker compose -f docker-compose.yaml -f docker-compose.production.yaml up --build -d
```

In this command, ensure to replace `<remote server's IP number>` with your remote server's IP. Also, remember to add your private SSH key to the SSH agent using the ssh-add command.

For Windows PowerShell, you can set the environment variable and run the command like this:

```powershell
$env:DOCKER_HOST="ssh://ubuntu@<remote server's IP number>"; $env:DOCKER_HOST_PORT=8080; $env:SESSION_SECRET="june-compost-sniff8"; docker compose -f docker-compose.yaml -f docker-compose.production.yaml up --build -d
```

Again, replace `<remote server's IP number>` with your remote server's IP.

##### The docker compose command explained

Here is an explanation of the `docker compose` command used above:

```bash
docker compose -f docker-compose.yaml -f docker-compose.production.yaml up --build -d
```

1. **`docker compose`**:
   - This is the main command to manage multi-container Docker applications defined in Docker Compose files. Note that it's using the newer syntax "compose" as opposed to the old "docker-compose" (with a hyphen).

2. **`-f docker-compose.yaml -f docker-compose.production.yaml`**:
   - The `-f` option allows you to specify the files that Docker Compose should use. Multiple `-f` flags can be combined to merge Compose files.
   - This command tells Docker Compose to use both `docker-compose.yaml` and `docker-compose.production.yaml`. The configurations from `docker-compose.production.yaml` will override or extend those in `docker-compose.yaml`.

3. **`up`**:
   - This command creates and starts the containers as defined in the Docker Compose files. If the containers are already running, Docker Compose will update them as needed.

4. **`--build`**:
   - This flag forces Docker Compose to build the images before starting the containers. This is useful when you have made changes to the Dockerfile or any of the files in the build context.

5. **`-d`**:
   - This flag stands for "detached mode." It runs the containers in the background and allows you to continue using the terminal for other tasks.

By combining these options, the command effectively merges two Docker Compose configuration files, builds the necessary Docker images, and starts the defined services in detached mode. This workflow is particularly useful for applying environment-specific configurations, such as development, testing, or production settings, ensuring a streamlined and flexible deployment process.

#### Automated deployment

The file `.gitlab-ci.yml` is a GitLab CI/CD pipeline configuration file, describing a sequence of steps to be executed in a continuous integration and delivery (CI/CD) process. Here's an explanation of the components and their functions:

##### Shared SSH Setup

```yaml
.before_script_ssh_setup: &before_script_ssh_setup
  - command -v ssh-agent >/dev/null || ( apt-get update -y && apt-get install openssh-client -y )
  - eval $(ssh-agent -s)
  - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
  - mkdir -p ~/.ssh
  - chmod 700 ~/.ssh
  - ssh-keyscan -H $REMOTE_HOST >> ~/.ssh/known_hosts
  - chmod 644 ~/.ssh/known_hosts
```

This section defines reusable steps to set up SSH:

- Ensure `ssh-agent` is installed.
- Start the `ssh-agent`.
- Add the SSH private key to the `ssh-agent`.
- Create the `.ssh` directory and set permissions.
- Add the remote server's SSH key to `known_hosts` to avoid prompts.

##### Docker Image

```yaml
image: docker:27-cli
```

This specifies the Docker image to be used for the jobs, which supports Docker commands.

##### Stages

```yaml
stages:
  - build
  - test
  - deploy
```

Defines the stages of the pipeline to be executed in order: `build`, `test`, `deploy`.

##### Build Job

```yaml
build-job:
  stage: build
  script:
    - echo "Compiling the code..."
    - sleep 2 # Simulate compilation time.
    - echo "Compile complete."
```

- **Stage**: `build`.
- **Script**: Simulates code compilation.

##### Unit Test Job

```yaml
unit-test-job:
  stage: test # Runs after the build stage is successful.
  script:
    - echo "Running unit tests... This will take about 60 seconds."
    - sleep 2 # Simulate test time.
    - echo "Code coverage is 90%"
```

- **Stage**: `test` (runs after the `build` stage).
- **Script**: Simulates running unit tests.

##### Lint Test Job

```yaml
lint-test-job:
  stage: test
  script:
    - echo "Linting code... This will take about 10 seconds."
    - sleep 2 # Simulate linting time.
    - echo "No lint issues found."
```

- **Stage**: `test`.
- **Script**: Simulates code linting.

##### Deploy to Staging

```yaml
deploy_staging_job:
  stage: deploy
  environment:
    name: staging
    url: http://$STAGING_HOST
  variables:
    REMOTE_HOST: $STAGING_HOST
    DOCKER_HOST: ssh://ubuntu@$REMOTE_HOST
  before_script: *before_script_ssh_setup
  script:
    - echo "Deploying to staging..."
    - docker compose -f docker-compose.yaml -f docker-compose.production.yaml up --build -d
  only:
    - deploy
```

- **Stage**: `deploy`.
- **Environment**: Deployment settings for the staging environment.
- **Variables**: Set `REMOTE_HOST` and `DOCKER_HOST`.
- **Before Script**: Reuses SSH setup steps.
- **Script**: Runs deployment commands for staging.
- **Only**: Runs in the `deploy` branch.

##### Manual Approval Step

```yaml
manual_approval_step:
  stage: deploy
  script:
    - echo "Manual approval required before deploying to production."
  when: manual
  only:
    - deploy
```

- **Stage**: `deploy`.
- **Script**: Simulates manual approval step.
- **When**: Requires manual intervention.
- **Only**: Runs in the `deploy` branch.

##### Deploy to Production

```yaml
deploy_production_job:
  stage: deploy
  environment:
    name: production
    url: http://$PRODUCTION_HOST
  variables:
    REMOTE_HOST: $PRODUCTION_HOST
    DOCKER_HOST: ssh://ubuntu@$REMOTE_HOST
  before_script: *before_script_ssh_setup
  script:
    - echo "Deploying to production..."
    - docker compose -f docker-compose.yaml -f docker-compose.production.yaml up --build -d
  only:
    - deploy
  needs:
    - manual_approval_step
```

- **Stage**: `deploy`.
- **Environment**: Deployment settings for the production environment.
- **Variables**: Set `REMOTE_HOST` and `DOCKER_HOST`.
- **Before Script**: Reuses SSH setup steps.
- **Script**: Runs deployment commands for production.
- **Only**: Runs in the `deploy` branch.
- **Needs**: Depends on the manual approval step.

This configuration sets up a robust CI/CD pipeline that manages code compilation, testing (both unit and lint), and deployment to staging and production environments with a manual approval step before the production deployment.
