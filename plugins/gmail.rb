require 'gmail'

class GMail

  def self.run(conf, testing)
    trace_back = testing ? 30*24*3600 : 2*24*3600
    output = []
    conf["accounts"].each do |account|
      # validate first
      if account["username"].to_s.length < 1 or account["password"].to_s.length < 1
        puts "missing gmail user name or password"
        return []
      end

      Gmail.connect(account["username"], account["password"]) do |g|
        mails = g.inbox.emails(:unread, :after => (Time.now - trace_back))
        puts "new emails for #{account["username"]}: #{mails.count}" if testing
        mails.each do |m|
          bodytext = m.text_part ? m.text_part.body.to_s : (m.body.to_s.length > 0 ? m.body.to_s : "")
          t = Time.now.localtime
          output << "#{m.from[0].name}: #{m.subject} === #{bodytext}".gsub("&amp;", "&").gsub(/=\?WINDOWS-\d+\?Q\?/, "")[0..512] + " (#{t.hour}:#{t.min})"
          keep = false
          subject_l = m.subject.downcase
          conf["keep"].each do |query|
              if subject_l.index(query.downcase)
                keep = true
              break
            end
          end
          if keep
            m.unread!
          else
            m.read!
          end
        end
      end
    end
    puts output.join("\n") if testing
    return output
  end
  
end