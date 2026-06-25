extends Object
class_name ImageConditions

static func areTrue(conditions):
	for condition in conditions:
		if(condition is int):
			condition = [condition]
		var con = condition[0]
		var args = condition
		args.pop_front()
		
		if(con == ImageCon.MalePC):
			if(!ServiceLocator.safe_get_service(&"Player").hasPenis()):
				return false
			if(ServiceLocator.safe_get_service(&"Player").hasVagina()):
				return false
			if(ServiceLocator.safe_get_service(&"Player").getFemininity() > 0.5 && ServiceLocator.safe_get_service(&"Player").getGender() != Gender.Male):
				return false
		if(con == ImageCon.ShemalePC):
			if(!ServiceLocator.safe_get_service(&"Player").hasPenis()):
				return false
			if(ServiceLocator.safe_get_service(&"Player").hasVagina()):
				return false
			if(ServiceLocator.safe_get_service(&"Player").getFemininity() < 0.4):
				return false
		if(con == ImageCon.FemalePC):
			if(ServiceLocator.safe_get_service(&"Player").hasPenis()):
				return false
			if(!ServiceLocator.safe_get_service(&"Player").hasVagina()):
				return false
			if(ServiceLocator.safe_get_service(&"Player").getFemininity() < 0.5 && ServiceLocator.safe_get_service(&"Player").getGender() != Gender.Female):
				return false
		if(con == ImageCon.HermPC):
			if(!ServiceLocator.safe_get_service(&"Player").hasPenis()):
				return false
			if(!ServiceLocator.safe_get_service(&"Player").hasVagina()):
				return false
				
		if(con == ImageCon.FlagIsTrue):
			if(!ServiceLocator.safe_get_service(&"MainScene").getFlag(args[0])):
				return false
		if(con == ImageCon.FlagIsFalse):
			if(ServiceLocator.safe_get_service(&"MainScene").getFlag(args[0])):
				return false
		if(con == ImageCon.FlagEquals):
			if(ServiceLocator.safe_get_service(&"MainScene").getFlag(args[0]) != args[1]):
				return false
		if(con == ImageCon.FlagAbove):
			if(ServiceLocator.safe_get_service(&"MainScene").getFlag(args[0]) <= args[1]):
				return false
		if(con == ImageCon.FlagBelow):
			if(ServiceLocator.safe_get_service(&"MainScene").getFlag(args[0]) >= args[1]):
				return false
		if(con == ImageCon.FlagAboveOrEqual):
			if(ServiceLocator.safe_get_service(&"MainScene").getFlag(args[0]) < args[1]):
				return false
		if(con == ImageCon.FlagBelowOrEqual):
			if(ServiceLocator.safe_get_service(&"MainScene").getFlag(args[0]) > args[1]):
				return false
	return true
