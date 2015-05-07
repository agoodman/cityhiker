// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var base = {};
base.init = function() {
	console.log("base.init");
	base.gridRequests = {};
	base.gridRequestIds = [];
	base.overlays = {};
	base.segments = [];
	base.filterLevel = 0; // show everything
    google.maps.event.addDomListener(window, 'load', base.initMap);

	$('#button-plus').click(base.increaseFilterLevel);
	$('#button-minus').click(base.decreaseFilterLevel);
	$('#button-query').click(base.createGridRequests);
	base.updateFilterLevel();
};
base.initMap = function() {
	console.log("base.initMap");
	var mapOptions = {
		center: new google.maps.LatLng(37.795,-122.415),
		zoom: 14
	};
	base.map = new google.maps.Map(document.getElementById('mapPanel'), mapOptions);
	google.maps.event.addListener(base.map, 'mouseup', base.refreshMap);
	google.maps.event.addListener(base.map, 'zoom_changed', base.refreshMap);
};
base.nearest = function(val) {
	return val - (val % 5);
};
base.gradeColor = function(grade) {
	if( Math.abs(grade) < 2 ) {
		return "#00ff00";
	}else if( Math.abs(grade) < 10 ) {
		return "#ffff00";
	}else if( Math.abs(grade) < 20 ) {
		return "#ffaa00";
	}else{
		return "#ff0000";
	}
};
base.refreshMap = function() {
	base.loadSegments();
};
base.increaseFilterLevel = function() {
	base.filterLevel++;
	if( base.filterLevel>6 ) {
		base.filterLevel = 6;
	}
	base.updateFilterLevel();
	base.refreshMap();
};
base.decreaseFilterLevel = function() {
	base.filterLevel--;
	if( base.filterLevel<0 ) {
		base.filterLevel = 0;
	}
	base.updateFilterLevel();
	base.refreshMap();
};
base.updateFilterLevel = function() {
	var val;
	if( base.filterLevel==0 ) {
		val = "0%";
	}else{
		val = (base.filterLevel*5)+"%";
	}
	$('#filter-level').html(val);
};
base.createGridRequests = function() {
	var bounds = base.map.getBounds();
	var ne = bounds.getNorthEast();
	var sw = bounds.getSouthWest();
	console.log("CityHiker.refreshMap("+sw.lat()+","+sw.lng()+","+ne.lat()+","+ne.lng()+")");
	var minlat = base.nearest(Math.floor(sw.lat() * 1e3)) * 100;
	var minlng = base.nearest(Math.floor(sw.lng() * 1e3)) * 100;
	var maxlat = base.nearest(Math.floor(ne.lat() * 1e3)) * 100;
	var maxlng = base.nearest(Math.floor(ne.lng() * 1e3)) * 100;
	var gridh = (maxlat - minlat) / 500;
	var gridw = (maxlng - minlng) / 500;
	console.log("grid: "+minlat+","+minlng+" - "+maxlat+","+maxlng+" ("+gridw+","+gridh+")");
	for (var i=0;i<gridw;i++) {
		for (var j=0;j<gridh;j++) {
			$.ajax({
				async: false,
				url: "/grid_requests.json",
				type: "POST",
				data: {
					min_lat: minlat + j*500,
					min_lng: minlng + i*500,
					max_lat: minlat + (j+1)*500,
					max_lng: minlng + (i+1)*500
				},
				success: function(xhr,msg,data) {
					var raw = data.responseText;
					var req = JSON.parse(raw);
					if( req.completed_at == null ) {
						base.gridRequests[req.id] = req;
						base.gridRequestIds.push(req.id);
						console.log("created grid request: "+req.id);
					}
				}
			});
			base.startWatchingGridStatus();
		}
	}
};
base.startWatchingGridStatus = function() {
	if( !base.isWatching ) {
		console.log("CityHiker.startWatching");
		base.isWatching = true;
		base.checkGridStatus();
	}
};
base.stopWatchingGridStatus = function() {
	if( base.isWatching ) {
		console.log("CityHiker.stopWatching");
		base.isWatching = false;
	}
};
base.checkGridStatus = function() {
	$.ajax({
		async: false,
		url: "/grid_requests.json",
		success: function(xhr,msg,data) {
			var raw = data.responseText;
			var reqs = JSON.parse(raw);
			if( reqs.length == 0 ) {
				for (var k=0;k<base.gridRequestIds.length;k++) {
					var req = base.gridRequests[base.gridRequestIds[k]];
					req.completed_at = 1;
					base.updateGridOverlay(req);
				}
				base.stopWatchingGridStatus();
			}else{
				var pendingIds = [];
				for (var k=0;k<reqs.length;k++) {
					base.updateGridOverlay(reqs[k]);
					pendingIds.push(reqs[k].id);
				}
				var completedIds = [];
				for (var k=0;k<base.gridRequestIds.length;k++) {
					var found = false;
					for (var n=0;n<pendingIds.length;n++) {
						if( pendingIds[n] == base.gridRequestIds[k] ) {
							found = true;
							break;
						}
					}
					if( found == false ) {
						completedIds.push(base.gridRequestIds[k]);
					}
				}
				for (var k=0;k<completedIds.length;k++) {
					for (var n=0;n<base.gridRequestIds.length;n++) {
						if( base.gridRequestIds[n] == completedIds[k] ) {
							var req = base.gridRequests[base.gridRequestIds[n]];
							req.completed_at = 1;
							base.updateGridOverlay(req);
							base.gridRequestIds = base.gridRequestIds.splice(n, 1);
							break;
						}
					}
				}
				console.log("CityHiker.gridStatus: "+reqs.length);
				if( base.isWatching ) {
					setTimeout(base.checkGridStatus, 10000);
				}
			}
		}
	});
};
base.updateGridOverlay = function(req) {
	console.log("CityHiker.updateOverlay: "+JSON.stringify(req.id)+" completed at "+req.completed_at);
	if( req.completed_at == null ) {
		if( base.overlays[req.id] == null ) {
			var rect = new google.maps.Rectangle({
				strokeOpacity: 0,
				fillColor: '#ff0000',
				fillOpacity: 0.25,
				map: base.map,
				bounds: new google.maps.LatLngBounds(
					new google.maps.LatLng(req.min_lat/1e5, req.min_lng/1e5),
					new google.maps.LatLng(req.max_lat/1e5, req.max_lng/1e5)
				)
			});
			base.overlays[req.id] = rect;
		}
	}else{
		if( base.overlays[req.id] != null ) {
			base.overlays[req.id].setMap(null);
			base.overlays[req.id] = null;
		}
	}
};
base.loadSegments = function() {
	var bounds = base.map.getBounds();
	var ne = bounds.getNorthEast();
	var sw = bounds.getSouthWest();
	for (var k=0;k<base.segments.length;k++) {
		base.segments[k].setMap(null);
	}
	base.segments = [];
	$.ajax({
		url: "/road_segments.json",
		type: "GET",
		data: {
			where: {
				road_segments: {
					start_lat: {
						gt: sw.lat()
					},
					start_lng: {
						gt: sw.lng()
					},
					end_lat: {
						lt: ne.lat()
					},
					end_lng: {
						lt: ne.lng()
					},
					percent_grade: {
						gt: base.filterLevel * 5
					}
				}
			}
		},
		success: function(xhr,msg,data) {
			var segments = JSON.parse(data.responseText);
			console.log("msg: "+msg);
			console.log("raw data: "+segments.length+" segments");
			for (var k=0;k<segments.length;k++) {
				var line = new google.maps.Polyline({
					path: [
						new google.maps.LatLng(segments[k].start_lat, segments[k].start_lng),
						new google.maps.LatLng(segments[k].end_lat, segments[k].end_lng)
					],
					strokeColor: base.gradeColor(segments[k].percent_grade),
					strokeWeight: 4
				});
				line.setMap(base.map);
				base.segments.push(line);
			}
		}
	});
};
var CityHiker = base;
$(CityHiker.init);
