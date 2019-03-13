# frozen_string_literal: true

RSpec.describe 'Listener::Worker' do
  let(:worker) { Application['listener.worker'] }
  let!(:topic) { SecureRandom.uuid }
  let!(:channel) { SecureRandom.uuid }

  let(:blocking) { false }

  let(:json) { Application['json.json'] }

  before { Application['persistence.drop_db'].call }

  let(:producer) { Application['messaging.producer_factory'].call }
  let(:write_message) { Application['messaging.write_message'] }

  def wait_for_work
    sleep 0.5
  end

  let(:worker_thread) {
    Thread.new do
      worker.run(topic: topic, channel: channel, blocking: blocking)
    end.tap do |t|
      t.abort_on_exception = true
    end
  }

  let(:user_id) { 123 }

  let(:message) do
    {
      'latitude' => 48.864193,
      'longitude' => 2.350498,
      'id' => user_id
    }
  end

  let(:json_message) { Application['json.generator'].call(message).value! }
  let(:location_repo) { Application['persistence.location_repo'] }

  it 'records a message' do
    write_message.call(
      producer: producer,
      topic: "#{topic}#ephemeral",
      message: json_message
    ).value!

    worker_thread.run

    wait_for_work

    worker.stop
    worker_thread.join

    last_update = location_repo.last_update(user_id: user_id)

    expect(last_update.latitude).to eq(message['latitude'])
    expect(last_update.longitude).to eq(message['longitude'])
    expect(last_update.updated_at).to be_a(Time)
  end

  context 'non-blocking' do
    let(:blocking) { false }

    it 'can gracefully stop on empty queue' do
      worker_thread.run

      worker.stop

      # join will return nil if timeout is reached
      expect(worker_thread.join(0.1)).to eq(worker_thread)
    end
  end

  context 'blocking' do
    let(:blocking) { true }

    it 'blocks on empty queue and must be killed' do
      worker_thread.run

      # join will return nil if timeout is reached
      expect(worker_thread.join(0.1)).to eq(nil)
    end

  end
end
