require 'spec_helper'

describe EmailReader do
  describe '.retrieve_and_store' do
    def create_mail(number)
      a_body = "Test Email #{number} Body\nFrom: Earl Falken#{number} <earl#{number}@falken.com>"

      Mail.new do
        from "andy#{number}@benny.com"
        to "caroll#{number}@danny.com"
        subject "Fw: Test Email #{number} Subject"
        body a_body
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

    it "should extract and process the 'From:' line" do
      EmailReader.retrieve_and_store
      mail = SmuEmail.first
      mail.sender_email.should_not == nil
      mail.sender_name.should_not == nil
    end

    context "when the tag does not exist" do
      it "should create a new tag" do
        expect {
          EmailReader.retrieve_and_store
        }.to change(Tag, :count).by(2)
      end
    end

    context "when tags exist" do
      before do
        Tag.new(name: "Earl Falken1").save
        Tag.new(name: "Earl Falken2").save
      end

      it "should not create the tags" do
        Tag.first(name: "Earl Falken1").should_not == nil
        Tag.first(name: "Earl Falken2").should_not == nil
        expect {
          EmailReader.retrieve_and_store
        }.to change(Tag, :count).by(0)
      end
    end

    it "should remove 'Fw:' from the subject" do
      EmailReader.retrieve_and_store
      mail = SmuEmail.first
      mail.subject.index("Fw:").should == nil
    end
  end
end
