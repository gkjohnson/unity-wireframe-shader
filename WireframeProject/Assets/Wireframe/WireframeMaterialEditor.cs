using System.Collections;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

// Custom Material Editor for the UCLA Game Lab Wireframe Shader
// Enables toggling "cutout" and "double-sided" rendering modes
public class WireframeMaterialEditor : ShaderGUI
{
    bool _cutout = false;
    bool _doubleSided = false;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

        EditorGUI.BeginChangeCheck();
        _cutout = EditorGUILayout.Toggle("Cutout", _cutout);
        _doubleSided = EditorGUILayout.Toggle("Double Sided", _doubleSided);
        if (EditorGUI.EndChangeCheck())
        {
            Material mat = materialEditor.target as Material;

            if (_cutout)
            {
                mat.EnableKeyword("CUTOUT");
                mat.SetInt("_ZWrite", 1);
                mat.renderQueue = 2000; // Geometry render queue
            }
            else
            {
                mat.DisableKeyword("CUTOUT");
                mat.SetInt("_ZWrite", 0);
                mat.renderQueue = 3000; // Transparent render queue
            }

            // mat.SetInt("_Cull", (int)(_doubleSided ? CullMode.Off : CullMode.Back));
            mat.SetShaderPassEnabled("BACKSIDE", false);            
        }
    }

}
