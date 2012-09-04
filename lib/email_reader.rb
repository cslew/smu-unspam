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
      new_mail = SmuEmail.new(subject: mail.subject)
      new_mail.save

      puts mail.subject
    end

    puts "{\"task\": \"retrieve_and_store\", \"number_of_emails\": #{mails.length}}"
  end
end
