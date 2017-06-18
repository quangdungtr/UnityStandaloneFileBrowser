#if UNITY_STANDALONE_OSX

using System;
using System.Runtime.InteropServices;

using UnityEngine;

namespace SFB {
    public class StandaloneFileBrowserMac : MonoBehaviour, IStandaloneFileBrowser {
        private Action<string[]> _openFileCb;
        private Action<string[]> _openFolderCb;
        private Action<string> _saveFileCb;

        [DllImport("StandaloneFileBrowser")]
        private static extern IntPtr DialogOpenFilePanel(
            string title,
            string directory,
            string extension,
            bool multiselect);
        [DllImport("StandaloneFileBrowser")]
        private static extern void DialogOpenFilePanelAsync(
            bool isEditor,
            string goName,
            string methodName,
            string title,
            string directory,
            string extension,
            bool multiselect);
        [DllImport("StandaloneFileBrowser")]
        private static extern IntPtr DialogOpenFolderPanel(
            string title,
            string directory,
            bool multiselect);
        [DllImport("StandaloneFileBrowser")]
        private static extern void DialogOpenFolderPanelAsync(
            bool isEditor,
            string goName,
            string methodName,
            string title,
            string directory,
            bool multiselect);
        [DllImport("StandaloneFileBrowser")]
        private static extern IntPtr DialogSaveFilePanel(
            string title,
            string directory,
            string defaultName,
            string extension);
        [DllImport("StandaloneFileBrowser")]
        private static extern void DialogSaveFilePanelAsync(
            bool isEditor,
            string goName,
            string methodName,
            string title,
            string directory,
            string defaultName,
            string extension);

        public string[] OpenFilePanel(string title, string directory, ExtensionFilter[] extensions, bool multiselect) {
            var paths = Marshal.PtrToStringAnsi(DialogOpenFilePanel(
                title,
                directory,
                GetFilterFromFileExtensionList(extensions),
                multiselect));
            return paths.Split((char)28);
        }

        public void OpenFilePanelAsync(string title, string directory, ExtensionFilter[] extensions, bool multiselect, Action<string[]> cb) {
            _openFileCb = cb;
            DialogOpenFilePanelAsync(
                Application.isEditor,
                gameObject.name,
                "OnOpenFilePanelResult",
                title,
                directory,
                GetFilterFromFileExtensionList(extensions),
                multiselect);
        }

        private void OnOpenFilePanelResult(string paths) {
            _openFileCb.Invoke(paths.Split((char)28));
        }

        public string[] OpenFolderPanel(string title, string directory, bool multiselect) {
            var paths = Marshal.PtrToStringAnsi(DialogOpenFolderPanel(
                title,
                directory,
                multiselect));
            return paths.Split((char)28);
        }

        public void OpenFolderPanelAsync(string title, string directory, bool multiselect, Action<string[]> cb) {
            _openFolderCb = cb;
            DialogOpenFolderPanelAsync(
                Application.isEditor,
                gameObject.name,
                "OnOpenFolderPanelResult",
                title,
                directory,
                multiselect);
        }

        private void OnOpenFolderPanelResult(string paths) {
            _openFolderCb.Invoke(paths.Split((char)28));
        }

        public string SaveFilePanel(string title, string directory, string defaultName, ExtensionFilter[] extensions) {
            return Marshal.PtrToStringAnsi(DialogSaveFilePanel(
                title,
                directory,
                defaultName,
                GetFilterFromFileExtensionList(extensions)));
        }

        public void SaveFilePanelAsync(string title, string directory, string defaultName, ExtensionFilter[] extensions, Action<string> cb) {
            _saveFileCb = cb;
            DialogSaveFilePanelAsync(
                Application.isEditor,
                gameObject.name,
                "OnSaveFilePanelResult",
                title,
                directory,
                defaultName,
                GetFilterFromFileExtensionList(extensions));
        }

        private void OnSaveFilePanelResult(string path) {
            _saveFileCb.Invoke(path);
        }

        private static string GetFilterFromFileExtensionList(ExtensionFilter[] extensions) {
            if (extensions == null) {
                return "";
            }

            var filterString = "";
            foreach (var filter in extensions) {
                filterString += filter.Name + ";";

                foreach (var ext in filter.Extensions) {
                    filterString += ext + ",";
                }

                filterString = filterString.Remove(filterString.Length - 1);
                filterString += "|";
            }
            filterString = filterString.Remove(filterString.Length - 1);
            return filterString;
        }
    }
}

#endif