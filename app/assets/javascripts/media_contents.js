 $(document).ready(function () {
   Dropzone.autoDiscover = false;

   var stepOne = $('.step-one');
   var stepTwo = $('.step-two');
   var stepThree = $('.step-three');
   var exportButton = $('.export-btn');
   var dropzone = $('.dropzone');
   var mediaDropzone = new Dropzone("#media-dropzone", {
     addRemoveLinks: true,
		init: function() {
    	return this.on('removedfile', function(file) {
      	if (file.xhr) {
        	return $.ajax({
          	url: "" + ($("#media-dropzone").attr("action")) + "/" + (JSON.parse(file.xhr.response).id),
          	type: 'DELETE'
        	});
      	}
    	});
 		}
  });

  // Temporarily disable dropzone zone
  dropzone.removeClass('dz-clickable');
  $(".dz-hidden-input").prop("disabled",true);

   exportButton.on('click', function(event){
     event.preventDefault();
     openPopUpWindow();
     stepTwo.removeClass('active');
     stepThree.addClass('active').transition('pulse');
     stepThree.removeClass('disabled');
     dropzone.removeClass('disabled').addClass('dz-clickable');
     $(".dz-hidden-input").prop("disabled", false);
     stepTwo.addClass('completed').transition('pulse');
   });

  $('.ui.form').form({
    on: 'blur',
    inline: true,
    transition: 'scale',
    revalidate: 'true',
    onSuccess: function(event, fields) {
      console.log('success');
      stepOne.removeClass('active');
      stepTwo.addClass('active').transition('pulse');;
      stepTwo.removeClass('disabled');
      stepOne.addClass('completed').transition('pulse');;
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

 // Notifications
	$('.message.close').on('click', function() {
    $(this).closest('.message').transition('fade');
  });

  // Handle dropzone events
  return mediaDropzone.on('success', function(file, responseText){
   console.log('file uploaded successfully');
   console.log('File: ' + file);
   console.log('responseText: ' + responseText);

  $('.user-info').transition('fade');
  $('.export-linkedin').transition('fade');
  $('.upload').addClass('dropzone-filed-added').transition('jiggle');
  setTimeout(function() {
    window.location = Routes.thank_you_path();
  }, 3000);
 });

 return mediaDropzone.on('drop', function(event){
   console.log('file dropped');
   $('.user-info').transition('fade');
   $('.export-linkedin').transition('fade');
   $('.upload').addClass('dropzone-filed-added').transition('jiggle');

 });

 return mediaDropzone.on('addedfile', function(file){
   console.log('file added');
  $('.user-info').transition('fade');
  $('.export-linkedin').transition('fade');
  $('.upload').transition('jiggle').addClass('dropzone-filed-added');
 });
	return mediaDropzone.on('thumbnail', function(file, dataUrl){
   console.log('file added');
   $('.user-info').transition('fade');
   $('.export-linkedin').transition('fade');
   $('.upload').transition('jiggle').addClass('dropzone-filed-added');
 });
 return mediaDropzone.on('processing', function(file){
   console.log('file added');
   $('.user-info').transition('fade');
   $('.export-linkedin').transition('fade');
   $('.upload').transition('jiggle').addClass('dropzone-filed-added');
 });

});


function openPopUpWindow () {
  window.open(
    'https://www.linkedin.com/people/export-settings',
    'popUpWindow',
    'height=300,width=400,left=10,top=10,resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no,status=yes'
  );
}
