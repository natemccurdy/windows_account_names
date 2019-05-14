# Custom fact that shows the current name of the Administrator and
# Guest accounts based on well-known SID's.
#
# http://support.microsoft.com/kb/243330
#
require 'puppet'

Facter.add(:windows_accounts) do
  confine osfamily: :windows

  setcode do
    account_names = {}

    all_users = Puppet::Resource.indirection.search('user')

    account_names['Administrator'] = all_users.find { |user| user[:uid] =~ %r{^S-1-5-21.*-500$} }.title
    account_names['Guest']         = all_users.find { |user| user[:uid] =~ %r{^S-1-5-21.*-501$} }.title

    account_names
  end
end
