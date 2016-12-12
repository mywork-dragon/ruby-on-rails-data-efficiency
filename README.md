## Introduction

We're currently migrating from our current architecture to a hybrid container and static instance flow
to support both our scraping + UI scalability needs AND our device lab setup with Mac-specific utilities.

For this reason, we'll support **both** a **Docker-based** and **non-Docker-based** workflow going forward.

## Getting Started

### Installation

* Install RVM: https://rvm.io/
* Clone the repository
* Download Docker version >= 1.12.3. Check after installing:

  ```bash
  $ docker -v
  Docker version 1.12.3, build 6b644ec
  $ docker-compose -v
  docker-compose version 1.8.1, build 878cff1
  ```
* Install the necessary gems: `bundle install`
* Copy the example environment variable config: `cp .env.example .env`. Feel free to change `.env`
* [non-Docker only] Install mysql on your machine. Preferably use `homebrew` if you're on a Mac

### Local Development

For Docker-based flows:

* Use docker-compose to build the containers: `docker-compose up`
* [1st time only] Use `docker-compose run` to set up the mysql container with the proper database structure

  ```bash
  $ docker-compose run varys bash
  $ cd /varys
  $ rake db:migrate db:schema:load
  ```

* Check the docker-compose.yml file for the setup, particularly the port mappings. For example, here's a snippet

  ```yaml
  ...
    nginx:
      build: .
      ports:
        - "8888:80"
      command: nginx -g "daemon off;"
  ...
  ```
  * In this example, the nginx container's port 80 is available on machine's port 8888. `curl localhost:8888` will hit the container
* To run console commands: `docker-compose run varys bash`
* To run syntax linter: `docker-compose run varys bundle exec rubocop`
* To run tests: `docker-compose run varys rake test`

For non-Docker flows:
* Just develop on your machine as a normal Rails app
* To run syntax linter: `rubocop`
* To run tests: `rake test`

## Deployment

There are two deployment methods, ECS or Capistrano.

Current ECS deployment types:
* web - Customer-facing UI
* staging - development UI environment

Current Capistrano deployments
* everything else

### ECS deployment

You can only deploy built Docker images. We use Circle-CI to automate that process. Circle-CI tests every commit but only builds an image and uploads it to AWS if it is **tagged**

Steps:
* Ensure mighty-cli is installed: https://github.com/MightySignal/mighty-cli
* Use mightytag to tag the commit/branch you want to deploy: `mightytag`
  * Once you've tagged it, Circle-CI will run tests and build it. You can monitor the process at https://circleci.com/dashboard
  * Once it is finished, a Slack notification will be sent to the #circle-ci channel with a build command
* Use `mightydeploy` to deploy the built tag. The Slack notification should have the appropriate command. You'll likely need the specify the ECS Service
  * For web, use `WEB`
  * For staging, use `STAGING`
* Once that command is run, go to ECS in the AWS console and monitor the `Events` tab in your chosen Service

### Capistrano deployment

We've written a prompt script to automate this:
```bash
./get_swole.rb
```
