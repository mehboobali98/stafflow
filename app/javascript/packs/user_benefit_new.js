$(document).on('change', '[type=checkbox]', function(){
  if($(this).is(":checked") && !$(this).attr('id').includes('status'))
    {
      $(this).parent().parent().next().next().children().children().attr("disabled", false);
      
    }
    else if(!$(this).attr('id').includes('status'))
    {
      $(this).parent().parent().next().next().children().children().attr("disabled", true);
    }
});
