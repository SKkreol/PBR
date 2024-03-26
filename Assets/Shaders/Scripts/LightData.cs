using UnityEngine;

[CreateAssetMenu(menuName = "My Assets/LightData")]
public class LightData : ScriptableObject
{
    public Color lightColor = Color.white;
    public Vector3 lightDir = Vector3.zero;
    [Min(0.5f)]
    public float lightIntensity = 1.0f;
    public Material skyBoxMaterial;
    public Cubemap hdrSkyBox;
    public Cubemap reflectionProbe;
}