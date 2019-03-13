# frozen_string_literal: true

RSpec.describe 'yaml' do
  describe 'parser' do
    let(:parser) { Application['yaml.parser'] }
    let(:parse) { parser.call(string) }

    context 'invalid' do
      let(:string) { "\t whatever" }

      it 'returns a failiure with the errror' do
        expect(parse.failure).to be_a(Psych::SyntaxError)
      end
    end

    context 'valid' do
      let(:string) { '--- foo' }

      it 'returns success with the parsed yaml' do
        expect(parse.success).to eq('foo')
      end
    end
  end
end
