import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import skyui.util.GlobalFunctions;

import gfx.events.EventDispatcher;

class SkillTreeView extends MovieClip
{
  /* CONSTANTS */	

  /* STAGE ELEMENTS */

	public var clipPlane: MovieClip;
	public var edgePlane: MovieClip;
	public var background: MovieClip;

  /* PROPERTIES */
  
	public var skillData: Object;
	
	public var entryRenderer: String;
	public var edgeRenderer: String;
	
	public var horizontalSpacing: Number = 75;
	public var verticalSpacing: Number = 75;
	
	public function get selectedClip(): SkillTreeEntry
	{
		return _selectedClip;
	}
	
	public function set selectedClip(a_clip: SkillTreeEntry)
	{
		if (_selectedClip == a_clip)
			return;
			
		var oldClip = _selectedClip;
		
		_selectedClip = a_clip;
		
		if (oldClip)
			oldClip.invalidate();
			
		if (a_clip)
			a_clip.invalidate();
	}
	
	
  /* PRIVATE VARIABLES */
	
	private var _rootName: String;
	private var _selectedClip: SkillTreeEntry;
	private var _clipPool: Array;
	private var _edgePool: Array;
	
	
  /* INITIALIZATION */
	
	public function SkillTreeView()
	{
		super();
		
		_selectedClip = null;
		
		_rootName = null;
		_clipPool = [];
		_edgePool = [];

		edgePlane = this.createEmptyMovieClip("edgePlane", this.getNextHighestDepth());
		clipPlane = this.createEmptyMovieClip("clipPlane", this.getNextHighestDepth());
		
		EventDispatcher.initialize(this);
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
  
  	public function setRootSkill(a_name: String): Void 
	{
		if (a_name != _rootName) {
			_rootName = a_name;
			updateTree();
		}
	}
	
	private function prepareClips(a_count: Number): Void
	{
		var d = a_count - _clipPool.length;

		// Grow pool?
		if (d > 0) {
			var nextIndex = _clipPool.length;
			
			for (var i=0; i<d; i++) {
				var clip = clipPlane.attachMovie(entryRenderer, entryRenderer + nextIndex, clipPlane.getNextHighestDepth());		
				_clipPool[nextIndex] = clip;
				nextIndex++;
			}
		}
		
		// Hide all clips
		for (var i=0; i<_clipPool.length; i++) {
			_clipPool[i]._visible = false;
			_clipPool[i].clearData();
		}
	}
	
	private function prepareEdges(a_count: Number): Void
	{		
		var d = a_count - _edgePool.length;

		// Grow pool?
		if (d > 0) {
			var nextIndex = _edgePool.length;
			
			for (var i=0; i<d; i++) {
				var clip = edgePlane.attachMovie(edgeRenderer, edgeRenderer + nextIndex, edgePlane.getNextHighestDepth());		
				_edgePool[nextIndex] = clip;
				nextIndex++;
			}
		}
		
		// Hide all edges
		for (var i=0; i<_edgePool.length; i++) {
			_edgePool[i]._visible = false;
		}
	}
	
	private function collectNodes(a_node: Object, a_nodes: Array): Void
	{
		a_node.__marked = true;
		a_nodes.push(a_node);
		
		for (var i=0; i<a_node.children.length; i++) {
			var childName = a_node.children[i];
			var child = skillData[childName];
			if (child.__marked == undefined)
				collectNodes(child, a_nodes);
		}
	}
	
	private function updateTree(): Void
	{
		var nodes  = [];		
		var rootNode = skillData[_rootName];
		
		collectNodes(rootNode, nodes);
		prepareClips(nodes.length);
		
		var clipIndex = 0;

		// Set entries
		for (var i=0; i<nodes.length; i++) {
			var node = nodes[i];
			var clip = _clipPool[clipIndex++];
			
			clip._x = node.position[0] / 100 * background._width;
			clip._y = node.position[1] / 100 * -background._height;
			clip._visible = true;
			clip.setData(node);
			node.clip = clip;
		}

		var edgeCount = 0;

		// Unmark nodes and count edges
		for (var i=0; i<nodes.length; i++) {
			var node = nodes[i];
			delete node.__marked;
			
			if (node.children)
				edgeCount += node.children.length;
		}
		
		// Allocate edges
		prepareEdges(edgeCount);
		
		var edgeIndex = 0;
		
		for (var i=0; i<nodes.length; i++) {
			var node = nodes[i];
			var nodeClip = node.clip;
			
			for (var j=0; j<node.children.length; j++) {
				var childName = node.children[j];
				var child = skillData[childName];
				var childClip = child.clip;
				
				var e = _edgePool[edgeIndex++];
				e._visible = true;
				
				e._x = nodeClip._x;
				e._y = nodeClip._y;
				
				e._width = GlobalFunctions.getDistance(nodeClip, childClip);
				e._rotation = GlobalFunctions.getAngle(nodeClip, childClip);
			
			}
		}
	}
	
	private function onSkillRollOver(a_clip: SkillTreeEntry, a_keyboardOrMouse: Number): Void
	{
		selectedClip = a_clip;
		dispatchEvent({type: "selectionChange", data: a_clip.data});
	}
	
	private function onSkillRollOut(a_clip: SkillTreeEntry, a_keyboardOrMouse: Number): Void
	{
	}
	
	private function onSkillPress(a_clip: SkillTreeEntry, a_keyboardOrMouse: Number): Void
	{
		dispatchEvent({type: "itemPress", data: a_clip.data});
	}
	
	private function onSkillPressAux(a_clip: SkillTreeEntry, a_keyboardOrMouse: Number, a_buttonIndex: Number): Void
	{
	}
	

  /* PRIVATE FUNCTIONS */
}