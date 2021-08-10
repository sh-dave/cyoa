package cyoa;

import haxe.ds.Option;

class Context {
	public var currentKey: String;

	public final state: Map<String, String> = [];
	// TODO (DK) remove the Option, use -1?
	//	also make it an Map<String, Array<Int>> so we can query the number of times a choice was selected?
	public final choice_results: Map<String, haxe.ds.Option<Int>> = [];

	public final indices: Map<String, Int> = [];
	public final node_status: Map<String, NodeStatus> = [];

	public function new() {
	}

	public function selectChoice( key: String, value: Int ) {
		choice_results.set(key, Some(value));
	}

	public function suspend() {
		// node_status.clear();
		// indices.clear();

		final removable = [];

		for (id => r in choice_results) {
			if (r == None) {
				removable.push(id);
			}
		}

		for (r in removable) {
			choice_results.remove(r);
		}
	}

	public function clear() {
		currentKey = null;
		state.clear();
		choice_results.clear();
		indices.clear();
		node_status.clear();
	}
}
