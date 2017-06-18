#if UNITY_EDITOR

using System;
using UnityEngine;
using UnityEditor;

namespace SFB {
    public class StandaloneFileBrowserEditor : MonoBehaviour, IStandaloneFileBrowser  {
        public string[] OpenFilePanel(string title, string directory, ExtensionFilter[] extensions, bool multiselect) {
            string path = "";

            if (extensions == null) {
                path = EditorUtility.OpenFilePanel(title, directory, "");
            }
            else {
                path = EditorUtility.OpenFilePanelWithFilters(title, directory, GetFilterFromFileExtensionList(extensions));
            }

            return string.IsNullOrEmpty(path) ? new string[0] : new[] { path };
        }

        public void OpenFilePanelAsync(string title, string directory, ExtensionFilter[] extensions, bool multiselect, Action<string[]> cb) {
            var paths = OpenFilePanel(title, directory, extensions, multiselect);
            cb.Invoke(paths);
        }

        public string[] OpenFolderPanel(string title, string directory, bool multiselect) {
            var path = EditorUtility.OpenFolderPanel(title, directory, "");
            return string.IsNullOrEmpty(path) ? new string[0] : new[] {path};
        }

        public void OpenFolderPanelAsync(string title, string directory, bool multiselect, Action<string[]> cb) {
            var paths = OpenFolderPanel(title, directory, multiselect);
            cb.Invoke(paths);
        }

        public string SaveFilePanel(string title, string directory, string defaultName, ExtensionFilter[] extensions) {
            var ext = extensions != null ? extensions[0].Extensions[0] : "";
            var name = string.IsNullOrEmpty(ext) ? defaultName : defaultName + "." + ext;
            return EditorUtility.SaveFilePanel(title, directory, name, ext);
        }

        public void SaveFilePanelAsync(string title, string directory, string defaultName, ExtensionFilter[] extensions, Action<string> cb) {
            var path = SaveFilePanel(title, directory, defaultName, extensions);
            cb.Invoke(path);
        }

        // EditorUtility.OpenFilePanelWithFilters extension filter format
        private static string[] GetFilterFromFileExtensionList(ExtensionFilter[] extensions) {
            var filters = new string[extensions.Length * 2];
            for (int i = 0; i < extensions.Length; i++) {
                filters[(i * 2)] = extensions[i].Name;
                filters[(i * 2) + 1] = string.Join(",", extensions[i].Extensions);
            }
            return filters;
        }
    }
}

#endif
