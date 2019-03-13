# frozen_string_literal: true

RSpec.describe 'Messaging::ConsumerProvider' do
  let(:custom_exception) { Class.new(StandardError) }
  let(:provider) { Application['messaging.consumer_provider'] }
  let(:consumer_double) { instance_double('Nsq::Consumer', terminate: true) }

  before do
    Application.stub('messaging.consumer_factory', -> proc { consumer_double })
  end

  after { Application.unstub('messaging.consumer_factory') }

  it 'yields a consumer' do
    expect { |b|
      provider.with_consumer(&b)
    }.to yield_with_args(consumer_double)
  end

  it 'terminates' do
    expect(consumer_double).to receive(:terminate)

    provider.with_consumer { true }
  end

  it 'terminates when block raises exception' do
    expect(consumer_double).to receive(:terminate)

    begin
      provider.with_consumer { raise custom_exception }
    rescue custom_exception
      # ignored
    end
  end
end
