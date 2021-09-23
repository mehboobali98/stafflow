
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
global.$ = global.jQuery = require("jquery"); 
require("./settings")
require('./user')
require("bootstrap")
import "@fortawesome/fontawesome-free/css/all"
import "chartkick/chart.js"
document.addEventListener("turbolinks:load", function() {
  $(function () {
    $('[data-toggle="tooltip"]').tooltip();
    $('[data-toggle="popover"]').popover();
  })
})
$(document).ready(function(){
  $("#search_btn").on("click", function(event){
    event.preventDefault();
    // $("#search_form").preventDefault;
    let search_key = document.getElementById("search_box").value;
    sendMassUpdateRequest("GET", "/search/search_data", search_key);

    // $.ajax({
    //   type: "GET",
    //   url: "/search/search_data",
    //   data: {
    //    search_data : search_key
    //   }
    // })
  })
})