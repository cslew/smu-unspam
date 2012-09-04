require 'spec_helper'

describe Tag do
  it { should have_property :id }
  it { should have_property :name }

  it { should have_many :taggings }
  it { should have_many(:smu_emails).through(:taggings) }
end
