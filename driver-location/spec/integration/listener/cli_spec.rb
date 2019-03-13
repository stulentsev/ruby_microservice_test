# frozen_string_literal: true

RSpec.describe 'CLI' do
  let(:topic) { SecureRandom.uuid }
  let(:channel) { SecureRandom.uuid }

  it 'displays help text' do
    expect {
      Listener::Cli.start(%w[help start])
    }.to output(/Usage:/).to_stdout
  end

  it 'sucessfully starts with all options' do
    expect {
      t = Thread.new do
        Listener::Cli.start(%W[start --topic=#{topic} --channel=#{channel} --workers=1])
      end
      sleep 0.1
      t.kill
    }.to output(/OK, Starting Workers/).to_stdout_from_any_process
  end
end
