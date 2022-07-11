package;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import meta.data.*;
import openfl.utils.Assets;
import sys.FileSystem;

/**
	This class is used as an extension to many other forever engine stuffs, please don't delete it as it is not only exclusively used in forever engine
	custom stuffs, and is instead used globally.
**/
class ForeverTools
{
	public static var menuString:String = 'freakyMenu';

	// set up maps and stuffs
	public static function resetMenuMusic(resetVolume:Bool = false)
	{
		menuString = Init.trueSettings.get('Menu Music');

		// make sure the music is playing
		if (((FlxG.sound.music != null) && (!FlxG.sound.music.playing)) || (FlxG.sound.music == null))
		{
			FlxG.sound.playMusic(Paths.music('menu/$menuString'), (resetVolume) ? 0 : 0.7);
			if (resetVolume) FlxG.sound.music.fadeIn(4, 0, 0.7);

			// placeholder bpm
			Conductor.changeBPM(102);
		}
		//
	}

	public static function returnSkinAsset(asset:String, assetModifier:String = 'base', changeableSkin:String = 'default', baseLibrary:String,
			?defaultChangeableSkin:String = 'default', ?defaultBaseAsset:String = 'base'):String
	{
		var realAsset = '$baseLibrary/$changeableSkin/$assetModifier/$asset';
		if (!FileSystem.exists(Paths.getPath('images/' + realAsset + '.png', IMAGE)))
		{
			realAsset = '$baseLibrary/$defaultChangeableSkin/$assetModifier/$asset';
			if (!FileSystem.exists(Paths.getPath('images/' + realAsset + '.png', IMAGE)))
				realAsset = '$baseLibrary/$defaultChangeableSkin/$defaultBaseAsset/$asset';
		}

		return realAsset;
	}

	public static function killMusic(songsArray:Array<FlxSound>)
	{
		// neat function thing for songs
		for (i in 0...songsArray.length)
		{
			// stop
			songsArray[i].stop();
			songsArray[i].destroy();
		}
	}

	public static function getColFromFlixel(str:String):FlxColor
	{
		return switch (str)
		{
			case "black": FlxColor.BLACK;
			case "white": FlxColor.WHITE;
			case "blue": FlxColor.BLUE;
			case "brown": FlxColor.BROWN;
			case "cyan": FlxColor.CYAN;
			case "gray": FlxColor.GRAY;
			case "green": FlxColor.GREEN;
			case "lime": FlxColor.LIME;
			case "magenta": FlxColor.MAGENTA;
			case "orange": FlxColor.ORANGE;
			case "pink": FlxColor.PINK;
			case "purple": FlxColor.PURPLE;
			case "red": FlxColor.RED;
			case "transparent" | _: FlxColor.TRANSPARENT;
		}
	}
}
