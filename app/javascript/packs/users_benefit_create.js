$(document).on('change', '[id=CheckBox]', function(){
  if($(this).is(":checked"))
    {
      $("#" + $(this).attr('data-id')).attr("disabled", false);
    }
    else
    {
      $("#" + $(this).attr('data-id')).attr("disabled", true);
    }
});
