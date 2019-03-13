RSpec.describe 'Messaging' do
  context 'default' do
    it 'has constant pool' do
      expect(Application['messaging.producer_pool'].object_id)
        .to eq(Application['messaging.producer_pool'].object_id)
    end
  end

  describe '#write_message' do
    let(:message_writer) { ::Common::Messaging::WriteMessage.new }

    let(:producer) { instance_double('Nsq::Producer', write_to_topic: nil) }
    let(:topic)    { 'topic' }
    let(:message)  { 'message' }
    let(:max_retries) { 2 }

    subject(:write_message) do
      message_writer.call(
        producer: producer,
        topic: topic,
        message: message,
        max_retries: max_retries,
        retry_timeout: 0
      )
    end

    context 'success' do
      it 'returns success' do
        expect(write_message.success?).to eq(true)
      end
    end

    context 'ECONNREFUSED' do
      before do
        allow(producer).to receive(:write_to_topic) { raise Errno::ECONNREFUSED }
      end

      it 'wraps the error' do
        expect(write_message.failure).to be_a(Errno::ECONNREFUSED)
      end
    end

    context 'No connections available/Runtime Error' do

      it 'retries' do
        expect(producer).to receive(:write_to_topic) {
          raise RuntimeError.new('no conns')
        }.exactly(max_retries).times

        write_message
      end
    end

  end
end
