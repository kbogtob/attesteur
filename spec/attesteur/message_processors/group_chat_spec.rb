# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::MessageProcessors::GroupChat do
  subject do
    described_class.new(brain, api)
  end

  let(:brain) do
    instance_double(Attesteur::BotBrain)
  end

  let(:api) do
    double(Telegram::Bot::Api,
      send_message: true)
  end

  let(:fake_user) do
    instance_double(Attesteur::User)
  end

  let(:message) do
    Telegram::Bot::Types::Message.new(
      chat: chat,
      text: text
    )
  end

  let(:chat) do
    Telegram::Bot::Types::Chat.new(id: 'chat', type: chat_type)
  end

  let(:chat_type) do
    'group'
  end

  let(:text) do
    nil
  end

  describe '#eligible?' do
    context 'when the message is not a message' do
      let(:message) do
        Telegram::Bot::Types::CallbackQuery.new(data: 'stuff')
      end

      it 'returns false' do
        expect(subject.eligible?(fake_user, message)).to be false
      end
    end

    context 'when the message is on a private chat' do
      let(:chat_type) do
        'private'
      end

      it 'returns false' do
        expect(subject.eligible?(fake_user, message)).to be false
      end
    end

    context 'when the message is on a channel or group chat' do
      let(:chat_type) do
        'group'
      end

      it 'returns true' do
        expect(subject.eligible?(fake_user, message)). to be true
      end
    end
  end

  describe '#consume_message' do
    context 'when the text is nil' do
      it 'returns :stop' do
        expect(subject.consume_message(fake_user, message)).to be :stop
      end

      it 'does not send any message' do
        expect(api)
          .not_to receive(:send_message)

        subject.consume_message(fake_user, message)
      end
    end

    context 'when the text does not contain "attestation"' do
      let(:text) do
        "attends station"
      end

      it 'returns :stop' do
        expect(subject.consume_message(fake_user, message)).to be :stop
      end

      it 'does not send any message' do
        expect(api)
          .not_to receive(:send_message)

        subject.consume_message(fake_user, message)
      end
    end

    context 'when the text contains "attestation"' do
      let(:text) do
        "hello j'ai pas eu d'attestations"
      end

      it 'returns :stop' do
        expect(subject.consume_message(fake_user, message)).to be :stop
      end

      it 'sends the special message' do
        expect(api)
          .to receive(:send_message)
          .with(
            chat_id: 'chat',
            text: Attesteur::Texts::SLIDE_TO_DM
          )

        subject.consume_message(fake_user, message)
      end
    end
  end
end
