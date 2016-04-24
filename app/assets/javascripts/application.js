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




$(document).ready(function () {

   var stepOne = $('.step-one');
   var stepTwo = $('.step-two');
   var stepThree = $('.step-three');
   var exportButton = $('.export-btn');

   exportButton.on('click', function(event){
     event.preventDefault();
     openPopUpWindow();
     stepTwo.removeClass('active');
     stepThree.addClass('active');
     stepThree.removeClass('disabled');
     stepTwo.addClass('completed');
   });

  $('.ui.form').form({
    on: 'blur',
    inline: true,
    transition: 'scale',
    revalidate: 'true',
    onSuccess: function(event, fields) {
      console.log('success');
      stepOne.removeClass('active');
      stepTwo.addClass('active');
      stepTwo.removeClass('disabled');
      stepOne.addClass('completed');
      exportButton.removeClass('disabled');
    },
    onInvalid: function() {
     console.log('invalid');
    },
    onVaid: function() {
      console.log('valid');
    },
    onFailure: function(formErrors, fields) {
     console.log('failure');
   },
    fields: {
     name: {
       identifier: 'name',
       rules: [
         {
           type: 'empty',
           prompt: 'Please enter your name'
         },
         {
           type: 'minLength[2]',
           prompt: 'Your name must be at least {ruleValue} characters'
         }

       ]
     },
     email: {
       identifier: 'email',
       rules: [
         {
           type: 'email',
           prompt: 'Please provide a valid e-mail'
         }
       ]
     }
   }
 });
});

function openFileUploader () {
  console.log('howdyyyyy');
  var fileUploadButton = document.getElementById('file');
  fileUploadButton
  fileUploadButton.addEventListener('click', function(event){
    console.log('howdyyyyy');
    if (event.preventDefault) event.preventDefault();
    if (event.stopPropagation) event.stopPropagation();
    console.log('howdyyyyy');
    this.click();

    return false;
  });
}

function openPopUpWindow () {
  window.open(
    'https://www.linkedin.com/people/export-settings',
    'popUpWindow',
    'height=300,width=400,left=10,top=10,resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no,status=yes'
  );
}
