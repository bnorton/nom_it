# config/unicorn.rb
# Set environment to development unless something else is specified
env = ENV["RAILS_ENV"] || "development"

# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
worker_processes 4

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "/tmp/unicorn.nom_it.socket", :backlog => 64

# Preload our app for more speed
preload_app true

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

pid "/tmp/unicorn.nom_it.pid"

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
pwd = working_directory "/home/deployer/apps/justnom.it/current"

# Production specific settings
if env == "production"

  # feel free to point this anywhere accessible on the filesystem
  user 'deployer', 'staff'
  shared_path = "#{pwd}/tmp"

  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "/tmp/unicorn.nom_it.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end

# # # Sample verbose configuration file for Unicorn (not Rack)
# # #
# # # This configuration file documents many features of Unicorn
# # # that may not be needed for some applications. See
# # # http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
# # # for a much simpler configuration file.
# # #
# # # See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# # # documentation.
# # 
# # # Use at least one worker per core if you're on a dedicated server,
# # # more will usually help for _short_ waits on databases/caches.
# # worker_processes 4
# # 
# # # Since Unicorn is never exposed to outside clients, it does not need to
# # # run on the standard HTTP port (80), there is no reason to start Unicorn
# # # as root unless it's from system init scripts.
# # # If running the master process as root and the workers as an unprivileged
# # # user, do this to switch euid/egid in the workers (also chowns logs):
# # # user "unprivileged_user", "unprivileged_group"
# # 
# # # Help ensure your application will always spawn in the symlinked
# # # "current" directory that Capistrano sets up.
# # APP_PATH = "/u/apps/justnom.it/current"
# # working_directory APP_PATH
# # 
# # # listen on both a Unix domain socket and a TCP port,
# # # we use a shorter backlog for quicker failover when busy
# # listen "/tmp/sockets/unicorn.sock", :backlog => 64
# # listen 8080, :tcp_nopush => true
# # 
# # # nuke workers after 30 seconds instead of 60 seconds (the default)
# # timeout 30
# # 
# # # feel free to point this anywhere accessible on the filesystem
# # pid APP_PATH + "/tmp/pids/unicorn.pid"
# # 
# # # By default, the Unicorn logger will write to stderr.
# # # Additionally, ome applications/frameworks log to stderr or stdout,
# # # so prevent them from going to /dev/null when daemonized here:
# # stderr_path APP_PATH + "/log/unicorn.stderr.log"
# # stdout_path APP_PATH + "/log/unicorn.stderr.log"
# # 
# # # combine REE with "preload_app true" for memory savings
# # # http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
# # preload_app true
# # GC.respond_to?(:copy_on_write_friendly=) and
# #   GC.copy_on_write_friendly = true
# # 
# # before_fork do |server, worker|
# #   # the following is highly recomended for Rails + "preload_app true"
# #   # as there's no need for the master process to hold a connection
# #   defined?(ActiveRecord::Base) and
# #     ActiveRecord::Base.connection.disconnect!
# # 
# #   # The following is only recommended for memory/DB-constrained
# #   # installations.  It is not needed if your system can house
# #   # twice as many worker_processes as you have configured.
# #   #
# #   # # This allows a new master process to incrementally
# #   # # phase out the old master process with SIGTTOU to avoid a
# #   # # thundering herd (especially in the "preload_app false" case)
# #   # # when doing a transparent upgrade.  The last worker spawned
# #   # # will then kill off the old master process with a SIGQUIT.
# #   # old_pid = "#{server.config[:pid]}.oldbin"
# #   # if old_pid != server.pid
# #   #   begin
# #   #     sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
# #   #     Process.kill(sig, File.read(old_pid).to_i)
# #   #   rescue Errno::ENOENT, Errno::ESRCH
# #   #   end
# #   # end
# #   #
# #   # Throttle the master from forking too quickly by sleeping.  Due
# #   # to the implementation of standard Unix signal handlers, this
# #   # helps (but does not completely) prevent identical, repeated signals
# #   # from being lost when the receiving process is busy.
# #   # sleep 1
# # end
# # 
# # after_fork do |server, worker|
# #   # per-process listener ports for debugging/admin/migrations
# #   # addr = "127.0.0.1:#{9293 + worker.nr}"
# #   # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)
# # 
# #   # the following is *required* for Rails + "preload_app true",
# #   defined?(ActiveRecord::Base) and
# #     ActiveRecord::Base.establish_connection
# # 
# #   # if preload_app is true, then you may also want to check and
# #   # restart any other shared sockets/descriptors such as Memcached,
# #   # and Redis.  TokyoCabinet file handles are safe to reuse
# #   # between any number of forked children (assuming your kernel
# #   # correctly implements pread()/pwrite() system calls)
# # end
# 
# 
# ENV['MY_RUBY_HOME'] = run "`which ruby`"
# APP_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))
# 
# if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
#   begin
#     rvm_path = File.dirname(File.dirname(ENV['MY_RUBY_HOME']))
#     rvm_lib_path = File.join(rvm_path, 'lib')
#     $LOAD_PATH.unshift rvm_lib_path
#     require 'rvm'
#     RVM.use_from_path! APP_ROOT
#   rescue LoadError
#     raise "RVM ruby lib is currently unavailable."
#   end
# end
# 
# ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
# require 'bundler/setup'
# 
# worker_processes 4
# working_directory APP_ROOT
# 
# preload_app true
# 
# timeout 30
# 
# listen APP_ROOT + "/tmp/sockets/unicorn.sock", :backlog => 64
# 
# pid APP_ROOT + "/tmp/pids/unicorn.pid"
# 
# stderr_path APP_ROOT + "/log/unicorn.stderr.log"
# stdout_path APP_ROOT + "/log/unicorn.stdout.log"
# 
# before_fork do |server, worker|
#   defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
# 
#   old_pid = RAILS_ROOT + '/tmp/pids/unicorn.pid.oldbin'
#   if File.exists?(old_pid) && server.pid != old_pid
#     begin
#       Process.kill("QUIT", File.read(old_pid).to_i)
#     rescue Errno::ENOENT, Errno::ESRCH
#       puts "Old master alerady dead"
#     end
#   end
# end
# 
# after_fork do |server, worker|
#   defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
# end
# 
