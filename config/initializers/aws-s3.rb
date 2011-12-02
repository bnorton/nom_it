require "aws/s3"

# AWS::S3::DEFAULT_HOST = "s3-us-west-1.amazonaws.com"
# AWS::S3::DEFAULT_HOST = "img.justnom.s3.amazonaws.com"

Paperclip.interpolates(:s3_norcal_url) do |att, style|
    "#{att.s3_protocol}://s3-us-west-1.amazonaws.com/#{att.bucket_name}/#{att.path(style)}"
end

module AWS
    module S3
        DEFAULT_HOST = "s3-us-west-1.amazonaws.com"
    end
end
