package cyoa;

enum NodeStatus {
	/**
	 * The node failed.
	 */
	Failure;

	/**
	 * The node is running (it may be waiting for input).
	 */
	Running;

	/**
	 * The node completed successfully.
	 */
	Success;
}
