# frozen_string_literal: true

module Attesteur
  module Generation
    class Certificate
      def initialize(name:, pdf:, qr_code:)
        @name = name
        @pdf = pdf
        @qr_code = qr_code
      end

      def pdf_name
        "#{name}.pdf"
      end

      def qr_code_name
        "#{name}.qrcode.png"
      end

      def pdf_upload_io
        Faraday::UploadIO.new(pdf, 'application/pdf', "#{name}.pdf")
      end

      def qr_code_upload_io
        Faraday::UploadIO.new(qr_code, 'image/png', "#{name}.png")
      end

      private
      attr_reader :name
      attr_reader :pdf
      attr_reader :qr_code
    end
  end
end