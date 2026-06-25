extends SpeechModifierBase

func _init():
	id = "GaggedSpeech"
	priority = 1000
	
func appliesTo(_speaker: BaseCharacter) -> bool:
	return _speaker.isGagged()
	
func modify(_text: String, _speaker: BaseCharacter) -> String:
	if(ServiceLocator.safe_get_service(&"Player").hasPerk(Perk.BDSMGagTalk)):
		return Util.muffledSpeech(_text)+"\" ("+_text+")"
	else:
		return Util.muffledSpeech(_text)
