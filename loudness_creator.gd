extends Control
@onready var sound_item_list: ItemList = %SoundItemList
var soundPaths:Array = []

var spectrum:AudioEffectSpectrumAnalyzerInstance
@onready var calculate_button: Button = %CalculateButton
@onready var calculate_all_button: Button = %CalculateAllButton


func _ready() -> void:
	updateSoundList()
	
	spectrum = AudioServer.get_bus_effect_instance(1, 0)

func updateSoundList():
	sound_item_list.clear()
	
	soundPaths = getAllSoundPathsFromFolder(getBaseSoundFolder())
	for path in soundPaths:
		sound_item_list.add_item(path.get_file())

func getBaseSoundFolder() -> String:
	var theFolder:String = OS.get_executable_path().get_base_dir()
	return theFolder

func getAllSoundPathsFromFolder(_folder:String, _extentions:Array = ["ogg", "wav", "mp3"]) -> Array:
	var result:Array = []
	
	var dir = DirAccess.open(_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
				#print("Found directory: " + file_name)
			else:
				if(file_name.get_extension() in _extentions):
					var full_path = _folder.path_join(file_name)
					result.append(full_path)
			file_name = dir.get_next()
	
	return result

var currentResource:SoundLoudnessResource
var currentSoundPath:String = ""

var pickedFrameTime:float = 1.0/10.0
func _on_calculate_button_pressed() -> void:
	if(stepAmount > 0):
		print("We're busy!")
		return
	if(sound_item_list.get_selected_items().is_empty()):
		return
	var thePath:String = soundPaths[sound_item_list.get_selected_items()[0]]

	var theSound:AudioStream = loadSound(thePath)
	var theLen:float = theSound.get_length()
	
	Audio.playSound(theSound)
	workTime = pickedFrameTime
	stepAmount = int(ceil(theLen / pickedFrameTime))
	currentResource = SoundLoudnessResource.new()
	currentResource.frameTime = pickedFrameTime
	currentSoundPath = thePath
	calculate_button.disabled = true
	calculate_all_button.disabled = true
	
var scanAllMode:bool = false
var scanAllIndx:int = 0

var stepAmount:int = 0
var workTime:float = 0.0

func _process(_delta: float) -> void:
	#calcMaxEnergy()
	#print(calcMaxEnergy())
	if(stepAmount > 0):
		if(workTime <= 0.0):
			workTime += pickedFrameTime
			var energy := calcMaxEnergy()
			#print(energy)
			currentResource.data.append(energy)
			stepAmount -= 1
			if(stepAmount <= 0):
				#print("DONE")
				calculate_button.disabled = false
				calculate_all_button.disabled = false
				#ResourceSaver.save(currentResource, currentSoundPath+".tres")
				var _data:Dictionary = {
					frameTime = currentResource.frameTime,
					data = currentResource.data,
				}
				var file := FileAccess.open(currentSoundPath+".loud", FileAccess.WRITE)
				file.store_string(var_to_str(_data))

				if(scanAllMode):
					batchScanDo()
				return
		workTime -= _delta

func calcMaxEnergy() -> float:
	#if(true):
		#
		##print(spectrum.get_magnitude_for_frequency_range(0.0, 11050.0))
		#var magnitude:= spectrum.get_magnitude_for_frequency_range(0.0, 11050.0).length()
		#var energy := linear_to_db(magnitude)
		#return energy
	var maxEnergy:float = -9999.0
	const VU_COUNT = 16
	const FREQ_MAX = 11050.0
	const MIN_DB = 60
	
	var prev_hz:float= 0.0

	for _i in range(VU_COUNT+1):
		var hz:float = _i * FREQ_MAX / VU_COUNT
		var magnitude:= spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		#var energy := linear_to_db(magnitude)
		var energy := clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		#var height := energy * HEIGHT * HEIGHT_SCALE
		if(energy > maxEnergy):
			maxEnergy = energy
		prev_hz = hz
	return maxEnergy

func loadSound(_path:String) -> AudioStream:
	var theSound:AudioStream
	var theExt:String = _path.get_extension()
	if(theExt == "ogg"):
		theSound = AudioStreamOggVorbis.load_from_file(_path)
	if(theExt == "wav"):
		theSound = AudioStreamWAV.load_from_file(_path)
	if(theExt == "mp3"):
		theSound = AudioStreamMP3.load_from_file(_path)
	return theSound

func batchScanDo():
	if(scanAllIndx >= soundPaths.size()):
		scanAllMode = false
		#print("DONE BATCH!")
		return
	sound_item_list.select(scanAllIndx)
	_on_calculate_button_pressed()
	scanAllIndx += 1

func _on_calculate_all_button_pressed() -> void:
	scanAllMode = true
	if(sound_item_list.get_selected_items().size() > 0):
		scanAllIndx = sound_item_list.get_selected_items()[0]
	else:
		scanAllIndx = 0
	
	batchScanDo()
