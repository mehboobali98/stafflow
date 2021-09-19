$(document).ready(function () {
  $('#sidebar_toggle_btn').on('click', function () {
    console.log("im in");
    $('.sidebar').toggleClass('active');
    if ($('.sidebar').hasClass('active')) {
      console.log("active");
      $(".home_content").addClass("sidebar-toggle");
      $(".home_content").removeClass("home_content");
    } else {
      console.log("inactive");
      $(".sidebar-toggle").addClass("home_content");
      $(".home_content").removeClass("sidebar-toggle");
    }
  });
});