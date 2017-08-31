var _DRIVER_COUNT_PAGE = 16;
//var _MODULE_GROUPS = ["01 - 10", "11 - 20", "21 - 30", "31 - 40", "41 - 50", "51 - 60", "61 - 62"]; 
// erroneous approach, i can't see module greater than 55 (i2c addresses greater than 0x77)
//var _MODULE_GROUPS = ["01 - 04"]; //initial release
var _MODULE_GROUPS = ["01 - 10", "11 - 20", "21 - 30", "31 - 40", "41 - 50", "51 - 55"]; // final release

var _TEMPLATES = {
  drivers: { title: "SELECT driver(s)", file: "template/drivers/drivers.tmpl", target: "drivers_content" },
  drv_module_select: {title: null, file: "template/drivers/modals/module_select.tmpl", target: "drv_module_select"},
  drv_value: {title: null, file: "template/drivers/modals/change_driver_value.tmpl", target: "drv_value"},
  drv_status: {title: null, file: "template/drivers/modals/update_status.tmpl", target: "drv_status"},
  configs: {title: "CONFIG driver(s)", file: "template/configs/configs.tmpl", target: "configs_content"},
  cfg_import_csv_modal: {title: null, file: "template/configs/modals/import_csv.tmpl", target: "cfg_import_csv_modal_div"}
}

var _drivers = [];
var _drivers_selected = [];
var _current_group = 1;

var _current_config_list = [];
var _current_config_driver = "1";


$( document ).ready(function()
{
  init_drivers();
  setInterval(update_drivers, 2000);
});
