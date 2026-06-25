extends SpeechModifierBase

const hypnoHighlights = [
		"cock", "dick", "penis", "member", "shaft", "strapon",
		"cocks", "dicks", "penises", "members", "shafts", "strapons",
		"pussy", "clit", "cunt", "vulva", "slit",
		"pussies", "clits", "cunts", "vulvae", "slits",
		"breast", "tit", "titty", "boob", "nip", "nipple", "teat", "udder",
		"breasts", "tits", "titties", "boobs", "nips", "nipples", "teats", "udders",
		"butt", "ass",
		"butts",
		"toy", "pet", "bitch", "slut", "whore",
		"slutty", "horny", "lewd","needy",
		"breed", "fuck", "sex",
		"bred", "fucked",
		"cum",
		"rough",
		"cute", "adorable", "cutie", "beautiful",
		"submit", "obey", "surrender",
		"fucktoy","fuckpet",
		"please",
	]
	
const wordPrefix = "[tornado radius=2.0 freq=2.0 connected=1][pulse color=#FF33FF height=0.0 freq=3.0]"
const wordSuffix = "[/pulse][/tornado]"

var hypnoHighlightsUnused := []
var lastReset := -1

func appliesTo(_speaker: BaseCharacter) -> bool:
	if(ServiceLocator.safe_get_service(&"Player") != _speaker and ServiceLocator.safe_get_service(&"Player").hasPerk(Perk.HypnosisKeywordsDrawback)):
		if(ServiceLocator.safe_get_service(&"Player").hasPerk(Perk.HypnosisDeepTranceDrawback)):
			return true
		elif(HypnokinkUtil.isHypnotized(ServiceLocator.safe_get_service(&"Player")) and ServiceLocator.safe_get_service(&"Player").hasPerk(Perk.HypnosisFamousDrawback)):
			return true
		elif(HypnokinkUtil.isInTrance(ServiceLocator.safe_get_service(&"Player"))):
			return true
	return false
	
func modify(_text: String, _speaker: BaseCharacter) -> String:
	if(lastReset != ServiceLocator.safe_get_service(&"MainScene").getTime()):
		hypnoHighlightsUnused = hypnoHighlights.duplicate()
		lastReset = ServiceLocator.safe_get_service(&"MainScene").getTime()
	
	var pos = 0
	var textLen = _text.length()
	var outText = ""
	
	while pos < textLen:
		if(Util.asciiletters.has(_text[pos])):
			var word = _text[pos]
			pos += 1
			
			while pos < textLen:
				if(Util.asciiletters.has(_text[pos]) || Util.digits.has(_text[pos]) || _text[pos] == "_"):
					word += _text[pos]
					pos += 1
				else:
					break
			
			var word_base = basifyWword.to_lower(.unicode_at(0))
			if(word_base in hypnoHighlights):
				outText += wordPrefix+word+wordSuffix
				if(word_base in hypnoHighlightsUnused):
					#avoid firing more than once per word in the same instance of time
					hypnoHighlightsUnused.erase(word_base)
					ServiceLocator.safe_get_service(&"Player").addEffect(StatusEffect.Suggestible, [randi_range(1,4)]) #add a little hypnosis
					ServiceLocator.safe_get_service(&"Player").addLust(randi_range(1,5)) #a little bit of lust
					#ServiceLocator.safe_get_service(&"Player").addArousal(randf_range(0.0,0.03)) #and a bit less arousal
			else:
				outText += word
		else:
			outText += _text[pos]
			pos += 1
	
	return outText
	
static func basifyWword: String.unicode_at(0) -> String:
	if(word.ends_with("ing")):
		word = word.substr(0, len(word) - 3)
	return word
