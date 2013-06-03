var Map = function (id, latitude, longitude) {
  this._map_canvas = new google.maps.Map(document.getElementById(id), {
      center: new google.maps.LatLng(latitude, longitude),
      zoom: 14,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      scaleControl: true,
      scrollwheel: false
    });

  this._markers = {};
}

Map.prototype.create_marker = function (options) {
    var info_window = new google.maps.InfoWindow({
        content: options.window_text
      });
    delete options.window_text;

    var iw_opened = false;

    var marker = new google.maps.Marker(options);
    marker.open_info_window = function () {
        info_window.open(marker.getMap(), marker);
        iw_opened = true;
      }
    marker.close_info_window = function () {
        info_window.close();
        iw_opened = false;
      }

    google.maps.event.addListener(marker, 'click', function (event) {
      if (iw_opened) {
        marker.close_info_window();
      } else {
        marker.open_info_window();
      }
    });

    return marker;
  }

Map.prototype.set_marker = function (id, latitude, longitude, title, window_text) {
    this._markers[id] = this.create_marker({
        position: new google.maps.LatLng(latitude, longitude),
        title: title,
//        icon: 'http://chart.googleapis.com/chart?chst=d_map_pin_icon_withshadow&chld=info|ff9999',
        map: this._map_canvas,
        animation: google.maps.Animation.DROP,
        window_text: window_text
      });
  }

Map.prototype.move_to = function (id) {
    for (var m in this._markers) { this._markers[m].close_info_window(); }

    var destination = this._markers[id];
    if (destination) {
      this._map_canvas.panTo(destination.position);
      destination.open_info_window();
    }
  }
