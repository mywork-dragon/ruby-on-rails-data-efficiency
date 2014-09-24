var page = require('webpage').create(),
    system = require('system'),
    address;

if (system.args.length === 1) {
    console.log('Usage: netlog.js <some URL>');
    phantom.exit(1);
} else {
    address = system.args[1];

    page.onResourceRequested = function (req) {
      console.log(req.url + "\n");
      // console.log('requested: ' + JSON.stringify(req, undefined, 4));
    };

    page.onResourceReceived = function (req) {
      console.log(req.url + "\n");
        // console.log('received: ' + JSON.stringify(req, undefined, 4));
    };

    page.open(address, function (status) {
        if (status !== 'success') {
            console.log('Cannot load the address!');
            phantom.exit();
        } else {
            window.setTimeout(function () {
                phantom.exit();
            }, 10000); // ms of how long to wiat
        }
    });
}