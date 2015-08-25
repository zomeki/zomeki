
  var myMap     = null;
  var markers = new Object();
  var marker_list = new Object();
  var navigationPath = null;
  var currentPosition= new Object();
  var currentMarker;
  var position_options = {
    enableHighAccuracy: true,
    timeout           : 27000,
    maximumAge  : 0
  };

  var positionIcon = new google.maps.MarkerImage(
                'http://maps.google.co.jp/mapfiles/ms/icons/red-dot.png',
                new google.maps.Size(32,32),
                new google.maps.Point(0,0),
                new google.maps.Point(16,32)
              );
  var defaultIcon = new google.maps.MarkerImage(
                'http://maps.google.co.jp/mapfiles/ms/icons/blue-dot.png',
                new google.maps.Size(32,32),
                new google.maps.Point(0,0),
                new google.maps.Point(16,32)
              );
  function renderMap(default_latitude, default_longitude, set_markers){
    if(window.navigator && window.navigator.geolocation){
      window.navigator.geolocation.watchPosition(function(pos) {
      if(myMap==null){
      marker_list = set_markers;
      var mapOptions = {
          center: new google.maps.LatLng(pos.coords.latitude,pos.coords.longitude),
          zoom: 15,
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          mapTypeControl: false,
          scaleControl: true,
          scrollwheel: true
        };
        myMap = new google.maps.Map(document.getElementById("canvas"), mapOptions);

        var currentPos = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
        currentPosition["lat"] = pos.coords.latitude;
        currentPosition["lng"] = pos.coords.longitude;
        myMap.panTo(currentPos);
        setMarker();
        }

        currentPosition["lat"] = pos.coords.latitude;
        currentPosition["lng"] = pos.coords.longitude;
        if(currentMarker){
          currentMarker.position = currentPos;
        }else{
          currentMarker = new google.maps.Marker({
            position: currentPos,
            icon: positionIcon
          });
          currentMarker.setMap(myMap);
        }
    }, function() {
      if(myMap==null){
          marker_list = set_markers;
          var mapOptions = {
              center: new google.maps.LatLng(default_latitude, default_longitude),
              zoom: 15,
              mapTypeId: google.maps.MapTypeId.ROADMAP,
              mapTypeControl: false,
              scaleControl: true,
              scrollwheel: true
            };
          myMap = new google.maps.Map(document.getElementById("canvas"), mapOptions);
          return false;
          var currentPos = new google.maps.LatLng(default_latitude, default_longitude);
          currentPosition["lat"] = default_latitude;
          currentPosition["lng"] = default_longitude;
          myMap.panTo(currentPos);
          setMarker();
        }
      },
      position_options
      );
    }else{
      marker_list = set_markers;
      var mapOptions = {
          center: new google.maps.LatLng(default_latitude, default_longitude),
          zoom: 15,
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          mapTypeControl: false,
          scaleControl: true,
          scrollwheel: true
        };
      myMap = new google.maps.Map(document.getElementById("canvas"), mapOptions);
      var currentPos = new google.maps.LatLng(default_latitude, default_longitude);
      myMap.panTo(currentPos);
      setMarker();
    }
  }

  function setMarker(){
    if(marker_list){

      for(key in marker_list){
      var options = {
        position: new google.maps.LatLng(marker_list[key]["lat"], marker_list[key]["lng"]),
        title: marker_list[key]["title"],
        map: myMap
      };
      if (marker_list[key]["icon_url"]) {
        options.icon = marker_list[key]["icon_url"];
      }else{
        options.icon = defaultIcon;
      }
        markers[key] = new google.maps.Marker(options);
        attachMarkerEvent(markers[key], marker_list[key]["item_id"]);
        markers[key].setMap(myMap);
      }
    }
  }

  function attachMarkerEvent(marker, marker_id){

    google.maps.event.addListener(marker, 'click', function() {
        new google.maps.Geocoder().geocode({
          latLng: marker.getPosition()
        }, function(result, status) {
          if (status == google.maps.GeocoderStatus.OK) {
          var infoContent = '<p>'+ marker_list[marker_id]["title"] +'</p>';
          if(window.navigator && window.navigator.geolocation){
            infoContent += '<a href="#'+ marker_id +  '" class="atmNavigation">ここまでのルート表示</a><br />';
          }
          if(marker_list[marker_id]["url"]){
            infoContent += '<a href="' + marker_list[marker_id]["url"] + '" target="_blank">詳細画面を表示</a>';
          }
            new google.maps.InfoWindow({
              content: infoContent,
              maxWidth: 200
            }).open(marker.getMap(), marker);
          }
        });
      });
  }


  function clickMarker(marker_id){
    if(markerWindows[marker_id]){
      //
    }else{

      markerWindows[marker_id] = new google.maps.InfoWindow({
        content: infoContent,
        positon: marker_list[marker_id]["marker"].getPosition()
      });
    }
    markerWindows[marker_id].open(myMap);
    document.body.style.cursor = 'default';
  }

  $(document).on("click", ".atmNavigation", function(e){
    e.preventDefault();
    var From = new google.maps.LatLng(currentPosition["lat"], currentPosition["lng"]);
    var To = markers[$(this).attr("href").replace(/#/,"")].getPosition();
    renderLines(From, To);
  });

  function renderLines(From, To) {
    new google.maps.DirectionsService().route({
      origin: From,
      destination: To,
      travelMode: google.maps.DirectionsTravelMode.WALKING
    }, function(result, status) {
      if (status == google.maps.DirectionsStatus.OK) {
          if(navigationPath){
            navigationPath.setMap(null);
          }
          var points = result.routes[0]["overview_path"];
          navigationPath = new google.maps.Polyline({
          path: points,
          strokeColor: "#FF0000",
          strokeOpacity: 0.7,
          strokeWeight: 5
        });
        navigationPath.setMap(myMap);
      }
    });
  }
