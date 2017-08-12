require 'kontena/cli/models/platform'

describe Kontena::Cli::Models::Platform do

  let(:api_data) do
    {
      'id' => 'foobar',
      'attributes' => {
        'initial-size' => 3,
        'grid-id' => 'foobar',
        'state' => 'online'
      },
      'relationships' => {
        'region' => {
          'data' => {
            'id' => 'us-east'
          }
        }
      }
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

  describe '#online?' do
    it 'returns true if state online' do
      expect(subject.online?).to be_truthy
    end

    it 'returns false if state is not online' do
      allow(subject).to receive(:api_data).and_return({
        'attributes' => {
          'state' => 'offline'
        }
      })
      expect(subject.online?).to be_falsey
    end
  end

  describe '#region' do
    it 'returns region from relationships' do
      expect(subject.region).to eq('us-east')
    end

    it 'returns nil if no relationship exist' do
      subject.api_data.delete('relationships')
      expect(subject.region).to be_nil
    end
  end
end

