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

    Puppet::Type.type('user').instances.find_all do |user|
      user_values = user.retrieve
      # Check for the well-known admin SID.
      account_names['Administrator'] = user.name if user_values[user.property(:uid)] =~ /^S-1-5-21.*-500$/
      # Check for the well-known guest SID.
      account_names['Guest'] = user.name if user_values[user.property(:uid)] =~ /^S-1-5-21.*-501$/
    end

    account_names
  end
end
