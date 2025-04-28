# LewdAudioSorter
 A little godot app to quickly (but manually) sort moans or other lewd noises by mouth-state/intensity/speed

![pic](https://github.com/user-attachments/assets/66cdb4ea-3476-4899-ac45-e677e05982f8)

# How to use
1) Copy the [.exe file](../../releases) into the folder that has all the sounds
2) Launch it. App will gather the list of sounds and select the first one. Press 'PREVIEW' to hear how the first sound sounds.
3) Using the 2 buttons, pick the sound's mouth state (Opened or closed). Opened means the moan sounds like Ahhhh. Closed means Mmmmh. You get the idea x3
4) Using the 3 buttons, pick the sound's speed. Slow, Medium or Fast. Up to you to decide. But the app will automatically try to guess it from the sound's length.
5) Using the last 3 buttons, pick which intensity the sound is. Low, Medium or High. Make this choice last because pressing one of these will actually sort the sound into the final folder!
6) The app will pick the next sound and preview it automatically. Repeat the process until there are no sounds left to process.

Final folder names will look like this: OpenLowSlow, OpenMediumFast, ClosedHighMedium, etc. App will make sure the sound names are unique numbers (1.ogg, 2.ogg, etc), it will never override existing sounds (if the folder already has 1.ogg, the app will use the name 2.ogg, etc).

There is also a 'Gather from folder' button. It will move (not copy) all the sounds from the selected folders into the folder where the .exe file is while also renaming them with unique number names to avoid overriding anything. If the sounds had unique names, those will be lost.
