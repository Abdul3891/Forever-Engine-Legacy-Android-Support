package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import meta.CoolUtil;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.AbsoluteSprite;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import sys.FileSystem;
import sys.io.File;

typedef CreditsData =
{
    data:Array<Dynamic>,
    name:String,
    icon:String,
    desc:String,
    quote:String,
    url:String, // this should be an array so we can add multiple socials later
    color:Array<FlxColor>,
    offsetX:Int,
    offsetY:Int,
    size:Float,
    bg:String,
}

class CreditsMenu extends MusicBeatState
{
    var alfabe:FlxTypedGroup<Alphabet>;
    var bg:FlxSprite = new FlxSprite();
    var bgTween:FlxTween;
    var infoText:FlxText;

    var curSelected:Int;
    
    var icons:Array<AbsoluteSprite> = [];
    var creditsData:CreditsData;
    
    override function create()
    {
        super.create();

        creditsData = Json.parse(Paths.getTextFromFile('credits.json'));

		#if DISCORD_RPC
        Discord.changePresence('MENU SCREEN', 'Credits Menu');
        #end

        if (creditsData.bg != null && creditsData.bg.length > 0)
			bg.loadGraphic(Paths.image(creditsData.bg));
		else
			bg.loadGraphic(Paths.image('menus/base/menuDesat'));

        bg.antialiasing = true;
        bg.screenCenter();
        bg.color = FlxColor.WHITE;
        add(bg);

        alfabe = new FlxTypedGroup<Alphabet>();
        add(alfabe);

        for (i in 0...creditsData.data.length)
        {
            var alphabet:Alphabet = new Alphabet(0, 70 * i, creditsData.data[i][0], !selectableItem(i));
            alphabet.isMenuItem = true;
            alphabet.itemType = "Centered";
            alphabet.screenCenter(X);
            alphabet.targetY = i;
            alfabe.add(alphabet);

            if (selectableItem(i)) {
                var curIcon = 'credits/${creditsData.data[i][1]}';
                var icon:AbsoluteSprite = new AbsoluteSprite(curIcon, alphabet, creditsData.data[i][6], creditsData.data[i][7]);
                if (creditsData.data[i][8] != null) icon.setGraphicSize(Std.int(icon.width * creditsData.data[i][8]));

                if (creditsData.data[i][1].length <= 1 || creditsData.data[i][1] == null) icon.visible = false;

                icons.push(icon);
                add(icon);

                curSelected = 1;
            }
        }

        infoText = new FlxText(5, FlxG.height - 24, 0, "", 32);
        infoText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        infoText.textField.background = true;
        infoText.textField.backgroundColor = FlxColor.BLACK;
        add(infoText);

        changeSelection();
    }

    var holdTime:Float = 0;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

        if (controls.UI_UP_P) {
            changeSelection(-shiftMult);
            holdTime = 0;
        }

        if (controls.UI_DOWN_P) {
            changeSelection(shiftMult);
            holdTime = 0;
        }

        /**
        * Hold Scrolling Code
        * @author ShadowMario
        **/

        if(controls.UI_DOWN || controls.UI_UP)
		{
			var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
			holdTime += elapsed;
			var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

			if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
			{
				changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
			}
		}

        if(FlxG.mouse.wheel != 0)
            changeSelection(-shiftMult * FlxG.mouse.wheel);

        if (controls.BACK || FlxG.mouse.justPressedRight) {
            Main.switchState(this, new MainMenuState());
            Paths.clearUnusedMemory();
        }

        if (controls.ACCEPT || FlxG.mouse.justPressed && selectableItem(curSelected) && creditsData.data[curSelected][4] != null
            && creditsData.data[curSelected][4] != '') 
            CoolUtil.browserLoad(creditsData.data[curSelected][4]);
    }
    
    public function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        do {
            curSelected += change;
            if (curSelected < 0)
                curSelected = creditsData.data.length - 1;
            if (curSelected >= creditsData.data.length)
                curSelected = 0;
        } while(!selectableItem(curSelected));

        var color:FlxColor = FlxColor.fromRGB(creditsData.data[curSelected][5][0],
            creditsData.data[curSelected][5][1], creditsData.data[curSelected][5][2]);

        if (bgTween != null)
            bgTween.cancel();
            
        if (color != bg.color)
        {
            bgTween = FlxTween.color(bg, 0.35, bg.color, color,
            {
                onComplete: function(tween:FlxTween)
                bgTween = null
            });
        }
        
        infoText.text = creditsData.data[curSelected][2];
        if (creditsData.data[curSelected][3] != null && creditsData.data[curSelected][3].length >= 1) infoText.text += ' - "' + creditsData.data[curSelected][3] + '"';

        var bullShit:Int = 0;
        for (item in alfabe.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;
            
            item.alpha = 0.6;
            
            if (!selectableItem(bullShit - 1))
                item.alpha = 1;
            
            if (item.targetY == 0)
            {
                item.alpha = 1;
            }
        }
    }
    
    public function selectableItem(id:Int):Bool
        return creditsData.data[id].length > 1;
}