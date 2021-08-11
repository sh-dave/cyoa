package cyoa;

class MultipleChoiceEntry {
	public var run = 0;
	// TODO (DK) just use an Array<Int> instead (index == run)?
	public var selection: Map<Int, Int> = []; // <run, answer>

	public function new() {
	}
}

class Context {
	public var rootKey: String;
	public var currentKey: String;

	public final state: Map<String, String> = [];
	public final choice_results: Map<String, MultipleChoiceEntry> = [];

	public final indices: Map<String, Int> = [];
	public final node_status: Map<String, NodeStatus> = [];

	public function new() {
	}
}
