using System.Collections;
using UnityEngine;
using SFB;

public class BasicSample : MonoBehaviour {
    private string _path;

    void OnGUI() {
        var guiScale = new Vector3(Screen.width / 800.0f, Screen.height / 600.0f, 1.0f);
        GUI.matrix = Matrix4x4.TRS(Vector3.zero, Quaternion.identity, guiScale);

        GUILayout.Space(20);
        GUILayout.BeginHorizontal();
        GUILayout.Space(20);
        GUILayout.BeginVertical();

        // Open File Samples

        if (GUILayout.Button("Open File")) {
            WriteResult(StandaloneFileBrowser.OpenFilePanel("Open File", "", "", false));
        }
        if (GUILayout.Button("Open File Async")) {
            StandaloneFileBrowser.OpenFilePanelAsync("Open File", "", "", false, (string[] paths) => { WriteResult(paths); });
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Open File Multiple")) {
            StandaloneFileBrowser.OpenFilePanelAsync("Open File", "", "", true, (string[] paths) => { WriteResult(paths); });
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Open File Extension")) {
            StandaloneFileBrowser.OpenFilePanelAsync("Open File", "", "txt", true, (string[] paths) => { WriteResult(paths); });
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Open File Directory")) {
            StandaloneFileBrowser.OpenFilePanelAsync("Open File", Application.dataPath, "", true, (string[] paths) => { WriteResult(paths); });
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Open File Filter")) {
            var extensions = new [] {
                new ExtensionFilter("Image Files", "png", "jpg", "jpeg" ),
                new ExtensionFilter("Sound Files", "mp3", "wav" ),
                new ExtensionFilter("All Files", "*" ),
            };
            StandaloneFileBrowser.OpenFilePanelAsync("Open File", "", extensions, true, (string[] paths) => { WriteResult(paths); });
        }

        GUILayout.Space(15);

        // Open Folder Samples

        if (GUILayout.Button("Open Folder")) {
            StandaloneFileBrowser.OpenFolderPanelAsync("Select Folder", "", true, (string[] paths) => { WriteResult(paths); });
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Open Folder Directory")) {
            StandaloneFileBrowser.OpenFolderPanelAsync("Select Folder", Application.dataPath, true, (string[] paths) => { WriteResult(paths); });
        }

        GUILayout.Space(15);

        // Save File Samples

        if (GUILayout.Button("Save File")) {
            StandaloneFileBrowser.SaveFilePanelAsync("Save File", "", "", "", (string path) => { WriteResult(path); });
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Save File Default Name")) {
            StandaloneFileBrowser.SaveFilePanelAsync("Save File", "", "MySaveFile", "", (string path) => { WriteResult(path); });
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Save File Default Name Ext")) {
            StandaloneFileBrowser.SaveFilePanelAsync("Save File", "", "MySaveFile", "dat", (string path) => { WriteResult(path); });
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Save File Directory")) {
            StandaloneFileBrowser.SaveFilePanelAsync("Save File", Application.dataPath, "", "", (string path) => { WriteResult(path); });
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Save File Filter")) {
            // Multiple save extension filters with more than one extension support.
            var extensionList = new [] {
                new ExtensionFilter("Binary", "bin"),
                new ExtensionFilter("Text", "txt"),
            };
            StandaloneFileBrowser.SaveFilePanelAsync("Save File", "", "MySaveFile", extensionList, (string path) => { WriteResult(path); });
        }

        GUILayout.EndVertical();
        GUILayout.Space(20);
        GUILayout.Label(_path);
        GUILayout.EndHorizontal();
    }

    public void WriteResult(string[] paths) {
        if (paths.Length == 0) {
            return;
        }

        _path = "";
        foreach (var p in paths) {
            _path += p + "\n";
        }
    }

    public void WriteResult(string path) {
        _path = path;
    }
}
