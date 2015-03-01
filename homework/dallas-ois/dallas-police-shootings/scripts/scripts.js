$(document).ready(function(){

	/***************
	MAP
	***************/
	
	// initialize map
	var map = L.map('map', {
		scrollWheelZoom: false
	}).setView([32.84, -96.8], 11);

	// add mapbox tile layer
	L.tileLayer('https://{s}.tiles.mapbox.com/v4/jeffbarrera.laeglbf9/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiamVmZmJhcnJlcmEiLCJhIjoiUG00VnlJSSJ9.gJojliOmZfmMlFDeEMRebw', {
    	attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
    	maxZoom: 18
	}).addTo(map);

	// function to add popup data
	function onEachFeature(feature, layer) {
	    // does this feature have a property named popupContent?
	    if (feature.properties && feature.properties.popupContent) {
	        layer.bindPopup(feature.properties.popupContent);
	    }
	}

	// read in incidents from geojson.js
	L.geoJson(incidents, {
	    onEachFeature: onEachFeature
	}).addTo(map);

	/***************
	Tables
	***************/

	//initialize sorter plugin
	$("#incidents table").tablesorter({sortList: [[1,1]]});
	$("#officers table").tablesorter({sortList: [[1,1]]}); 
	$("#suspects table").tablesorter({sortList: [[1,1]]});

	// show/hide details
	$('.details-panel').hide();
	$('a.details-link').click(function(event){
		event.preventDefault();
		var panelID = $(this).data("panelid");
		$("#" + panelID).toggle();
	});


 




});