# config/unicorn.rb
env = ENV["RAILS_ENV"] || "development"

app_root = ENV["NOM_ROOT"] || "/apps/nom/current"
app_root_shared = ENV["NOM_ROOT_SHARED"] || "/apps/nom/shared"

worker_processes 4


listen "#{app_root}/tmp/sockets/unicorn.sock", :backlog => 64

preload_app true

timeout 30

pid "#{app_root}/tmp/pids/unicorn.pid"

# Production specific settings
if env == "production"
  working_directory app_root

  user 'root', 'root'
  shared_path = app_root_shared

  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
end

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{app_root}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

end
