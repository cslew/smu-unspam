class Tagging
  include DataMapper::Resource

  belongs_to :smu_email, :key => true
  belongs_to :tag , :key => true
end
