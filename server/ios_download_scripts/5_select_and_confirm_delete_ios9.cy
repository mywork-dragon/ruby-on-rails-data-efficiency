function viewIsSubviewOfView(subview, superview) {
    
    var maxIterations = 25;
    var n = 0;

    while(n < maxIterations) {

        subview = subview.superview;

        if (subview == null) {
            return false;
        }

        if (subview == superview) {
            return true;        
        }

        n++;
    }

    return false;
}

function findTable() {
    var navigationControllers = choose(UINavigationController);

    var navigationController = null;
    for each (var aNavigationController in navigationControllers) {
        if ([aNavigationController class] == UINavigationController) {
            if (navigationController != null) { throw "Found multiple UINavigationController options"; }
            navigationController = aNavigationController;
        }
    }

    topViewControllerView = navigationController.topViewController.view;

    var tableViews = choose(UITableView);

    var available = null;

    for each (var tableView in tableViews) {
        if (viewIsSubviewOfView(tableView, topViewControllerView)) {
            if (available != null) { throw "Found multiple table options"; }

            available = tableView;
        }
        
    }

    if (available == null) { throw "Could not find table"; }
    return available;
}

function findAlertController(svc) {
    start = Date.now();

    while (Date.now() - start < 5000) {
        pvc = svc.presentedViewController

        if (pvc != null) { 
        return pvc; 
        }

    }

    throw "Could not find UIAlertController";
}

function sleep(seconds) {
    start = Date.now();

    while (Date.now() - start < seconds) {
        //do nothing
    }

    return;
}

svc = choose(PSSplitViewController)[0];

var table = findTable(),
delegate = table.delegate;

indexPath = [NSIndexPath indexPathForRow:0 inSection:1];

[delegate tableView:table didSelectRowAtIndexPath:indexPath];

var presentedViewController = null;

sleep(3);

alertController = svc.presentedViewController;

action = alertController.actions[0];
handler = action.handler;
handler(action);