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
        when :userserv
          debug "Identifying with UserServ"
          identify_userserv
        else
          debug "Not going to identify with unknown type #{config[:type].inspect}"
        end
      end

      match(/^You are successfully identified as/,           use_prefix: false, use_suffix: false, react_on: :private, method: :identified_nickserv)
      match(/^You are now identified for/,                   use_prefix: false, use_suffix: false, react_on: :private, method: :identified_nickserv)
      match(/^Password accepted - you are now recognized\./, use_prefix: false, use_suffix: false, react_on: :private, method: :identified_nickserv)
      def identified_nickserv(m)
        if m.user == User("nickserv") && config[:type] == :nickserv
          debug "Identified with NickServ"
          @bot.handlers.dispatch :identified, m
        end
      end

      match(/^CHALLENGE (.+?) (.+)$/, use_prefix: false, use_suffix: false, react_on: :notice, method: :challengeauth)
      def challengeauth(m)
        return unless m.user && m.user.nick == "Q"
        return unless [:secure_quakenet, :challengeauth].include?(config[:type])

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

      match(/^You are now logged in as/, use_prefix: false, use_suffix: false, react_on: :notice, method: :identified_quakenet)
      def identified_quakenet(m)
        if m.user == User("q") && [:quakenet, :secure_quakenet, :challengeauth].include?(config[:type])
          debug "Identified with Q"
          @bot.handlers.dispatch(:identified, m)
        end
      end

      match(/^You are now logged in as/, use_prefix: false, use_suffix: false, react_on: :notice, method: :identified_userserv)
      def identified_userserv(m)
        service_name = config[:service_name] || "UserServ"
        if m.user == User(service_name) && config[:type] == :userserv
          debug "Identified with UserServ"
          @bot.handlers.dispatch :identified, m
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
        if config[:username]
          User("nickserv").send("identify %s %s" % [config[:username], config[:password]])
        else
          User("nickserv").send("identify %s" % [config[:password]])
        end
      end

      def identify_kreynet
        User("K!k@krey.net").send("LOGIN %s %s" % [config[:username], config[:password]])
      end

      def identify_userserv
        service_name = config[:service_name] || "UserServ"
        User(service_name).send("LOGIN %s %s" % [config[:username], config[:password]])
      end
    end
  end
end
