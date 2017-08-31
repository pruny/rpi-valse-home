// Read Only Pins
//read_only_pins = []
//read_only_pins = ["21","22"]
read_only_pins = ["0","2","3","4","5","6","21","22","23","24","25","26","27","28","29"]

//this function sends and receives the pin's status
function change_pin (pin, status) {
	//this is the http request
	var request = new XMLHttpRequest();
	request.open( "GET" , "gpio.php?pin=" + pin + "&status=" + status );
	request.send(null);
	//receiving information
	request.onreadystatechange = function () {
		if (request.readyState == 4 && request.status == 200) {
			return (parseInt(request.responseText));
		}
		//test if fail
		else if (request.readyState == 4 && request.status == 500) {
			alert ("server error");
			return ("fail");
		}
		//else 
		else { return ("fail"); }
	}
}

var container = document.querySelector("#container");
container.addEventListener("click", buttonManager, false);
 
function buttonManager(e) {
    if(e.target !== e.currentTarget && e.target.id == "toggle_btn") {
	button_array = document.getElementsByTagName("a");
	for(var i=0; i<button_array.length; i++) {
		if(button_array[i].id.substring(0,7) != "button_") continue;
		pin = button_array[i].id.substring(7,9)
		if(e.target.target === "off")
		{	
			// ignore read only pins			
			if(read_only_pins.indexOf(pin) !== -1) continue;
			if(i===button_array.length-2)
			{
	                        e.target.target = "on";
	                        e.target.className="btn_on";
	                        e.target.parentNode.getElementsByTagName("span")[0].id="light_green"
			}

            // high level  "1" is the "normal" (idle) state; low level "0" is the "abnormal" (switched) state
			var new_status = change_pin ( pin, 1);
			if (new_status !== "fail") {
				button_array[i].target = "on";
				button_array[i].className = "btn_on";
				button_array[i].parentNode.getElementsByTagName("span")[0].id="light_green"
			}
			continue;
		}

                if(e.target.target === "on")
                {	
			// ignore read only pins
			if(read_only_pins.indexOf(pin) !== -1) continue;
			if(i===button_array.length-2)
			{
	                        e.target.target = "off";
	                        e.target.className="btn_off";
	                        e.target.parentNode.getElementsByTagName("span")[0].id="light_red"
			}

                        // high level  "1" is the "normal" (idle) state; low level "0" is the "abnormal" (switched) state
                        var new_status = change_pin ( pin, 0);
                        if (new_status !== "fail") {
                                button_array[i].target = "off";
                                button_array[i].className = "btn_off";
                                button_array[i].parentNode.getElementsByTagName("span")[0].id="light_red"
                        }
			continue;
                }
		
	}
    }
    if (e.target !== e.currentTarget && e.target.id.substring(0,7) == "button_") {
	// ignore read only pins
	if(read_only_pins.indexOf(e.target.id.substring(7,9)) !== -1) return 0;

		// if red
		// high level  "1" is the "normal" (idle) state
        if ( e.target.target === "off" ) {
                var new_status = change_pin ( e.target.id.substring(7,9), 1);
                //new_status = "abcd";
                if (new_status !== "fail") {
                        e.target.target = "on";
                        e.target.className="btn_on";
                        e.target.parentNode.getElementsByTagName("span")[0].id="light_green"
                        return 0;
                        }
                }

		// if green
        // low level "0" is the "abnormal" (switched) state
        if ( e.target.target === "on" ) {
                var new_status = change_pin ( e.target.id.substring(7,9), 0);
                //new_status = "abcd";
                if (new_status !== "fail") {
                        e.target.target = "off"
                        e.target.className="btn_off";
                        e.target.parentNode.getElementsByTagName("span")[0].id="light_red"
                        return 0;
                        }
                }

    }
    e.stopPropagation();
}	
