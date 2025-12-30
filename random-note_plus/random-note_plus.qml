import QtQml 2.0
import com.qownnotes.noteapi 1.0

/*
	This script creates a menu item and a button to jump to a random note from the collection
	or just the subfolder 
 */
QtObject {
	property var noteIds;


    function customActionInvoked(identifier) {
		if (identifier == "randomNote"){
			noteIds = script.fetchNoteIdsByNoteTextPart("");
			script.log(identifier + ":" + noteIds );
		} else if (identifier == "randomCurrentFolder"){
			//ill do something nicer later maybe
			noteIds = [];	
			var noteSubFolderQmlObj = Qt.createQmlObject(
				"import QOwnNotesTypes 1.0; NoteSubFolder{}",
				mainWindow,
				"noteSubFolder",
			);
			var noteSubFolder = noteSubFolderQmlObj.activeNoteSubFolder();
			
			for (var n = 0; n < noteSubFolder.notes.length; n++){
				noteIds.push(noteSubFolder.notes[n].id);
			}
		} else {
			return;
		}

        var len = noteIds.length;
        var rand = Math.floor(Math.random() * len);
        var noteId = noteIds[rand];
		var note = script.fetchNoteById(noteId);
        
        script.setCurrentNote(note);
        script.regenerateNotePreview();

        var path = script.currentNoteFolderPath();
        var subfolderName = getSubFolder(note, path);
        script.jumpToNoteSubFolder(subfolderName);
    }
    function getSubFolder(note, path) {
        var fileName = note.fullNoteFilePath;
        var pathRe = new RegExp(path + "\/((.*)\/)*.*");
        var subfolderName = fileName.replace(pathRe, "$2");
        return subfolderName;
    }
    /**
     * Initializes the custom action
     */
    function init() {
        script.registerCustomAction("randomNote", "Random note", "Random note", "media-playlist-shuffle");
		script.registerCustomAction("randomCurrentFolder", "Random note in folder", "Random note in folder", "view-refresh");
    }
}

