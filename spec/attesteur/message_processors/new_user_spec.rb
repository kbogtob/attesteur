# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::MessageProcessors::NewUser do
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

  let(:message) do
    instance_double(Telegram::Bot::Types::Message)
  end

  describe '#eligible?' do
    let(:fake_user) do
      instance_double(Attesteur::User,
        greeted?: greeted,
        subscribed?: subscribed,
      )
    end

    context 'when the user was greeted' do
      let(:greeted) do
        true
      end

      let(:subscribed) do
        false
      end

      it 'returns false' do
        expect(subject.eligible?(fake_user, message)).to be false
      end
    end

    context 'when the user was not greeted' do
      let(:greeted) do
        false
      end

      context 'and the user is not subscribed' do
        let(:subscribed) do
          false
        end

        it 'returns true' do
          expect(subject.eligible?(fake_user, message)).to be true
        end
      end

      context 'and the user is subscribed' do
        let(:subscribed) do
          true
        end

        it 'returns false' do
          expect(subject.eligible?(fake_user, message)).to be false
        end
      end
    end
  end

  describe '#consume_message' do
    let(:fake_user) do
      instance_double(Attesteur::User,
        id: '1234',
        greet!: true
      )
    end

    it 'greets the user' do
      expect(api)
        .to receive(:send_message)
        .with(
          chat_id: '1234',
          text: Attesteur::Texts::SUBSCRIPTION
        )

      subject.consume_message(fake_user, message)
    end

    it 'marks the user as greeted' do
      expect(fake_user)
        .to receive(:greet!)

      subject.consume_message(fake_user, message)
    end

    it 'returns next' do
      expect(subject.consume_message(fake_user, message)).to be :next
    end
  end
end
