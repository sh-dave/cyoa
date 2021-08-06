# cyoa

A little `Choose you own adventure` library. The basic idea of this implementation is actually to behave kinda like behavior trees.

## usage

- create a node enum for whatever custom stuff you want to implement
- create a tree class to handle your custom nodes
- start listening for events
- call `tree.process()` to run the logic

```haxe
import cyoa.Events;
import cyoa.Tree;

enum SomeCustomNode {
    /**
     * Like `cyoa.Node.Narrate`, but also displays a character portrait.
     */
    Say( char: String, text: String, ?format: String );
}

class SayEvent extends Event {
	public static inline final Id = 'my-custom-say-event';

    public var char: String;
    public var text: String;
    public var format: String;

    public function new() {
        super(Id);
    }
}

class CustomTree extends Tree<SomeCustomNode, Context> {
    final say_event = new SayEvent();

	override function evalCustomNode( node: SomeCustomNode, ctx: Context, nodeKey: String ) : NodeStatus {
		switch node {
            case Say(char, text, format):
                say_event.char = char;
                say_event.text = text;
                say_event.format = format;
                dispatch(say_event);
                return Success;
        }
    }
}

// add a couple of shortcut functions to make the following node tree easier to read
function seq( nodes: Array<Node<SomeCustomNode>> ) : Node<SomeCustomNode> { return Sequence(nodes); }
function sel( nodes: Array<Node<SomeCustomNode>> ) : Node<SomeCustomNode> { return Selector(nodes); }
function n( text: String, ?format ) : Node<SomeCustomNode> { return Narrate(text, format); }
function mc( key: String, choices: Array<MultipleChoiceAnswer<SomeCustomNode>> ) : Node<SomeCustomNode> { return MultipleChoice(key, choices); }
function say( char: String, text: String, ?format: String ) : Node<SomeCustomNode> { return Custom(Say(char, text, format)); }

final nodes = [
    // intro passage
    'prelude' => seq([
        // print a line of text
        n('Want to know more?'),

        // offer multiple choices
        mc('#1', [
            // goto `explain more` passage when user clicks `Yes!`
            { line: 'Yes!': next: Goto('explain_more') },

            // goto `goodbye` passage when user clicks `No.`
            { line: 'No.': next: Goto('goodbye') },
        ]);
    ]),

    'explain_more' => seq([
        n('Use a "Sequence" to run multiple nodes one after another.'),
        n('Use a "Selector" to selectively run nodes. It will return as soon as the first node returns "Success".'),
        n('Use "Goto" to jump to a different passage.'),
        n('TBH, i am to bored to write more example code now, just read the description of the available nodes.'),
        End,
    ]),

    'goodbye' => seq([
        n('So long, and Thanks for All the Fish.'),
        End,
    ]),
];

function process_tree( ctx ) {
    switch tree.process(ctx) {
        case Running: // waiting for some sort of input
        case Failure: // oh noes, a node failed for some reason and wasn't handled properly
        case Success: // the story is all done
    }
}

function on_story_event( event: cyoa.Event ) {
    switch event.type {
        case NarrationEvent.Id:
			final n: NarrationEvent = cast event;
            // add some line of text to your scene

        case MultipleChoiceEvent.Id:
			final mc: MultipleChoiceEvent = cast event;

            // add a button for each `mc.item`
            for (item in mc.items) {
                add_some_button(item.text, function on_click() {
                    ctx.choice_results.set(mc.key, Some(item.index));
                    process_tree();
                });
            }

        case SayEvent.Id:
            final say: SayEvent = cast event;
            // add an image and text to your scene
    }
}

final ctx = new cyoa.Context();
final tree = new CustomTree();
tree.listen(on_story_event);
tree.init(nodes, 'prelude');
process_tree(ctx);

```
