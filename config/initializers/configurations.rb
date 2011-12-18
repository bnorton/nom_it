RAILS_ENV = ENV['RAILS_ENV'] || 'development'

MONGODB_CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'mongodb.yml'))[RAILS_ENV]
MEMCACHED_CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'memcached.yml'))[RAILS_ENV]
S3_CONFIG = YAML.load_file(File.join(Rails.root, 'config', 's3.yml'))[RAILS_ENV]
