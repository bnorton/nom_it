# "/tmp/unicorn.nom_it.pid"

# set :application, "justnom.it"


# set :scm, :git

# set :user, :root

role :web, "96.126.97.77"                          # Your HTTP server, Apache/etc
role :app, "96.126.97.77"                          # This may be the same as your `Web` server
role :db,  "96.126.97.77", :primary => true        # This is where Rails migrations will run

# set :rails_env, :production
# set :unicorn_binary, "unicorn"


# config/deploy.rb 
require "bundler/capistrano"

set :scm,             :git
set :repository,      "git@github.com:bnorton/nom_it.git"
set :branch,          "origin/master"
set :migrate_target,  :current
set :ssh_options,     { :forward_agent => true }
set :rails_env,       "production"
set :deploy_to,       "/u/apps/justnom.it"
set :normalize_asset_timestamps, false

set :user,            "deployer"
set :group,           "staff"
set :use_sudo,        false

# role :web,    "justnom.it"
# role :app,    "justnom.it"
# role :db,     "justnom.it", :primary => true

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

default_environment["RAILS_ENV"] = 'production'

# Use our ruby-1.9.2-p290@my_site gemset
default_environment["PATH"]         = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/rvm/bin"
default_environment["GEM_HOME"]     = "/usr/local/rvm/gems"
default_environment["GEM_PATH"]     = "/usr/local/rvm/gems/ree-1.8.7-2011.03@nom"
default_environment["RUBY_VERSION"] = "ruby-1.8.7-p320"

default_run_options[:shell] = 'bash'

namespace :deploy do
  desc "Deploy your application"
  task :default do
    update
    restart
  end

  desc "Setup your git-based deployment app"
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "git clone #{repository} #{current_path}"
  end

  task :cold do
    update
    migrate
  end

  task :update do
    transaction do
      update_code
    end
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
    finalize_update
  end

  desc "Update the database (overwritten to avoid symlink)"
  task :migrations do
    transaction do
      update_code
    end
    migrate
    restart
  end

  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't
    # save empty folders
    run <<-CMD
      rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/system #{latest_release}/public/system &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids &&
      ln -sf #{shared_path}/database.yml #{latest_release}/config/database.yml
    CMD

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill -s USR2 `cat /tmp/unicorn.my_site.pid`"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill -s QUIT `cat /tmp/unicorn.my_site.pid`"
  end  

  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => { :no_release => true } do
      set :branch, "HEAD@{1}"
      deploy.default
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => { :no_release => true } do
      run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end
end

def run_rake(cmd)
  run "cd #{current_path}; #{rake} #{cmd}"
end





# set :application, "justnom.it"
# set :repository,  "git@github.com:bnorton/nom_it.git"
# 
# set :scm, :git
# 
# set :user, :root
# 
# role :web, "justnom.it"                          # Your HTTP server, Apache/etc
# role :app, "justnom.it"                          # This may be the same as your `Web` server
# role :db,  "justnom.it", :primary => true        # This is where Rails migrations will run
# 
# set :rails_env, :production
# set :unicorn_binary, "unicorn"
# set :unicorn_config, "#{current_path}/config/unicorn.rb"
# set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"
# 
# $:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
# require "rvm/capistrano"                  # Load RVM's capistrano plugin.
# set :rvm_ruby_string, 'ree@nom'        # Or whatever env you want it to run in.
# 
# namespace :deploy do
#   task :start, :roles => :app, :except => { :no_release => true } do 
#     # run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
#     run "cd #{current_path} && #{unicorn_binary} -c #{unicorn_config} -E #{rails_env}"
#   end
#   task :stop, :roles => :app, :except => { :no_release => true } do 
#     # run "#{try_sudo} kill `cat #{unicorn_pid}`"
#     run "kill `cat #{unicorn_pid}`"
#   end
#   task :graceful_stop, :roles => :app, :except => { :no_release => true } do
#     # run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
#     run "kill -s QUIT `cat #{unicorn_pid}`"
#   end
#   task :reload, :roles => :app, :except => { :no_release => true } do
#     # run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
#     run "kill -s USR2 `cat #{unicorn_pid}`"
#   end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     stop
#     start
#   end
# end

# load 'deploy' if respond_to? :namespace
# 
# set :domain, "justnom.it"
# set :application, "www.example.com"
# set :deploy_to, "/var/www/#{domain}/#{application}/public"
# set :repository, "git@github.com:username/example.git"
# set :scm, :git
# set :user, "username"
# 
# server "example.com", :app, :web, :db, :primary => true
# 
# after "deploy:symlink", "deploy:copy_config"
# 
# namespace :deploy do
# 
#   desc "Copy existing config files."
#   task :copy_config do
#     IGNORE = ['Capfile']
# 
#     run "cat #{latest_release}/.gitignore" do |channel, stream, data|
#       data.split(/\n/).each do |f|
#         next if IGNORE.include?(f)
#         begin
#           run "/bin/ls #{previous_release}/#{f}"
#         rescue Capistrano::Error => e
#           next
#         end
#         run "cp -rf #{previous_release}/#{f} #{latest_release}/#{f}"
#       end
#     end
#   end
# 
#   task :migrate do; end
# 
#   task :restart do; end
# 
#   task :start do; end
# 
# end