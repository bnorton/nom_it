# MONGO_CONFIG     = YAML.load_file(File.join(Rails.root, "config", "mongodb.yml"))
# MEMCACHED_CONFIG = YAML.load_file(File.join(Rails.root, "config", "memcached.yml"))
# MYSQL_CONFIG = YAML.load_file(File.join(Rails.root, "config", "database.yml"))
RAND_SEED = 36**10

Paperclip.options[:command_path] = "/usr/local/bin"
Paperclip.options[:log_command] = true
Paperclip.options[:log] = true

Paperclip.interpolates(:s3_norcal_url) { |attachment, style|
  "#{attachment.s3_protocol}://#{AWS::S3::DEFAULT_HOST}/#{attachment.bucket_name}/#{attachment.path(style).gsub(%r{^/}, "")}"
}
Paperclip.interpolates(:s3_static_url) { |attachment, style|
  "http://static.justnom.it/#{attachment.path(style).gsub(%r{^/}, "")}"
}

