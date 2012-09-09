class ImageAttachment
  include DataMapper::Resource
  property :id, Serial
  property :filename, String

  belongs_to :smu_email
end
