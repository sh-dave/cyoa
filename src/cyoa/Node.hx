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
	 *
	 * example:
	 *
	 * Sequence([
	 * 		Narrate("Wall of text."),
	 * 		Narrate("Even more wall of text."),
	 * 		Sequence([
	 * 			Narrate("Nested, but quite useless"),
	 * 		]),
	 * 		Goto(""),
	 * ])
	 */
	Sequence( nodes: Array<Node<T>> );

	/**
	 * A selector. It's stateful and keeps track of `Running` children.
	 * Stops iteration as soon as the first child succeeds; fails when all children fail.
	 *
	 * example:
	 *
	 * Selector([
	 * 		Sequence([HasVariable("test1"), Goto("passage-test1")]),
	 * 		Sequence([CompareVariable("test2", "5"), Goto("passage-test2-mode5")]),
	 * 		Goto("passage-untested"),
	 * ])
	 */
	 Selector( nodes: Array<Node<T>> );

	/**
	 * Store a state variable.
	 */
	SetVariable( key: String, value: String );

	/**
	 * Test if a variable matches `value`.
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
	 * Present multiple choices.
	 */
	MultipleChoice( key: String, choices: Array<MultipleChoiceAnswer<T>> );

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

	/**
	 * Was option `choice` during `run` selected?
	 */
	Internal_Chose( key: String, run: Int, choice: Int );
}
