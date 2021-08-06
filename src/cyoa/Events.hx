package cyoa;

class Event {
	public final type: String;

	function new( type: String ) {
		this.type = type;
	}
}

class NarrationEvent extends Event {
	public static inline final Id = 'narration-event';

	public var text: String;
	public var format: Null<String>;

	public function new() {
		super(Id);
	}
}

@:structInit
class MultipleChoiceItem {
	public var index: Int;
	public var text: String;
	public var format: Null<String>;
}

class MultipleChoiceEvent extends Event {
	public static inline final Id = 'multiple-choice-event';

	public var key: String;
	public var items: Array<MultipleChoiceItem> = [];

	public function new() {
		super(Id);
	}
}
