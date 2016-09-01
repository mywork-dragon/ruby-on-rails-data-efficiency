var sw = findOrThrow(null, true, classMatcher('UISwitch'), 'Could not find UISwitch');

if (sw.on == NO)
{
  throwSuccess("Password not required.");
}