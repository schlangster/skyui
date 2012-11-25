import skyui.widgets.WidgetBase;
import skyui.components.Meter;

class skyui.widgets.meter.MeterWidget extends WidgetBase
{
  /* PRIVATE VARIABLES */
	
	private var _initialized: Boolean = false;
	private var __width;
	private var __height;


  /* STAGE ELEMENTS */
	
	public var meter: Meter;
	

  /* INITIALIZATION */
	
	public function MeterWidget()
	{
		super();
		meter._visible = false;
	}

	/*public function onLoad(){
		initNumbers(200, 25.2, 0x00FF00, -1, -1, 100);
		initStrings("center");
		initCommit();

		//_global.setTimeout(this, "test", 1000)
	}

	function test()
	{
		setFillMode("Left");
		setPercent(25, true)
	}*/


	// @papyrus
	public function initNumbers(a_width: Number, a_height: Number, a_lightColor: Number, a_darkColor: Number, a_flashColor: Number,
								a_percent: Number, a_fillSpeed: Number, a_emptySpeed: Number): Void
	{
		setSize(a_width, a_height);
		setColors(a_lightColor, a_darkColor);
		setFlashColor(a_flashColor);
		setPercent(a_percent, true);
		
		//a_fillSpeed;
		//a_emptySpeed;
	}


	// @papyrus
	public function initStrings(a_fillMode: String): Void
	{
		setFillMode(a_fillMode)
	}

	// @papyrus
	public function initCommit(): Void
	{
		meter._visible = true;
		_initialized = true;
	}

	// @papyrus
	public function setWidth(a_width: Number): Void
	{
		meter.width(a_width);
		invalidateSize();
	}

	// @papyrus
	public function setHeight(a_height: Number): Void
	{
		meter.height(a_height);
		invalidateSize();
	}

	// @papyrus
	public function setSize(a_width: Number, a_height: Number): Void
	{
		meter.setSize(a_width, a_height);
		invalidateSize();
	}

	// @papyrus
	public function setColor(a_lightColor: Number): Void
	{
		meter.color = a_lightColor;
	}

	// @papyrus
	public function setColors(a_lightColor: Number, a_darkColor: Number): Void
	{
		meter.setColors(a_lightColor, a_darkColor);
	}

	// @papyrus
	public function setFlashColor(a_flashColor: Number): Void
	{
		meter.flashColor = a_flashColor;
	}

	// @papyrus
	public function setFillMode(a_fillMode: String): Void
	{
		meter.fillMode = a_fillMode;
	}

	// @papyrus
	public function setPercent(a_percent: Number, a_force: Boolean): Void
	{
		meter.setPercent(a_percent, a_force);
	}

	// @papyrus
	public function startFlash(a_force: Boolean): Void
	{
		meter.startFlash(a_force);
	}


  /* PRIVATE FUNCTIONS */

	// @Overrides WidgetBase
	private function getWidth(): Number
	{
		return __width;
	}
	// @Overrides WidgetBase
	private function getHeight(): Number
	{
		return __height;
	}
	
	// @Overrides WidgetBase
	private function invalidateSize(): Void
	{
		__width = meter.width;
		__height = meter.height;
		updateAlign();
	}
}