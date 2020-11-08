# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::MessageProcessors::Unsubscribed do
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
    instance_double(Telegram::Bot::Types::Message,
      text: 'Paris'
    )
  end

  describe '#eligible?' do
    let(:fake_user) do
      instance_double(Attesteur::User,
        subscribed?: subscribed,
      )
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

  describe '#consume_message' do
    let(:fake_user) do
      instance_double(Attesteur::User,
        id: '1234',
        fill: true,
        next_missing_field: 'town',
        subscribing?: subscribing,
        subscribing!: true,
        subscribed?: subscribed,
      )
    end

    let(:subscribed) do
      false
    end

    context 'when the user is not subscribing yet' do
      let(:subscribing) do
        false
      end

      it 'asks the next_missing_field question' do
        expect(api)
          .to receive(:send_message)
          .with(
            chat_id: '1234',
            text: Attesteur::Texts.question_for("town"),
          )

        subject.consume_message(fake_user, message)
      end

      it 'marks the user as subscribing' do
        expect(fake_user)
          .to receive(:subscribing!)

        subject.consume_message(fake_user, message)
      end

      it 'returns stop' do
        expect(subject.consume_message(fake_user, message)).to be :stop
      end
    end

    context 'when the user is subscribing' do
      let(:subscribing) do
        true
      end

      it 'fills the user' do
        expect(fake_user)
          .to receive(:fill)
          .with('town', 'Paris')

        subject.consume_message(fake_user, message)
      end

      it 'asks the next_missing_field question' do
        expect(api)
          .to receive(:send_message)
          .with(
            chat_id: '1234',
            text: Attesteur::Texts.question_for("town"),
          )

        subject.consume_message(fake_user, message)
      end

      it 'returns stop' do
        expect(subject.consume_message(fake_user, message)).to be :stop
      end

      context 'when it is the last field' do
        before do
          allow(brain)
            .to receive(:save)
        end

        let(:subscribed) do
          # this should never happen in real life
          # but it is useful here to simulate the fact
          # that we reach the end of subscription
          true
        end

        it 'fills the user' do
          expect(fake_user)
            .to receive(:fill)
            .with('town', 'Paris')

          subject.consume_message(fake_user, message)
        end

        it 'does not send a message' do
          expect(api)
            .not_to receive(:send_message)

          subject.consume_message(fake_user, message)
        end

        it 'saves the user in the brain' do
          expect(brain)
            .to receive(:save)
            .with(fake_user)

          subject.consume_message(fake_user, message)
        end

        it 'returns next' do
          expect(subject.consume_message(fake_user, message)).to be :next
        end
      end
    end
  end
end
