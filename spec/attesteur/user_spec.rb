# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::User do
  subject do
    described_class.new('1234', infos)
  end

  let(:infos) do
    {}
  end

  describe '#initialize' do
    context 'when the user is created with infos' do
      let(:infos) do
        {
          "first_name" => "Donald",
          "last_name" => "Duck",
          "birth_date" => "01/01/1900",
          "birth_place" => "Disneyland",
          "zipcode" => "75001",
          "town" => "Paris",
          "address" => "1 rue de la Paix",
        }
      end

      its(:id) { is_expected.to eq '1234' }
      its(:subscribed?) { is_expected.to be true }
      its(:infos) { is_expected.to eq infos }
      its(:next_missing_field) { is_expected.to be_nil }
    end

    context 'when the user is created without infos' do
      its(:id) { is_expected.to eq '1234' }
      its(:subscribed?) { is_expected.to be false }
      its(:infos) { is_expected.to be_empty }
      its(:next_missing_field) { is_expected.not_to be_nil }
    end
  end

  describe '#fill' do
    before do
      subject.subscribing!
    end

    context 'when filling all fields' do
      it 'does not consider the user as subscribing anymore' do
        expect do
          subject.fill("first_name", "Donald")
          subject.fill("last_name", "Duck")
          subject.fill("birth_date", "01/01/1900")
          subject.fill("birth_place", "Disneyland")
          subject.fill("zipcode", "75001")
          subject.fill("town", "Paris")
          subject.fill("address", "1 rue de la Paix")
        end.to change { subject.subscribing? }.from(true).to(false)
      end

      it 'considers the user as subscribed' do
        expect do
          subject.fill("first_name", "Donald")
          subject.fill("last_name", "Duck")
          subject.fill("birth_date", "01/01/1900")
          subject.fill("birth_place", "Disneyland")
          subject.fill("zipcode", "75001")
          subject.fill("town", "Paris")
          subject.fill("address", "1 rue de la Paix")
        end.to change { subject.subscribed? }.from(false).to(true)
      end

      it 'fills the infos' do
        expect do
          subject.fill("first_name", "Donald")
          subject.fill("last_name", "Duck")
          subject.fill("birth_date", "01/01/1900")
          subject.fill("birth_place", "Disneyland")
          subject.fill("zipcode", "75001")
          subject.fill("town", "Paris")
          subject.fill("address", "1 rue de la Paix")
        end.to change { subject.infos }.from({}).to(
          "first_name" => "Donald",
          "last_name" => "Duck",
          "birth_date" => "01/01/1900",
          "birth_place" => "Disneyland",
          "zipcode" => "75001",
          "town" => "Paris",
          "address" => "1 rue de la Paix",
        )
      end

      it 'has no missing fields' do
        subject.fill("first_name", "Donald")
        subject.fill("last_name", "Duck")
        subject.fill("birth_date", "01/01/1900")
        subject.fill("birth_place", "Disneyland")
        subject.fill("zipcode", "75001")
        subject.fill("town", "Paris")
        subject.fill("address", "1 rue de la Paix")

        expect(subject.next_missing_field).to be_nil
      end
    end

    context 'when filling all fields except town' do
      it 'still considers the user as subscribing' do
        expect do
          subject.fill("first_name", "Donald")
          subject.fill("last_name", "Duck")
          subject.fill("birth_date", "01/01/1900")
          subject.fill("birth_place", "Disneyland")
          subject.fill("zipcode", "75001")
          subject.fill("address", "1 rue de la Paix")
        end.not_to change { subject.subscribing? }.from(true)
      end

      it 'does not consider the user as subscribed' do
        expect do
          subject.fill("first_name", "Donald")
          subject.fill("last_name", "Duck")
          subject.fill("birth_date", "01/01/1900")
          subject.fill("birth_place", "Disneyland")
          subject.fill("zipcode", "75001")
          subject.fill("address", "1 rue de la Paix")
        end.not_to change { subject.subscribed? }.from(false)
      end

      it 'fills the infos' do
        expect do
          subject.fill("first_name", "Donald")
          subject.fill("last_name", "Duck")
          subject.fill("birth_date", "01/01/1900")
          subject.fill("birth_place", "Disneyland")
          subject.fill("zipcode", "75001")
          subject.fill("address", "1 rue de la Paix")
        end.to change { subject.infos }.from({}).to(
          "first_name" => "Donald",
          "last_name" => "Duck",
          "birth_date" => "01/01/1900",
          "birth_place" => "Disneyland",
          "zipcode" => "75001",
          "address" => "1 rue de la Paix",
        )
      end

      it 'has the town as a missing field' do
        subject.fill("first_name", "Donald")
        subject.fill("last_name", "Duck")
        subject.fill("birth_date", "01/01/1900")
        subject.fill("birth_place", "Disneyland")
        subject.fill("zipcode", "75001")
        subject.fill("address", "1 rue de la Paix")

        expect(subject.next_missing_field).to eq 'town'
      end
    end
  end

  describe '#greet!' do
    it 'changes the flag greeted' do
      expect do
        subject.greet!
      end.to change { subject.greeted? }.from(false).to(true)
    end
  end
end
