require 'spec_helper'

describe SmuEmail do
  it { should have_property :id }
  it { should have_property :date }
  it { should have_property :subject }
  it { should have_property :sender_email }
  it { should have_property :sender_name }

  it { should have_many :taggings }
  it { should have_many(:tags).through(:taggings) }
end
