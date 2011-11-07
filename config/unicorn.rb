# config/unicorn.rb
env = ENV["RAILS_ENV"] || "development"

worker_processes 4

listen "/apps/nom/shared/sockets/unicorn.sock", :backlog => 64

preload_app true

timeout 30

pid "/apps/nom/shared/pids/unicorn.pid"

# Production specific settings
if env == "production"
  working_directory "/apps/nom/current"

  user 'root', 'root'
  shared_path = "/apps/nom/shared"

  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
end

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "/apps/nom/shared/pids/unicorn.pid.oldbin"
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
