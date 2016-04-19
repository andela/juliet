// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require semantic-ui
//= require dropzone
//= require_tree .

$(document).ready(function() {
  Dropzone.autoDiscover = false;
  var mediaDropzone;
  mediaDropzone = new Dropzone(".dropzone", { url: '/file/post' });
  return mediaDropzone.on("success", function(file, responseText) {
    var fileUrl;
    fileUrl = responseText.file_name.url;
  });
  
  return mediaDropzone.on("complete", function(file, responseText) {
  
  });

});

//$(document).on("ready page:load", Dropzone.discover);

