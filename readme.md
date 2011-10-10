# SINASTRANO - deploy your capistrano application over the web

sinastrano is a [sinatra](http://www.sinatrarb.com/intro.html) application running on [rack](http://rack.rubyforge.org/) using [capistrano](https://github.com/capistrano/capistrano)

![sinastrano](http://f.cl.ly/items/0z0Q380v290L381N2H11/Bildschirmfoto%202011-12-01%20um%2018.44.07.png "sinastrano")

## REQUIREMENTS

* git (version ~> 1.7.7)
* bundler (bundle exec)
* sendmail (on port 25)

## SETUP

    bundle install
    cp config.yaml.example config.yaml
    vi config.yaml
    foreman start

## USAGE

the access is done with Rack::Auth::Basic so you need to provide username and password

### CLONE PROJECT

clones the project you want to deploy into the configured directory

### DEPLOY

if you want to deploy you need to select a revison

#### E-MAIL

after a successful deployment an e-mail will be sent

### UPDATE PROJECT

this will update the working copy of the projects git repository

## TODOS

* find a way to remove capistrano dependencies and execute the cap stuff within the target project
* cleanup the code
* add tests

## ISSUES

* changing the capistrano deployment in a remote branch won't work, cause the repo is not forced to the latest commit on update
