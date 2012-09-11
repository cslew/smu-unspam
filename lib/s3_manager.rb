require 'aws/s3'

class S3Manager
  include AWS::S3

  def self.upload_attachment(filename, file)
    AWS::S3::Base.establish_connection!(
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )

    S3Object.store(filename, file, ENV['s3_bucket'],
                   access: :public_read)
  end
end
