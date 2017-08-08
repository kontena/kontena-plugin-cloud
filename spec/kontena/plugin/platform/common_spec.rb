require 'kontena/plugin/platform/common'

describe Kontena::Plugin::Platform::Common do

  let(:current_account) { double(:current_account, username: 'david') }
  let(:cloud_client) { double(:cloud_client) }
  let(:config) { double(:config) }

  let(:described_class) do
    Class.new do
      include Kontena::Plugin::Platform::Common

      def current_account; end
    end
  end

  describe '#current_organization' do

    it 'returns username by default' do
      allow(subject).to receive(:current_account).and_return(current_account)
      expect(subject.current_organization).to eq('david')
    end

    it 'returns nil if current_account does not exist' do
      expect(subject.current_organization).to be_nil
    end

    it 'returns org from env' do
      allow(ENV).to receive(:[]).with('KONTENA_ORGANIZATION').and_return('foo-inc')
      expect(subject.current_organization).to eq('foo-inc')
    end
  end
end