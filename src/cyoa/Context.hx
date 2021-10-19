package cyoa;

class MultipleChoiceEntry {
	public var run = 0;
	// TODO (DK) just use an Array<Int> instead (index == run)?
	public var selection: Map<Int, Int> = []; // <run, answer>

	public function new() {
	}
}

class Context {
	public var root_key: String;
	public var current_key: String;
	public var saved_key: Null<String>;

	public final state: Map<String, String> = [];
	public final choice_results: Map<String, MultipleChoiceEntry> = [];

	public final indices: Map<String, Int> = [];
	public final node_status: Map<String, NodeStatus> = [];

	public function new() {
	}
}
