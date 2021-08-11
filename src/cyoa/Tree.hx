package cyoa;

import haxe.ds.Option;
import cyoa.Context;
import cyoa.Events;

// TODO (DK) remove `CONTEXT`?
class Tree<NODE, CONTEXT: Context> {
	var nodes: Map<String, Node<NODE>>;
	var current: Node<NODE>;
	var nextRootKey: Option<String> = None;

	final listeners: Array<Event -> Void> = [];
	final logFn: String -> Void;
	final narrate_event = new NarrationEvent();
	final present_multiple_choice_event = new MultipleChoiceEvent();
	var _indent = 0;

	public function new( logFn ) {
		this.logFn = logFn;
	}

	/**
	 * Inject the node tree. It will jump to node set int `ctx.currentKey`.
	 */
	public function init( ctx: CONTEXT, nodes ) {
		this.nodes = nodes;
		this.current = nodes.get(ctx.currentKey);
		this.nextRootKey = None;
	}

	/**
	 * Run the logic.
	 */
	public function process( ctx: CONTEXT ) : NodeStatus {
		final r = eval(current, ctx, ctx.currentKey);

		switch nextRootKey {
			case None:
				return r;

			case Some(key):
				final next = nodes.get(key);
				ctx.currentKey = key;
				current = next;
				nextRootKey = None;
				ctx.indices.clear();
				ctx.node_status.clear();
				return process(ctx);
		}
	}

	/**
	 * Answer a multiple choice.
	 */
	public function answer( ctx: CONTEXT, key: String, answer: Int ) : NodeStatus {
		final entry = ctx.choice_results.get(key);

		if (entry != null) {
			entry.selection.set(entry.run, answer);
			return Success;// process(ctx);
		} else {
			log('[ERROR] answer for key=$key not found');
			return Failure;
		}
	}

	/**
	 * Suspends the story for serialization.
	 *
	 * You should new serialize the whole `ctx` object.
	 * To resume the story, deserialize the `ctx` object and just call `process()`.
	 * This will run the whole story and automatically reselect your choices until the point you stopped at. It will also emit all previous events again so your scene can be rebuilt.
	 */
	public function suspend( ctx: CONTEXT ) {
		ctx.node_status.clear();
		ctx.indices.clear();

		for (r in ctx.choice_results) {
			r.run = 0;
		}
	}

	/**
	 * Clears the whole context to basically reset the progress.
	 */
	public function clear( ctx: CONTEXT ) {
		ctx.currentKey = null;
		ctx.state.clear();
		ctx.choice_results.clear();
		ctx.indices.clear();
		ctx.node_status.clear();
	}

	/**
	 * Register an event listener.
	 */
	public function listen( fn: Event -> Void ) {
		for (i in 0...listeners.length) {
			if (listeners[i] == null) {
				listeners[i] = fn;
				return;
			}
		}

		listeners.push(fn);
	}

	/**
	 * Unregister an event listener.
	 */
	public function unlisten( fn: Event -> Void ) {
		for (i in 0...listeners.length) {
			if (listeners[i] == fn) {
				listeners[i] = null;
			}
		}
	}

	function dispatch( event: Event ) {
		for (i in 0...listeners.length) {
			if (listeners[i] != null) {
				listeners[i](event);
			}
		}
	}

	function evalCustomNode( node: NODE, ctx: CONTEXT, nodeKey: String ) : NodeStatus {
		log('evalCustomNode() is not overridden');
		return Failure;
	}

	function get_node_index( ctx: CONTEXT, key: String ) : Int {
		final old = ctx.indices.get(key);
		return old != null ? old : 0;
	}

	function set_node_index( ctx: CONTEXT, key: String, value: Int ) {
		ctx.indices.set(key, value);
	}

	function update_node_status( ctx: CONTEXT, key: String, value: NodeStatus ) : NodeStatus {
		final r = ctx.node_status.get(key);

		if (r == null) {
			ctx.node_status.set(key, value);
			return value;
		}

		return r;
	}

	function setNextRoot( next: Option<String> ) {
		this.nextRootKey = next;
	}

	function log( msg: String ) {
		final pad = StringTools.lpad('', ' ', _indent);
		logFn('$pad$msg');
	}

	function eval( node: Node<NODE>, ctx: CONTEXT, nodeKey: String ) : NodeStatus {
		_indent += 2;
		final r = _eval(node, ctx, nodeKey);
		_indent -= 2;
		return r;
	}

	function _eval( node: Node<NODE>, ctx: CONTEXT, nodeKey: String ) : NodeStatus {
		switch node {
			case Sequence(nodes):
				log('sequence($nodeKey)');

				final last = get_node_index(ctx, nodeKey);

				for (i in last...nodes.length) {
					final n = nodes[i];
					final r = _eval(n, ctx, '$nodeKey/$i');

					switch r {
						case Success:

						case Running:
							set_node_index(ctx, nodeKey, i);
							log('/sequence($nodeKey)[$i] => $r');
							return r;

						case Failure:
							set_node_index(ctx, nodeKey, nodes.length);
							log('/sequence($nodeKey)[$i] => $r');
							return update_node_status(ctx, nodeKey, r);
					}
				}

				log('/sequence($nodeKey) => Success');
				return update_node_status(ctx, nodeKey, Success);

			case Selector(nodes):
				log('selector($nodeKey)');
				final last = get_node_index(ctx, nodeKey);

				for (i in last...nodes.length) {
					final n = nodes[i];
					final r = eval(n, ctx, '$nodeKey/$i');

					switch r {
						case Success:
							set_node_index(ctx, nodeKey, nodes.length);
							log('/selector($nodeKey)[$i] => $r');
							return update_node_status(ctx, nodeKey, r);

						case Running:
							set_node_index(ctx, nodeKey, i);
							log('/selector($nodeKey)[$i] => $r');
							return r;

						case Failure:
					}
				}

				log('/selector($nodeKey) => Failure');
				return update_node_status(ctx, nodeKey, Failure);

			// case Chance(probability):
			// 	final r: StoryStatus = Math.random() <= probability ? Success : Failure;
			// 	log(':CHANCE($nodeKey) probability=$probability $r');
			// 	return r;

			case Goto(key):
				log('goto($nodeKey) key=$key');
				final next = nodes.exists(key);

				if (next) {
					setNextRoot(Some(key));
					log('/goto($nodeKey) key=$key => Success');
					return Success;
				}

				log('/GOTO($nodeKey) key=$key => Failure');
				return Failure;

			case End:
				log(':end($nodeKey)');
				return Success;

			case SetVariable(key, value):
				log(':set_variable($nodeKey) key=$key value=$value');
				ctx.state.set(key, value);
				return Success;

			case HasVariable(key):
				final r: NodeStatus = ctx.state.exists(key) ? Success : Failure;
				log(':has_variable($nodeKey) key=$key => $r');
				return r;

			case CompareVariable(key, value):
				final r: NodeStatus = ctx.state.get(key) == value ? Success : Failure;
				log(':compare_variable($nodeKey) key=$key value=$value => $r');
				return r;

			case Narrate(text, format):
				narrate_event.text = text;
				narrate_event.format = format;
				dispatch(narrate_event);
				return Success;

			case MultipleChoice(key, choices):
				var entry = ctx.choice_results.get(key);

				if (entry == null) {
					ctx.choice_results.set(key, entry = new MultipleChoiceEntry());
					entry.run = 0;
					entry.selection.set(0, -1);
				} else if (!entry.selection.exists(entry.run)) {
					entry.selection.set(entry.run, -1);
				}

				final selected = entry.selection.get(entry.run);

				if (selected == -1) {
					log('multiple_choice($nodeKey) key=$key');
					final last = get_node_index(ctx, nodeKey);
					var itemIndex = 0;

					present_multiple_choice_event.key = key;
					present_multiple_choice_event.items = [];

					for (i in last...choices.length) {
						final c = choices[i];

						present_multiple_choice_event.items[itemIndex] = {
							text: c.line,
							format: c.format,
							index: i,
						}

						itemIndex += 1;
					}

					dispatch(present_multiple_choice_event);
					log('multiple_choice($nodeKey) key=$key => Running');
					return Running;
				} else {
					final run = entry.run;
					// final answer = entry.selection.get(run);
					entry.run += 1;

					final r = _eval(Selector([
						for (i in 0...choices.length)
							Sequence([Node.Internal_Chose(key, run, i), choices[i].next])
					]), ctx, nodeKey); // TODO (DK) is nodekey correct here?

					return r;
				}

			case Internal_Chose(key, run, value):
				final entry = ctx.choice_results.get(key);
				final sel = entry.selection.get(run);
				return sel == value ? Success : Failure;

			case Custom(node):
				return evalCustomNode(node, ctx, nodeKey);
		}
	}
}
