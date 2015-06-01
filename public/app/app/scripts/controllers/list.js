'use strict';

angular.module('appApp').controller("ListCtrl", ["$scope", "$http", "$routeParams", "$rootScope", "listApiService", function($scope, $http, $routeParams, $rootScope, listApiService) {

  var data = {"results":[{"app":{"id":62,"name":"Alpha","mobilePriority":"high","userBase":"moderate","lastUpdated":"2015-02-21","adSpend":true,"categories":[]},"company":{"id":391,"name":"Parisian, Satterfield and Koepp","fortuneRank":391}},{"app":{"id":317,"name":"Alpha","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-07-08","adSpend":true,"categories":[]},"company":{"id":18,"name":"Cole-Cormier","fortuneRank":18}},{"app":{"id":40,"name":"Alpha","mobilePriority":"medium","userBase":"moderate","lastUpdated":"2015-03-04","adSpend":true,"categories":[]},"company":{"id":1777,"name":"Langosh and Sons","fortuneRank":277}},{"app":{"id":24,"name":"Alpha","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-06-21","adSpend":true,"categories":[]},"company":{"id":160,"name":"Ward, Fisher and Shields","fortuneRank":160}},{"app":{"id":466,"name":"Bigtax","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-09-01","adSpend":true,"categories":[]},"company":{"id":492,"name":"Bernier Inc","fortuneRank":492}},{"app":{"id":452,"name":"Biodex","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-07-14","adSpend":true,"categories":[]},"company":{"id":369,"name":"Padberg and Sons","fortuneRank":369}},{"app":{"id":473,"name":"Fintone","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-07-25","adSpend":true,"categories":[]},"company":{"id":1673,"name":"Koch, VonRueden and Predovic","fortuneRank":173}},{"app":{"id":278,"name":"Fintone","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-09-28","adSpend":true,"categories":[]},"company":{"id":472,"name":"Romaguera Inc","fortuneRank":472}},{"app":{"id":254,"name":"Fix San","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-07-22","adSpend":true,"categories":[]},"company":{"id":94,"name":"Skiles Inc","fortuneRank":94}},{"app":{"id":388,"name":"Fix San","mobilePriority":"high","userBase":"strong","lastUpdated":"2015-04-26","adSpend":true,"categories":[]},"company":{"id":492,"name":"Bernier Inc","fortuneRank":492}},{"app":{"id":342,"name":"Fixflex","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-10-09","adSpend":true,"categories":[]},"company":{"id":354,"name":"Lubowitz Group","fortuneRank":354}},{"app":{"id":463,"name":"Fixflex","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-07-14","adSpend":true,"categories":[]},"company":{"id":410,"name":"Gleichner, Bergnaum and Bartell","fortuneRank":410}},{"app":{"id":411,"name":"Fixflex","mobilePriority":"medium","userBase":"moderate","lastUpdated":"2015-01-15","adSpend":true,"categories":[]},"company":{"id":77,"name":"Bechtelar, Parisian and Friesen","fortuneRank":77}},{"app":{"id":126,"name":"Greenlam","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-07-09","adSpend":true,"categories":[]},"company":{"id":472,"name":"Romaguera Inc","fortuneRank":472}},{"app":{"id":239,"name":"Greenlam","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-12-11","adSpend":true,"categories":[]},"company":{"id":374,"name":"Jacobs, Windler and Beer","fortuneRank":374}},{"app":{"id":106,"name":"Greenlam","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-12-19","adSpend":true,"categories":[]},"company":{"id":342,"name":"Bahringer, Connelly and Cassin","fortuneRank":342}},{"app":{"id":391,"name":"Hatity","mobilePriority":"high","userBase":"moderate","lastUpdated":"2015-03-02","adSpend":true,"categories":[]},"company":{"id":218,"name":"Rowe-Weimann","fortuneRank":218}},{"app":{"id":445,"name":"Holdlamis","mobilePriority":"medium","userBase":"moderate","lastUpdated":"2015-02-05","adSpend":true,"categories":[]},"company":{"id":497,"name":"Welch-Donnelly","fortuneRank":497}},{"app":{"id":271,"name":"Home Ing","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-10-12","adSpend":true,"categories":[]},"company":{"id":83,"name":"Rippin-Christiansen","fortuneRank":83}},{"app":{"id":130,"name":"It","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-08-13","adSpend":true,"categories":[]},"company":{"id":252,"name":"Daniel, Herzog and Sanford","fortuneRank":252}},{"app":{"id":456,"name":"Job","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-07-02","adSpend":true,"categories":[]},"company":{"id":276,"name":"Reynolds-Spinka","fortuneRank":276}},{"app":{"id":215,"name":"Keylex","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-09-14","adSpend":true,"categories":[]},"company":{"id":269,"name":"Kihn-Corwin","fortuneRank":269}},{"app":{"id":85,"name":"Keylex","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-06-06","adSpend":true,"categories":[]},"company":{"id":356,"name":"Pfannerstill Group","fortuneRank":356}},{"app":{"id":399,"name":"Keylex","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-10-25","adSpend":true,"categories":[]},"company":{"id":68,"name":"Romaguera, Collier and Hegmann","fortuneRank":68}},{"app":{"id":349,"name":"Keylex","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-09-03","adSpend":true,"categories":[]},"company":{"id":399,"name":"Prosacco-Murphy","fortuneRank":399}},{"app":{"id":222,"name":"Konklab","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-05-22","adSpend":true,"categories":[]},"company":{"id":133,"name":"Bahringer, Strosin and Lockman","fortuneRank":133}},{"app":{"id":407,"name":"Konklux","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-11-26","adSpend":true,"categories":[]},"company":{"id":311,"name":"Hayes-Wilkinson","fortuneRank":311}},{"app":{"id":426,"name":"Lotlux","mobilePriority":"high","userBase":"moderate","lastUpdated":"2015-01-10","adSpend":true,"categories":[]},"company":{"id":170,"name":"Lynch, O'Reilly and Quigley","fortuneRank":170}},{"app":{"id":324,"name":"Lotstring","mobilePriority":"high","userBase":"strong","lastUpdated":"2015-03-06","adSpend":true,"categories":[]},"company":{"id":1745,"name":"Satterfield Inc","fortuneRank":245}},{"app":{"id":417,"name":"Lotstring","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-11-23","adSpend":true,"categories":[]},"company":{"id":18,"name":"Cole-Cormier","fortuneRank":18}},{"app":{"id":22,"name":"Mat Lam Tam","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-10-27","adSpend":true,"categories":[]},"company":{"id":354,"name":"Lubowitz Group","fortuneRank":354}},{"app":{"id":118,"name":"Mat Lam Tam","mobilePriority":"high","userBase":"moderate","lastUpdated":"2015-03-09","adSpend":true,"categories":[]},"company":{"id":132,"name":"Schultz LLC","fortuneRank":132}},{"app":{"id":311,"name":"Mat Lam Tam","mobilePriority":"medium","userBase":"moderate","lastUpdated":"2015-02-05","adSpend":true,"categories":[]},"company":{"id":462,"name":"West, Hodkiewicz and Morissette","fortuneRank":462}},{"app":{"id":301,"name":"Namfix","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-11-18","adSpend":true,"categories":[]},"company":{"id":134,"name":"Dare Inc","fortuneRank":134}},{"app":{"id":457,"name":"Otcom","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-09-02","adSpend":true,"categories":[]},"company":{"id":1,"name":"Monahan, Streich and Mertz","fortuneRank":1}},{"app":{"id":495,"name":"Otcom","mobilePriority":"high","userBase":"strong","lastUpdated":"2015-03-31","adSpend":true,"categories":[]},"company":{"id":188,"name":"Runolfsson, Wiegand and Denesik","fortuneRank":188}},{"app":{"id":315,"name":"Overhold","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-11-16","adSpend":true,"categories":[]},"company":{"id":350,"name":"Collier, Tromp and Hayes","fortuneRank":350}},{"app":{"id":409,"name":"Overhold","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-12-06","adSpend":true,"categories":[]},"company":{"id":441,"name":"O'Connell and Sons","fortuneRank":441}},{"app":{"id":305,"name":"Overhold","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-11-20","adSpend":true,"categories":[]},"company":{"id":143,"name":"Strosin Group","fortuneRank":143}},{"app":{"id":8,"name":"Overhold","mobilePriority":"medium","userBase":"strong","lastUpdated":"2015-02-25","adSpend":true,"categories":[]},"company":{"id":184,"name":"Mosciski, Fritsch and Schiller","fortuneRank":184}},{"app":{"id":19,"name":"Quo Lux","mobilePriority":"medium","userBase":"moderate","lastUpdated":"2015-01-30","adSpend":true,"categories":[]},"company":{"id":309,"name":"Kerluke-Von","fortuneRank":309}},{"app":{"id":128,"name":"Quo Lux","mobilePriority":"high","userBase":"strong","lastUpdated":"2015-03-25","adSpend":true,"categories":[]},"company":{"id":86,"name":"Hills, Rosenbaum and Breitenberg","fortuneRank":86}},{"app":{"id":350,"name":"Quo Lux","mobilePriority":"high","userBase":"strong","lastUpdated":"2015-04-28","adSpend":true,"categories":[]},"company":{"id":66,"name":"Ziemann Group","fortuneRank":66}},{"app":{"id":286,"name":"Rank","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-10-30","adSpend":true,"categories":[]},"company":{"id":33,"name":"Tremblay and Sons","fortuneRank":33}},{"app":{"id":168,"name":"Rank","mobilePriority":"high","userBase":"moderate","lastUpdated":"2015-01-16","adSpend":true,"categories":[]},"company":{"id":138,"name":"Wintheiser Group","fortuneRank":138}},{"app":{"id":281,"name":"Rank","mobilePriority":"high","userBase":"moderate","lastUpdated":"2015-01-02","adSpend":true,"categories":[]},"company":{"id":27,"name":"Denesik, Nader and Keebler","fortuneRank":27}},{"app":{"id":265,"name":"Rank","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-08-08","adSpend":true,"categories":[]},"company":{"id":463,"name":"Hettinger LLC","fortuneRank":463}},{"app":{"id":153,"name":"Redhold","mobilePriority":"high","userBase":"moderate","lastUpdated":"2014-08-24","adSpend":true,"categories":[]},"company":{"id":205,"name":"Torp, Gislason and Crona","fortuneRank":205}},{"app":{"id":494,"name":"Redhold","mobilePriority":"low","userBase":"moderate","lastUpdated":"2014-08-27","adSpend":true,"categories":[]},"company":{"id":106,"name":"Herzog, Wuckert and Kling","fortuneRank":106}},{"app":{"id":490,"name":"Ronstring","mobilePriority":"high","userBase":"strong","lastUpdated":"2015-04-26","adSpend":true,"categories":[]},"company":{"id":69,"name":"Gleichner, Abernathy and Walker","fortuneRank":69}}],"resultsCount":90};

  $rootScope.apps = data.results;
  $rootScope.numApps = data.resultsCount;

  $scope.usersLists = listApiService.getLists();
  $scope.createList = listApiService.createNewList;
  $scope.getList = function(listName) {
    var data = listApiService.getList(listName);
    $rootScope.apps = data.results;
    $rootScope.numApps = data.resultsCount;
  };
  $scope.addSelectedTo = function(list, selectedApps) {
    listApiService.addSelectedTo(list, selectedApps);
    $scope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
  };
  $scope.deleteSelected = listApiService.deleteSelected;

}]);
