# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::MessageProcessors::Forget do
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
    instance_double(Attesteur::User, id: '1234')
  end

  let(:message) do
    Telegram::Bot::Types::Message.new(
      text: text
    )
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

    context 'when the text is nil' do
      it 'returns false' do
        expect(subject.eligible?(fake_user, message)).to be_falsy
      end
    end

    context 'when the text does not contain /forget' do
      let(:text) do
        'Bonjour'
      end

      it 'returns false' do
        expect(subject.eligible?(fake_user, message)).to be false
      end
    end

    context 'when the text contains /forget' do
      let(:text) do
        'je veux être oublié /forget'
      end

      it 'returns true' do
        expect(subject.eligible?(fake_user, message)).to be true
      end
    end
  end

  describe '#consume_message' do
    before do
      allow(brain)
        .to receive(:delete)
    end

    it 'returns :stop' do
      expect(subject.consume_message(fake_user, message)).to be :stop
    end

    it 'sends a message to ack request' do
      expect(api)
        .to receive(:send_message)
        .with(
          chat_id: '1234',
          text: Attesteur::Texts::FORGETING,
        )

      subject.consume_message(fake_user, message)
    end

    it 'asks the brain to forget the user' do
      expect(brain)
        .to receive(:delete)
        .with(fake_user)

      subject.consume_message(fake_user, message)
    end
  end
end
