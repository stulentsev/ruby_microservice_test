# frozen_string_literal: true

RSpec.describe 'Persistence::LocationRepo' do
  let(:repo) { Application['persistence.location_repo'] }
  let(:stream) { 'stream' }

  let(:user_id) { '1' }
  # precision to seconds, not ms
  let(:time) { Time.at(Time.now.utc.to_i).utc }

  let(:event) {
    Types::LocationEvent.new(
      latitude: 48.864193,
      longitude: 2.350498,
      user_id: user_id,
      received_at: time
    )
  }

  before { Application['persistence.drop_db'].call }

  describe '#create' do
    it 'creates elements' do
      expect {
        repo.record_event(event)
      }.to change {
        repo.user_events_count(user_id: event.user_id)
      }.from(0).to(1)
    end

    it 'creates with correct attributes' do
      repo.record_event(event)

      last_update = repo.last_update(user_id: event.user_id)

      expect(last_update.latitude).to eq(event.latitude)
      expect(last_update.longitude).to eq(event.longitude)

      # redis looses usec precision when persisting the Time
      expect(last_update.updated_at).to eq(Time.at(event.received_at.to_i))
    end

    context 'enforces max size' do
      let(:max_len) { 2 }
      let(:events_count) { 10 }
      let(:events) do
        Array.new(events_count) do |i|
          Types::LocationEvent.new(
            latitude: rand(-100..100).to_f,
            longitude: rand(-100..100).to_f,
            user_id: user_id,
            received_at: time - i
          )
        end
      end

      let(:most_recent_event) { events.first }

      before { events.each { |e| repo.record_event(e, max_len: max_len) } }

      it 'caps events keeping the most recent ones' do
        expect(repo.user_events_count(user_id: user_id)).to eq(max_len)
        expect(repo.last_update(user_id: user_id).updated_at).to eq(events.first.received_at)
      end
    end
  end

  describe '#recent_locations_for_user' do
    subject(:recent_updates) { repo.recent_locations_for_user(user_id: user_id, seconds: 100) }

    let(:events) {
      {
        excluded_old: Types::LocationEvent.new(
          latitude: 48.864193,
          longitude: 2.350498,
          user_id: user_id,
          received_at: time - 102
        ),
        initial: Types::LocationEvent.new(
          latitude: 48.864193,
          longitude: 2.350498,
          user_id: user_id,
          received_at: time - 60
        ),
        first_update: Types::LocationEvent.new(
          latitude: 48.000000,
          longitude: 2.350498,
          user_id: user_id,
          received_at: time - 55
        ),
        first_stop: Types::LocationEvent.new(
          latitude: 48.000000,
          longitude: 2.350498,
          user_id: user_id,
          received_at: time - 50
        ),
        second_stop: Types::LocationEvent.new(
          latitude: 48.000000,
          longitude: 2.350498,
          user_id: user_id,
          received_at: time - 45
        ),
        third_stop: Types::LocationEvent.new(
          latitude: 48.000000,
          longitude: 2.350498,
          user_id: user_id,
          received_at: time - 40
        ),
        back_to_initial: Types::LocationEvent.new(
          latitude: 48.864193,
          longitude: 2.350498,
          user_id: user_id,
          received_at: time - 35
        ),
        final: Types::LocationEvent.new(
          latitude: 48.000000,
          longitude: 2.000000,
          user_id: user_id,
          received_at: time - 30
        )
      }
    }

    before { events.values.each { |e| repo.record_event(e) } }

    it 'returns a chronological list of unique location updates' do
      expect(recent_updates.size).to eq(4)

      first = recent_updates[0]
      expect(first.longitude).to eq(events[:initial].longitude)
      expect(first.latitude).to eq(events[:initial].latitude)
      expect(first.updated_at).to eq(events[:initial].received_at)

      second = recent_updates[1]
      expect(second.longitude).to eq(events[:first_update].longitude)
      expect(second.latitude).to eq(events[:first_update].latitude)
      expect(second.updated_at).to eq(events[:first_update].received_at)

      third = recent_updates[2]
      expect(third.longitude).to eq(events[:back_to_initial].longitude)
      expect(third.latitude).to eq(events[:back_to_initial].latitude)
      expect(third.updated_at).to eq(events[:back_to_initial].received_at)

      last = recent_updates[3]
      expect(last.longitude).to eq(events[:final].longitude)
      expect(last.latitude).to eq(events[:final].latitude)
      expect(last.updated_at).to eq(events[:final].received_at)
    end
  end

end
