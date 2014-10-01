var page = require('webpage').create(),
    system = require('system'),
    address;
    
page.settings.resourceTimeout = 20000; // 20 seconds

if (system.args.length === 1) {
    console.log('Usage: netlog.js <some URL>');
    phantom.exit(1);
} else {
    address = system.args[1];

    console.log('before onResourceRequested');

    page.onResourceRequested = function (req) {
      //console.log(req.url + "\n");
      // console.log('requested: ' + JSON.stringify(req, undefined, 4));
    };

    console.log('before onResourceReceived');

    page.onResourceReceived = function (req) {
      //console.log(req.url + "\n");
      // console.log('received: ' + JSON.stringify(req, undefined, 4));
    };

    console.log('before open');

    page.open(address, function (status) {
      console.log('opened');
        if (status !== 'success') {
            console.log('Cannot load the address!');
            phantom.exit(0);
        } else {
          console.log('Loaded the address');
            window.setTimeout(function () {
              console.log('Timeout expired. Time to exit.');
                phantom.exit(0);
            }, 10000); // ms of how long to wait
        }
    });
}