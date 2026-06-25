extends SceneBase
class_name HK_SessionAwakenerBase

func onAwakener():
	processTime(10*60)
	ServiceLocator.safe_get_service(&"Player").removeEffect(StatusEffect.UnderHypnosis)
	
	var currentStacks = HypnokinkUtil.getSuggestibleStacks(ServiceLocator.safe_get_service(&"Player"))
	
	if(getFlag("HypnokinkModule.VionMode") == HypnokinkUtil.VionGood):
		HypnokinkUtil.changeSuggestibilityBy(ServiceLocator.safe_get_service(&"Player"), -currentStacks)
	if(getFlag("HypnokinkModule.VionMode") == HypnokinkUtil.VionNeutral):
		HypnokinkUtil.changeSuggestibilityBy(ServiceLocator.safe_get_service(&"Player"), -currentStacks / 2)
	if(getFlag("HypnokinkModule.VionMode") == HypnokinkUtil.VionEvil):
		pass #mean Vion just leaves you hypnotized
		
func afterAwakener():
	
	if(getFlag("HypnokinkModule.VionMode") == HypnokinkUtil.VionGood):
		ServiceLocator.safe_get_service(&"Player").addSkillExperience(Skill.Hypnosis, 40)
	if(getFlag("HypnokinkModule.VionMode") == HypnokinkUtil.VionNeutral):
		ServiceLocator.safe_get_service(&"Player").addSkillExperience(Skill.Hypnosis, 60)
	if(getFlag("HypnokinkModule.VionMode") == HypnokinkUtil.VionEvil):
		ServiceLocator.safe_get_service(&"Player").addSkillExperience(Skill.Hypnosis, 80)
		
	setFlag("HypnokinkModule.LastSessionTime", (ServiceLocator.safe_get_service(&"MainScene").currentDay * 24*60*60) + ServiceLocator.safe_get_service(&"MainScene").timeOfDay)
