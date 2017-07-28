[![Puppet Forge](https://img.shields.io/puppetforge/v/nate/windows_account_names.svg)](https://forge.puppetlabs.com/nate/windows_account_names)

# Windows Accounts Fact

This Puppet module adds a custom fact called `windows_accounts` that shows the current name of the Administrator and Guest users on Windows.

This is useful for those that change or randomize these built-in accounts then need to know what the name is. Or, when you need to know what the current name is to trigger the renaming.

For example, this shows that we've renamed the Administrator account to `Kermit` on this machine:

```shell
ps> facter -p windows_accounts

{
  Administrator => 'Kermit',
  Guest => 'Guest'
}
```

## Example 1

Say that we want to rename the Administrator account to `abcdefg`, we could use this fact to check if we need to change it:

```puppet
# Save the current Administrator account name to a shorter variable.
$current_admin = $facts['windows_accounts']['Administrator']

if $current_admin != 'abcdefg' {
  exec { 'Rename Administrator':
    command  => "$(Get-WMIObject Win32_UserAccount -Filter 'Name=\"${current_admin}\"').Rename('abcdefg')",
    provider => powershell,
  }
}
```

> Note that this is a bit of a contrived example as it'd probably be better to use an `unless` attribute with some PowerShell to make the exec idempotent.

## Example 2

Say that we wanted to query PuppetDB for the name of the Administrator account on all of our nodes.

```shell
ps> puppet query 'fact_contents[certname,value] { path ~> ["windows_accounts", "Administrator"] }'
[
  {
    "certname": "win-appx-web.corp.net",
    "value": "Administrator"
  },
  {
    "certname": "win-appx-db.corp.net",
    "value": "xadmin"
  }
]
```

We can see that the win-appx-db node's administrator account is called `xadmin`.

## How this works

Windows uses well-known SID's to identify its built-in accounts: <http://support.microsoft.com/kb/243330>

This fact enumerates all local users and looks for the SID's that match the pattern for the Administrator and Guest accounts.

| Account       | SID Pattern          |
| ------------- | -------------------- |
| Administrator | `/^S-1-5-21.*-500$/` |
| Guest         | `/^S-1-5-21.*-501$/` |

