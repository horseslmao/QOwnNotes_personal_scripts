import QtQml 2.0
import QOwnNotesTypes 1.0


QtObject {
	property string outputWebsite;
	property bool newNoteTemplate;
	
	property variant settingsVariables: [
		{
			"identifier": "outputWebsite",
			"name": "Select link database used for urls",
			"description": "Loads 2 json files to use for applying headers and footers in the preview pane, and patching urls from a lookup table",
			"type": "selection",
			"default": "local_md",
			"items": {"local_md": "Local", "redditwiki": "Reddit Wiki"},
		},
		{
			'identifier': 'newNoteTemplate',
			'name': 'New Note Template',
			'description': 'Attempt to copy the contents of "_foldername_template.md" in the same folder as the new note automatically.',
			'type': 'boolean',
			'default': 'false'
		}
	];

	
	function doSomethingWithYourVariables() {
		script.setLabelText("lazytemplate1", "LTOutputCFG:" + outputWebsite);
		var filePath = script.currentNoteFolderPath() + "/_data/" + outputWebsite + "_urlpatch.json"
		script.setLabelText("lazytemplate2", "LTOutputURL:" + script.fileExists(filePath));
		var filePath = script.currentNoteFolderPath() + "/_data/" + outputWebsite + "_templates.json"
		script.setLabelText("lazytemplate3", "LTOutputTEMP: " + script.fileExists(filePath));
	}
	
	function doApplyTemplate() {
		var noteSubFolderQmlObj = Qt.createQmlObject(
			"import QOwnNotesTypes 1.0; NoteSubFolder{}",
			mainWindow,
			"noteSubFolder",
		);
				
		var note = script.currentNote();
		var filePath = note.fullNoteFileDirPath + "/_" + noteSubFolderQmlObj.activeNoteSubFolder().name + "_template.md"
		if (script.fileExists(filePath)) {
			var data = script.readFromFile(filePath)
			var re = new RegExp(/^#{1,6}\s(.+)$/m, 'm');
			script.noteTextEditSelectAll();
			script.noteTextEditWrite("# "+ note.name +"\n")
			script.noteTextEditWrite(data.replace(re, ""))
		} else {
			script.log("NO TEMPLATE AT:"+filePath);
		}
	}
	
	function customActionInvoked(identifier) {
		if (identifier == "initLazyTemplate"){
			doApplyTemplate();
		}
	}

	function preNoteToMarkdownHtmlHook(note, markdown, forExport) {
		var noteSubFolderQmlObj = Qt.createQmlObject(
			"import QOwnNotesTypes 1.0; NoteSubFolder{}",
			mainWindow,
			"noteSubFolder",
		);
		var noteSubFolder = noteSubFolderQmlObj.activeNoteSubFolder();
		
		//BREADCRUMBS + footer
		var filePath = script.currentNoteFolderPath() + "/_data/" + outputWebsite + "_templates.json"
		if (script.fileExists(filePath)) {
			var data = JSON.parse(script.readFromFile(filePath));
			
			var re = new RegExp('^#+\s*(.*)$', 'm');
			markdown = markdown.replace(re, data["/"+note.relativeNoteFileDirPath]["mainheader"]+"$1");
			markdown = markdown + data["/"+note.relativeNoteFileDirPath]["footer"]
		}
		
		///1 for 1 swaps nothing fancy for now
		var filePath = script.currentNoteFolderPath() + "/_data/" + outputWebsite + "_urlpatch.json"
		if (script.fileExists(filePath)) {
			var data = JSON.parse(script.readFromFile(filePath));
			for (var key in data) {
				var re = new RegExp('\('+key+'\)', 'g');
				markdown = markdown.replace(re, data[key]);
			};
		}

		return markdown;
	}

	function noteToMarkdownHtmlHook(note, html, forExport) {
		//ha i dont even care anymore
		if (outputWebsite != "local_md") {
			var re = new RegExp('<a href="file:///([^"]+)http([^"]+)">', 'g');
			html = html.replace(re, "<a href=\"http$2\">");
		}
		
		//eh adding titles for free because im too lazy to do this properly
		var re = new RegExp('<a href="([^"]+)">', 'g');
		html = html.replace(re, "<a href=\"$1\" title=\"$1\">");

		return html;
	}
	
	function noteOpenedHook(note) {
		if (newNoteTemplate) {
			var chk = "# "+ note.name +"\n\n"
			if (note.noteText == chk){
				doApplyTemplate();
			}
		}
	}
	
	function init() {
		script.registerLabel("lazytemplate1", "LTOutputCFG:");
		script.registerLabel("lazytemplate2", "LTOutputURL:");
		script.registerLabel("lazytemplate3", "LTOutputTEMP:");
		script.registerCustomAction("initLazyTemplate", "Attempt to apply a template", "Template", "edit-guides");
		doSomethingWithYourVariables();
	}
}

