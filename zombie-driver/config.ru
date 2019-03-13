# frozen_string_literal: true

require_relative 'system/container'

Application.finalize!

run Application['web.app']
