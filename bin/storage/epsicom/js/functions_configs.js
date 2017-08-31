function compare_start_times(a,b) {
  if (a.start < b.start)
    return -1;
  if (a.start > b.start)
    return 1;
  return 0;
}

function modal_import_csv_open() {
  //module_modal_init();
  $("#modal3").openModal({
    in_duration: 200,
    out_duration: 150
  });
}


function render_config(fd=false, saving="0", func=function(){}) {
  //dom_render_template(_TEMPLATES.configs, {time: _current_config_list, title: "Driver "+pad(_current_config_driver,2)}, function() {
  console.log("RENDER CONFIG "+saving);
  dom_render_template(
    _TEMPLATES.configs,
    {
      saving: saving,
      time: _current_config_list,
      title: "Module "+pad(_current_group,2)+" <i class='material-icons'>chevron_right</i> Driver "+pad(_current_config_driver,2)
    },
    function() {
      $('.tooltipped').velocity("stop");
      $('.tooltipped').tooltip('remove');
      $('.tooltipped').tooltip({delay: 0});
      $("#mod_slider_configs").roundSlider("destroy");
      $("#mod_slider_configs").roundSlider({
        radius: 100,
        width: 30,
        sliderType: "min-range",
        value: 0,
        startAngle: 90,
        mouseScrollAction: false,
        handleSize: "50",
        change: function(e) {
          console.log(e.value);
          console.log(td_ref.attr('id'));
          var change_id = td_ref.attr('id').split("_")[0];
          var new_val = e.value;
          _current_config_list[change_id].value = new_val;
          render_config();
          //$("#cfg_value_slider").fadeOut(10);
        }
      });

      //Init tooltips
      $('.tooltipped').velocity("stop");
      $('.tooltipped').tooltip('remove');
      $('.tooltipped').tooltip({delay: 30});

      dom_render_template(_TEMPLATES.cfg_import_csv_modal, {}, function() {
        //modal_bind_click_events_MS();
      });

      func();
}, fade=fd);
}

function init_configs() {
  bind_click_events_configs();

  $.getScript("js/external/jquery-clockpicker.js", function(data, textStatus, jqxhr) {

    $(document).on("click", "#configs_content > #configs_time_data_result > div > table > tbody > tr > td.time", function(e) {
      $("#clkpicker").clockpicker({
      donetext: 'OK',
      default: '00:00',
      placement: 'bottom',
      autoclose: true,
      beforeShow: function() {
        console.log("before show");
      },
      afterDone: function() {
        ///console.log("after done");
        ///console.log($("#clkpicker").val());
        //td_ref.text($("#clkpicker").val());
        var index = (td_ref.attr('id')).split("_")[0];
        var elem_id = (td_ref.attr('id')).split("_")[1];
        var new_elem_value = $("#clkpicker").val();

        change_config(index, elem_id, new_elem_value);
        //console.log(index);
        //console.log(elem_id);
      }
      });

    console.log($(this).text());
    console.log($(this).attr('id'));

    //$(this).text("AAA");
    td_ref = $(this);
    //console.log(event.pageX);
    var bodyOffsets = document.body.getBoundingClientRect();
    tempX = e.pageX - bodyOffsets.left - 23;
    tempY = e.pageY;

    //$("#clockpicker_div").css({'position':'absolute', 'top':tempY,'left':tempX})
    //$(".popover").css({'position':'absolute', 'top':tempY,'left':tempX})
    $("#clkpicker").clockpicker('show');
    $(".popover").css({'position':'absolute', 'top':tempY,'left':tempX})
    })


  });


  $.getScript("js/external/roundslider.js", function(data, textStatus, jqxhr) {
    $(document).on("click", "#configs_content > #configs_time_data_result > div > table > tbody > tr > td.value", function(e) {
      console.log("VALUE SLIDER");
      var bodyOffsets = document.body.getBoundingClientRect();
      tempX = e.pageX - bodyOffsets.left - 23;
      tempY = e.pageY;

      var this_value = $(this).text() + "%";
      $("#mod_slider_configs").roundSlider({value: this_value});

      if(parseInt($(this).text())<10)
        $(".rs-tooltip.edit, .rs-tooltip .rs-input").css("margin-left", "-17px");
      else
        $(".rs-tooltip.edit, .rs-tooltip .rs-input").css("margin-left", "-26px");

      $("#cfg_value_slider").css({'position':'absolute', 'top':tempY,'left':tempX, 'display': 'block'});
      //console.log($(this).attr('id'));
      //var change_id = $(this).attr('id').split("_")[0];
      td_ref = $(this);

    });
  });

}


function hhmmss_to_seconds(time) {
  var hours = time.split(":")[0];
  var min = time.split(":")[1];
  var sec = time.split(":")[2];
  return ((parseInt(hours)*3600)+(parseInt(min)*60)+parseInt(sec))
}


function change_config(index, elem_id, new_elem_value) {
  //console.log("CHANGE_CONFIG");
  //console.log("change_config - INDEX: "+index);
  //console.log("change_config - ELEM_ID: "+elem_id);
  //console.log("change_config - VAL: "+new_elem_value);
  //console.log("change_config - VAL(s): "+hhmmss_to_seconds(new_elem_value));
  var current_cfg = _current_config_list[parseInt(index)];
  console.log(current_cfg);

  if(elem_id == "start") {
    //console.log(_current_config_list[parseInt(index)][elem_id]);

    /*
    _current_config_list[parseInt(index)][elem_id+"_s"] = hhmmss_to_seconds(new_elem_value);
    _current_config_list[parseInt(index)][elem_id] = new_elem_value;
    _current_config_list[parseInt(index)].duration_s = _current_config_list[parseInt(index)].end_s - _current_config_list[parseInt(index)].start_s;
    _current_config_list[parseInt(index)].duration = (_current_config_list[parseInt(index)].duration_s).toString().toHHMMSS();
    */
    if(current_cfg.end_s == "N/A") {
      _current_config_list[parseInt(index)][elem_id+"_s"] = hhmmss_to_seconds(new_elem_value);
      _current_config_list[parseInt(index)][elem_id] = new_elem_value;
    }
    else if((current_cfg.end_s - hhmmss_to_seconds(new_elem_value)) < 1) {
      console.log("END-START < 1");
      Materialize.toast("START time can't be GREATER than END time", 4000);
    } else {
      _current_config_list[parseInt(index)][elem_id+"_s"] = hhmmss_to_seconds(new_elem_value);
      _current_config_list[parseInt(index)][elem_id] = new_elem_value;
      _current_config_list[parseInt(index)].duration_s = parseInt(_current_config_list[parseInt(index)].end_s) - parseInt(_current_config_list[parseInt(index)].start_s);
      _current_config_list[parseInt(index)].duration = (_current_config_list[parseInt(index)].duration_s).toString().toHHMMSS();
    }
  } else if (elem_id=="end") {
    if(current_cfg.start_s == "N/A") {
      _current_config_list[parseInt(index)][elem_id+"_s"] = hhmmss_to_seconds(new_elem_value);
      _current_config_list[parseInt(index)][elem_id] = new_elem_value;
    } else if((hhmmss_to_seconds(new_elem_value) - current_cfg.start_s) < 1) {
      console.log("END-START < 1");
      Materialize.toast("START time can't be GREATER than END time", 4000);
    } else {
      _current_config_list[parseInt(index)][elem_id+"_s"] = hhmmss_to_seconds(new_elem_value);
      _current_config_list[parseInt(index)][elem_id] = new_elem_value;
      _current_config_list[parseInt(index)].duration_s = parseInt(_current_config_list[parseInt(index)].end_s) - parseInt(_current_config_list[parseInt(index)].start_s);
      _current_config_list[parseInt(index)].duration = (_current_config_list[parseInt(index)].duration_s).toString().toHHMMSS();
    }

  } else if (elem_id == "duration") {
    if(current_cfg.start_s == "N/A") {
      _current_config_list[parseInt(index)][elem_id+"_s"] = hhmmss_to_seconds(new_elem_value);
      _current_config_list[parseInt(index)][elem_id] = new_elem_value;
    } else {
      _current_config_list[parseInt(index)].end_s = parseInt(_current_config_list[parseInt(index)].start_s) + hhmmss_to_seconds(new_elem_value);
      _current_config_list[parseInt(index)][elem_id+"_s"] = hhmmss_to_seconds(new_elem_value);
      _current_config_list[parseInt(index)][elem_id] = new_elem_value;

      if(_current_config_list[parseInt(index)].end_s > 86399) {
        _current_config_list[parseInt(index)].end_s = 86399;
        _current_config_list[parseInt(index)].duration_s = parseInt(_current_config_list[parseInt(index)].end_s) - parseInt(_current_config_list[parseInt(index)].start_s);
        _current_config_list[parseInt(index)].duration = (_current_config_list[parseInt(index)].duration_s).toString().toHHMMSS();
      }

      _current_config_list[parseInt(index)].end = _current_config_list[parseInt(index)].end_s.toString().toHHMMSS();
    }
  }

  //_current_config_list.sort(compare_start_times);
render_config();


  //_current_config_list.push(new_time);
  //_current_config_list.sort(compare_start_times);
  console.log("/CHANGE_CONFIG");
}


String.prototype.toHHMMSS = function () {
    var sec_num = parseInt(this, 10); // don't forget the second param
    var hours   = Math.floor(sec_num / 3600);
    var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
    var seconds = sec_num - (hours * 3600) - (minutes * 60);

    if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    if (seconds < 10) {seconds = "0"+seconds;}
    return hours+':'+minutes+':'+seconds;
}


function refresh_config(fade=true, saving=0) {
  get_configs_ajax(parseInt(_current_config_driver), function(result) {
    _current_config_list = [];
    console.log(result);
    if(!result || "error" in result) {
      $("#"+_TEMPLATES.drivers.target).fadeOut(300, function() {
        //dom_render_template(_TEMPLATES.configs, {}, function() {});
        render_config(fd=fade, saving=saving);
      });

      //Init tooltips
      $('.tooltipped').velocity("stop");
      $('.tooltipped').tooltip('remove');
      $('.tooltipped').tooltip({delay: 30});

    } else {
      $.each(result, function(i, cfg) {
        _current_config_list.push({
          id: cfg.id,
          start: cfg.start.toHHMMSS(),
          start_s: cfg.start,
          end: cfg.end.toHHMMSS(),
          end_s: cfg.end,
          duration: (cfg.end - cfg.start).toString().toHHMMSS(),
          duration_s: (cfg.end - cfg.start).toString(),
          value: cfg.value,
          enabled: cfg.enabled,
          indb: true
        });
      });
      _current_config_list.sort(compare_start_times);

      $("#"+_TEMPLATES.drivers.target).fadeOut(300, function() { render_config(fd=fade, saving=saving); });

    }

    //Init tooltips
    $('.tooltipped').velocity("stop");
    $('.tooltipped').tooltip('remove');
    $('.tooltipped').tooltip({delay: 30});

  });
}


function open_edit_config() {
  //console.log("CURRENT CONFIG DRIVER: "+_current_config_driver);
  //console.log(_drivers_selected[0]);
  if(_drivers_selected.length == 0)
    Materialize.toast('Please SELECT at least one driver', 3000);
  else {
    _current_config_driver = parseInt(_drivers_selected[0]).toString();
    refresh_config();
  }
}



function action_configs_time_new() {
  /*
  var last_cfg = _current_config_list.slice(-1)[0];
  console.log(last_cfg);
  var new_time = {
    id: _current_config_driver,
    start: last_cfg.end_s.toHHMMSS(),
    start_s: last_cfg.end_s,
    end: (parseInt(last_cfg.end_s)+1).toString().toHHMMSS(),
    end_s: (parseInt(last_cfg.end_s)+1).toString(),
    duration: (parseInt(last_cfg.end_s)+1 - last_cfg.end_s).toString().toHHMMSS(),
    duration_s: (parseInt(last_cfg.end_s)+1 - last_cfg.end_s).toString(),
    value: 0,
    enabled: 1
  };
  */

  var new_time = {
    id: _current_config_driver,
    start: "--:--:--",
    start_s: "N/A",
    end: "--:--:--",
    end_s: "N/A",
    duration: "--:--:--",
    duration_s: "N/A",
    value: 0,
    enabled: 1
  };

_current_config_list.push(new_time);
//_current_config_list.sort(compare_start_times);

render_config();

//console.log("NEW");
//console.log(new_time);
//console.log(_current_config_list.slice(-1)[0])

//console.log(_current_config_list.sort(compare_start_times));
}


function delete_config() {
  console.log("DELETE CFG");
  $('.tooltipped').velocity("stop");
  $('.tooltipped').tooltip('remove');
  //console.log($(this).attr('id'));
  var delete_id = ($(this).attr('id')).split("_")[2];
  //console.log(delete_id);
  _current_config_list.splice(delete_id, 1);

render_config()

}

function disable_enable_config() {
  console.log("DISABLE CONFIG");
  console.log($(this).attr('id'));
  $('.tooltipped').velocity("stop");
  $('.tooltipped').tooltip('remove');

  var disable_id = ($(this).attr('id')).split("_")[3];
console.log("ENABLED: "+_current_config_list[disable_id].enabled);


  if(_current_config_list[disable_id].enabled == 0) {
    _current_config_list[disable_id].enabled = 1;
  } else {
    _current_config_list[disable_id].enabled = 0;
  }

console.log("ENABLED: "+_current_config_list[disable_id].enabled);


render_config();

  console.log(disable_id);
}

function close_edit_config() {
  $("#header_title").html(_TEMPLATES.drivers.title.replace(">", "<i class='material-icons' style='display: initial; font-size: initial;'>chevron_right</i>"));
  $("#"+_TEMPLATES.configs.target).fadeOut(300, function() {
      //$("#header_title").text(_TEMPLATES.drivers.title);
      $("#"+_TEMPLATES.drivers.target).fadeIn(300);
  });

}


function no_config_overlaps() {
  console.log("CHECK OVERLAPS");
  console.log(_current_config_list);
  var no_overlaps = true;
  _current_config_list.sort(compare_start_times);
  for(i=1; i< _current_config_list.length; i++) {
    if(_current_config_list[i].enabled=="0" || _current_config_list[i-1].enabled=="0" ) {
        continue;
    }

    if(isNaN(_current_config_list[i].start_s) || isNaN(_current_config_list[i].end_s)) {
      _current_config_list.splice(i,1);
      continue;
    }

    if(isNaN(_current_config_list[i-1].start_s) || isNaN(_current_config_list[i-1].end_s)) {
      _current_config_list.splice(i-1,1);
      continue;
    }

    if(parseInt(_current_config_list[i].start_s) < parseInt(_current_config_list[i-1].end_s)) {
      no_overlaps = false;
      _current_config_list[i].overlap = true;
      _current_config_list[i-1].overlap = true;
      console.log(_current_config_list[i].overlap);
    //  _current_config_list[i].value = "0";
  //    _current_config_list[i-1].value = "0";

      //console.log("OVERLAP DETECTED");
      //console.log(_current_config_list[i]);
      //console.log(_current_config_list[i-1]);
      //console.log("/OVERLAP DETECTED");
    } else {
      //_current_config_list[i].overlap = false;
      //_current_config_list[i-1].overlap = false;
    }
  }
  //$.each(_current_config_list, function(i, cfg) {
  //});
  console.log("/CHECK OVERLAPS");
  console.log(_current_config_list);
  return no_overlaps;
}


function save_config() {
  //console.log("SAVE CONFIG");
  //save_config_ajax();
  console.log("SAVE CONFIG");
  console.log(no_config_overlaps());
/*
  $.each(_current_config_list, function(i, cfg) {
     var cfg = {
       id: cfg.id,
       group_id: _current_group,
       start: cfg.start_s,
       end: cfg.end_s,
       value: cfg.value,
       enabled: cfg.enabled
     }

     });
*/




if(no_config_overlaps())
{
  render_config(fd=false, saving="1");
  //Init tooltips
  $('.tooltipped').velocity("stop");
  $('.tooltipped').tooltip('remove');
  $('.tooltipped').tooltip({delay: 30});

  delete_config_ajax(function(result, textStatus) {
    console.log(result);
    console.log(textStatus);
    //refresh_config(fade=false);
    var success_count = 0;
    var error_count = 0;
    var nan_count = 0;

    if(_current_config_list.length == 0) {
      Materialize.toast('Config SAVED successfully', 3000);
      refresh_config(fd=false, saving="0");
    }



    $.each(_current_config_list, function(i, cfg) {
      if(isNaN(cfg.start_s) || isNaN(cfg.end_s)) {
        nan_count += 1;
        console.log("NAN!");
        return true; // continue equivalent
      }

       var cfg = {
         id: cfg.id,
         group_id: _current_group,
         start: cfg.start_s,
         end: cfg.end_s,
         value: cfg.value,
         enabled: cfg.enabled
       };

       create_config_ajax(cfg, function(result, textStatus) {
         console.log(cfg);
         console.log(textStatus);
         console.log(_current_config_list.length);
         console.log(success_count+error_count+nan_count);
         if(textStatus=="success") {
          success_count += 1;
        } else {
          error_count +=1;
        }
        if((success_count+error_count+nan_count)==_current_config_list.length) {
          refresh_config(fade=false);
          generate_csv();
          if(error_count > 0) {
            Materialize.toast('ERROR saving config', 3000);
          } else {
            Materialize.toast('Config SAVED successfully', 3000);
          }
        }

       });

       });


//    create_config_ajax({id:"1", group_id:"1", start:"1", end:"2", value:"55", enabled:"1"}, function(result, textStatus){
//      console.log(result);
//    });
  });
} else {
  render_config(fd=false);
  //Init tooltips
  $('.tooltipped').velocity("stop");
  $('.tooltipped').tooltip('remove');
  $('.tooltipped').tooltip({delay: 30});

  Materialize.toast('OVERLAP detected, config not saved! (Check highlighted rows)', 5000);
}
  console.log("/SAVE CONFIG");
}


function import_config_modal() {
  console.log("IMPORT CONFIG MODAL");
  get_config_csv_list(function(result, textStatus) {
    console.log(result);
    var res = result.split(",");
    console.log(res);

    var html_string_csv = "";
    for (var i = 0; i < res.length; i++) {
      html_string_csv += "<a class='collection-item config_item_csv_file'>"+res[i]+"</a>";
    }

    $("#modal3 > .modal-content > .collection").html(html_string_csv);

    modal_import_csv_open();
    //var arr = $.map(result, function(el) { return el });
    //console.log(arr);
  //  $.each(result, function(i, csv_file) {
  //     console.log(csv_file);
  //   });
  });
  console.log("/IMPORT MODAL");
}

function import_config() {
  console.log(this.text);
  $("#modal3").closeModal();
  get_confg_csv_content(this.text, function(result, textStatus) {
    if("error" in JSON.parse(result)) {
      console.log("error importing csv: " + JSON.parse(result)["error"]);
      Materialize.toast(JSON.parse(result)["error"], 5000);
    } else {
      console.log(result);
      _current_config_list = [];
      $.each(JSON.parse(result), function(i, cfg) {
        console.log(cfg);
        //console.log(cfg.start.toHHMMSS());

        _current_config_list.push({
          id: _current_config_driver,
          start: cfg.start.toHHMMSS(),
          start_s: cfg.start,
          end: cfg.end.toHHMMSS(),
          end_s: cfg.end,
          duration: (cfg.end - cfg.start).toString().toHHMMSS(),
          duration_s: (cfg.end - cfg.start).toString(),
          value: cfg.value,
          enabled: cfg.enabled,
          indb: true
        });


      });


      _current_config_list.sort(compare_start_times);

      $('.tooltipped').velocity("stop");
      $('.tooltipped').tooltip('remove');
      $('.tooltipped').tooltip({delay: 0});

      $("#"+_TEMPLATES.drivers.target).fadeOut(300, function() { render_config(fd=false, saving=false); });
      Materialize.toast("CSV imported successfully", 3000);
    }


    /*
    $.each(result, function(i, cfg) {
      _current_config_list.push({
        id: cfg.id,
        start: cfg.start.toHHMMSS(),
        start_s: cfg.start,
        end: cfg.end.toHHMMSS(),
        end_s: cfg.end,
        duration: (cfg.end - cfg.start).toString().toHHMMSS(),
        duration_s: (cfg.end - cfg.start).toString(),
        value: cfg.value,
        enabled: cfg.enabled,
        indb: true
      });
    });
    _current_config_list.sort(compare_start_times);

    $("#"+_TEMPLATES.drivers.target).fadeOut(300, function() { render_config(fd=fade, saving=saving); });
*/

  });
}


function bind_click_events_configs() {
  $('#edit_config').click(open_edit_config);

  $("#configs_content").on('click', '#save_config_btn', save_config);
  $("#configs_content").on('click', '#import_config_btn', import_config_modal);
  $("#configs_content").on('click', '#configs_back_btn', close_edit_config);
  $("#configs_content").on('click', '#create_config_time_btn', action_configs_time_new);
  $("#configs_content").on('click', '[id^=delete_cfg_]', delete_config);
  $("#configs_content").on('click', '[id^=disable_enable_cfg_]', disable_enable_config);
  //$("#configs_content").on('click', '#cfg_import_csv_modal_div > #modal3 > .modal-content > .config_item_csv_file', import_config);
  $("#configs_content").on('click', '#cfg_import_csv_modal_div > #modal3 > .modal-content > .collection > .config_item_csv_file', import_config);

}

function get_configs_ajax(drv, callback) {
  $.ajax({
     type: "GET",
     //url:'api/configs/id/'+drv,
     url:'api/configs/'+drv+'/group_id/'+_current_group,
     success: function(result) { callback(result) }
  });
}

function delete_config_ajax(callback) {
  //var _current_group = 1;
  //var _current_config_list = [];
  //var _current_config_driver = "1";
  //var test_data = { "abc": {"test": "1"} };
  $.ajax({
     type: "DELETE",
     //data: test_data,
     url:'api/configs/'+_current_config_driver+"/group_id/"+_current_group,
     success: function(result, textStatus) { callback(result, textStatus) }
  });
}

function create_config_ajax(config_data, callback) {
  create_driver(_current_config_driver, 0, function(){});
  $.ajax({
     type: "POST",
     data: config_data,
     url:'api/configs/',
     success: function(result, textStatus) { callback(result, textStatus); }
  });
}

function generate_csv() {
  //generate CSV file
  $.ajax({
     type: "POST",
     data: {id: _current_config_driver, module: _current_group},
     url:'php/generate_csv.php',
     success: function(result, textStatus) { console.log("GENERATE CSV: "+textStatus); console.log(result); }
  });
}

function get_config_csv_list(callback) {
  $.ajax({
     type: "POST",
     //data: {id: _current_config_driver, module: _current_group},
     url:'php/get_csv_list.php',
     success: function(result, textStatus) { callback(result, textStatus); }
  });
}

function get_confg_csv_content(file_string, callback) {
  $.ajax({
     type: "POST",
     data: {file: file_string},
     url:'php/read_csv.php',
     success: function(result, textStatus) { callback(result, textStatus); }
  });
}
