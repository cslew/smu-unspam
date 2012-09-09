require 'spec_helper'

describe ImageAttachment do
  it { should have_property :id }
  it { should have_property :filename }

  it { should belong_to :smu_email }
end
