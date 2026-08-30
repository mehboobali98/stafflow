$(document).ready(function() {
  $("#company").keyup(function() {
    subdomain = $(this).val().replace(/[^A-Z0-9]/ig, "").toLowerCase();
    $('#subdomain').val(subdomain);
    $('#span_subdomain').html(subdomain);
  });
});