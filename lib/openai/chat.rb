# frozen_string_literal: true

class OpenAI
  class Chat
    include Anima.new(:messages, :api_settings, :openai, :config)
    using Util::Colorize

    def initialize(opts)
      opts = { settings: {}.freeze, config: Config.create }.merge(opts)
      messages = opts.fetch(:messages).map do |msg|
        if msg.is_a?(Hash)
          Message.new(msg)
        else
          msg
        end
      end

      super(
        messages:,
        api_settings: opts.fetch(:settings),
        config: opts.fetch(:config),
        openai: opts.fetch(:openai)
      )
    end

    def configure(**configuration)
      with(config: config.with(configuration))
    end

    def add_user_message(message)
      add_message('user', message)
    end
    alias user add_user_message

    def add_system_message(message)
      add_message('system', message)
    end
    alias system add_system_message

    def add_assistant_message(message)
      add_message('assistant', message)
    end
    alias assistant add_assistant_message

    def submit
      openai.logger.info("[Chat] [tokens=#{total_tokens}] Submitting messages:\n\n#{to_log_format}")

      begin
        response = openai.api.chat_completions.create(
          **api_settings,
          messages: raw_messages
        )
      rescue OpenAI::API::Error::ContextLengthExceeded
        raise 'Context length exceeded.'
        openai.logger.warn('[Chat] Context length exceeded. Shifting chat')
        return shift_history.submit
      end

      msg = response.choices.first.message

      add_message(msg.role, msg.content).tap do |new_chat|
        openai.logger.info("[Chat] Response:\n\n#{new_chat.last_message.to_log_format(config)}")
      end
    end

    def last_message
      messages.last
    end

    def to_log_format
      messages.map do |msg|
        msg.to_log_format(config)
      end.join("\n\n")
    end

    private

    def shift_history
      drop_index = messages.index { |msg| msg.role != 'system' }
      new_messages = messages.slice(0...drop_index) + messages.slice((drop_index + 1)..)

      with(messages: new_messages)
    end

    def total_tokens
      openai.tokens.for_model(api_settings.fetch(:model)).num_tokens(messages.map(&:content).join(' '))
    end

    def raw_messages
      messages.map(&:to_h)
    end

    def add_message(role, content)
      with_message(role:, content:)
    end

    def with_message(message)
      with(messages: messages + [message])
    end

    class Config
      include Anima.new(:assistant_name)

      def self.create
        new(assistant_name: 'assistant')
      end
    end

    class Message
      include Anima.new(:role, :content)

      def to_log_format(config)
        prefix =
          case role
          when 'user' then "#{role}:".upcase.green
          when 'system' then "#{role}:".upcase.yellow
          when 'assistant' then "#{config.assistant_name}:".upcase.red
          else
            raise "Unknown role: #{role}"
          end

        "#{prefix} #{content}"
      end
    end
  end
end
