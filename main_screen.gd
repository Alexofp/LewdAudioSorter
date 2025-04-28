extends Control

enum {
	MOUTH_OPENED,
	MOUTH_CLOSED,
}

enum {
	SPEED_SLOW,
	SPEED_MEDIUM,
	SPEED_FAST,
}

enum {
	INTENSITY_LOW,
	INTENSITY_MEDIUM,
	INTENSITY_HIGH,
}

var currentMouth:int = MOUTH_OPENED
var currentSpeed:int = SPEED_SLOW

var soundPaths:Array = []

@onready var mouth_open_button: Button = %MouthOpenButton
@onready var mouth_closed_button: Button = %MouthClosedButton
@onready var speed_slow_button: Button = %SpeedSlowButton
@onready var speed_medium_button: Button = %SpeedMediumButton
@onready var speed_fast_button: Button = %SpeedFastButton
@onready var sort_amount_label: Label = %SortAmountLabel
@onready var file_name_label: Label = %FileNameLabel
@onready var length_label: Label = %LengthLabel
@onready var len_slow_spin_box: SpinBox = %LenSlowSpinBox
@onready var len_fast_spin_box: SpinBox = %LenFastSpinBox
@onready var gather_folder_window: ConfirmationDialog = %GatherFolderWindow
@onready var gather_folder_item_list: ItemList = %GatherFolderItemList


func _ready() -> void:
	Audio.playNode = self
	#print(OS.get_executable_path())
	updateMouthSpeedButtons()
	
	#print(getAllSoundPathsFromFolder(OS.get_executable_path().get_base_dir()))
	scanPaths(true)

func updateMouthSpeedButtons():
	mouth_open_button.disabled = (currentMouth == MOUTH_OPENED)
	mouth_closed_button.disabled = (currentMouth == MOUTH_CLOSED)
	
	speed_slow_button.disabled = (currentSpeed == SPEED_SLOW)
	speed_medium_button.disabled = (currentSpeed == SPEED_MEDIUM)
	speed_fast_button.disabled = (currentSpeed == SPEED_FAST)

func _on_mouth_open_button_pressed() -> void:
	currentMouth = MOUTH_OPENED
	updateMouthSpeedButtons()

func _on_mouth_closed_button_pressed() -> void:
	currentMouth = MOUTH_CLOSED
	updateMouthSpeedButtons()

func _on_speed_slow_button_pressed() -> void:
	currentSpeed = SPEED_SLOW
	updateMouthSpeedButtons()

func _on_speed_medium_button_pressed() -> void:
	currentSpeed = SPEED_MEDIUM
	updateMouthSpeedButtons()

func _on_speed_fast_button_pressed() -> void:
	currentSpeed = SPEED_FAST
	updateMouthSpeedButtons()

func scanPaths(updateSpeedButtons:bool = false):
	soundPaths = getAllSoundPathsFromFolder(OS.get_executable_path().get_base_dir())
	
	updateCurrentPath(updateSpeedButtons)
	
func updateCurrentPath(updateSpeedButtons:bool = false):
	sort_amount_label.text = "Files left to sort: "+str(soundPaths.size())
	
	if(soundPaths.is_empty()):
		file_name_label.text = "Current file name: ----"
		length_label.text = "Length: ---"
		return
	var currentFilePath:String = soundPaths[0]
	file_name_label.text = "Current file name: "+currentFilePath.get_file()
	
	var soundLen:float = getSoundLength(currentFilePath)
	length_label.text = "Length: "+str( round(soundLen*100.0)/100.0 )+" s"
	if(updateSpeedButtons):
		var slowLenLimit:float = len_slow_spin_box.value
		var fastLenLimit:float = len_fast_spin_box.value
		
		if(soundLen >= slowLenLimit):
			currentSpeed = SPEED_SLOW
		elif(soundLen <= fastLenLimit):
			currentSpeed = SPEED_FAST
		else:
			currentSpeed = SPEED_MEDIUM
		updateMouthSpeedButtons()

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

func getAllFolders(_folder:String) -> Array:
	var result:Array = []
	
	var dir = DirAccess.open(_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var full_path = _folder.path_join(file_name)
				result.append(full_path)
			else:
				#if(file_name.get_extension() in _extentions):
				#	var full_path = _folder.path_join(file_name)
				#	result.append(full_path)
				pass
			file_name = dir.get_next()
	
	return result

func getFreeNumberFileNameFromFolder(_folder:String, _extentions:Array = ["ogg", "wav", "mp3"]) -> String:
	var theFiles:Array = getAllSoundPathsFromFolder(_folder, _extentions)
	var theFilesDict:Dictionary = {}
	for filePathA in theFiles:
		var filePath:String = filePathA
		theFilesDict[filePath.get_file().get_basename()] = true
	
	var fileI:int = 1
	while(theFilesDict.has(str(fileI))):
		fileI += 1
	return str(fileI)

func getSoundLength(_path:String) -> float:
	var theExt:String = _path.get_extension()
	if(theExt == "ogg"):
		var theSound := AudioStreamOggVorbis.load_from_file(_path)
		return theSound.get_length()
	if(theExt == "wav"):
		var theSound := AudioStreamWAV.load_from_file(_path)
		return theSound.get_length()
	if(theExt == "mp3"):
		var theSound := AudioStreamMP3.load_from_file(_path)
		return theSound.get_length()
	
	assert(false, "Can't get length of sounds with this extension: "+str(theExt))
	return 0.0

func _on_preview_button_pressed() -> void:
	if(soundPaths.is_empty()):
		return
	var currentFilePath:String = soundPaths[0]
	var _path:String = currentFilePath
	
	var theSound:AudioStream
	var theExt:String = _path.get_extension()
	if(theExt == "ogg"):
		theSound = AudioStreamOggVorbis.load_from_file(_path)
	if(theExt == "wav"):
		theSound = AudioStreamWAV.load_from_file(_path)
	if(theExt == "mp3"):
		theSound = AudioStreamMP3.load_from_file(_path)
	
	if(theSound):
		Audio.playSound(theSound)

func getSoundFolderNameBySettings(_mouth:int, _intensity:int, _speed:int) -> String:
	var mouthName:String = "Open"
	var intenseName:String = "Low"
	var speedName:String = "Slow"
	if(_mouth == MOUTH_CLOSED):
		mouthName = "Closed"
	if(_intensity == INTENSITY_MEDIUM):
		intenseName = "Medium"
	if(_intensity == INTENSITY_HIGH):
		intenseName = "High"
	if(_speed == SPEED_MEDIUM):
		speedName = "Medium"
	if(_speed == SPEED_FAST):
		speedName = "Fast"
	return mouthName+intenseName+speedName

func makeFolder(_folder:String):
	DirAccess.make_dir_recursive_absolute(_folder)

func getBaseSoundFolder() -> String:
	var theFolder:String = OS.get_executable_path().get_base_dir()
	# if last folder name is Unsorted, go up a folder
	return theFolder

func sortCurrentToIntensity(newIntensity:int):
	if(soundPaths.is_empty()):
		return
	var currentFilePath:String = soundPaths[0]
	
	var baseFolder:String = getBaseSoundFolder()
	var sortedFolder:String = getSoundFolderNameBySettings(currentMouth, newIntensity, currentSpeed)
	
	var finalFolder:String = baseFolder.path_join(sortedFolder)
	
	makeFolder(finalFolder)
	var freeNumberName:String = getFreeNumberFileNameFromFolder(finalFolder)
	
	var finalFilePath:String = finalFolder.path_join(freeNumberName+"."+currentFilePath.get_extension())
	
	DirAccess.rename_absolute(currentFilePath, finalFilePath)
	#print("MOVE FROM: '"+currentFilePath+"' TO '"+finalFilePath+"'")
	scanPaths(true)
	_on_preview_button_pressed()

func _on_intensity_low_button_pressed() -> void:
	sortCurrentToIntensity(INTENSITY_LOW)

func _on_intensity_medium_button_pressed() -> void:
	sortCurrentToIntensity(INTENSITY_MEDIUM)

func _on_intensity_high_button_pressed() -> void:
	sortCurrentToIntensity(INTENSITY_HIGH)

var folderList:Array = []
func _on_gather_from_folder_button_pressed() -> void:
	gather_folder_window.popup_centered()
	
	var someFolderList:Array = getAllFolders(OS.get_executable_path().get_base_dir())
	folderList = []
	
	gather_folder_item_list.clear()
	for folderPathA in someFolderList:
		var folderPath:String = folderPathA
		
		if(getAllSoundPathsFromFolder(folderPath).is_empty()):
			continue
		
		folderList.append(folderPath)
		gather_folder_item_list.add_item(folderPath.get_file())

func _on_gather_folder_window_confirmed() -> void:
	var selectedIndx:Array = gather_folder_item_list.get_selected_items()
	
	var targetPath:String = OS.get_executable_path().get_base_dir()
	
	for theIndx in selectedIndx:
		var folderPath:String = folderList[theIndx]
		
		var theSoundPaths:Array = getAllSoundPathsFromFolder(folderPath)
		
		for soundPath in theSoundPaths:
			var freeNumberName:String = getFreeNumberFileNameFromFolder(targetPath)
			
			var finalTargetPath:String = targetPath.path_join(freeNumberName+"."+soundPath.get_extension())
			DirAccess.rename_absolute(soundPath, finalTargetPath)
		
	scanPaths(true)
