require "openssl"

module Cinch
  module Plugins
    class Identify
      include Cinch::Plugin

      listen_to :connect, method: :identify
      def identify(m)
        case config[:type]
        when :quakenet
          debug "Identifying with Q"
          identify_quakenet
        when :secure_quakenet, :challengeauth
          debug "Identifying with Q, using CHALLENGEAUTH"
          identify_secure_quakenet
        when :nickserv
          debug "Identifying with NickServ"
          identify_nickserv
        when :kreynet
          debug "Identifying with K on KreyNet"
          identify_kreynet
        end
      end

      match(/^CHALLENGE (.+?) (.+)$/, use_prefix: false, use_suffix: false, react_on: :notice)
      def challengeauth(m)
        return unless m.user && m.user.nick == "Q"
        if match = m.message.match(/^CHALLENGE (.+?) (.+)$/)
          challenge = match[1]
          @bot.debug "Received challenge '#{challenge}'"

          username = config[:username].irc_downcase(:rfc1459)
          password = config[:password][0,10]

          key = OpenSSL::Digest::SHA256.hexdigest(username + ":" + OpenSSL::Digest::SHA256.hexdigest(password))
          response = OpenSSL::HMAC.hexdigest("SHA256", key, challenge)
          User("Q@CServe.quakenet.org").send("CHALLENGEAUTH #{username} #{response} HMAC-SHA-256")
        end
      end

      private
      def identify_quakenet
        User("Q@CServe.quakenet.org").send("auth %s %s" % [config[:username], config[:password]])
      end

      def identify_secure_quakenet
        User("Q@CServe.quakenet.org").send("CHALLENGE")
      end

      def identify_nickserv
        User("nickserv").send("identify %s %s" % [config[:username], config[:password]])
      end

      def identify_kreynet
        User("K!k@krey.net").send("LOGIN %s %s" % [config[:username], config[:password]])
      end
    end
  end
end
