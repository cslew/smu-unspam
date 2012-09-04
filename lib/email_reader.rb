require 'mail'

class EmailReader
  def self.config
    Mail.defaults do
      retriever_method :pop3, :address => ENV['email_server'],
                       :port => ENV['email_port'],
                       :user_name => ENV['email_user_name'],
                       :password => ENV['email_password'],
                       :enable_ssl => true
    end
  end

  def self.retrieve_and_store
    EmailReader.config
    mails = Mail.all

    mails.each do |mail|
      mail.subject.gsub!("Fwd: ", "")
      sender_data = process_from(mail.body.encoded.split("\n").grep(/From:/)[0])
      new_mail = SmuEmail.new(subject: mail.subject,
                              date: Date.today,
                              sender_name: sender_data[:sender_name],
                              sender_email: sender_data[:sender_email])
      new_mail.save
    end

    puts "{\"task\": \"retrieve_and_store\", \"number_of_emails\": #{mails.length}}"
  end

  private
  def self.process_from(line)
    #sender_name
    sender_name = line
    sender_name.slice!("From: ")
    left_arrow_index = sender_name.index("<")
    sender_name = sender_name[0, left_arrow_index-1]

    #sender_email
    left_arrow_index = line.index("<")
    right_arrow_index = line.index(">")
    sender_email = line[left_arrow_index+1..right_arrow_index-1]

    {sender_name: sender_name, sender_email: sender_email}
  end
end