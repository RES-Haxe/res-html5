package res.bios.html5;

import haxe.Json;
import js.Browser;

class Storage extends res.storage.Storage {
	static final LS_KEY:String = 'res_storage';

	override public function save() {
		Browser.getLocalStorage().setItem(LS_KEY, Json.stringify(data));
	}

	override public function restore() {
		final s_data = Browser.getLocalStorage().getItem(LS_KEY);
		if (s_data != null)
			data = Json.parse(s_data);
	}
}
