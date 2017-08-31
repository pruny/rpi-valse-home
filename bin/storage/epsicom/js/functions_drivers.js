function compare_id(a,b) {
  if (a.id < b.id)
    return -1;
  if (a.id > b.id)
    return 1;
  return 0;
}

function check_drivers_new(_drivers_new) {
  var changed = JSON.stringify(_drivers) != JSON.stringify(_drivers_new);
  _drivers = _drivers_new;
  if(changed) {
    $("[id^=slider_]").asPieProgress("go", "0%");
    $(".card").addClass("notindb");

    $.each(_drivers, function(i, item) {
      $("#slider_"+pad(item.id,2)).asPieProgress('go',item.value+"%");
      $("#slider_"+pad(item.id,2)).parent().parent().removeClass("notindb");
      if(item.config_enabled == 0) {
        $("#driver_disabled_icon_"+pad(item.id,2)).removeClass("hidden");
      } else {
        $("#driver_disabled_icon_"+pad(item.id,2)).addClass("hidden");
      }
    });
  }
}

function create_driver(id, value, callback) {
  $.ajax({
     type: "POST",
     data: {id: id, group_id: _current_group, value: value},
     url:'api/drivers/',
     success: function(result, textStatus) { callback(result, textStatus, id, value) }
  });
}

function update_driver(id, value, callback) {
  $.ajax({
     type: "PUT",
     data: {value: value, value_applied: 0},
     url:'api/drivers/'+id+'/group_id/'+_current_group,
     success: function(result, textStatus) { callback(result, textStatus, id, value) }
  });
}

function enable_driver_config(id, callback) {
  $.ajax({
     type: "PUT",
     data: {config_enabled: 1},
     url:'api/drivers/'+id+'/group_id/'+_current_group,
     success: function(result, textStatus) { callback(result, textStatus) }
  });
}

function disable_driver_config(id, callback) {
  $.ajax({
     type: "PUT",
     data: {config_enabled: 0},
     url:'api/drivers/'+id+'/group_id/'+_current_group,
     success: function(result, textStatus) { callback(result, textStatus) }
  });
}


////////////////////////////
// Action functions
////////////////////////////

function action_select_deselect() {
  var id = this.id.split("_")[1];
  var index = _drivers_selected.indexOf(id);
  if( index == -1)
  {
    _drivers_selected.push(id);
    _drivers_selected.sort(sortNumber);
    dom_selection_change();
  }
   else
   {
     _drivers_selected.splice(index, 1);
     _drivers_selected.sort(sortNumber);
     dom_selection_change();
   }

   if(_drivers_selected.length != parseInt(_DRIVER_COUNT_PAGE)) {
     select_toggle_btn(true);
   } else {
     select_toggle_btn(false);
   }
}

function selected_all() {
  _drivers_selected = [];
  for (var id=1; id<=_DRIVER_COUNT_PAGE; id++) {
    _drivers_selected.push(pad(id.toString(),2));
  }
  _drivers_selected.sort(sortNumber);
  dom_selection_change();
}


function select_toggle_btn(state) {
  if(state) {
    $("#select_toggle").html("<i class=\"material-icons\">radio_button_checked</i>");
    $("#select_toggle").removeClass("grey");
    $("#select_toggle").addClass("orange");
    $("#select_toggle").attr("data-tooltip", "ALL drivers");
  } else {
    $("#select_toggle").html("<i class=\"material-icons\">radio_button_unchecked</i>");
    $("#select_toggle").removeClass("orange");
    $("#select_toggle").addClass("grey");
    $("#select_toggle").attr("data-tooltip", "NO drivers");
  }
}

function select_toggle() {
  if(_drivers_selected.length != parseInt(_DRIVER_COUNT_PAGE)) {
    selected_all();
    select_toggle_btn(false);
  } else {
    selected_none();
    select_toggle_btn(true);
  }
}

function selected_none() {
  _drivers_selected = [];
  dom_selection_change();
}

function dom_selection_change() {

  // Update Count
  count = _drivers_selected.length;
  $("[id^=selected_count]").text(count);

  // Update Chips
  var chip_content = "";
  $.each(_drivers_selected, function(i, item) {
     chip_content += "<div id='chip_"+item+"' class='chip'>"+pad(item,2)+"</div>";
   });
  $("#chip_container").html(chip_content);

  // Card highlight
  $("[id^=card_]").removeClass('card_selected');
  $.each(_drivers_selected, function(i, driver) {
    $("#card_"+driver).addClass('card_selected');
  });

}

function action_update_driver() {
  var value = $("#mod_slider")[0].innerText;
  var driver_id_list = _drivers.map(function(drv) { return pad(drv.id,2); });
  var status = { success:[], error:[] }

  $.each(_drivers_selected, function(i, driver) {
    if(driver_id_list.indexOf(driver) != -1)
    {
      //console.log("Update driver: "+driver);
      update_driver(driver, value, check_update_status);
    }
    else
    {
      //console.log("Create driver: "+driver);
      create_driver(driver, value, check_update_status);
    }
  });

  function check_update_status(result, textStatus, id, value) {
    if("error" in result)
      status.error.push(id);
    else
      status.success.push(id)

    if((status.success.length+status.error.length) == _drivers_selected.length) {
      if(status.success.length == _drivers_selected.length) {
        Materialize.toast('Successfully UPDATED selected driver(s)', 3000);
        get_drivers(_current_group, check_drivers_new);
        //select_toggle();
        selected_none();
        select_toggle_btn(true);
      } else {
        //dom_update_status_modal(result);
        console.log("Error updating/creating drivers: "+JSON.stringify(status.error));
        get_drivers(_current_group, check_drivers_new);
        //select_toggle();
        selected_none();
        select_toggle_btn(true);
      }

      selected_none();
    }
  }

}

function init_modals() {
  // Change module
  $.getScript("js/functions_drivers_modals.js", function(data, textStatus, jqxhr) {
    module_modal_init();
    dom_render_template(_TEMPLATES.drv_module_select, {}, function() {
      modal_bind_click_events_MS();
    });

    // Change driver value
    $.getScript("js/external/roundslider.js", function(data, textStatus, jqxhr) {
      dom_render_template(_TEMPLATES.drv_value, {}, function() {
        init_modal_CDV();
        modal_bind_click_events_CDV();
      });
    });

  });

}

function enable_config() {
  console.log("ENABLE CONFIG");
  var driver_id_list = _drivers.map(function(drv) { return pad(drv.id,2); });
  var success_count = 0;
  var error_count = 0;

  function check_status() {
    if ((success_count+error_count) == _drivers_selected.length) {
      if(error_count == 0) {
        Materialize.toast("Successfully ENABLED driver config(s)", 3000);
      } else {
        Materialize.toast("ERROR enabling driver config(s)", 3000);
      }
      update_drivers();
    }
  }

  if(_drivers_selected.length <= 0) {
    Materialize.toast("Please SELECT at least one driver", 3000);
  } else {
    $.each(_drivers_selected, function(i, driver) {
      //console.log(driver);
      if(driver_id_list.indexOf(driver) != -1)
      {
        enable_driver_config(driver, function(result, textStatus) {
          if("error" in result)
            error_count += 1;
          else
            success_count += 1;
          check_status();
        });
      } else {
        create_driver(driver, 0, function(result, textStatus) {
          if("error" in result)
            error_count += 1;
          else {
            enable_driver_config(driver, function(result, textStatus) {
              if("error" in result)
                error_count += 1;
              else
                success_count += 1;
              check_status();
            });
          }
        });
      }
    });
  }
}

function disable_config() {
  console.log("DISABLE CONFIG");
  var driver_id_list = _drivers.map(function(drv) { return pad(drv.id,2); });
  var success_count = 0;
  var error_count = 0;
//console.log(_drivers);

  function check_status() {
    if ((success_count+error_count) == _drivers_selected.length) {
      if(error_count == 0) {
        Materialize.toast("Successfully DISABLED driver config(s)", 3000);
      } else {
        Materialize.toast("ERROR disabling driver config(s)", 3000);
      }
      update_drivers();
    }
  }


  if(_drivers_selected.length <= 0) {
    Materialize.toast("Please SELECT at least one driver", 3000);
  } else {
    $.each(_drivers_selected, function(i, driver) {
      //console.log(driver);
      if(driver_id_list.indexOf(driver) != -1)
      {
        disable_driver_config(driver, function(result, textStatus) {
          if("error" in result)
            error_count += 1;
          else
            success_count += 1;
          check_status();
        });
      } else {
        create_driver(driver, 0, function(result, textStatus) {
          if("error" in result)
            error_count += 1;
          else {
            disable_driver_config(driver, function(result, textStatus) {
              if("error" in result)
                error_count += 1;
              else
                success_count += 1;
              check_status();
            });
          }
        });
      }

    });
  }
}


function init_drivers() {
  //BIND CLICK EVENT
  // Card click
  $(".card").click(action_select_deselect);

  // Select/Deselect all
  $("#select_toggle").click(select_toggle);

  $("#enable_config_btn").click(enable_config);
  $("#disable_config_btn").click(disable_config);

  //INIT
  init_modals();
}
