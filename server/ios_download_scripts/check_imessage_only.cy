var iMessageOnlyText = findOrThrow(null, true, classAndDescriptionMatcher('SKUIAttributedStringView', /Only for iMessage/i), 'Could not find iMessage only text')

throwSuccess('iMessage only app')
