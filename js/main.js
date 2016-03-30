$(document).ready(function () {

  var getUrl = document.getElementById("getUrlBtn");
  var searchPane = document.getElementById("content");

  getUrl.addEventListener('click', function (e) {
    e.preventDefault();
    var companyName = document.getElementById("name").value;
    var companyLocation = document.getElementById("location").value;
    var startUp = document.getElementById("start-up");
    companyType(companyName, companyLocation, startUp);
  });

  var companyType = function(name, location, flag) {
    var params =  "company=", starter = false;
    if (flag.checked == true) {
         params += name, starter = true
      } else {
        params += name + " " + location;
      }
      return makeAjaxCall(params, starter);
  };

  var makeAjaxCall = function (query, startup) {
    $.ajax({
      type: "POST",
      url: "http://localhost:8080/",
      data: { company : "andela" },
      success: function(res) {
        var urlList = JSON.parse(res).url;
        addSearchResultsToDom(urlList);
      },
      error: function(xhr){
        console.log("There was an error");
        console.log(xhr);
      }
    })
  };

  var addSearchResultsToDom = function (urlList) {
    console.log(urlList);
    var frag = document.createDocumentFragment();
    for(var i = 0; i < urlList.length; i++) {
      var urlPane = document.getElementById("url" + (i + 1));
      urlPane.textContent = urlList[i];
    }
  };

});
