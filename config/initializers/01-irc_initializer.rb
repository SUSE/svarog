puts "*** 01-irc_initializer.rb"

if ENV['RACK_ENV'] != 'test'
  require 'cinch'

  # Redirect $stderr to log file
  $stderr = File.new('log/irc.log', 'w')
  $stderr.sync = true

  IRC = Thread.new do
    class SvarogPlugin
      include Cinch::Plugin

      timer 5, method: :notify
      def notify
        Notification::Message.all.each do |message|
          CONFIG[:irc][:channels].each do |channel|
            # Too much noise => bot.nick = message.sender

            case message.type
            when 'success'
              notification = "\x0300,09 #{message.type.upcase} \x03 #{message.sender}: #{message.text}"
            when 'info'
              notification = "\x0300,12 #{message.type.upcase} \x03 #{message.sender}: #{message.text}"
            when 'alert'
              notification = "\x0300,04 #{message.type.upcase} \x03 #{message.sender}: #{message.text}"
            when 'warning'
              notification = "\x0300,07 #{message.type.upcase} \x03 #{message.sender}: #{message.text}"
            else
              notification = "#{message.sender}: #{message.text}"
            end

            success = Channel(channel).send(notification)
            message.destroy if success
          end
        end
      end
    end

    bot = Cinch::Bot.new do
      configure do |c|
        c.nick = CONFIG[:irc][:nick]
        c.server = CONFIG[:irc][:server]
        c.channels = CONFIG[:irc][:channels]
        c.verbose = false
        c.plugins.plugins = [SvarogPlugin]
        c.log = self.loggers.first
      end
    end

    bot.start
  end
end
