package cyoa;

typedef MultipleChoiceAnswer<T> = {
	// TODO (DK) add like a counter or something so choices might can optionally be hidden when they were already selected?
	final line: String;
	final ?format: String;
	final next: Node<T>;
}

enum Node<T> {
	/**
	 * A sequence of nodes. It's stateful and keeps track of `Running` children.
	 * Stops iteration and fails as soon as the first child fails; succeeds when all children succeed.
	 */
	Sequence( nodes: Array<Node<T>> );

	/**
	 * A selector. It's stateful and keeps track of `Running` children.
	 * Stops iteration as soon as the first child succeeds; fails when all children fail.
	 */
	Selector( nodes: Array<Node<T>> );

	/**
	 * Succeeds when RNG roll is equal or less than `probability`
	 * @param probability - in the range of 0.0 ... 1.0
	 */
	// Chance( probability: Float );

	// SetCounter( key: String, value: Float );
	// AddCounter( key: String, value: Float );
	// MatchCounter( key: String, op: CounterOp, value: Float );

	/**
	 * Store a state variable.
	 */
	SetVariable( key: String, value: String );

	/**
	 * Test if a stored variable matches `value`.
	 */
	CompareVariable( key: String, value: String );

	/**
	 * Test if a variable `key` exists.
	 */
	HasVariable( key: String );

	/**
	 * Print lines of text.
	 * @param format - will be fed into haxeui's `styleNames` for the label
	 */
	Narrate( text: String, ?format: String );

	/**
	 * Present multiple choices to the reader.
	 */
	MultipleChoice( key: String, choices: Array<MultipleChoiceAnswer<T>> );

	/**
	 * Was option `choice` selected?
	 */
	Chose( key: String, choice: Int );

	/**
	 * Goto another node identified by `key`.
	 */
	Goto( key: String );

	/**
	 * Finish the story.
	 */
	End;

	/**
	 * Allow customization.
	 */
	Custom( node: T );
}
