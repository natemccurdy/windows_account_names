# Rspec tests for the windows_accounts fact.
require 'puppet'
require 'spec_helper'

describe 'windows_accounts' do
  context 'when not on Windows' do
    let(:stub_os) { { 'family' => 'Darwin' } }

    it 'returns nil' do
      allow(Facter.fact(:os)).to receive(:value).and_return(stub_os)
      expect(Facter.value(:windows_accounts)).to be_nil
    end
  end

  context 'when on Windows' do
    # NOTE: The 'os' fact's keys are all strings, not symbols.
    let(:stub_os) { { 'family' => 'windows' } }
    let(:test_users) do
      [
        Puppet::Resource.new(:user, 'NewAdministrator', parameters: { uid: 'S-1-5-21-example-500' }),
        Puppet::Resource.new(:user, 'NewGuest', parameters: { uid: 'S-1-5-21-example-501' }),
        Puppet::Resource.new(:user, 'foo', parameters: { uid: 'S-1-5-21-example-1001' }),
      ]
    end

    before(:each) do
      Facter.clear
      allow(Facter.fact(:os)).to receive(:value).and_return(stub_os)
    end

    after(:each) do
      Facter.clear
    end

    it 'os.family is windows' do
      # This is here just to validate the before block.
      expect(Facter.fact(:os).value).to eq(stub_os)
    end

    it 'returns a hash with nil values when no users are found' do
      allow(Puppet::Resource.indirection).to receive(:search).with('user').and_return([])
      expect(Facter.value(:windows_accounts)).to eq({ 'Administrator' => nil, 'Guest' => nil })
    end

    it 'returns the Administrator and Guest account names' do
      allow(Puppet::Resource.indirection).to receive(:search).with('user').and_return(test_users)
      expect(Facter.value(:windows_accounts)).to eq({ 'Administrator' => 'NewAdministrator', 'Guest' => 'NewGuest' })
    end
  end
end
