# frozen_string_literal: true

require 'thor'
require 'import'
require 'listener/runner'
require 'pp'

module Listener
  class Cli < Thor
    BANNER = <<-BANNER_TEXT

    ヽ(ﾟｰﾟ*ヽ)ヽ(*ﾟｰﾟ*)ﾉ(ﾉ*ﾟｰﾟ)ﾉ

    UH
      HI

        (◕‿◕✿)


    BANNER_TEXT

    method_option :topic,
                  type: :string,
                  default: ENV['NSQ_TOPIC'],
                  desc: 'MQ topic to subscribe to, defaults to NSQ_TOPIC from ENV'

    method_option :channel,
                  type: :string,
                  default: Application.config.name.to_s,
                  desc: 'MQ channel to subscribe to, can be set with NSQ_CHANNEL from ENV. NOTE: Consumers will receive duplicate messages on each unique channel connected to a topic'

    method_option :blocking,
                  type: :boolean,
                  default: false,
                  desc: 'Run consumer in blocking mode - faster for high loads, but blocks TERM until a message is received'

    method_option :workers,
                  type: :numeric,
                  default: 4,
                  desc: 'Number of concurrent workers to start'

    desc 'start', 'Run listener daemon'
    def start
      # copy thor opts structure to our own
      opts = {}
      options.each do |k, v|
        opts[k.to_sym] = v
      end

      r = Application['listener.runner']

      say BANNER

      say "=" * 60
      say "TOPIC ........: #{em opts[:topic]}"
      say "CHANNEL ......: #{em opts[:channel]}"
      say "BLOCKING .....: #{em opts[:blocking]}"
      say "WORKERS  .....: #{em opts[:workers]}"
      say "=" * 60

      ok 'Starting Workers.......'
      say "=" * 60

      r.run(opts)
    end

    private

    def em(text)
      shell.set_color(text, nil, true)
    end

    def ok(detail = nil)
      text = detail ? "OK, #{detail}." : 'OK.'
      say text, :green
    end

    def error(detail)
      say detail, :red
    end
  end
end
