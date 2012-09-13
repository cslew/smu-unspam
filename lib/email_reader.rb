require 'mail'

class EmailReader
  def self.config
    Mail.defaults do
      retriever_method :pop3, :address => ENV['EMAIL_SERVER'],
                       :port => ENV['EMAIL_PORT'],
                       :user_name => ENV['EMAIL_USER_NAME'],
                       :password => ENV['EMAIL_PASSWORD'],
                       :enable_ssl => true
    end
  end

  def self.retrieve_and_store
    EmailReader.config
    mails = Mail.all

    mails.each do |mail|
      original_subject = mail.subject
      puts "{\"processing\": \"#{original_subject}\", \"start_time\": #{Time.now.to_i}}"

      mail.subject.gsub!("Fw: ", "")
      sender_data = process_from(mail.body.encoded.split("\n").grep(/From:/)[0])

      if sender_data[:success] == 0
        puts "No sender name, skipping email."
        puts "{\"processing\": \"#{mail.subject}\", \"end_time\": #{Time.now.to_i}, \"success\": 0, \"error_message\": sender_data[:error_message]}"
        next
      end

      new_mail = SmuEmail.new(subject: mail.subject,
                              date: Date.today,
                              sender_name: sender_data[:sender_name],
                              sender_email: sender_data[:sender_email])

      tag_name = sender_data[:sender_name]
      tag = Tag.first(name: tag_name)

      if !tag
        tag = Tag.new(name: tag_name)
        tag.save
      end

      new_mail.tags << tag
      new_mail.save

      read_and_upload_attachments(mail, new_mail)

      puts "{\"processing\": \"#{original_subject}\", \"end_time\": #{Time.now.to_i}, \"success\": 1}"
    end

    puts "{\"task\": \"retrieve_and_store\", \"number_of_emails\": #{mails.length}}"
  end

  private
  def self.read_and_upload_attachments(mail, smu_email)
    mail.attachments.each do |attachment|
      # Attachments is an AttachmentsList object containing a
      # number of Part objects
      if (attachment.content_type.start_with?('image/'))
        filename = "#{Time.now.to_i.to_s}-#{attachment.filename}"
        begin
          file = attachment.body.decoded
          S3Manager.upload_attachment(filename, file)

          image_attachment = ImageAttachment.new(filename: filename)
          smu_email.image_attachments << image_attachment
          smu_email.save
        rescue Exception => e
          puts "Unable to upload attachment for #{filename} because #{e.message}"
        end
      end
    end
  end

  def self.process_from(line)
    #sender_name
    sender_name = line
    from_index = sender_name.index("From:")
    sender_name = sender_name[from_index+5, sender_name.length]
    left_arrow_index = sender_name.index("<")

    if left_arrow_index == nil
      return { success: 0, error_message: "name not found in From:" }
    end

    sender_name = sender_name[0, left_arrow_index-1]
    sender_name.strip!

    #sender_email
    left_arrow_index = line.index("<")
    right_arrow_index = line.rindex(">")
    sender_email = line[left_arrow_index+1..right_arrow_index-1]

    {success: 1, sender_name: sender_name, sender_email: sender_email}
  end
end
