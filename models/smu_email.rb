class SmuEmail
  include DataMapper::Resource
  property :id, Serial
  property :date, Date
  property :subject, Text
  property :sender_name, Text
  property :sender_email, Text

  has n, :taggings
  has n, :tags, :through => :taggings
end
