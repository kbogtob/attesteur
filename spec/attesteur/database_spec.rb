# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Attesteur::Database do
  subject do
    described_class.new(path)
  end

  let(:path) do
    "/tmp/lol"
  end

  before do
    allow(FileUtils)
      .to receive(:mkdir_p)
  end

  describe '#initialize' do
    it 'creates the given directory path' do
      expect(FileUtils)
        .to receive(:mkdir_p)
        .with("/tmp/lol")

      subject
    end
  end

  describe '#exists?' do
    before do
      allow(File)
        .to receive(:exist?)
        .with("/tmp/lol/1234.yml")
        .and_return(existence)
    end

    let(:existence) do
      double("boolean result")
    end

    it 'returns if the user file exists' do
      expect(subject.exists?("1234")).to be existence
    end
  end

  describe '#load' do
    context 'when user file does not exist' do
      before do
        allow(File)
          .to receive(:exist?)
          .with("/tmp/lol/1234.yml")
          .and_return(false)
      end

      it 'returns nil' do
        expect(subject.load('1234')).to be_nil
      end
    end

    context 'when user file exists' do
      before do
        allow(File)
          .to receive(:exist?)
          .with("/tmp/lol/1234.yml")
          .and_return(true)

        allow(YAML)
          .to receive(:load_file)
          .and_return(yaml_object)

        allow(Attesteur::User)
          .to receive(:new)
          .and_return(fake_user)
      end

      let(:yaml_object) do
        instance_double(Hash)
      end

      let(:fake_user) do
        instance_double(Attesteur::User)
      end

      it 'loads the correct YAML file' do
        expect(YAML)
          .to receive(:load_file)
          .with("/tmp/lol/1234.yml")

        subject.load('1234')
      end

      it 'builds the user correctly' do
        expect(Attesteur::User)
          .to receive(:new)
          .with('1234', yaml_object)

        subject.load('1234')
      end

      it 'returns the loaded user' do
        expect(subject.load('1234')).to be fake_user
      end
    end
  end

  describe '#save' do
    before do
      allow(YAML)
        .to receive(:dump)
        .and_return(yaml_content)

      allow(File)
        .to receive(:write)
    end

    let(:yaml_content) do
      instance_double(String)
    end

    let(:fake_user) do
      instance_double(Attesteur::User,
        id: '1234',
        infos: user_infos
      )
    end

    let(:user_infos) do
      instance_double(Hash)
    end

    it 'saves the user correctly' do
      expect(File)
        .to receive(:write)
        .with("/tmp/lol/1234.yml", yaml_content)

      subject.save(fake_user)
    end

    it 'builds the YAML correctly' do
      expect(YAML)
        .to receive(:dump)
        .with(user_infos)

      subject.save(fake_user)
    end
  end

  describe '#delete' do
    context 'when the user file does not exist' do
      before do
        allow(File)
          .to receive(:exist?)
          .with("/tmp/lol/1234.yml")
          .and_return(false)
      end

      it 'does nothing without failure' do
        subject.delete('1234')
      end
    end

    context 'when the user file exists' do
      before do
        allow(File)
          .to receive(:exist?)
          .with("/tmp/lol/1234.yml")
          .and_return(true)

        allow(File)
          .to receive(:delete)
      end

      it 'deletes the user file' do
        expect(File)
          .to receive(:delete)
          .with("/tmp/lol/1234.yml")

        subject.delete('1234')
      end
    end
  end
end
