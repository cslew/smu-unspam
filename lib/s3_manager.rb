require 'aws/s3'

class S3Manager
  include AWS::S3

  def self.upload_attachment(filename, file)
    AWS::S3::Base.establish_connection!(
        access_key_id: ENV['aws_access_key_id'],
        secret_access_key: ENV['aws_secret_access_key']
    )

    S3Object.store(filename, file, ENV['s3_bucket'],
                   access: :public_read)
  end
end
