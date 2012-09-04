require 'spec_helper'

describe EmailReader do
  describe '.retrieve_and_store' do
    def create_mail(number)
      Mail.new do
        from "andy#{number}@benny.com"
        to "caroll#{number}@danny.com"
        subject "Fwd: Test Email #{number} Subject"
        body "Test Email #{number} Body"
      end
    end

    before do
      EmailReader.config
      mails = []
      mails << create_mail(1)
      mails << create_mail(2)
      Mail.stub(:all).and_return(mails)
    end

    it 'should save the emails in the database' do
      expect {
        EmailReader.retrieve_and_store
      }.to change(SmuEmail, :count).by(2)
    end

    it "should remove 'Fwd:' from the subject" do
      EmailReader.retrieve_and_store
      mail = SmuEmail.first
      mail.subject.index("Fwd:").should == nil
    end
  end
end
