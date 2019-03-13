# frozen_string_literal: true

RSpec.describe 'Routers::Nsq' do
  let(:router) { Application['routers.nsq'] }

  let(:params) { { minutes: 5 } }
  let(:body) { nil }
  let(:topic) { 'topic' }
  let(:headers) { { 'Accept' => 'application/json' } }

  let(:producer_pool) { instance_double('ConnectionPool') }
  let(:producer_double) { instance_double('Nsq::Producer') }

  before do
    allow(producer_pool).to receive(:with).and_yield(producer_double)
    Application.stub('messaging.producer_pool', producer_pool)
  end
  after { Application.unstub('messaging.producer_pool') }

  subject(:response) {
    router.call(
      params: params,
      body: body,
      topic: topic
    )
  }

  describe 'published message' do
    it 'it writes json' do
      expect(producer_double).to receive(:write_to_topic).with(topic, '{"minutes":5}')

      response
    end

    context 'with body' do
      let(:body) { '{"id":1}' }

      it 'merges body json and params' do
        expect(producer_double).to receive(:write_to_topic).with(topic, '{"id":1,"minutes":5}')

        response
      end
    end

    context 'with params and body setting same things' do
      let(:body) { '{"minutes":1}' }

      it 'overrides body values from params' do
        expect(producer_double).to receive(:write_to_topic).with(topic, '{"minutes":5}')

        response
      end
    end
  end

  context 'success' do
    before { allow(producer_double).to receive(:write_to_topic) }

    it { expect(response.status).to eq(204) }
    it { expect(response.body).to eq(nil) }
  end

  context 'no body or params' do
    let(:params) { {} }
    let(:body) { nil }

    it 'returns bad request' do
      expect(response.status).to eq(400)
      expect(response.body).to eq('No parameters or request body')
    end
  end

  context 'invalid json in body' do
    let(:params) { {} }
    let(:body) { 'asd' }

    it 'returns bad request' do
      expect(response.status).to eq(400)
      expect(response.body).to start_with('unexpected character')
    end
  end

  context 'publish failed' do
    let(:params) { { id: 1 } }

    before do
      allow(producer_double).to receive(:write_to_topic) { raise Errno::ECONNREFUSED }
    end

    it 'returns bad request' do
      expect(response.status).to eq(400)
      expect(response.body).to start_with('Connection refused')
    end
  end

end
