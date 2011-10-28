set :application, "justnom.it"
set :repository,  "git@github.com:bnorton/nom_it.git"

set :scm, :git

role :web, "li90-14.members.linode.com"                          # Your HTTP server, Apache/etc
role :app, "li90-14.members.linode.com"                          # This may be the same as your `Web` server
role :db,  "li90-14.members.linode.com", :primary => true # This is where Rails migrations will run
# role :db,  "li90-14.members.linode.com"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end