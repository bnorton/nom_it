set :application, "justnom.it"
set :repository,  "git@github.com:bnorton/nom_it.git"

set :scm, :git

set :user, :root

role :web, "justnom.it"                          # Your HTTP server, Apache/etc
role :app, "justnom.it"                          # This may be the same as your `Web` server
role :db,  "justnom.it", :primary => true        # This is where Rails migrations will run

set :rails_env, :production
set :unicorn_binary, "unicorn"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do 
    # run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
    run "cd #{current_path} && #{unicorn_binary} -c #{unicorn_config} -E #{rails_env}"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    # run "#{try_sudo} kill `cat #{unicorn_pid}`"
    run "kill `cat #{unicorn_pid}`"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    # run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
    run "kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    # run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
    run "kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end
end

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