scriptname PN_FoodEffect extends ActiveMagicEffect  


; PROPERTIES --------------------------------------------------------------------------------------

PN_NeedsManager property		NeedsManagerInstance	auto


; EVENTS ------------------------------------------------------------------------------------------

event OnEffectStart(Actor a_target, Actor a_caster)
	; We use the duration to encode a value
	NeedsManagerInstance.ReduceHunger(GetDuration() as int)
	Dispel()
endEvent