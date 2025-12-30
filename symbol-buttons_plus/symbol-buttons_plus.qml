import QtQml 2.2
import QOwnNotesTypes 1.0

/// This script adds toolbar buttons to insert characters set in script options

Script {
	property var symbolListA;
	property var symbolListB;
	property var symbolListC;
	property string symbolStringA;
	property string symbolStringB;
	property string symbolStringC;
	
	property variant settingsVariables: [
		{
			"identifier": "symbolStringA",
			"name": "Symbols to insert with buttons",
			"description": "Put any unicode characters separated by commas. You can group multiple symbols together.",
			"type": "string",
			"default": "❗,❓,✅,❌,⭕,🧡,💛,💚,💙,💜,🤎,🖤,🤍,🔴,🟠,🟡,🟢,🔵,🟣,🟤,⚫,⚪,🟥,🟧,🟨,🟩,🟦,🟪,🟫"
		},
		{
			"identifier": "symbolStringB",
			"name": "Symbols to insert with buttons",
			"description": "Put any unicode characters separated by commas. You can group multiple symbols together.",
			"type": "string",
			"default": "📁,📙,📕,📗,📘,📔,📚,📓,📄,📜,📖,📋,📰,📦,🧰,💼,🎁,🧰,✨,💥,🌈,⚡,🔥,☄️,🌠,🌟,💖,🤖,🥽,🖥️,📱,🧪,⚙️,🚀,🎬,💡,📆,🌐,📌,⛔,🛑,🎶,🎵,🔔,👩‍⚕️,🦸‍,👻,💀,🧠,📢,🥼,💰,🎀,🔑,🔒,🌞"
		},
		{
			"identifier": "symbolStringC",
			"name": "Symbols to insert with buttons",
			"description": "Put any unicode characters separated by commas. You can group multiple symbols together.",
			"type": "string",
			"default": "🦖,💩,👾,👽,🤡,👄,👀,💋,💣,🎮,🧸,🐴,🦄,🐒,🤷,💨,🐎,🕷,🖕,🦝,🪐,🍀,🌸,🦾,🦴,🐲,💪,👋,🙈"
		}
	]
	
	
	function doSomethingWithYourVariables() {
		script.setLabelText("symbolButtons1", "SBCountA:" + symbolListA.length);
		script.setLabelText("symbolButtons2", "SBCountB:" + symbolListB.length);
		script.setLabelText("symbolButtons3", "SBCountC:" + symbolListC.length);
	}

	function customActionInvoked(symbol) {
		if (symbolListA.indexOf(symbol) != -1) {
			script.noteTextEditWrite(symbol);
		} else if (symbolListB.indexOf(symbol) != -1) {
			script.noteTextEditWrite(symbol);
		} else if (symbol == "allsymbolsA"){
			script.noteTextEditWrite(script.inputDialogGetItem("combo box", "Please select an item", symbolListA));
		} else if (symbol == "allsymbolsB"){
			script.noteTextEditWrite(script.inputDialogGetItem("combo box", "Please select an item", symbolListB));
		} else if (symbol == "allsymbolsC"){
			script.noteTextEditWrite(script.inputDialogGetItem("combo box", "Please select an item", symbolListC));
		}
	}
	function init() {
		symbolListA = symbolStringA.split(',');
		symbolListB = symbolStringB.split(',');
		symbolListC = symbolStringC.split(',');
		
		for (var n = 0; n < symbolListA.length; n++){
			script.registerCustomAction(symbolListA[n], symbolListA[n], symbolListA[n]);
		}
		for (var n = 0; n < symbolListB.length; n++){
			script.registerCustomAction(symbolListB[n], symbolListB[n], symbolListB[n]);
		}
		
		script.registerCustomAction("allsymbolsA", "Symbol Selector (1)", "Symbol Selector 1", "system-shutdown");
		script.registerCustomAction("allsymbolsB", "Symbol Selector (2)", "Symbol Selector 2", "help-about");
		script.registerCustomAction("allsymbolsC", "Symbol Selector (3)", "Symbol Selector 3", "tools-report-bug");
		
		script.registerLabel("symbolButtons1", "SBCountA:");
		script.registerLabel("symbolButtons2", "SBCountB:");
		script.registerLabel("symbolButtons3", "SBCountC:");
		doSomethingWithYourVariables();
	}
}