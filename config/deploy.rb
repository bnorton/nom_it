# config/deploy.rb 
require "bundler/capistrano"

default_environment["RAILS_ENV"] = 'production'
set :rails_env, "production"

set :scm,             :git
set :repository,      "git@github.com:bnorton/nom_it.git"
set :application,     "nom"

set :branch do
  if ENV["BRANCH_NAME"]
    ENV["BRANCH_NAME"]
  else
    "origin/master"
  end
end

set :deploy_via,      :checkout

set :rvm_use,         "rvm use ree@#{application}"

set :migrate_target,  :current
set :ssh_options,     { :forward_agent => true }

set :stage,           "#{rails_env}"

set :keep_releases, 4
set :deploy_to,       "/apps/#{application}"
set :normalize_asset_timestamps, false
set :clear_cache_cmd, "rails runner Rails.cache.clear"
set :completed_email, "rails runner UserMailer.deploy_complete"

set :unicorn_pid,     "#{shared_path}/pids/unicorn.pid" # "/apps/#{application}/current/tmp/pids/unicorn.pid"

set :user,            "root"
set :group,           "root"
set :use_sudo,        false

set :memcached_servers, ["justnom.it"]

set :mysql_master_host,  "localhost"
set :mysql_user_name,    "root"
set :mysql_password,     '"%planb56b6!"'
set :mysql_raw_password, '%planb56b6!'

set :mysql_database,     "#{stage}"
set :mongo_database,     "#{stage}"

role :web,    'justnom.it'
role :app,    'justnom.it'
role :db,     'justnom.it', :primary => true

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

# define REE in the default_environment
default_environment["PATH"]         = "/usr/local/mysql/bin:/usr/local/rvm/gems/ree-1.8.7-2011.03@#{application}/bin:/usr/local/rvm/gems/ree-1.8.7-2011.03@global/bin:/usr/local/rvm/rubies/ree-1.8.7-2011.03/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
default_environment["GEM_HOME"]     = "/usr/local/rvm/gems/ree-1.8.7-2011.03@#{application}"
default_environment["GEM_PATH"]     = "/usr/local/rvm/gems/ree-1.8.7-2011.03@#{application}:/usr/local/rvm/gems/ree-1.8.7-2011.03@global"
default_environment["RUBY_VERSION"] = "ree-1.8.7-2011.03"

default_run_options[:shell] = 'bash'

namespace :deploy do
  desc "Deploy your application"
  task :default do
    transaction do
      update
      assets
      clear_cache
      restart
      heartbeat
    end
    email_complete
  end

  desc "Setup your git-based deployment app"
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')};"
    run "git clone #{repository} #{current_path};"
    run "cd #{current_path} ; #{rvm_use} ; bundle install"
    run "mysqladmin -u #{mysql_user_name} -p'#{mysql_raw_password}' CREATE #{mysql_database}"
    run "cd #{current_path} ; #{rvm_use} ; bundle exec rake db:create db:schema:load"
  end

  task :cold do
    update
    migrate
  end

  task :update do
    transaction do
      update_code
      setup_config
    end
  end

  desc "Email the team"
  task :email_complete, :except => { :no_release => true } do
    run "cd #{latest_release}; #{rvm_use}; #{completed_email}"
  end

  desc "setup the config files for mongodb, memcached"
  task :setup_config, :except => { :no_release => true } do
    mongodb_yaml_template = <<-YAML
      #{stage}:
        dbdatabase: #{mongo_database}
        dbcollection_prefix: #{stage}
    YAML

    mencached_yaml_template = <<-YAML
      #{stage}:
        servers: [#{memcached_servers.join(', ')}]
    YAML

    mysql_yaml_template = <<-YAML
      #{stage}:
        adapter: mysql2
        username: #{mysql_user_name}
        password: #{mysql_password}
        database: #{mysql_database}
        host: #{mysql_master_host}
        encoding:  utf8
        collation: utf8_general_ci
    YAML

    mysql_shards_yaml_template = <<-YAML
    YAML

    mongodb_yml = ERB.new(mongodb_yaml_template).result(binding)
    memcached_yml = ERB.new(mencached_yaml_template).result(binding)
    mysql_yml = ERB.new(mysql_yaml_template).result(binding)

    put mongodb_yml, "#{latest_release}/config/mongodb.yml"
    put memcached_yml, "#{latest_release}/config/memcached.yml"
    put mysql_yml, "#{latest_release}/config/database.yml"

  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{latest_release}; git fetch origin ; git reset --hard #{branch}"
    finalize_update
  end

  desc "precompile the assets"
  task :assets do
    run "cd #{latest_release}; RAILS_ENV=#{stage} rake assets:precompile"
  end

  desc "Update the database (overwritten to avoid symlink)"
  task :migrations do
    transaction do
      update_code
    end
    migrate
    restart
  end

  desc "rollback the last migration"
  task :migrations_rollback do
    transaction do
      run "cd #{latest_release}; RAILS_ENV=#{stage} rake db:rollback ;"
    end
  end

  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    run <<-CMD
      rm -rf #{latest_release}/log #{latest_release}/public/system &&
      rm -rf #{latest_release}/tmp/pids #{latest_release}/tmp/sockets &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/system #{latest_release}/public/system &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids &&
      ln -s #{shared_path}/sockets #{latest_release}/tmp/sockets
    CMD

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{unicorn_pid}`"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    run "echo starting unicorn_rails"
    run "mkdir -p /apps/#{application}/shared/sockets"
    run "cd #{latest_release} ; #{rvm_use} ; bundle exec unicorn_rails -c config/unicorn.rb -E production -D"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill -s QUIT `cat #{unicorn_pid}`"
  end

  desc "Clear cache"
  task :clear_cache, :except => { :no_release => true } do
    run "cd #{latest_release}; #{rvm_use}; #{clear_cache_cmd}"
  end

  desc "wait for 10 seconds then just check that we are up"
  task :heartbeat do
    run "sleep 10; if ! curl --silent http://localhost/config/heartbeat.json | grep alive; then echo 'Looks like nom is down .. exiting with code 1'; exit 1; fi"
  end

  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => { :no_release => true } do
      set :branch, "HEAD@{1}"
      deploy.default
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => { :no_release => true } do
      run "cd #{latest_release}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end
end

def run_rake(cmd)
  run "cd #{latest_release}; #{rake} #{cmd}"
end
