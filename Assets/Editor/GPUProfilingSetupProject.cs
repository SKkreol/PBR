using System;
using UnityEditor;
using UnityEngine;
using System.IO;

namespace JarviGames
{
    public class GPUProfilingSetupProject : EditorWindow
    {
        private const string ManifestPath = "/Plugins/Android/AndroidManifest.xml";

        private const string NewPermissions =
            "<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" />";

        private const string PermissionInternet =
            "<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" />";

        private const string TooltipMessage =
            "A simple tool for setting up a project for debugging using the Snapdragon profiler, " +
            "click btn Setup, and after that create build";

        private const string Title = "GPUProfilingSetup";

        [MenuItem("Tools/TechArt/GPUProfilingSetup")]
        public static void ShowWindow()
        {
            var window = GetWindow<GPUProfilingSetupProject>(Title);
            window.minSize = new Vector2(300, 200);
        }

        private void OnGUI()
        {
            EditorGUILayout.HelpBox(TooltipMessage, MessageType.Info);
            if (GUILayout.Button("Setup"))
            {
                ApplyDebugProjectSettings();
                Close();
            }
        }

        private static void ApplyDebugProjectSettings()
        {
            PlayerSettings.Android.forceInternetPermission = true;
            PlayerSettings.Android.preferredInstallLocation = AndroidPreferredInstallLocation.PreferExternal;
            PlayerSettings.Android.forceSDCardPermission = true;
            PlayerSettings.Android.targetArchitectures = AndroidArchitecture.ARMv7;
            EditorUserBuildSettings.development = true;

            PlayerSettings.Android.useAPKExpansionFiles = false;
            PlayerSettings.Android.useCustomKeystore = false;

            var path = Application.dataPath + ManifestPath;
            var manifestContents = File.ReadAllText(path);

            if (manifestContents.Contains(NewPermissions))
                return;

            var index = manifestContents.IndexOf(PermissionInternet, StringComparison.Ordinal);

            if (index != -1)
            {
                var endIndex = manifestContents.IndexOf('>', index) + 1;
                manifestContents = manifestContents.Insert(endIndex, "\n" + NewPermissions);
                File.WriteAllText(path, manifestContents);
            }
            
            EditorUtility.DisplayDialog(Title, "All parameter is set and project ready for building", "OK");
        }
    }
}