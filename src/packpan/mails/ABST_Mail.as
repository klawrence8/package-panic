package packpan.mails
{
	import cobaltric.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import packpan.PP;
	/**
	 * An abstract Mail object, extended to become items that are manipulated by nodes.
	 * @author Alexander Huynh
	 */
	public class ABST_Mail 
	{
		protected var cg:ContainerGame;		// the parent container
		
		public var type:String;						// the name of this Mail
		public var position:Point;					// the current grid square of this Mail (0-indexed, origin top-left, L/R is x, U/D is y)
		public var colored:Boolean;					// whether or not this Mail is colored
		public var color:uint;						// the color of this Mail if applicable
		
		public var mc_mail:MovieClip;				// the mail MovieClip (SWC)
		public var mailState:int = PP.MAIL_IDLE;	// is this mail in a idle, success, or failure state
		
		/**
		 * Constructor.
		 * @param	_cg			the parent container (ABST_ContainerGame)
		 * @param	_type		the type of this mail (String)
		 * @param	_position	the starting grid location of this mail (Point)
		 */
		public function ABST_Mail(_cg:ContainerGame, _type:String, _position:Point, _color:uint = 0x000001) 
		{
			cg = _cg;
			type = _type;
			position = _position;
			color = _color;
			
			mc_mail = cg.addChildToGrid(new Mail(), position);		// create the MovieClip
			mc_mail.stop();											// default mail frame
			mc_mail.buttonMode = false;								// disable click captures
			mc_mail.mouseEnabled = false;
			mc_mail.mouseChildren = false;
			
			if (color == 0x000001) {
				colored = false;
			} else {
				colored = true;
				var ct:ColorTransform = new ColorTransform();
				ct.redMultiplier = int(color / 0x10000) / 255;
				ct.greenMultiplier = int(color % 0x10000 / 0x100) / 255;
				ct.blueMultiplier = color % 0x100 / 255;
				mc_mail.transform.colorTransform = ct;
			}
		}
		
		/**
		 * Called by ABST_ContainerGame every frame to make this Mail do things
		 * @return				PP.MAIL_IDLE, PP.MAIL_SUCCESS, or PP.MAIL_FAILURE
		 */
		public function step():int
		{
			// -- OVERRIDE THIS FUNCTION TO PROVIDE CUSTOM FUNCTIONALITY
			
			position = findGridSquare();		// find the current grid coordinates
			
			if (position)						// if we are in bounds
			{
				if (!cg.nodeGrid[position.x][position.y])		// if we are not on a Node (we are on the ground)
				{
					mailState = PP.MAIL_FAILURE;	// TODO falling-off animation
				}
				else								// otherwise have the Node in this grid square affect us
					cg.nodeGrid[position.x][position.y].affectMail(this);
			}
				  
			return mailState;
		}
		
		/**
		 * Returns the grid coordinates of this Mail object based on its actual coordinates
		 * Sets state to failure if not on a valid point (out of bounds)
		 * 
		 * @return		the grid square as a Point, or null if invalid
		 */
		protected function findGridSquare():Point
		{
			// black magic; but don't worry, I'm a Super High-School Level Electromage
			var p:Point = new Point(Math.round((mc_mail.y + 260) / 50), Math.round((mc_mail.x + 350) / 50));
			if (p.x < 0 || p.x > PP.DIM_X_MAX || p.y < 0 || p.y > PP.DIM_Y_MAX)
			{
				mailState = PP.MAIL_FAILURE;
				p = null;
			}
			return p;
		}
	}
}