# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::Cli do
  subject do
    described_class.new('xxxx')
  end

  describe '#start' do
    before do
      allow(Telegram::Bot::Client)
        .to receive(:run)
        .and_yield(bot)

      allow(Attesteur::BotBrain)
        .to receive(:new)
        .and_return(bot_brain)
    end

    let(:bot) do
      instance_double(Telegram::Bot)
    end

    let(:bot_brain) do
      instance_double(Attesteur::BotBrain, listen: true)
    end

    it 'runs the client with the right token' do
      expect(Telegram::Bot::Client)
        .to receive(:run)
        .with('xxxx', anything)

      subject.start
    end

    it 'runs the client with a logger' do
      expect(Telegram::Bot::Client)
        .to receive(:run)
        .with(anything, logger: instance_of(Logger))

      subject.start
    end

    it 'makes the bot brain listen' do
      expect(bot_brain)
        .to receive(:listen)

      subject.start
    end
  end
end
