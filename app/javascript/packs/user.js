// The following script fires on event change on company_name text field. After that it 
// removes any white spaces or special characters from the company_name value and then converts it into 
// lower case before setting it to subdomain text field 
$(document).ready(function() {
  $("#company_name").keyup(function() {
    subdomain = $(this).val().replace(/[^A-Z0-9]/ig, "").toLowerCase();
    $('#subdomain').val(subdomain);
  });
})
