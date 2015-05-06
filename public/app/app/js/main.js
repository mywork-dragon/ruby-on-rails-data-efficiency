$(document).ready(function() {

  /* User feedback widget initialization - feedback_me */
  fm_options = {
    bootstrap: true,
    name_placeholder: "Full name",
    name_required: true,
    show_email : true,
    message_placeholder: "Any feedback, questions or bugs?",
    feedback_url: "http://localhost:3000/api/save_user_feedback",
    // feedback_url: "http://www.mightysignal.com/api/save_user_feedback",
    position : "right-bottom",
    delayed_options: {
      success_color: "#5cb85c",
      fail_color: "#d2322d",
      delay_success_milliseconds: 3500,
      send_success: "Thanks for your feedback!"
    }
  };
  //init feedback_me plugin
  fm.init(fm_options);

});
