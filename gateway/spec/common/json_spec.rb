# frozen_string_literal: true

RSpec.describe 'json' do
  describe 'parser' do
    let(:parser) { Application['json.parser'] }
    let(:parse) { parser.call(string) }

    context 'invalid' do
      let(:string) { 'whatever' }

      it 'returns a failiure with the errror' do
        expect(parse.failure).to be_a(MultiJson::ParseError)
      end
    end

    context 'valid' do
      let(:string) { '{"a": "b"}' }

      it 'returns success with the parsed json' do
        expect(parse.success).to eq('a' => 'b')
      end
    end
  end

  describe 'generator' do
    let(:generator) { Application['json.generator'] }
    let(:generate) { generator.call(object) }

    let(:object) { { a: 'b' } }

    it 'returns a json string' do
      expect(generate.success).to eq('{"a":"b"}')
    end
  end

end
