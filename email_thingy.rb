emails = %w(
joeypatterson007@gmail.com
tabithahawkins058@gmail.com
dwaynepadilla7@gmail.com
robinriley65@gmail.com
marjorieneal26@gmail.com
francisdaniel371@gmail.com
lvkbcjoiew948534@gmail.com
monicabrady82@gmail.com
webstercrystal7@gmail.com
shanesimon916@gmail.com
schwartzclifton@gmail.com
nicholsangela991@gmail.com
dorisunderwood463@gmail.com
jacquelinegrant002@gmail.com
lanceprice459@gmail.com
jodymartinez881@gmail.com
clydeglover642@gmail.com
lyonsmyra00@gmail.com
jonpena866@gmail.com
noeliakoziel123@gmail.com
)


emails.each{|email| GoogleAccount.create(email: email, password: 'thisisapassword', android_identifier: '3B87ADE0DA509B10', blocked: 0, flags: 0, last_used: DateTime.now, in_use: 0, device: 0, scrape_type: 0)}