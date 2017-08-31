////////////////////////////
// Module Select
////////////////////////////

function module_modal_init() {
  html_string = "";
  for (var i = 0; i < _MODULE_GROUPS.length; i++) {
    html_string += "<a class='collection-item module_group'>"+_MODULE_GROUPS[i]+"</a>";
  }

  $("#modal2 > .modal-content > .collection").html(html_string);
  $("#modal2_back").addClass("hidden");
}

function modal_module_range_select() {
  start = parseInt(this.text.split(" - ")[0]);
  end = parseInt(this.text.split(" - ")[1]);
  html_string="";

  for(i=start; i<=end; i++) {
    html_string += "<a href='#!' class='collection-item module_group_select'>"+pad(i,2)+"</a>";
  }

  $("#modal2 > .modal-content > .collection").fadeOut(150, function() {
    $(this).html(html_string).fadeIn(250);
  });

  $("#modal2_back").removeClass("hidden");
}

function modal_module_select() {
  $("#modal2").closeModal();
  $("#module_id").text(this.text);
  selected_none();
  //select_toggle();
  select_toggle_btn(true);
  _current_group = parseInt(this.text);
  $(".driver_disabled_icon").addClass("hidden");
  update_drivers();
}

function modal_module_open() {
  module_modal_init();
  $("#modal2").openModal({
    in_duration: 200,
    out_duration: 150
  });
}

function modal_module_back() {
  $("#modal2 > .modal-content > .collection").fadeOut(150, function() {
    module_modal_init();
    $(this).fadeIn(250);
  });
}

function action_change_group() {
  $("#group_selector > li").removeClass("active teal");
  $(this).addClass("active teal");
  _current_group = $(this).text();
  get_drivers(_current_group, check_drivers_new);
}

/////////////////

function modal_bind_click_events_MS() {
  $("#modal2").on('click', '.module_group', modal_module_range_select);
  $("#modal2").on('click', '.module_group_select', modal_module_select);
  $("#module_id").click(modal_module_open);
  $("#modal2").on('click', '#modal2_back', modal_module_back)

  $("#group_selector > .grp_btn").click(action_change_group);
}

////////////////////////////
// Change Driver Value
////////////////////////////

function init_modal_CDV() {
  $("#mod_slider").roundSlider({
    radius: 120,
    width: 40,
    sliderType: "min-range",
    value: 0,
    startAngle: 90,
    mouseScrollAction: true,
    handleSize: "50",
  });
  $('.collapsible').collapsible();
}

function dom_open_edit_modal() {
  if(_drivers_selected.length == 0)
    Materialize.toast('Please SELECT at least one driver', 3000);
  else {
    var val = 0;
    if(_drivers_selected.length==1)
      val = $("#slider_"+_drivers_selected[0]+" > .pie_progress__number").text().replace('%','');

    $("#mod_slider").roundSlider({value: val});
    if(val<10)
      $(".rs-tooltip.edit, .rs-tooltip .rs-input").css("margin-left", "-17px");
    else
      $(".rs-tooltip.edit, .rs-tooltip .rs-input").css("margin-left", "-26px");

    $('#modal1').openModal({
      in_duration: 200,
      out_duration: 150
    });
  }
}

function modal_bind_click_events_CDV() {
  $("#mobile_change_values, #change_drv_values").click(dom_open_edit_modal);
  $("#modal_set_ok").click(action_update_driver);
}
