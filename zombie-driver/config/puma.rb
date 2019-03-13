# frozen_string_literal: true

port        ENV.fetch('PORT') { 3800 }
environment ENV.fetch('RACK_ENV') { 'development' }

threads_count = ENV.fetch('MAX_THREADS') { 2 }
threads threads_count, threads_count

workers ENV.fetch('WEB_CONCURRENCY') { 2 }
preload_app!
queue_requests true
