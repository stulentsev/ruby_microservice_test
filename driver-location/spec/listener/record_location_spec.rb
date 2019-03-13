# frozen_string_literal: true

RSpec.describe 'RecordLocation' do
  let(:transaction) { Application['listener.record_location'] }
  let(:id) { 1 }
  let(:time) { Time.now.utc }
  let(:persistence_error) { Class.new(StandardError) }

  let(:result) { transaction.call(data) }

  let(:repo_double) { double('location_repo') }

  before { Application.stub('persistence.location_repo', repo_double) }
  after  { Application.unstub('persistence.location_repo') }

  let(:valid_data) do
    {
      'latitude' => 48.864193,
      'longitude' => 2.350498,
      'id' => id,
      'timestamp' => time
    }
  end

  context 'extra keys' do
    let(:data) { valid_data.merge('new' => 'whatever') }

    it 'allows them' do
      expect(repo_double).to receive(:record_event)
      expect(result.success?).to eq(true)
    end
  end

  context 'string user id' do
    let(:data) { valid_data.merge('id' => 'whatever') }

    it 'allows it' do
      expect(repo_double).to receive(:record_event)

      expect(result.success?).to eq(true)
    end
  end

  context 'string latitude' do
    let(:data) { valid_data.merge('latitude' => '48.864193') }

    it 'allows it' do
      expect(repo_double).to receive(:record_event)

      expect(result.success?).to eq(true)
    end
  end

  context 'string longitude' do
    let(:data) { valid_data.merge('longitude' => '48.864193') }

    it 'allows it' do
      expect(repo_double).to receive(:record_event)

      expect(result.success?).to eq(true)
    end
  end

  context 'persistance failure' do
    let(:data) { valid_data }

    before do
      allow(repo_double).to receive(:record_event).and_raise(persistence_error)
    end

    it 'returns failure' do
      expect(result.failure).to be_a(persistence_error)
    end

  end

  describe 'validation errors' do
    subject(:errors) { transaction.call(invalid_data).failure.keys }
    let(:data) { valid_data }

    context 'invalid latitude' do
      let(:invalid_data) { data.merge('latitude' => 'asdasd') }

      it { is_expected.to eq([:latitude]) }
    end

    context 'missing latitude' do
      let(:invalid_data) { data.tap { |d| d.delete('latitude') } }

      it { is_expected.to eq([:latitude]) }
    end

    context 'empty latitude' do
      let(:invalid_data) { data.merge('latitude' => nil) }

      it { is_expected.to eq([:latitude]) }
    end

    context 'less than min latitude' do
      let(:invalid_data) { data.merge('latitude' => -91.0) }

      it { is_expected.to eq([:latitude]) }
    end

    context 'more than max latitude' do
      let(:invalid_data) { data.merge('latitude' => 91.0) }

      it { is_expected.to eq([:latitude]) }
    end

    context 'invalid longitude type' do
      let(:invalid_data) { data.merge('longitude' => 'asdasd') }

      it { is_expected.to eq([:longitude]) }
    end

    context 'missing longitude' do
      let(:invalid_data) { data.tap { |d| d.delete('longitude') } }

      it { is_expected.to eq([:longitude]) }
    end

    context 'empty longitude' do
      let(:invalid_data) { data.merge('longitude' => nil) }

      it { is_expected.to eq([:longitude]) }
    end

    context 'less than min longitude' do
      let(:invalid_data) { data.merge('longitude' => -181.0) }

      it { is_expected.to eq([:longitude]) }
    end

    context 'more than max longitude' do
      let(:invalid_data) { data.merge('longitude' => 181.0) }

      it { is_expected.to eq([:longitude]) }
    end

    context 'invalid timestamp' do
      let(:invalid_data) { data.merge('timestamp' => 'asdasd') }

      it { is_expected.to eq([:timestamp]) }
    end

    context 'missing timestamp' do
      let(:invalid_data) { data.tap { |d| d.delete('timestamp') } }

      it { is_expected.to eq([:timestamp]) }
    end

    context 'empty timestamp' do
      let(:invalid_data) { data.merge('timestamp' => nil) }

      it { is_expected.to eq([:timestamp]) }
    end

    context 'invalid id' do
      let(:invalid_data) { data.merge('id' => [1]) }

      it { is_expected.to eq([:id]) }
    end

    context 'missing id' do
      let(:invalid_data) { data.tap { |d| d.delete('id') } }

      it { is_expected.to eq([:id]) }
    end

    context 'empty id' do
      let(:invalid_data) { data.merge('id' => nil) }

      it { is_expected.to eq([:id]) }
    end
  end
end
