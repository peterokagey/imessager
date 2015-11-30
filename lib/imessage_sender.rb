class MessageSender

  def initialize(message)
    @text = message
  end

  def send!
    puts "Attempting to send '#{@text}'."
    system(send)
    puts "Message appears to have successfully sent!"
  end

  private

  DEFAULT_PHONE_NUMBER = ENV['MICHAELS_PHONE_NUMBER']

  def send
    @send ||= "osascript -e \"#{apple_script}\""
  end

  # http://www.tenshu.net/2015/02/send-imessage-and-sms-with-applescript.html
  def raw_script
    %(
      tell application "Messages"
        send "#{@text}" to buddy "#{DEFAULT_PHONE_NUMBER}" of (service 1 whose service type is iMessage)
      end tell
    )
  end

  def apple_script
    raise "Unsupported character!" if @text =~ /[\n"\\]/
    raw_script.gsub('"', "\\\"") # escape quotes
  end

end

MessageSender.new("How is your day going?").send!
