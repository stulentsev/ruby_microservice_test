# frozen_string_literal: true

require_relative 'types'
require_relative 'messaging'

Dry::System.register_provider(
  :common,
  boot_path: Pathname(__dir__).join('boot').realpath
)
