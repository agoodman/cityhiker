// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var CityHiker = {};
CityHiker.init = function() {
	console.log("CityHiker.init");
	CityHiker.gridRequests = [];
	CityHiker.segments = [];
    google.maps.event.addDomListener(window, 'load', CityHiker.initMap);
};
CityHiker.initMap = function() {
	console.log("CityHiker.initMap");
	var mapOptions = {
		center: new google.maps.LatLng(37.795,-122.415),
		zoom: 14
	};
	CityHiker.map = new google.maps.Map(document.getElementById('mapPanel'), mapOptions);
	google.maps.event.addListener(CityHiker.map, 'mouseup', CityHiker.refreshMap);
	google.maps.event.addListener(CityHiker.map, 'zoom_changed', CityHiker.refreshMap);
	$(document).keyup(function(event) {
		if( event.which == 82 ) {
			CityHiker.createGridRequests();
		}
	});
};
CityHiker.nearest = function(val) {
	return val - (val % 5);
};
CityHiker.gradeColor = function(grade) {
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
CityHiker.refreshMap = function() {
	CityHiker.loadSegments();
};
CityHiker.createGridRequests = function() {
	var bounds = CityHiker.map.getBounds();
	var ne = bounds.getNorthEast();
	var sw = bounds.getSouthWest();
	console.log("CityHiker.refreshMap("+sw.lat()+","+sw.lng()+","+ne.lat()+","+ne.lng()+")");
	var minlat = CityHiker.nearest(Math.floor(sw.lat() * 1e3)) * 100;
	var minlng = CityHiker.nearest(Math.floor(sw.lng() * 1e3)) * 100;
	var maxlat = CityHiker.nearest(Math.floor(ne.lat() * 1e3)) * 100;
	var maxlng = CityHiker.nearest(Math.floor(ne.lng() * 1e3)) * 100;
	var gridh = (maxlat - minlat) / 500;
	var gridw = (maxlng - minlng) / 500;
	console.log("grid: "+minlat+","+minlng+" - "+maxlat+","+maxlng+" ("+gridw+","+gridh+")");
	if( CityHiker.overlays && CityHiker.overlays.length>0 ) {
		for (var k=0;k<CityHiker.overlays.length;k++) {
			CityHiker.overlays[k].setMap(null);
		}
	}
	CityHiker.overlays = [];
	for (var i=0;i<gridw;i++) {
		for (var j=0;j<gridh;j++) {
			var rect = new google.maps.Rectangle({
				strokeOpacity: 0,
				fillColor: '#ff0000',
				fillOpacity: 0.25,
				map: CityHiker.map,
				bounds: new google.maps.LatLngBounds(
					new google.maps.LatLng((minlat+j*500)/1e5, (minlng+i*500)/1e5),
					new google.maps.LatLng((minlat+(j+1)*500)/1e5, (minlng+(i+1)*500)/1e5)
				)
			});
			CityHiker.overlays.push(rect);
			$.ajax({
				url: "/grid_requests.json",
				type: "POST",
				data: {
					min_lat: minlat + j*500,
					min_lng: minlng + i*500,
					max_lat: minlat + (j+1)*500,
					max_lng: minlng + (i+1)*500
				},
				success: function(xhr,msg,data) {
					console.log("created grid request: "+JSON.stringify(data));
				}
			})
		}
	}
};
CityHiker.loadSegments = function() {
	var bounds = CityHiker.map.getBounds();
	var ne = bounds.getNorthEast();
	var sw = bounds.getSouthWest();
	for (var k=0;k<CityHiker.segments.length;k++) {
		CityHiker.segments[k].setMap(null);
	}
	CityHiker.segments = [];
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
					strokeColor: CityHiker.gradeColor(segments[k].percent_grade),
					strokeWeight: 4
				});
				line.setMap(CityHiker.map);
				CityHiker.segments.push(line);
			}
		}
	});
};
$(CityHiker.init);
