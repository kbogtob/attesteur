# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::Dispatcher do
  subject do
    described_class.new(processors)
  end

  let(:processors) do
    [
      group_chat_processor,
      new_user_processor,
    ]
  end

  let(:group_chat_processor) do
    instance_double(Attesteur::MessageProcessors::GroupChat)
  end

  let(:new_user_processor) do
    instance_double(Attesteur::MessageProcessors::NewUser)
  end

  describe '#dispatch' do
    let(:user) do
      instance_double(Attesteur::User)
    end

    let(:message) do
      instance_double(Telegram::Bot::Types::Message)
    end

    context 'when no processor is eligible' do
      before do
        allow(group_chat_processor)
          .to receive(:eligible?)
          .with(user, message)
          .and_return(false)

        allow(new_user_processor)
          .to receive(:eligible?)
          .with(user, message)
          .and_return(false)
      end

      it 'returns 0 processor called' do
        expect(subject.dispatch(user, message)).to eq 0
      end
    end

    context 'when first processor is eligible' do
      before do
        allow(group_chat_processor)
          .to receive(:eligible?)
          .with(user, message)
          .and_return(true)
      end

      context 'when first processor returns :stop' do
        before do
          allow(group_chat_processor)
            .to receive(:consume_message)
            .with(user, message)
            .and_return(:stop)
        end

        it 'returns 1 processor called' do
          expect(subject.dispatch(user, message)).to eq 1
        end

        it 'consumes the message using the first processor' do
          expect(group_chat_processor)
            .to receive(:consume_message)
            .with(user, message)

            subject.dispatch(user, message)
        end

        it 'does not try the next processor' do
          expect(new_user_processor)
            .not_to receive(:eligible?)

          subject.dispatch(user, message)
        end
      end

      context 'when first processor returns :next' do
        before do
          allow(group_chat_processor)
            .to receive(:consume_message)
            .with(user, message)
            .and_return(:next)

          allow(new_user_processor)
            .to receive(:eligible?)
            .with(user, message)
            .and_return(false)
        end

        it 'returns 1 processor called' do
          expect(subject.dispatch(user, message)).to eq 1
        end

        it 'consumes the message using the first processor' do
          expect(group_chat_processor)
            .to receive(:consume_message)
            .with(user, message)

          subject.dispatch(user, message)
        end

        it 'does tries the next processor' do
          expect(new_user_processor)
            .to receive(:eligible?)
            .with(user, message)

          subject.dispatch(user, message)
        end

        context 'when the next processor is also eligible' do
          before do
            allow(new_user_processor)
              .to receive(:eligible?)
              .with(user, message)
              .and_return(true)

            allow(new_user_processor)
              .to receive(:consume_message)
              .with(user, message)
              .and_return(:stop)
          end

          it 'returns 2 processor called' do
            expect(subject.dispatch(user, message)).to eq 2
          end

          it 'consumes the message using the first processor' do
            expect(group_chat_processor)
              .to receive(:consume_message)
              .with(user, message)

            subject.dispatch(user, message)
          end

          it 'consumes the message using the second processor' do
            expect(new_user_processor)
              .to receive(:consume_message)
              .with(user, message)

            subject.dispatch(user, message)
          end
        end
      end
    end
  end
end
