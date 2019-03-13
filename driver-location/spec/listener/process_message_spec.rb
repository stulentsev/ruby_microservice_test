# frozen_string_literal: true

RSpec.describe 'Listener::ProcessMessage' do
  let(:message) { instance_double('Nsq::Message', body: message_body, timestamp: time, attempts: 0) }

  let(:handler) { Application['listener.process_message'] }
  let(:action) { handler.call(message) }
  let(:time) { Time.now.utc }

  let(:message_data) do
    {
      "latitude": 48.864193,
      "longitude": 2.350498,
      "id": 123
    }
  end

  let(:message_body) { Application['json.generator'].call(message_data).value! }

  let(:logger_double) { instance_double('Logger') }

  let(:persistence_double) { double('Persistence').as_null_object }

  before { Application.stub('persistence.pool', persistence_double) }
  after  { Application.unstub('persistence.pool') }

  before { Application.stub('logger', logger_double) }
  after  { Application.unstub('logger') }

  context 'success' do
    it 'finishes the message and persists' do
      expect(message).to receive(:finish)

      action
    end
  end

  context 'error' do
    context 'invalid json' do
      let(:message_body) { '{invalid}' }

      it 'logs' do
        allow(message).to receive(:finish)

        expect(logger_double).to receive(:error)
        action
      end

      it 'marks the message as finished' do
        allow(logger_double).to receive(:error)

        expect(message).to receive(:finish)
        action
      end
    end

    context 'invalid message structure' do
      let(:message_data) do
        {
          "invalid": 48.864193
        }
      end

      it 'logs error' do
        allow(message).to receive(:finish)

        expect(logger_double).to receive(:error)
        action
      end

      it 'marks the message as finished' do
        allow(logger_double).to receive(:error)

        expect(message).to receive(:finish)
        action
      end
    end

    context 'valid message, failed persist' do
      let(:persistence_double) { nil }

      it 'logs error' do
        allow(message).to receive(:requeue)

        expect(logger_double).to receive(:error)
        action
      end

      it 'doesnt finish the message' do
        allow(logger_double).to receive(:error)
        allow(message).to receive(:requeue)

        expect(message).not_to receive(:finish)
        action
      end

      it 'requeues the message' do
        allow(logger_double).to receive(:error)

        expect(message).to receive(:requeue)
        action
      end
    end
  end
end
