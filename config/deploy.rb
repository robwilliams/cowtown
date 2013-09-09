require "bundler/capistrano"
require "dotenv/capistrano"

set :application, "cowtown"
set :repository,  "git@github.com:robwilliams/cowtown.git"
set :branch,      "master"
set :user,        "deploy"
set :deploy_to,   "/home/#{user}/apps/#{application}"
set :scm, :git

role :app, "37.139.17.66"

set :use_sudo, false
default_run_options[:pty]   = true
ssh_options[:forward_agent] = true

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, :roles => :app do
    run "cd #{latest_release} && "\
        "#{sudo} bundle exec foreman export upstart /etc/init "\
        "-a #{application} -u #{user} -l #{shared_path}/log"
  end
  
  desc "Start the application services"
  task :start, :roles => :app do
    sudo "start #{application}"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    sudo "stop #{application}"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    sudo "stop #{application}"
    sudo "start #{application}"
  end
end

after "deploy:update", "foreman:export"
after "deploy:update", "foreman:restart"
