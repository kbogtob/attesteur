# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::MessageProcessors::Subscribed do
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

  before do
    allow(Attesteur::Generation::Generator)
      .to receive(:new)
      .and_return(fake_generator)
  end

  let(:fake_generator) do
    instance_double(Attesteur::Generation::Generator)
  end

  describe '#eligible?' do
    let(:fake_user) do
      instance_double(Attesteur::User,
        subscribed?: subscribed,
      )
    end

    let(:message) do
      instance_double(Telegram::Bot::Types::Message,
        text: 'Paris'
      )
    end

    context 'when the user is subscribed' do
      let(:subscribed) do
        true
      end

      it 'returns true' do
        expect(subject.eligible?(fake_user, message)).to be true
      end
    end

    context 'when the user is not subscribed' do
      let(:subscribed) do
        false
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
      )
    end

    context 'when the message is a text message' do
      let(:message) do
        Telegram::Bot::Types::Message.new(
          chat: chat,
          text: text
        )
      end

      let(:chat) do
        Telegram::Bot::Types::Chat.new(id: 'chat')
      end

      let(:text) do
        "Hey"
      end

      it 'replies with the menu' do
        expect(api)
          .to receive(:send_message)
          .with(
            chat_id: '1234',
            text: Attesteur::Texts::GENERATE,
            reply_markup: an_instance_of(Telegram::Bot::Types::InlineKeyboardMarkup),
          )

        subject.consume_message(fake_user, message)
      end
    end

    context 'when the message is an answer callback' do
      let(:fake_generator) do
        instance_double(Attesteur::Generation::Generator,
          generate: certificate
        )
      end

      let(:certificate) do
        instance_double(Attesteur::Generation::Certificate,
          pdf_upload_io: pdf_upload_io,
          pdf_name: pdf_name,
          qr_code_upload_io: qr_code_upload_io,
          qr_code_name: qr_code_name,
        )
      end

      let(:pdf_upload_io) do
        instance_double(Faraday::UploadIO, 'fake pdf io')
      end

      let(:pdf_name) do
        instance_double(String, 'pdf name')
      end

      let(:qr_code_upload_io) do
        instance_double(Faraday::UploadIO, 'fake qrcode io')
      end

      let(:qr_code_name) do
        instance_double(String, 'qr code name')
      end

      let(:api) do
        double(Telegram::Bot::Api,
          send_message: true,
          send_photo: true,
          send_document: true)
      end

      %w[
        reason_work
        reason_food
        reason_health
        reason_sport
        reason_family
        reason_pets
        reason_school
      ].each do |reason|
        context "when having data '#{reason}'" do
          let(:message) do
            Telegram::Bot::Types::CallbackQuery.new(data: reason)
          end

          it 'replies with a waiting answer' do
            expect(api)
              .to receive(:send_message)
              .with(
                chat_id: '1234',
                text: Attesteur::Texts::GENERATING,
              )

            subject.consume_message(fake_user, message)
          end

          it 'generates the certificate with the right reason' do
            expect(fake_generator)
              .to receive(:generate)
              .with(fake_user, reason)

            subject.consume_message(fake_user, message)
          end

          it 'replies with the pdf document' do
            expect(api)
              .to receive(:send_document)
              .with(
                chat_id: '1234',
                document: pdf_upload_io,
                file_name: pdf_name,
              )

            subject.consume_message(fake_user, message)
          end

          it 'replies with the qrcode photo' do
            expect(api)
              .to receive(:send_photo)
              .with(
                chat_id: '1234',
                photo: qr_code_upload_io,
                file_name: qr_code_name,
              )

            subject.consume_message(fake_user, message)
          end

          it 'thanks the user' do
            expect(api)
              .to receive(:send_message)
              .with(
                chat_id: '1234',
                text: Attesteur::Texts::BYE,
              )

            subject.consume_message(fake_user, message)
          end
        end
      end

      context "when having data 'help'" do
        let(:message) do
          Telegram::Bot::Types::CallbackQuery.new(data: 'help')
        end

        it 'replies with a helping answer' do
          expect(api)
            .to receive(:send_message)
            .with(
              chat_id: '1234',
              text: Attesteur::Texts::HELP,
            )

          subject.consume_message(fake_user, message)
        end
      end

      context "when having other unknown data" do
        let(:message) do
          Telegram::Bot::Types::CallbackQuery.new(data: 'yolo')
        end

        it 'replies with a specific answer' do
          expect(api)
            .to receive(:send_message)
            .with(
              chat_id: '1234',
              text: Attesteur::Texts::UNKNOWN,
            )

          subject.consume_message(fake_user, message)
        end
      end
    end
  end
end
