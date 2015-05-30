
var term = "hi"

$.get( "http://localhost:3000/api/results", { search : term }, function(data) {
  console.log(data)
});