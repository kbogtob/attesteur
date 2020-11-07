# frozen_string_literal: true

module Attesteur
  module Generation
    class Generator
      def initialize(templates_path = nil)
        @templates_path = templates_path || File.join(File.dirname(__FILE__), '../../..', 'templates')
      end

      def generate(user, reason)
        time = Time.now + 2 * 60
        erb_engine = ERBEngine.new(user, reason, time)

        Certificate.new(
          name: time.strftime("attestation.%d.%m.%Y-%H.%M.%S"),
          qr_code: StringIO.new(build_qr_code(erb_engine)),
          pdf: StringIO.new(build_pdf(erb_engine)),
        )
      end

      private
      attr_reader :templates_path

      def build_pdf(erb_engine)
        Prawn::Document.new.tap do |pdf|
          pdf.text(erb_engine.template(attestation_erb))
        end.render
      rescue Prawn::Errors::IncompatibleStringEncoding => e
        Prawn::Document.new.tap do |pdf|
          pdf.text("Caractères inconnus dans vos informations.")
        end.render
      end

      def build_qr_code(erb_engine)
        RQRCode::QRCode.new(erb_engine.template(qr_erb)).as_png(size: 500).to_datastream.to_blob
      end

      def attestation_erb
        @attestation_erb ||= File.read(File.join(templates_path, "attestation.erb"))
      end

      def qr_erb
        @qr_erb ||= File.read(File.join(templates_path, "qr_code.erb"))
      end
    end
  end
end
