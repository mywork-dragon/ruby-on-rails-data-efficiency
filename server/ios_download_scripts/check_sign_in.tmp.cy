var appleId = @"$0"

var accountCell = findOrThrow(null, true, classMatcher('StoreSettingsAccountCell'));

var appleIdText = accountCell.text();

if(appleIdText.includes(appleId))
{
  throwSuccess("Account logged in.")
}

throwError("Not Logged in.")
