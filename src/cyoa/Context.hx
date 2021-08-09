package cyoa;

class Context {
	public var log: String -> Void;

	public final state: Map<String, String> = [];
	// TODO (DK) remove the Option, use -1?
	//	also make it an Map<String, Array<Int>> so we can query the number of times a choice was selected?
	public final choice_results: Map<String, haxe.ds.Option<Int>> = [];

	public final indices: Map<String, Int> = [];
	public final node_status: Map<String, NodeStatus> = [];

	public function new( log: String -> Void ) {
		this.log = log;
	}

	public function clear() {
		state.clear();
		choice_results.clear();
		indices.clear();
		node_status.clear();
	}
}
