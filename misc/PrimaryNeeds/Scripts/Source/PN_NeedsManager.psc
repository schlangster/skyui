scriptname PN_NeedsManager extends Quest  

; PRIVATE VARIABLES -------------------------------------------------------------------------------

; Time in game hours
float	_curTime				= 0.0
float	_lastIncreaseTime		= 0.0

; Timers in real seconds
float	_hungerSoundTimer		= 0.0
float	_thirstSoundTimer		= 0.0
float	_fatigueSoundTimer		= 0.0
float	_soundCooldownTimer		= 0.0

; Current HTF states
int 	_hunger					= 0
int 	_thirst					= 0
int 	_fatigue				= 0

int 	_lastHunger				= -1
int 	_lastThirst				= -1
int 	_lastFatigue			= -1

; Penalty levels (0=none)
int		_hungerLevel			= 0
int		_thirstLevel			= 0
int		_fatigueLevel			= 0

; Sleep tracking
float	_sleepStartTime
float	_sleepEndTime
int		_sleepDuration


; PROPERTIES --------------------------------------------------------------------------------------

int property HungerPercent
	int function get()
		return Lerp(0, 100, HungerWarnThreshold, HungerPenaltyThreshold1, _hunger, true) as int
	endFunction
endProperty

int property ThirstPercent
	int function get()
		return Lerp(0, 100, ThirstWarnThreshold, ThirstPenaltyThreshold1, _thirst, true) as int
	endFunction
endProperty

int property FatiguePercent
	int function get()
		return Lerp(0, 100, FatigueWarnThreshold, FatiguePenaltyThreshold1, _fatigue, true) as int
	endFunction
endProperty

int property HungerLevel
	int function get()
		return _hungerLevel
	endFunction
endProperty

int property ThirstLevel
	int function get()
		return _thirstLevel
	endFunction
endProperty

int property FatigueLevel
	int function get()
		return _fatigueLevel
	endFunction
endProperty

ObjectReference property	PlayerRef auto

bool property		HungerEnabled				= true auto
bool property		ThirstEnabled				= true auto
bool property		FatigueEnabled				= true auto

; Real seconds between update checks
float property	UpdateInterval	= 3.0 auto

; Increase per game (sleep) hour
int property		HungerPerHour				= 10 auto
int property		HungerPerSleepHour			= 5 auto
int property		ThirstPerHour				= 10 auto
int property		ThirstPerSleepHour			= 10 auto
int property		FatiguePerHour				= 10 auto
int property		FatiguePerSleepHour			= -20 auto

; Warn threshold starts sound feedback, no penalties
; Level 1 applies penalties
; Level 2 applies severe penalties
; Values are capped at max
int property		HungerWarnThreshold			= 60 auto
int property		HungerPenaltyThreshold1		= 120 auto
int property		HungerPenaltyThreshold2		= 350 auto
int property		HungerMax					= 420 auto

int property		ThirstWarnThreshold			= 50 auto
int property		ThirstPenaltyThreshold1		= 100 auto
int property		ThirstPenaltyThreshold2		= 200 auto
int property		ThirstMax					= 250 auto

int property		FatigueWarnThreshold		= 160 auto
int property		FatiguePenaltyThreshold1	= 200 auto
int property		FatiguePenaltyThreshold2	= 400 auto
int property		FatigueMax					= 480 auto

; Sound feedback interval in real seconds, lerped between min and max
float property		SoundMinInterval			= 40.0 auto
float property		SoundMaxInterval			= 150.0 auto

; Cooldown after any sound feedback in real seconds
float property		SoundCooldownInterval		= 10.0 auto

; Male sounds at index 0, female at 1
Sound[] property	HungerSounds auto
Sound[] property	ThirstSounds auto
Sound[] property	FatigueSounds auto

; Level 1 penalty at index 0, level 2 at 1
Spell[] property	HungerPenalties auto
Spell[] property	ThirstPenalties auto
Spell[] property	FatiguePenalties auto

GlobalVariable property	PlayerIsVampire auto
GLobalVariable property	PlayerIsWerewolf auto


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_lastIncreaseTime = 24 * Utility.GetCurrentGameTime()
	RegisterForSingleUpdate(UpdateInterval)
	RegisterForSleep()
endEvent


; EVENTS ------------------------------------------------------------------------------------------

function OnUpdate()
	_curTime = 24 * Utility.GetCurrentGameTime()

	CheckValueIncrease()
	UpdatePenalties()
	UpdateSounds()

	; Causes widget to pull most recent data
	if (_hunger != _lastHunger || _thirst != _lastThirst || _fatigue != _lastFatigue)
		_lastHunger = _hunger
		_lastThirst = _thirst
		_lastFatigue = _fatigue
		SendModEvent("PNX_statusUpdated")
	endIf

	RegisterForSingleUpdate(UpdateInterval)
endFunction

event OnSleepStart(float a_sleepStartTime, float a_desiredSleepEndTime)
	_sleepStartTime = 24 * a_sleepStartTime
	_sleepEndTime = 24 * a_desiredSleepEndTime ; change later if interrupted
endEvent

event OnSleepStop(bool a_interrupted)
	if (a_interrupted)
		_sleepEndTime = 24 * Utility.GetCurrentGameTime()
	endIf

	; We add up the sleep duration in case player sleeps several times until the main loop is processed again
	_sleepDuration += (_sleepEndTime - _sleepStartTime) as int

	; Play sound again if still sleepy
	_fatigueSoundTimer = 0.0
endEvent


; PUBLIC FUNCTIONS --------------------------------------------------------------------------------

function ReduceHunger(int a_hours)
	_hunger -= a_hours * HungerPerHour
	if (_hunger < 0)
		_hunger = 0
	endIf

	_hungerSoundTimer = 0.0
endFunction

function ReduceThirst(int a_hours)
	_thirst -= a_hours * ThirstPerHour
	if (_thirst < 0)
		_thirst = 0
	endIf

	_thirstSoundTimer = 0.0
endFunction

function ReduceFatigue(int a_hours)
	_fatigue -= a_hours * FatiguePerHour
	if (_fatigue < 0)
		_fatigue = 0
	endIf

	_fatigueSoundTimer = 0.0
endFunction


; PRIVATE FUNCTIONS -------------------------------------------------------------------------------

function CheckValueIncrease()

	bool isVampire = PlayerIsVampire.GetValueInt() > 0

	if (!HungerEnabled || isVampire)
		_hunger = 0
	endIf

	if (!ThirstEnabled || isVampire)
		_thirst = 0
	endIf

	if (!FatigueEnabled || isVampire)
		_fatigue = 0
	endIf

	int d = (_curTime - _lastIncreaseTime) as int

	; Wait at least one hour between increases
	if (d < 1)
		return
	endIf

	; We reset the timers after longer waiting durations to remind the player to be careful
	if (d > 3)
		_hungerSoundTimer = 0.0
		_thirstSoundTimer = 0.0
		_fatigueSoundTimer = 0.0
	endIf

	; Sleep duration is 0 if not slept at all
	int awakeDuration = d - _sleepDuration

	if (HungerEnabled && _hunger < HungerMax && !isVampire)
		_hunger += awakeDuration * HungerPerHour
		_hunger += _sleepDuration * HungerPerSleepHour
		if (_hunger > HungerMax)
			_hunger = HungerMax
		elseIf (_hunger < 0)
			_hunger = 0
		endIf
	endIf

	if (ThirstEnabled && _thirst < ThirstMax && !isVampire)
		_thirst += awakeDuration * ThirstPerHour
		_thirst += _sleepDuration * ThirstPerSleepHour
		if (_thirst > ThirstMax)
			_thirst = ThirstMax
		elseIf (_thirst < 0)
			_thirst = 0
		endIf
	endIf

	if (FatigueEnabled && _fatigue < FatigueMax && !isVampire)
		_fatigue += awakeDuration * FatiguePerHour
		_fatigue += _sleepDuration * FatiguePerSleepHour
		if (_fatigue > FatigueMax)
			_fatigue = FatigueMax
		elseIf (_fatigue < 0)
			_fatigue = 0
		endIf
	endIf

	_lastIncreaseTime = _curTime

	; Reset
	_sleepDuration = 0
endFunction

function UpdatePenalties()
	bool applyHunger = false
	bool applyThirst = false
	bool applyFatigue = false
	
	Actor player = Game.GetPlayer()

	if (_hunger > HungerPenaltyThreshold2)
		applyHunger = (_hungerLevel != 2)
		_hungerLevel = 2
	elseIf (_hunger > HungerPenaltyThreshold1)
		applyHunger = (_hungerLevel != 1)
		_hungerLevel = 1
	else
		applyHunger = (_hungerLevel != 0)
		_hungerLevel = 0
	endIf

	if (_thirst > ThirstPenaltyThreshold2)
		applyThirst = (_thirstLevel != 2)
		_thirstLevel = 2
	elseIf (_thirst > ThirstPenaltyThreshold1)
		applyThirst = (_thirstLevel != 1)
		_thirstLevel = 1
	else
		applyThirst = (_thirstLevel != 0)
		_thirstLevel = 0
	endIf

	if (_fatigue > FatiguePenaltyThreshold2)
		applyFatigue = (_fatigueLevel != 2)
		_fatigueLevel = 2
	elseIf (_fatigue > FatiguePenaltyThreshold1)
		applyFatigue = (_fatigueLevel != 1)
		_fatigueLevel = 1
	else
		applyFatigue = (_fatigueLevel != 0)
		_fatigueLevel = 0
	endIf

	if (applyHunger)
		; Immediate feedback
		_hungerSoundTimer = 0.0

		if (_hungerLevel == 2)
			player.RemoveSpell(HungerPenalties[0])
			player.AddSpell(HungerPenalties[1], false)
		elseIf (_hungerLevel == 1)
			player.AddSpell(HungerPenalties[0], false)
			player.RemoveSpell(HungerPenalties[1])
		else
			player.RemoveSpell(HungerPenalties[0])
			player.RemoveSpell(HungerPenalties[1])
		endIf
	endIf

	if (applyThirst)
		_thirstSoundTimer = 0.0

		if (_thirstLevel == 2)
			player.RemoveSpell(ThirstPenalties[0])
			player.AddSpell(ThirstPenalties[1], false)
		elseIf (_thirstLevel == 1)
			player.AddSpell(ThirstPenalties[0], false)
			player.RemoveSpell(ThirstPenalties[1])
		else
			player.RemoveSpell(ThirstPenalties[0])
			player.RemoveSpell(ThirstPenalties[1])
		endIf
	endIf

	if (applyFatigue)
		_fatigueSoundTimer = 0.0

		if (_fatigueLevel == 2)
			player.RemoveSpell(FatiguePenalties[0])
			player.AddSpell(FatiguePenalties[1], false)
		elseIf (_fatigueLevel == 1)
			player.AddSpell(FatiguePenalties[0], false)
			player.RemoveSpell(FatiguePenalties[1])
		else
			player.RemoveSpell(FatiguePenalties[0])
			player.RemoveSpell(FatiguePenalties[1])
		endIf
	endIf
endFunction

function UpdateSounds()
	; General cooldown so we don't play sounds immediately after each other
	if (_soundCooldownTimer > 0)
		_soundCooldownTimer -= UpdateInterval
		return
	endIf

	if (_hungerSoundTimer > 0)
		_hungerSoundTimer -= UpdateInterval
	elseIf (_hunger > HungerWarnThreshold)
		PlaySound(HungerSounds)

		_hungerSoundTimer = Lerp(SoundMaxInterval, SoundMinInterval, HungerWarnThreshold, HungerMax, _hunger)

		return
	endIf

	if (_thirstSoundTimer > 0)
		_thirstSoundTimer -= UpdateInterval
	elseIf (_thirst > ThirstWarnThreshold)
		PlaySound(ThirstSounds)

		_thirstSoundTimer = Lerp(SoundMaxInterval, SoundMinInterval, ThirstWarnThreshold, ThirstMax, _thirst)

		return
	endIf

	if (_fatigueSoundTimer > 0)
		_fatigueSoundTimer -= UpdateInterval
	elseIf (_fatigue > FatigueWarnThreshold)
		PlaySound(FatigueSounds)

		_fatigueSoundTimer = Lerp(SoundMaxInterval, SoundMinInterval, FatigueWarnThreshold, FatigueMax, _fatigue)

		return
	endIf
endFunction

function PlaySound(Sound[] a_sounds)
	ActorBase playerBase = PlayerRef.GetBaseObject() as ActorBase
	int idx = playerBase.GetSex()
	a_sounds[idx].Play(PlayerRef)
	_soundCooldownTimer = SoundCooldownInterval
endFunction

float function Lerp(float a_targetMin, float a_targetMax, float a_sourceMin, float a_sourceMax, float a_sourceVal, bool a_bClamp = false)
	float v = a_targetMin + (a_targetMax - a_targetMin) * ((a_sourceVal - a_sourceMin) / (a_sourceMax - a_sourceMin))
	if (a_bClamp)
		if (v < a_targetMin)
			v = a_targetMin
		elseIf (v > a_targetMax)
			v = a_targetMax
		endIf
	endIf
	return v
endFunction