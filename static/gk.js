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

function append_plant(parent, plant) {
	console.log(plant);

	var p = document.createElement("li");
	p.classList.add("plant");

	var l = document.createElement("ul");

	var t = document.createElement("li");
	t.classList.add("name");
	t.innerHTML = plant["name"];
	l.appendChild(t);

	t = document.createElement("li");
	t.classList.add("type");
	t.innerHTML = plant["type"];
	l.appendChild(t);

	t = document.createElement("li");
	t.classList.add("moisture");
	t.classList.add(plant["moisture"]["state"]);
	t.innerHTML = plant["moisture"]["raw"];
	t.title = plant["moisture"]["state"];
	l.appendChild(t);

	t = document.createElement("li");
	t.classList.add("temperature");
	t.classList.add(plant["temperature"]["state"]);
	t.innerHTML = plant["temperature"]["raw"];
	t.title = plant["temperature"]["state"];
	l.appendChild(t);

	p.appendChild(l);
	parent.appendChild(p);
}

window.onload = function () {
	var tstamp = 0;
	function update() {
		JHR_GET("/plants", function (data) {
			if (data["tstamp"] == tstamp) {
				return;
			}
			tstamp = data["tstamp"];
			var x = document.getElementById("plants");
			x.innerHTML = "";
			plants = data["plants"];
			for (p in plants) {
				if (!plants.hasOwnProperty(p))
					continue;
				append_plant(x, plants[p]);
			}
		})
	}

	update();
	window.setInterval(update, 5000);
}
