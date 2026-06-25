extends SceneBase
class_name HK_SessionInductionBase

var bodyId: String

func onInduction(_args = []):
	ServiceLocator.safe_get_service(&"MainScene").setFlag("HypnokinkModule.SoftOptIn", true)
	ServiceLocator.safe_get_service(&"Player").addEffect(StatusEffect.UnderHypnosis)
	ServiceLocator.safe_get_service(&"Player").addEffect(StatusEffect.Suggestible, [30])
	processTime(10*60)
	bodyId = _args[0]
	
func afterInduction():
	runScene(bodyId)

func saveData():
	var data = super.saveData()
	data["bodyId"] = bodyId
	
	return data

func loadData(data):
	super.loadData(data)
	bodyId = SAVE.loadVar(bodyId, "bodyId", null)
