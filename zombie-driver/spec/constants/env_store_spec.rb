# frozen_string_literal: true

RSpec.describe 'Constants::EnvStore' do
  let(:store) { Application['constants.env_store'] }

  let(:env) { { 'ZOMBIE_DRIVER_MY_KEY' => 'value' } }

  let(:system_env_double) { class_double('ENV') }

  before do
    allow(system_env_double).to receive(:[]) do |key|
      env[key]
    end
  end

  before { Application.stub('system_env', system_env_double) }
  after { Application.unstub('system_env') }

  it 'transforms keys' do
    expect(store.fetch(:my_key)).to eq('value')
  end

  it 'works fine on missing values' do
    expect(store.fetch(:missing)).to eq(nil)
  end
end
