# Creating and deploying a rails app with puma + nginx

Start with rails composer:

    rails new <app_name> -m https://raw.github.com/RailsApps/rails-composer/master/composer.rb -T


Add capistrano and pg gems to Gemfile:

    gem 'capistrano'
    gem 'pg', '0.15.1'

Start capistrano on dir (shell):

    capify .

Uncomment this line on Capfile:

    load 'deploy/assets'


Create the server with Ubuntu 12.04 and configure it:

    ssh root@SERVER_IP
  
    apt-get -y update
    apt-get -y install curl git-core python-software-properties
    apt-get -y install libxslt-dev libxml2-dev
    apt-get -y install libmagickwand-dev
    apt-get -y install vim
  
    add-apt-repository ppa:nginx/stable
    apt-get -y update
    apt-get -y install nginx
    service nginx start
  
    add-apt-repository ppa:pitti/postgresql
    apt-get -y update
    apt-get -y install postgresql libpq-dev
    sudo -u postgres psql
    \password  
    create user dtuser with password 'PASSWORD';
    create database <app_name>_production owner dtuser;
    \q
  
    apt-get -y install telnet postfix
  
    add-apt-repository ppa:chris-lea/node.js
    apt-get -y update
    apt-get -y install nodejs
  
    adduser deployer --ingroup sudo
    su deployer
    cd
  
    curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
    # NOW FOLLOW THE INSTRUCTIONS AND ADD THEM TO THE TOP OF .BASHRC FILE
    vim ~/.bashrc
    . ~/.bashrc
    rbenv bootstrap-ubuntu-12-04
    rbenv install 2.0.0-p247
    rbenv global 2.0.0-p247
    gem install bundler --no-ri --no-rdoc
    rbenv update
    rbenv rehash
  
    ssh git@github.com


Create a database.example.yml file with the following contents:

    production:
      adapter: postgresql
      encoding: unicode
      database: <app_name>_production
      pool: 5
      host: localhost
      username: DB_USER
      password: DB_PASSWORD

Create a github repo with the app name and push it to github.

    git remote add origin git@github.com:<github_user>/<app_name>.git
    git push -u origin master

Create puma, ningx and deploy configuration files under config folder: https://gist.github.com/bruno-campos/6313750

Mark unicorn_init.sh file as exacutable:

    chmod +x config/puma_init.sh

Commit and push it to github.

Run deploy setup tasks

    cap deploy:setup

Now log into the server and edit the database.yml file with db credentials.

    ssh deployer@SERVER_IP
    cd apps/<app_name>/shared/config
    vim database.yml
    exit

Run the first deploy:

    cap deploy:cold

After deploy:cold

    ssh deployer@SERVER_IP
    sudo rm /etc/nginx/sites-enabled/default
    sudo service nginx restart
    sudo update-rc.d -f puma_<app_name> defaults
