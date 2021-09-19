$(document).ready(function () {
  $('#sidebar_toggle_btn').on('click', function () {
    $('.sidebar').toggleClass('active');
    if ($('.sidebar').hasClass('active')) {
      $(".home_content").addClass("sidebar-toggle");
      $(".home_content").removeClass("home_content");
    } else {
      $(".sidebar-toggle").addClass("home_content");
      $(".home_content").removeClass("sidebar-toggle");
    }
  });
});