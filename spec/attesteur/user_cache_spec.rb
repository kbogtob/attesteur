# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::UserCache do
  subject do
    described_class.new(database)
  end

  let(:database) do
    instance_double(Attesteur::Database)
  end

  describe '#find_or_initialize' do
    context 'when user not in DB' do
      before do
        allow(database)
          .to receive(:exists?)
          .with('1234')
          .and_return(false)

        allow(Attesteur::User)
          .to receive(:new)
          .with('1234')
          .and_return(user)
      end

      let(:user) do
        instance_double(Attesteur::User)
      end

      it 'returns the user' do
        expect(subject.find_or_initialize('1234'))
          .to eq user
      end

      it 'does not load the user from DB' do
        expect(database)
          .not_to receive(:load)

        subject.find_or_initialize('1234')
      end

      it 'caches the user' do
        expect(Attesteur::User)
          .to receive(:new)
          .exactly(1).time

        subject.find_or_initialize('1234')
        subject.find_or_initialize('1234')
      end
    end

    context 'when user in DB' do
      before do
        allow(database)
          .to receive(:exists?)
          .with('1234')
          .and_return(true)

        allow(database)
          .to receive(:load)
          .with('1234')
          .and_return(user)
      end

      let(:user) do
        instance_double(Attesteur::User)
      end

      it 'returns the user' do
        expect(subject.find_or_initialize('1234'))
          .to eq user
      end

      it 'caches it and return it' do
        expect(database)
          .to receive(:load)
          .exactly(1).time

        subject.find_or_initialize('1234')
        subject.find_or_initialize('1234')
      end
    end
  end

  describe '#delete' do
    before do
      allow(database)
        .to receive(:delete)
        .with('1234')
        .and_return(true)

      allow(database)
        .to receive(:exists?)
        .with('1234')
        .and_return(false)

      allow(Attesteur::User)
        .to receive(:new)
        .with('1234')
        .and_return(user, new_user_after_deletion)
    end

    let(:user) do
      instance_double(Attesteur::User)
    end

    let(:new_user_after_deletion) do
      instance_double(Attesteur::User)
    end

    it 'deletes the user in DB' do
      expect(database)
        .to receive(:delete)
        .with('1234')

      subject.delete('1234')
    end

    it 'deletes the user in the cache' do
      expect(subject.find_or_initialize('1234'))
        .to eq user
      expect(subject.find_or_initialize('1234'))
        .to eq user

      subject.delete('1234')

      expect(subject.find_or_initialize('1234'))
        .to eq new_user_after_deletion
    end
  end
end
