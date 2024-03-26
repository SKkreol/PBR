using UnityEngine;

public enum ShaderQuality
{
    UltraGraphics,
    HighGraphics,
    MediumGraphics,
    LowGraphics
}

[ExecuteInEditMode]
public class QualityController : MonoBehaviour
{
    [SerializeField]
    private ShaderQuality quality = ShaderQuality.UltraGraphics;
    
    private void Update()
    {
        SetShaderQuality(quality);
    }
    
    private void SetShaderQuality(ShaderQuality level)
    {
        var keyword = GetShaderKeyword(level);
        if (string.IsNullOrEmpty(keyword))
        {
            Debug.LogError("Shader keyword not found for quality: " + level);
            return;
        }

        Shader.DisableKeyword(ShaderKeywords.UltraGraphics);
        Shader.DisableKeyword(ShaderKeywords.HighGraphics);
        Shader.DisableKeyword(ShaderKeywords.MediumGraphics);
        Shader.DisableKeyword(ShaderKeywords.LowGraphics);
        Shader.EnableKeyword(keyword);
    }
    
    private string GetShaderKeyword(ShaderQuality level)
    {
        switch (level)
        {
            case ShaderQuality.UltraGraphics:
                return ShaderKeywords.UltraGraphics;
            case ShaderQuality.HighGraphics:
                return ShaderKeywords.HighGraphics;
            case ShaderQuality.MediumGraphics:
                return ShaderKeywords.MediumGraphics;
            case ShaderQuality.LowGraphics:
                return ShaderKeywords.LowGraphics;
            default:
                Debug.LogWarning("Unknown shader quality: " + quality);
                return null;
        }
    }
}
