# frozen_string_literal: true

require_relative 'system/container'

Application.finalize!

require 'rack/protection'
use ::Rack::Protection::FrameOptions
use ::Rack::Protection::HttpOrigin
use ::Rack::Protection::IPSpoofing
use ::Rack::Protection::JsonCsrf
use ::Rack::Protection::PathTraversal
use ::Rack::Protection::XSSHeader
use ::Rack::Protection::CookieTossing
use ::Rack::Protection::ContentSecurityPolicy
use ::Rack::Protection::RemoteReferrer


run Application['router.application']
