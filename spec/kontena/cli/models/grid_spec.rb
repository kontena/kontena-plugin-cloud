require 'kontena/cli/models/grid'

describe Kontena::Cli::Models::Grid do

  let(:api_data) do
    {
      'id' => 'foobar',
      'name' => 'foobar',
      'initial_size' => 3
    }
  end

  let(:subject) do
    described_class.new(api_data)
  end

  describe '#id' do
    it 'returns id' do
      expect(subject.id).to eq('foobar')
    end
  end

  describe '#initial_size' do
    it 'returns initial size' do
      expect(subject.initial_size).to eq(3)
    end
  end
end

