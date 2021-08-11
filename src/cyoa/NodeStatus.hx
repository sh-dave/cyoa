package cyoa;

enum abstract NodeStatus(Int) {
	/**
	 * The node failed.
	 */
	final Failure;

	/**
	 * The node is running (it may be waiting for input).
	 */
	final Running;

	/**
	 * The node completed successfully.
	 */
	final Success;
}
