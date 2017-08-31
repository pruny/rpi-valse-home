////////////////////////////
// Utility Functions
////////////////////////////

// Add leading zeros (Driver 01 etc)
function pad (str, max) {
  str = str.toString();
  return str.length < max ? pad("0" + str, max) : str;
}

function sortNumber(a,b) {
    return a - b;
}

////////////////////////////
// API - AJAX Functions
////////////////////////////

function get_drivers(group, callback) {
  $.ajax({
     type: "GET",
     url:'api/drivers/group_id/'+group,
     success: function(result) { callback(result) }
  });
}


////////////////////////////
// Other Functions
////////////////////////////

// RENDER
function dom_render_template(tmpl, data, func, fade=true) {
  if(tmpl.title) {
    $("#header_title").html(tmpl.title.replace(">", "<i class='material-icons' style='display: initial; font-size: initial;'>chevron_right</i>"));
  }


  $.ajax({
      url: tmpl.file,
      async: true,
      dataType: 'text',
      success: function(contents) {
          $.templates({my_template: contents});
          if(fade)
          {
            $('#'+tmpl.target).hide().html(
                $.render.my_template(data)
            ).fadeIn(200);
          }
          else {
            $('#'+tmpl.target).html($.render.my_template(data));
          }

          func();

      }
  });
}


// INIT
function init_drivers() {
  var data = [];
  for (var i=1; i<=_DRIVER_COUNT_PAGE; i++)
  {
    data.push({id: pad(i,2)});
  }
  dom_render_template(_TEMPLATES.drivers, {drivers: data}, function() {
    //Init drivers
    $("[id^=slider_]").asPieProgress({
      'namespace': 'pie_progress',
       min: 0,
       max: 100,
       goal: 0,
       step: 1,
       speed: 20,
       //delay: 300,
       //easing: 'linear'
    });

    //Update VALUES
    update_drivers();

    //Load additional js files
    load_js();

    //Init tooltips
    $('.tooltipped').velocity("stop");
    $('.tooltipped').tooltip('remove');
    $('.tooltipped').tooltip({delay: 30});
  })
}

// UPDATE
function update_drivers() {
  get_drivers(_current_group, function(_drivers_new) {
    if(!("error" in _drivers_new)) {
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
    } else {
      _drivers = [];
      $("[id^=slider_]").asPieProgress("go", "0%");
      $(".card").addClass("notindb");
    }

  });
}

function load_js() {
  $.getScript("js/functions_drivers.js", function(data, textStatus, jqxhr) {
    init_drivers();
  });

  $.getScript("js/functions_configs.js", function(data, textStatus, jqxhr) {
    init_configs();
  });
}
