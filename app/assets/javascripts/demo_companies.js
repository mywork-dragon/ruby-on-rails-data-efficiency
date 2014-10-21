$(document).ready(function(){
  $("select").change(function () {
    console.log("changed");
    var str = "";
    $("select option:selected").each(function() {
      str = $( this ).text();
    });
    
    //$("#companies-using").html(str);
    
    console.log(str + " selected")
    
    var data = {
      "service_name": str
    };
    
    $.ajax({

      url: "/demo_get_companies",
      data: data,

      success: function(data, response) {
        console.log("success! " + data);
        
        var companies = data.company_urls;
        var count = data.count;
        
        var list = "<ul>";
        
        var length = companies.length;
        for (var i = 0; i < length; i++) {
          list += "<li>" + companies[i] + "</li>";
        }
        
        if(count > 0)
        {
          list += "<li>Plus " + count + " more..."
        }
        
        list += "</ul>"

        $('#companies-using').html("<div><ul>" + list + "</ul></div>")
      }

    })
    
  }).change();
});