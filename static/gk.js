function JHR_GET (url, fun) {
	var xhr = new XMLHttpRequest();
	xhr.responseJSON = null;
	xhr.onreadystatechange = function () {
		if (xhr.readyState != 4)
			return;
		xhr.responseJSON = JSON.parse(xhr.responseText);
		fun(xhr.responseJSON);
	}
	xhr.open("GET", url, true);
	xhr.setRequestHeader('Accept', 'application/json');
	xhr.send();
	return xhr;
}

function append_plant(l, plant) {
	var item = document.createElement("li");
	item.innerHTML = plant["name"];
	console.log(plant);
	l.appendChild(item);
}

function gk_init() {
	var x = document.getElementById("plants");

	console.log("init");

	JHR_GET("/plants", function (data) {
		x.innerHTML = "";
		for (p in data) {
			if (!data.hasOwnProperty(p))
				continue;
			append_plant(x, data[p]);
		}
	})
}
