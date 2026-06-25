extends RefCounted
class_name SexVoice

## MIGRATED to Godot 4 (GDScript 2.0).
## Voice/reaction text generation for sex scenes.
## extends RefCounted → RefCounted. All dialogue preserved.

static func domReactToSubBodypart(bodypart, sex_engine, dom_info, sub_info) -> String:
	var dom = dom_info.getChar()
	var sub = sub_info.getChar()
	var dom_is_angry := dom_info.isAngry()
	var dom_is_mean: bool = dom_info.personalityScore({PersonalityStat.Mean: 1.0}) > 0.4

	var possible: Array = []

	if bodypart is BodypartBreasts:
		var lust_interests = dom.getLustInterests()
		var likes_big := lust_interests.getTopicValue(InterestTopic.BigBreasts, sub)
		var likes_lactation := lust_interests.getTopicValue(InterestTopic.LactatingBreasts, sub)

		if likes_lactation > 0.2:
			possible.append_array([
				"Wow, those are some beautiful lactating " + RNG.pick(["breasts", "tits"]) + " you've got there!",
				"I love the way your milk is flowing, it's so mesmerizing.",
				"Lactating breasts are incredibly sexy.",
			])
		elif likes_lactation < -0.2:
			possible.append_array([
				"You should be ashamed of yourself for lactating in public.",
				"I don't care for lactation. Not my thing.",
			])

		if likes_big > 0.2:
			if dom_is_angry or dom_is_mean:
				possible.append_array([
					"Well, look at the size of those things!",
					"I don't know if I should be impressed or intimidated.",
					"I bet those things could crush a man's skull.",
				])
			else:
				possible.append_array([
					"Oh yeah. I'd like to see what those puppies can do.",
					"I could stare at giant breasts all day.",
				])

	if possible.is_empty():
		return ""
	return RNG.pick(possible)
