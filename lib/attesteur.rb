# frozen_string_literal: true

require 'telegram/bot'
require 'rqrcode'
require 'prawn'
Prawn::Fonts::AFM.hide_m17n_warning = true

require 'fileutils'
require 'yaml'
require 'erb'

module Attesteur
end

require_relative 'attesteur/texts'
require_relative 'attesteur/user'
require_relative 'attesteur/database'
require_relative 'attesteur/generation'
require_relative 'attesteur/bot_brain'
require_relative 'attesteur/cli'