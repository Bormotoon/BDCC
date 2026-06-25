extends SceneBase

var npcID = ""
var rideMode = ""
var isFirstRide = true

func _init():
	sceneID = "SybianRidingScene"

func resolveCustomCharacterName(_charID):
	if(_charID == "npc"):
		return npcID

func _run():
	if(state == ""):
		playAnimation(StageScene.Sybian, "idle", {pc="pc", bodyState={naked=true}})
		saynn("Feeling horny, you decide to give your sybian machine a try.")

		if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
			saynn("Small silicone dildos slide up your holes as you lower yourself onto it, the soft texture brushing against your sensitive flesh.")

			saynn("Your clit rests on a little ridged platform, the sensations sending shivers down your spine already.")

		elif (ServiceLocator.safe_get_service(&"Player").isWearingChastityCage()):
			saynn("Small silicone dildo slides up your tailhole as you lower yourself onto it, the soft texture brushing against your sensitive flesh.")

			saynn("Your taint rests on a little ridged platform, the sensations sending shivers down your spine.")

		elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
			saynn("Small silicone dildo slides up your tailhole as you lower yourself onto it, the soft texture brushing against your sensitive flesh.")

			saynn("Your taint rests on a little ridged platform, the sensations sending shivers down your spine and making your cock twitch slightly.")

		else:
			saynn("Small silicone dildo slides up your tailhole as you lower yourself onto it, the soft texture brushing against your sensitive flesh.")

			saynn("Your taint rests on a little ridged platform, the sensations sending shivers down your spine.")

		addButton("Turn it on", "Start enjoying the vibrations", "turn_on_slave_check")
	if(state == "slave_wants_help"):
		playAnimation(StageScene.SybianOral, "idle", {pc="pc", npc=npcID, bodyState={naked=true}})
		saynn("You grab the sybian's little remote and flick the power switch.")

		if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
			saynn("The machine under you kicks into action, the dildos start vibrating inside you at an idly pace.. your pussy slit getting slightly wet around the toys already, the platform under your clit shifts ever so slightly, stimulating you.")

		elif (ServiceLocator.safe_get_service(&"Player").isWearingChastityCage()):
			saynn("The machine under you kicks into action, the dildo starts vibrating inside you at an idly pace, it's curved to perfectly massage your little prostate..")

			saynn("Your locked away member tries to get hard but the metal keeps it in check, the platform under your taint shifts ever so slightly, stimulating you.")

		elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
			saynn("The machine under you kicks into action, the dildo starts vibrating inside you at an idly pace, it's curved to perfectly massage your little prostate..")

			saynn("It's enough to make your {pc.penis} drip pre, the platform under your taint shifts ever so slightly, stimulating you.")

		else:
			saynn("The machine under you kicks into action, the dildo starts vibrating inside you at an idly pace.")

			saynn("It's enough to make you let out a cute sigh, the platform under your taint shifts ever so slightly, stimulating you.")

		saynn("One of your slaves, {npc.name}, seems to be unable to pull {npc.his} eyes off of you.")

		saynn("You can order {npc.him} to come closer to have some fun with {npc.him}.. or just ride the machine alone.")

		var theNpc = getCharacter(npcID)
		if (theNpc.hasReachablePenis()):
			addButtonWithChecks("Suck them off", "Suck their cock while riding the sybian", "do_ride_while_suck", [], [[ButtonChecks.NotOralBlocked]])
		if (theNpc.hasReachableVagina()):
			addButtonWithChecks("Eat them out", "Lick their pussy while riding the sybian", "do_ride_while_lick", [], [[ButtonChecks.NotOralBlocked]])
		addButton("Just ride", "Ignore them", "just_ride")
		addButton("Hump sybian", "Ignore them and hump the sybian", "just_hump")
		if (ServiceLocator.safe_get_service(&"Player").hasReachablePenis() && ServiceLocator.safe_get_service(&"Player").getWornCondom() == null):
			addButtonWithChecks("Put on a condom", "Wear a condom while doing this", "put_a_condom_on", [], [[ButtonChecks.HasCondoms]])
	if(state == "alone_pick_how_ride"):
		saynn("You grab the sybian's little remote and flick the power switch.")

		if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
			saynn("The machine under you kicks into action, the dildos start vibrating inside you at an idly pace.. your pussy slit getting slightly wet around the toys already, the platform under your clit shifts ever so slightly, stimulating you.")

		elif (ServiceLocator.safe_get_service(&"Player").isWearingChastityCage()):
			saynn("The machine under you kicks into action, the dildo starts vibrating inside you at an idly pace, it's curved to perfectly massage your little prostate..")

			saynn("Your locked away member tries to get hard but the metal keeps it in check, the platform under your taint shifts ever so slightly, stimulating you.")

		elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
			saynn("The machine under you kicks into action, the dildo starts vibrating inside you at an idly pace, it's curved to perfectly massage your little prostate..")

			saynn("It's enough to make your {pc.penis} drip pre, the platform under your taint shifts ever so slightly, stimulating you.")

		else:
			saynn("The machine under you kicks into action, the dildo starts vibrating inside you at an idly pace.")

			saynn("It's enough to make you let out a cute sigh, the platform under your taint shifts ever so slightly, stimulating you.")

		saynn("How do you want to enjoy it?")

		addButton("Just ride", "Ignore them", "just_ride")
		addButton("Hump sybian", "Ignore them and hump the sybian", "just_hump")
		if (ServiceLocator.safe_get_service(&"Player").hasReachablePenis() && ServiceLocator.safe_get_service(&"Player").getWornCondom() == null):
			addButtonWithChecks("Put on a condom", "Wear a condom while doing this", "put_a_condom_on", [], [[ButtonChecks.HasCondoms]])
		addDisabledButton("Slaves", "You don't have any slaves that can join")
	if(state == "sybian_loop"):
		var pcArousal = ServiceLocator.safe_get_service(&"Player").getArousal()
		var isHighArousal = (pcArousal < 0.5)
		if (rideMode == ""):
			if (isHighArousal):
				playAnimation(StageScene.Sybian, "ride", {pc="pc", bodyState={naked=true}})
			else:
				playAnimation(StageScene.Sybian, "intense", {pc="pc", bodyState={naked=true}})
			if (isFirstRide):
				if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
					saynn("The machine hums as you begin to ride it with slow, deliberate movements, its toys pleasure your eager holes. Feels good already..")

				elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
					saynn("The machine hums as you begin to ride it with slow, deliberate movements, its toy pleasuring your eager fuckhole, your {pc.penis} twitching and dripping pre. Feels good already..")

				else:
					saynn("The machine hums as you begin to ride it with slow, deliberate movements, its toy pleasuring your eager fuckhole. Feels good already..")

			else:
				if (RNG.chance(33)):
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("Your pussy clenches around the silicone shaft, the ridges and bumps teasing your sensitive clit with each motion while the anal dildo keeps you feeling stuffed.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("Your {pc.analStretch} {anus} clenches around the silicone shaft while your prostate is being stimulated, the ridges and bumps teasing your taint with each motion, your {pc.penis} leaking pre.")

					else:
						saynn("Your {pc.analStretch} {anus} clenches around the silicone shaft while your pleasure spot is being stimulated, the ridges and bumps teasing your taint with each motion.")

				elif (RNG.chance(33)):
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("Your hips rock back and forth, driving the vibrating dildos deeper into your slick, eager pussy and {pc.analStretch}, clenching anus as you lose yourself in the throes of pleasure.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("Your hips rock back and forth, driving the vibrating dildo deeper into your needy, eager anus as you lose yourself in the throes of pleasure, your {pc.penis} twitching wildly.")

					else:
						saynn("Your hips rock back and forth, driving the vibrating dildo deeper into your needy, eager anus as you lose yourself in the throes of pleasure.")

				else:
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("The ridged platform presses against your clit, sending waves of pleasure radiating through your body with each pass as you ride the sybian, lost in a haze of ecstasy.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("The ridged platform presses against your taint, sending waves of pleasure radiating through your body with each pass as you ride the sybian, lost in a haze of ecstasy.")

					else:
						saynn("The ridged platform presses against your taint, sending waves of pleasure radiating through your body with each pass as you ride the sybian, lost in a haze of ecstasy.")

				if (RNG.chance(20)):
					saynn("Your moans grow louder, filling the air with the sweet sounds of your pleasure.")

				elif (RNG.chance(20)):
					saynn("Your body can't keep itself from squirming, every movement driving you closer and closer..")

				if (pcArousal > 0.8):
					if (RNG.chance(33)):
						saynn("Your body trembles with anticipation, the orgasm getting closer and closer.")

					elif (RNG.chance(33)):
						saynn("You can feel the tension building within you as you approach the point of no return.")

					else:
						saynn("Your muscles tense with anticipation, every nerve in your body on fire as you feel yourself on the brink of release.")

		elif (rideMode == "hump"):
			if (isHighArousal):
				playAnimation(StageScene.Sybian, "hump", {pc="pc", bodyState={naked=true}})
			else:
				playAnimation(StageScene.Sybian, "humpfast", {pc="pc", bodyState={naked=true}})
			if (isFirstRide):
				if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
					saynn("Rather than ride the sybian peacefully, you decide to hump the fuck out of it, the two vibrating dildos sliding inside your slick holes as you ride the machine.")

				elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
					saynn("Rather than ride the sybian peacefully, you decide to hump the fuck out of it, the vibrating dildo sliding inside your needy hole and making your {pc.penis} leak as you ride the machine.")

				else:
					saynn("Rather than ride the sybian peacefully, you decide to hump the fuck out of it, the vibrating dildo sliding inside your needy hole as you ride the machine.")

			else:
				if (RNG.chance(33)):
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("The vibrating dildos slide in and out of your wet, eager pussy and {pc.analStretch} anus, your hand stimulating your clit.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("The vibrating dildos slide in and out of your eager {pc.analStretch} anus, your hand rubbing your {pc.penis}.")

					else:
						saynn("The vibrating dildos slide in and out of your eager {pc.analStretch} anus, your hand rubbing your taint.")

				elif (RNG.chance(33)):
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("The silicone shafts plunge deep into your hungry holes, filling you with an insatiable craving for more as you hump the sybian, lost in your own desire.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("The silicone shafts plunge deep into your hungry hole, filling you with an insatiable craving for more as you hump the sybian, your {pc.penis} bobs up and down while you are lost in your own desire.")

					else:
						saynn("The silicone shafts plunge deep into your hungry hole, filling you with an insatiable craving for more as you hump the sybian, lost in your own desire.")

				else:
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("Your {pussy} and {anus} clench around the silicone shafts, milking them for all they're worth as you hump the sybian.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("Your {pc.analStretch} {anus} clenches around the silicone shaft, milking it for all it's worth as you hump the sybian.")

					else:
						saynn("Your {pc.analStretch} {anus} clenches around the silicone shaft, milking it for all it's worth as you hump the sybian.")

				if (RNG.chance(20)):
					saynn("Your moans grow louder, filling the air with the sweet sounds of your pleasure.. while you keep pushing through and riding that sybian.")

				elif (RNG.chance(20)):
					saynn("Your body can't keep itself from squirming, every movement driving you closer and closer..")

				if (pcArousal > 0.8):
					if (RNG.chance(33)):
						saynn("Your body trembles with anticipation, the orgasm getting closer and closer.")

					elif (RNG.chance(33)):
						saynn("You can feel the tension building within you as you approach the point of no return.")

					else:
						saynn("Your muscles tense with anticipation, every nerve in your body on fire as you feel yourself on the brink of release.")

		elif (rideMode == "suck"):
			if (isHighArousal):
				playAnimation(StageScene.SybianOral, "blowjob", {pc="pc", npc=npcID, bodyState={naked=true}, npcBodyState={exposedCrotch=true, hard=true}})
			else:
				playAnimation(StageScene.SybianOral, "blowjobfast", {pc="pc", npc=npcID, bodyState={naked=true}, npcBodyState={exposedCrotch=true, hard=true}})
			if (isFirstRide):
				saynn("You call {npc.name} to get closer.. before pulling {npc.his} {npc.penis} out and getting it into your mouth, using your tongue to pleasure it..")

				if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
					saynn("At the same time, you begin to ride the humming machine with slow, deliberate movements, its toys pleasuring your eager holes. Feels so good to have all your holes stuffed..")

				elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
					saynn("At the same time, you begin to ride the humming machine with slow, deliberate movements, its toy pleasuring your eager fuckhole, your {pc.penis} twitching and dripping pre. Feels so good to have all your holes stuffed..")

				else:
					saynn("At the same time, you begin to ride the humming machine with slow, deliberate movements, its toy pleasuring your eager fuckhole. Feels so good to have all your holes stuffed..")

			else:
				if (RNG.chance(33)):
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("You suck that cock eagerly, dragging your tongue over its length. Your pussy clenches around the silicone shaft, the ridges and bumps teasing your sensitive clit with each motion while the anal dildo keeps you feeling stuffed.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("You suck that cock eagerly, dragging your tongue over its length. Your {pc.analStretch} {anus} clenches around the silicone shaft while your prostate is being stimulated, the ridges and bumps teasing your taint with each motion, your {pc.penis} leaking pre.")

					else:
						saynn("You suck that cock eagerly, dragging your tongue over its length. Your {pc.analStretch} {anus} clenches around the silicone shaft while your pleasure spot is being stimulated, the ridges and bumps teasing your taint with each motion.")

				elif (RNG.chance(33)):
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("Your hips rock back and forth, driving the vibrating dildos deeper into your slick, eager pussy and {pc.analStretch}, clenching anus as your throat is being stretched by that nice cock.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("Your hips rock back and forth, driving the vibrating dildo deeper into your needy, eager anus as your throat is being stretched by that nice cock, your {pc.penis} twitching wildly.")

					else:
						saynn("Your hips rock back and forth, driving the vibrating dildo deeper into your needy, eager anus as your throat is being stretched by that nice cock.")

				else:
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("The ridged platform presses against your clit, sending waves of pleasure radiating through your body with each pass as you ride the sybian and pleasure the cock of your slave at the same time.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("The ridged platform presses against your taint, sending waves of pleasure radiating through your body with each pass as you ride the sybian and pleasure the cock of your slave at the same time.")

					else:
						saynn("The ridged platform presses against your taint, sending waves of pleasure radiating through your body with each pass as you ride the sybian and pleasure the cock of your slave at the same time.")

				if (RNG.chance(20)):
					saynn("Your muffled moans grow louder, filling the air with the sweet sounds of your pleasure mixed with the wet slurping.")

				elif (RNG.chance(20)):
					saynn("Your body can't keep itself from squirming, every movement driving you closer and closer..")

				if (pcArousal > 0.8):
					if (RNG.chance(33)):
						saynn("Your body trembles with anticipation, the orgasm getting closer and closer. The cock that you're sucking feels like it's about to burst too..")

					elif (RNG.chance(33)):
						saynn("You can feel the tension building within you as you approach the point of no return. Just like the cock in your mouth..")

					else:
						saynn("Your muscles tense with anticipation, every nerve in your body on fire as you feel yourself on the brink of release. The {npc.penis} is throbbing in your mouth.")

		elif (rideMode == "lick"):
			if (isHighArousal):
				playAnimation(StageScene.SybianOral, "lick", {pc="pc", npc=npcID, bodyState={naked=true}, npcBodyState={exposedCrotch=true, hard=true}})
			else:
				playAnimation(StageScene.SybianOral, "lickfast", {pc="pc", npc=npcID, bodyState={naked=true}, npcBodyState={exposedCrotch=true, hard=true}})
			if (isFirstRide):
				saynn("You call {npc.name} to get closer.. before getting {npc.his} {npc.pussyStretch} pussy exposed and pressing your face into it, your tongue out and ready to please.")

				if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
					saynn("At the same time, you begin to ride the humming machine with slow, deliberate movements, its toys pleasuring your eager holes. Feels so good to have all your holes busy..")

				elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
					saynn("At the same time, you begin to ride the humming machine with slow, deliberate movements, its toy pleasuring your eager fuckhole, your {pc.penis} twitching and dripping pre. Feels so good to have all your holes busy..")

				else:
					saynn("At the same time, you begin to ride the humming machine with slow, deliberate movements, its toy pleasuring your eager fuckhole. Feels so good to have all your holes busy..")

			else:
				if (RNG.chance(33)):
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("You eat that {pussy} eagerly, dragging your tongue along the petals and licking the clit. Your own pussy clenches around the silicone shaft, the ridges and bumps teasing your sensitive clit with each motion while the anal dildo keeps you feeling stuffed.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("You eat that {pussy} eagerly, dragging your tongue along the petals and licking the clit. Your {pc.analStretch} {anus} clenches around the silicone shaft while your prostate is being stimulated, the ridges and bumps teasing your taint with each motion, your {pc.penis} leaking pre.")

					else:
						saynn("You eat that {pussy} eagerly, dragging your tongue along the petals and licking the clit. Your {pc.analStretch} {anus} clenches around the silicone shaft while your pleasure spot is being stimulated, the ridges and bumps teasing your taint with each motion.")

				elif (RNG.chance(33)):
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("Your hips rock back and forth, driving the vibrating dildos deeper into your slick, eager pussy and {pc.analStretch}, clenching anus as your tongue is exploring the inner walls of another wet slit.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("Your hips rock back and forth, driving the vibrating dildo deeper into your needy, eager anus as your tongue is exploring the slick inner walls of that {pussy}, your {pc.penis} twitching wildly.")

					else:
						saynn("Your hips rock back and forth, driving the vibrating dildo deeper into your needy, eager anus as your tongue is exploring the slick inner walls of that {pussy}.")

				else:
					if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
						saynn("The ridged platform presses against your clit, sending waves of pleasure radiating through your body with each pass as you ride the sybian and pleasure your slave's {npc.pussyStretch} {pussy} at the same time.")

					elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
						saynn("The ridged platform presses against your taint, sending waves of pleasure radiating through your body with each pass as you ride the sybian and pleasure your slave's {npc.pussyStretch} {pussy} at the same time.")

					else:
						saynn("The ridged platform presses against your taint, sending waves of pleasure radiating through your body with each pass as you ride the sybian and pleasure your slave's {npc.pussyStretch} {pussy} at the same time.")

				if (RNG.chance(20)):
					saynn("Your muffled moans grow louder, filling the air with the sweet sounds of your pleasure mixed with the wet slurping.")

				elif (RNG.chance(20)):
					saynn("Your body can't keep itself from squirming, every movement driving you closer and closer..")

				if (pcArousal > 0.8):
					if (RNG.chance(33)):
						saynn("Your body trembles with anticipation, the orgasm getting closer and closer. The pussy that you're licking feels like it's close too..")

					elif (RNG.chance(33)):
						saynn("You can feel the tension building within you as you approach the point of no return. Just like the pussy folds that your lips are pressed against..")

					else:
						saynn("Your muscles tense with anticipation, every nerve in your body on fire as you feel yourself on the brink of release. The pussy is twitching wildly from your licks.")

		if (pcArousal >= 1.0):
			saynn("You're about to cum..")

			addButton("Cum!", "Time to cum", "do_cum")
		else:
			addButton("Continue", "See what happens next", "do_next_loop")
	if(state == "do_cum"):
		if (rideMode == ""):
			playAnimation(StageScene.Sybian, "ride", {pc="pc", pcCum=true, bodyState={naked=true, hard=true}})
		elif (rideMode == "hump"):
			playAnimation(StageScene.Sybian, "hump", {pc="pc", pcCum=true, bodyState={naked=true, hard=true}})
		if (ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
			saynn("Your entire body trembles with the force of your climax, your pussy and ass spasming around the dildos as you succumb to the overwhelming waves of pleasure crashing over you.")

		elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
			saynn("Your entire body trembles with the force of your climax, your ass spasming around the dildo, your taint twitching as you succumb to the overwhelming waves of pleasure crashing over you.")

		if (rideMode == "suck"):
			playAnimation(StageScene.SybianOral, "blowjob", {pc="pc", pcCum=true, npc=npcID, bodyState={naked=true, hard=true}, npcBodyState={exposedCrotch=true, hard=true}})
			saynn("The taste of your slave's hot, thick {npc.cum} fills your mouth as you swallow eagerly, the sensation sending sparks of pleasure shooting through your body.")

		elif (rideMode == "lick"):
			playAnimation(StageScene.SybianOral, "lick", {pc="pc", pcCum=true, npc=npcID, bodyState={naked=true, hard=true}, npcBodyState={exposedCrotch=true, hard=true}})
			saynn("Your slave's pussy gushes with sweet nectar, her juices coating your face as you eagerly lap at her dripping cunt, lost in the intoxicating taste of her arousal.")

		if (ServiceLocator.safe_get_service(&"Player").isWearingChastityCage()):
			saynn("Your locked up cock is throbbing while shooting {pc.cum} through the hole in the little chastity cage, your prostate being milked hard!")

		elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis() && ServiceLocator.safe_get_service(&"Player").getWornCondom() != null):
			saynn("Your {pc.penis} is throbbing while shooting {pc.cum} into the condom, filling it fast as your prostate is being milked hard!")

		elif (ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
			saynn("Your {pc.penis} is throbbing while shooting strings of {pc.cum}, leaving quite a mess on the floor, your prostate being milked hard!")

		saynn("You're left heavily panting after that great orgasm.")

		addButton("Continue", "See what happens next", "endthescene_recovercondom")

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return

	if(_action == "turn_on_slave_check"):
		processTime(5*60)
		
		var possibleSlaveIDs = []
		var slaves = ServiceLocator.safe_get_service(&"MainScene").getPCSlavesIDs()
		for slaveID in slaves:
			var theChar:DynamicCharacter = getCharacter(slaveID)
			if(theChar == null || !theChar.isSlaveToPlayer()):
				continue
			var npcSlavery:NpcSlave = theChar.getNpcSlavery()
			if(npcSlavery.isDoingActivity()):
				continue
			if(npcSlavery.isActivelyResisting() || npcSlavery.isMindBroken()):
				continue
			if(theChar.hasReachablePenis() || theChar.hasReachableVagina()):
				possibleSlaveIDs.append(slaveID)
		
		ServiceLocator.safe_get_service(&"Player").addLust(10)
		ServiceLocator.safe_get_service(&"Player").addArousal(ServiceLocator.safe_get_service(&"Player").getLustLevel() * 0.2)
		
		if(RNG.chance(100) && possibleSlaveIDs.size() > 0):
			npcID = RNG.pick(possibleSlaveIDs)
			addCharacter(npcID)
			setState("slave_wants_help")
			return	
		
		setState("alone_pick_how_ride")
		return

	if(_action == "do_ride_while_suck"):
		setState("sybian_loop")
		rideMode = "suck"
		return

	if(_action == "do_ride_while_lick"):
		setState("sybian_loop")
		rideMode = "lick"
		return

	if(_action == "just_ride"):
		if(npcID != ""):
			removeCharacter(npcID)
		setState("sybian_loop")
		rideMode = ""
		return

	if(_action == "just_hump"):
		if(npcID != ""):
			removeCharacter(npcID)
		setState("sybian_loop")
		rideMode = "hump"
		return

	if(_action == "put_a_condom_on"):
		var breakChance = ServiceLocator.safe_get_service(&"Player").useWorstCondom()
		var condomItem:ItemBase = GlobalRegistry.createItem("UsedCondom")
		condomItem.breakChance = breakChance
		ServiceLocator.safe_get_service(&"Player").getInventory().forceEquipStoreOther(condomItem)
		addMessage("You put an empty condom on!")
		return

	if(_action == "do_cum"):
		processTime(5*60)
		ServiceLocator.safe_get_service(&"Player").orgasmFrom("pc")
		ServiceLocator.safe_get_service(&"Player").setArousal(0.0)
		if(rideMode == "suck"):
			var theNpc = getCharacter(npcID)
			ServiceLocator.safe_get_service(&"Player").gotThroatFuckedBy(npcID)
			ServiceLocator.safe_get_service(&"Player").cummedInMouthBy(npcID)
			theNpc.orgasmFrom("pc")
			if(theNpc.isSlaveToPlayer()):
				theNpc.getNpcSlavery().addUnhappiness(-10.0)
		if(rideMode == "lick"):
			var theNpc = getCharacter(npcID)
			ServiceLocator.safe_get_service(&"Player").cummedInMouthBy(npcID, FluidSource.Vagina, randf_range(0.3, 0.7))
			ServiceLocator.safe_get_service(&"Player").cummedOnBy(npcID, FluidSource.Vagina, randf_range(0.3, 0.7))
			theNpc.orgasmFrom("pc")
			if(theNpc.isSlaveToPlayer()):
				theNpc.getNpcSlavery().addUnhappiness(-10.0)

	if(_action == "do_next_loop"):
		processTime(1*60)
		isFirstRide = false
		ServiceLocator.safe_get_service(&"Player").addLust(10)
		ServiceLocator.safe_get_service(&"Player").addArousal(ServiceLocator.safe_get_service(&"Player").getLustLevel() * 0.2)
		setState("sybian_loop")
		return

	if(_action == "endthescene_recovercondom"):
		if(ServiceLocator.safe_get_service(&"Player").getWornCondom() != null):
			ServiceLocator.safe_get_service(&"Player").getInventory().unequipItem(ServiceLocator.safe_get_service(&"Player").getWornCondom())
			addMessage("You store the used condom!")
		playAnimation(StageScene.Solo, "stand")
		ServiceLocator.safe_get_service(&"Player").setArousal(0.0)
		endScene()
		return

	setState(_action)

func saveData():
	var data = super.saveData()

	data["npcID"] = npcID
	data["rideMode"] = rideMode
	data["isFirstRide"] = isFirstRide

	return data

func loadData(data):
	super.loadData(data)

	npcID = SAVE.loadVar(data, "npcID", "")
	rideMode = SAVE.loadVar(data, "rideMode", "")
	isFirstRide = SAVE.loadVar(data, "isFirstRide", true)
