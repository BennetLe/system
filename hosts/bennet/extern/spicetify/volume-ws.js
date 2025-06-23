(function WebsocketVolumeControl() {
	if (!Spicetify?.Player?.setVolume) {
    	setTimeout(websocketVolumeControl, 1000);
    	return;
  	}
	const ws = new WebSocket("ws://localhost:8765");

	ws.onopen = () => {
		console.log("[Spicetify WS] Connected to server");
	};

	ws.onmessage = (event) => {
		try {
			const data = JSON.parse(event.data);
			if (data.action == "volume-up") {
				Spicetify.Player.increaseVolume()
			} else if(data.action == "volume-down") {
				Spicetify.Player.decreaseVolume()
			}
		} catch(err) {
			console.error("[Spicetify WS] Error parsing message", err);
		}
	}

	ws.onerror = (err) => {
		console.error("[Spicetify WS] Error", err);
	}
})();
