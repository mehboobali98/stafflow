$(document).ready(function(){
  $('#setting_form').on('change keyup', function(){
    $('#submit_button').prop('disabled', false)
  });
})