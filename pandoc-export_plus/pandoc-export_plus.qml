import QtQml 2.0
import QOwnNotesTypes 1.0
import com.qownnotes.noteapi 1.0

Script {
	property string pandocPath;
	property string outputPath;
	property string scriptDirPath;

	// register your settings variables so the user can set them in the script settings
	property variant settingsVariables: [
		{
			"identifier": "pandocPath",
			"name": "Pandoc path",
			"description": "Please select the path to your Pandoc executable:",
			"type": "file",
			"default": "pandoc"
		},
		{
			"identifier": "outputPath",
			"name": "Output Directory",
			"description": "Please select the path to where generated files are placed:",
			"type": "directory",
			"default": "E:\\_out"
		}
	];
	
	function doSomethingWithYourVariables() {
		script.setLabelText("pandocExport1", "PEOutput:" + outputPath);
	}


	function customActionInvoked(identifier) {
		if ((identifier != "pandocExportPDF" ) &&
		(identifier != "pandocExportEPUB" ) &&
		(identifier != "pandocExportHTML" ) &&
		(identifier != "pandocExportTEX" ) ){
			return;
		}
		
		var noteSubFolderQmlObj = Qt.createQmlObject(
			"import QOwnNotesTypes 1.0; NoteSubFolder{}",
			mainWindow,
			"noteSubFolder",
		);
		var noteSubFolder = noteSubFolderQmlObj.activeNoteSubFolder();
		var note = script.currentNote();

		var fullFileName = note.fullNoteFilePath;
		var noteFileDir = note.fullNoteFileDirPath;
		var noteFolderDir = script.currentNoteFolderPath();
		
		//weird hack
		var noteName = note.fileName
		if (identifier == "pandocExportPDF"){
			noteName = note.fileName.replace(/\.[^.]+$/, ".pdf")
		} else if (identifier == "pandocExportEPUB"){
			noteName = note.fileName.replace(/\.[^.]+$/, ".epub")
		} else if (identifier == "pandocExportHTML"){
			noteName = note.fileName.replace(/\.[^.]+$/, ".html")
		} else if (identifier == "pandocExportTEX"){
			noteName = note.fileName.replace(/\.[^.]+$/, ".tex")
		}
		
		var outFile = outputPath + "/" + noteSubFolder.relativePath() + "/" + noteName
		script.log(identifier + outFile);

		//variables for pandoc
		var defaultsFile = noteFileDir + "/defaults.yaml";
		if (!script.fileExists(defaultsFile)) {
			defaultsFile = noteFolderDir + "/_data/defaults.yaml";
		}
		if (!script.fileExists(defaultsFile)) {
			defaultsFile = scriptDirPath + "/defaults.yaml";
		}
		
		var metadataFile = noteFileDir + "/metadata.yaml";
		if (!script.fileExists(metadataFile)) {
			metadataFile = noteFolderDir + "/_data/metadata.yaml";
		}
		if (!script.fileExists(metadataFile)) {
			metadataFile = scriptDirPath + "/metadata.yaml";
		}
		
		
		var pandocArgs = [fullFileName, "-d", defaultsFile, "-o", outFile, "--metadata-file", metadataFile ];
		var log = "--log=" + outputPath + "/" + noteSubFolder.relativePath() + "/" + noteName + "_log.json";
		pandocArgs.push(log);
		script.log(pandocArgs);

		script.startSynchronousProcess(pandocPath, pandocArgs, "", noteFileDir);
		script.log(identifier + ": exported note file - " + outFile);
	}


	function init() {
		script.registerCustomAction("pandocExportPDF", "Export note to PDF using pandoc", "PD-PDF", "application-pdf");
		script.registerCustomAction("pandocExportEPUB", "Export note to EPUB using pandoc", "PD-EPUB", "text-xml");
		script.registerCustomAction("pandocExportHTML", "Export note to HTML using pandoc", "PD-HTML", "text-html");
		script.registerCustomAction("pandocExportTEX", "Export note to TEX using pandoc", "PD-TEX", "text-x-generic");
		script.registerLabel("pandocExport1", "PEoutput:");
		doSomethingWithYourVariables();
	}
}