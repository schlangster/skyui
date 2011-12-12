dynamic class AnimatedSkillText extends MovieClip
{
    var SKILLS: Number = 18;
    var SKILL_ANGLE: Number = 20;
    var LocationsA = [-150, -10, 130, 270, 410, 640, 870, 1010, 1150, 1290, 1430];
    var ThisInstance;
    var attachMovie;
    var getNextHighestDepth;

    function AnimatedSkillText()
    {
        super();
        this.ThisInstance = this;
    }

    function InitAnimatedSkillText(aSkillTextA)
    {
        Shared.GlobalFunc.MaintainTextFormat();
        var __reg6 = 4;
        var __reg2 = 0;
        for (;;) 
        {
            if (__reg2 >= aSkillTextA.length) 
            {
                return;
            }
            var __reg3 = this.attachMovie("SkillText_mc", "SkillText" + __reg2 / __reg6, this.getNextHighestDepth());
            __reg3.LabelInstance.html = true;
            __reg3.LabelInstance.htmlText = aSkillTextA[__reg2 + 1].toString().toUpperCase() + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'" + aSkillTextA[__reg2 + 3].toString() + "\'>" + aSkillTextA[__reg2].toString() + "</font>";
            var __reg5 = new Components.Meter(__reg3.ShortBar);
            __reg5.SetPercent(aSkillTextA[__reg2 + 2]);
            __reg3._x = this.LocationsA[0];
            __reg2 = __reg2 + __reg6;
        }
    }

    function HideRing()
    {
        var __reg2 = 0;
        for (;;) 
        {
            if (__reg2 >= this.SKILLS) 
            {
                return;
            }
            this.ThisInstance["SkillText" + __reg2]._x = this.LocationsA[0];
            ++__reg2;
        }
    }

    function SetAngle(aAngle)
    {
        var __reg6 = Math.floor(aAngle / this.SKILL_ANGLE);
        var __reg10 = aAngle % this.SKILL_ANGLE / this.SKILL_ANGLE;
        var __reg2 = 0;
        for (;;) 
        {
            if (__reg2 >= this.SKILLS) 
            {
                return;
            }
            var __reg11 = this.LocationsA.length - 2;
            var __reg5 = Math.floor(__reg11 / 2) + 1;
            var __reg4 = __reg6 - __reg5 < 0 ? __reg6 - __reg5 + this.SKILLS : __reg6 - __reg5;
            var __reg8 = __reg6 + __reg5 >= this.SKILLS ? __reg6 + __reg5 - this.SKILLS : __reg6 + __reg5;
            var __reg7 = __reg4 > __reg8;
            if ((!__reg7 && (__reg2 > __reg4 && __reg2 <= __reg8)) || (__reg7 && (__reg2 > __reg4 || __reg2 <= __reg8))) 
            {
                var __reg3 = 0;
                if (__reg7) 
                {
                    __reg3 = __reg2 <= __reg4 ? __reg2 + (this.SKILLS - __reg4) : __reg2 - __reg4;
                }
                else 
                {
                    __reg3 = __reg2 - __reg4;
                }
                --__reg3;
                this.ThisInstance["SkillText" + __reg2]._x = Shared.GlobalFunc.Lerp(this.LocationsA[__reg3], this.LocationsA[__reg3 + 1], 1, 0, __reg10);
                var __reg9 = (__reg3 == 4 ? 100 - __reg10 * 100 : __reg10 * 100) * 0.75 + 100;
                this.ThisInstance["SkillText" + __reg2]._xscale = __reg3 == 5 || __reg3 == 4 ? __reg9 : 100;
                this.ThisInstance["SkillText" + __reg2]._yscale = __reg3 == 5 || __reg3 == 4 ? __reg9 : 100;
                this.ThisInstance["SkillText" + __reg2].ShortBar._yscale = __reg3 == 5 || __reg3 == 4 ? 100 - (__reg9 - 100) / 2.5 : 100;
            }
            else 
            {
                this.ThisInstance["SkillText" + __reg2]._x = this.LocationsA[0];
            }
            ++__reg2;
        }
    }

}
