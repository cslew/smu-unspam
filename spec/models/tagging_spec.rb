require 'spec_helper'

describe Tagging do
  it { should belong_to :smu_email }
  it { should belong_to :tag }
end
