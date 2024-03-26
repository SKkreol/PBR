using System;
using UnityEngine;

[ExecuteInEditMode]
public class LightManager : MonoBehaviour
{
    [SerializeField] 
    private ReflectionProbe _reflectionProbe;

    [SerializeField] 
    private Light _directionLight;
    [SerializeField]
    private LightData[] _lightPresets = Array.Empty<LightData>();

    private int lightPresetIndex;
    [SerializeField] private LightData _currentLightDate;
    private static readonly int SkyBoxTexID = Shader.PropertyToID("_Tex");

    private void Update()
    {
        if(_lightPresets.Length <=0)
            return;

        _currentLightDate = _lightPresets[lightPresetIndex];
        SetLightSettings(_currentLightDate);
    }

    private void SetLightSettings( LightData lightData)
    {
        _reflectionProbe.customBakedTexture = lightData.reflectionProbe;
        _directionLight.color = lightData.lightColor;
        _directionLight.intensity = lightData.lightIntensity;
        _directionLight.transform.rotation = Quaternion.Euler(lightData.lightDir);
        lightData.skyBoxMaterial.SetTexture(SkyBoxTexID, lightData.hdrSkyBox);
    }

    private void OnGUI()
    {
        if (GUI.Button(new Rect(100, 100, 100, 40), "Next"))
        {
            lightPresetIndex++;
            Debug.Log("Clicked the button Next");
        }
        
        if (GUI.Button(new Rect(100, 200, 100, 40), "Prev"))
        {
            lightPresetIndex--;
            Debug.Log("Clicked the button Prev");
        }

        if (lightPresetIndex >= _lightPresets.Length - 1)
        {
            lightPresetIndex = 0;
        }

        if (lightPresetIndex < 0)
        {
            lightPresetIndex = _lightPresets.Length - 1;
        }
    }
}