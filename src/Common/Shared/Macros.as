import gfx.io.GameDelegate;

class Shared.Macros
{
   function Macros()
   {
   }
   static function BSOUTPUT(asMessage)
   {
      GameDelegate.call("DoActionscriptOutput",[asMessage]);
   }
   static function BSASSERT(abConditional, asMessage)
   {
      if(!abConditional)
      {
         GameDelegate.call("DoActionscriptAssert",[abConditional,asMessage]);
      }
   }
}
