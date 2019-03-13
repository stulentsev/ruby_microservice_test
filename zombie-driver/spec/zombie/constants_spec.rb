# frozen_string_literal: true

RSpec.describe 'Zombie Constants' do
  let(:storage_double) { object_double(Application['constants.store'], fetch: stored_value) }

  before { Application.stub('constants.store', storage_double) }
  after { Application.unstub('constants.store') }

  describe 'distance_in_meters_threshold' do
    let(:value) { Application['zombie.constants.distance_in_meters_threshold_resolver'].call() }

    context 'nothing in the store' do
      let(:stored_value) { nil }

      it 'defaults' do
        expect(value).to eq(500)
      end
    end

    context 'bad value in the store' do
      let(:stored_value) { 'a' }

      it 'raises error' do
        expect { value }.to raise_error(ArgumentError)
      end
    end

    context 'bad type in the store' do
      let(:stored_value) { '1' }

      it 'casts the value' do
        expect(value).to eq(1)
      end
    end
  end

  describe 'period_in_minutes' do
    let(:value) { Application['zombie.constants.period_in_minutes_resolver'].call }

    context 'nothing in the store' do
      let(:stored_value) { nil }

      it 'defaults' do
        expect(value).to eq(5)
      end
    end

    context 'bad value in the store' do
      let(:stored_value) { 'a' }

      it 'raises error' do
        expect { value }.to raise_error(ArgumentError)
      end
    end

    context 'bad type in the store' do
      let(:stored_value) { '1' }

      it 'casts the value' do
        expect(value).to eq(1)
      end
    end
  end
end
