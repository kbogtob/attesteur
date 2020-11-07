# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::BotBrain do
  subject do
    described_class.new(bot)
  end

  let(:bot) do
    double(Telegram::Bot, api: api)
  end

  let(:api) do
    instance_double(Telegram::Bot::Api)
  end

  before do
    allow(Attesteur::Database)
      .to receive(:new)
      .and_return(database)

    allow(Attesteur::UserCache)
      .to receive(:new)
      .and_return(user_cache)

    allow(Attesteur::Dispatcher)
      .to receive(:new)
      .and_return(dispatcher)
  end

  let(:database) do
    instance_double(Attesteur::Database)
  end

  let(:user_cache) do
    instance_double(Attesteur::UserCache)
  end

  let(:dispatcher) do
    instance_double(Attesteur::Dispatcher)
  end

  describe '#initialize' do
    it 'builds the database correctly' do
      expect(Attesteur::Database)
        .to receive(:new)

      subject
    end

    it 'builds the user cache correctly' do
      expect(Attesteur::UserCache)
        .to receive(:new)
        .with(database)

      subject
    end

    before do
      allow(Attesteur::MessageProcessors::GroupChat)
        .to receive(:new)
        .and_return(group_chat)

      allow(Attesteur::MessageProcessors::NewUser)
        .to receive(:new)
        .and_return(new_user)

      allow(Attesteur::MessageProcessors::Forget)
        .to receive(:new)
        .and_return(forget)

      allow(Attesteur::MessageProcessors::Unsubscribed)
        .to receive(:new)
        .and_return(unsubscribed)

      allow(Attesteur::MessageProcessors::Subscribed)
        .to receive(:new)
        .and_return(subscribed)
    end

    let(:group_chat) do
      instance_double(Attesteur::MessageProcessors::GroupChat)
    end

    let(:new_user) do
      instance_double(Attesteur::MessageProcessors::NewUser)
    end

    let(:forget) do
      instance_double(Attesteur::MessageProcessors::Forget)
    end

    let(:unsubscribed) do
      instance_double(Attesteur::MessageProcessors::Unsubscribed)
    end

    let(:subscribed) do
      instance_double(Attesteur::MessageProcessors::Subscribed)
    end

    it 'builds the dispatcher correctly' do
      expect(Attesteur::Dispatcher)
        .to receive(:new)
        .with(
          a_collection_containing_exactly(
            group_chat,
            new_user,
            forget,
            unsubscribed,
            subscribed,
          )
        )

      subject
    end

    it 'builds the message processors correctly' do
      expect(Attesteur::MessageProcessors::GroupChat)
        .to receive(:new)
        .with(instance_of(described_class), api)
        .and_return(group_chat)

      expect(Attesteur::MessageProcessors::NewUser)
        .to receive(:new)
        .with(instance_of(described_class), api)
        .and_return(new_user)

      expect(Attesteur::MessageProcessors::Forget)
        .to receive(:new)
        .with(instance_of(described_class), api)
        .and_return(forget)

      expect(Attesteur::MessageProcessors::Unsubscribed)
        .to receive(:new)
        .with(instance_of(described_class), api)
        .and_return(unsubscribed)

      expect(Attesteur::MessageProcessors::Subscribed)
        .to receive(:new)
        .with(instance_of(described_class), api)
        .and_return(subscribed)

      subject
    end
  end

  describe '#listen' do
    let(:bot) do
      double(Telegram::Bot, api: api).tap do |b|
        allow(b).to receive(:listen).and_yield(message)
      end
    end

    let(:message) do
      instance_double(Telegram::Bot::Types::Message,
        from: instance_double(Telegram::Bot::Types::User,
                id: '1234'
              )
      )
    end

    let(:user_cache) do
      instance_double(Attesteur::UserCache,
        find_or_initialize: user
      )
    end

    let(:user) do
      instance_double(Attesteur::User)
    end

    let(:dispatcher) do
      instance_double(Attesteur::Dispatcher,
        dispatch: true
      )
    end

    it 'makes the bot listen' do
      expect(bot)
        .to receive(:listen)

      subject.listen
    end

    it 'fetches the user in the cache correctly' do
      expect(user_cache)
        .to receive(:find_or_initialize)
        .with('1234')

      subject.listen
    end

    it 'dispatches the message correctly' do
      expect(dispatcher)
        .to receive(:dispatch)
        .with(user, message)

      subject.listen
    end
  end

end
