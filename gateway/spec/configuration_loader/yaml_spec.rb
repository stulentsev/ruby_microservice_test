# frozen_string_literal: true

RSpec.describe 'ConfigurationLoader::Yaml' do
  let(:loader) { Application['configuration_loader.yaml'] }

  let(:config) { loader.call(config_string) }

  context 'full multi config' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path: "/drivers/:id/locations"
            method: "PATCH"
            nsq:
              topic: "locations"
          -
            path: "/drivers/:id"
            method: "GET"
            http:
              host: "zombie-driver"
      CONFIG_YAML
    end

    it 'has multiple endpoints' do
      config_list = config.value!

      nsq_config = config_list.first

      expect(nsq_config.path).to eq('/drivers/:id/locations')
      expect(nsq_config.verb).to eq('PATCH')
      expect(nsq_config.nsq.topic).to eq('locations')


      http_config = config_list[1]

      expect(http_config.path).to eq('/drivers/:id')
      expect(http_config.verb).to eq('GET')
      expect(http_config.http.host).to eq('zombie-driver')
    end
  end

  context 'nil yaml' do
    let(:config_string) { nil }

    it { expect(config.failure?).to eq(true) }
  end

  context 'empty yaml' do
    let(:config_string) { ' ' }

    it { expect(config.failure?).to eq(true) }
  end

  context 'invalid yaml' do
    let(:config_string) { "\t urls:" }

    it 'returns parsing error' do
      expect(config.failure?).to eq(true)
      expect(config.failure).to be_a(Psych::SyntaxError)
    end
  end

  context 'invalid config' do
    let(:config_string) do
      <<~CONFIG_YAML
        invalid:
      CONFIG_YAML
    end

    it { expect(config.failure?).to eq(true) }
  end

  context 'invalid config - missing path' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            method: "PATCH"
            nsq:
              topic: "locations"
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure).to eq(urls: { 0 => { path: ['is missing'] } })
    end
  end

  context 'invalid config - empty path' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path:
            method: "PATCH"
            nsq:
              topic: "locations"
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure).to eq(urls: { 0 => { path: ['must be filled'] } })
    end
  end

  context 'invalid config - missing method' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path: "/drivers/:id/locations"
            nsq:
              topic: "locations"
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure.fetch(:urls).fetch(0).fetch(:method)).not_to be_empty
    end
  end

  context 'invalid config - empty method' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path: "/drivers/:id/locations"
            method: ""
            nsq:
              topic: "locations"
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure.fetch(:urls).fetch(0).fetch(:method)).not_to be_empty
    end
  end

  context 'invalid config - unsupported nsq method' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path: "/drivers/:id/locations"
            method: "LOL"
            nsq:
              topic: "locations"
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure.fetch(:supported_nsq_method)).not_to be_empty
    end
  end

  context 'invalid config - unsupported http method' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path: "/drivers/:id/locations"
            method: TRACE
            http:
              host: "locations"
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure.fetch(:supported_http_method)).not_to be_empty
    end
  end

  context 'invalid config - missing http host' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path: "/drivers/:id/locations"
            method: "PATCH"
            http:
              whatever:
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure).to eq(urls: { 0 => { http: { host: ['is missing'] } } })
    end
  end

  context 'invalid config - empty http host' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path: "/drivers/:id/locations"
            method: "PATCH"
            http:
              host:
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure).to eq(urls: { 0 => { http: { host: ['must be filled'] } } })
    end
  end

  context 'invalid config - missing nsq topic' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path: "/drivers/:id/locations"
            method: "PATCH"
            nsq:
              whatever:
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure).to eq(urls: { 0 => { nsq: { topic: ['is missing'] } } })
    end
  end

  context 'invalid config - empty nsq topic' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path: "/drivers/:id/locations"
            method: "PATCH"
            nsq:
              topic:
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure).to eq(urls: { 0 => { nsq: { topic: ['must be filled'] } } })
    end
  end

  context 'invalid config - both http and nsq forwards' do
    let(:config_string) do
      <<~CONFIG_YAML
        urls:
          -
            path: "/drivers/:id/locations"
            method: "POST"
            nsq:
              topic: "locations"
            http:
              host: "zombie-driver"
      CONFIG_YAML
    end

    it 'returns errors hash' do
      expect(config.failure).to have_key(:exactly_one_forward)
    end
  end
end
