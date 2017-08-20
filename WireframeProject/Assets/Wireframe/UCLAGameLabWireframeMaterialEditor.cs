using System.Collections;
using UnityEditor;
using UnityEngine;

// Custom Material Editor for the UCLA Game Lab Wireframe Shader
// Enables toggling "cutout" and "double-sided" rendering modes
public class UCLAGameLabWireframeMaterialEditor : ShaderGUI
{
    const string DOUBLE_SIDED_SHADER = "UCLA Game Lab/Wireframe Double Sided";
    const string SINGLE_SIDED_SHADER = "UCLA Game Lab/Wireframe";

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

        Material mat = materialEditor.target as Material;

        EditorGUI.BeginChangeCheck();
        bool cutout = EditorGUILayout.Toggle("Cutout", mat.IsKeywordEnabled("CUTOUT"));
        bool doubleSided = EditorGUILayout.Toggle("Double Sided", mat.shader.name == DOUBLE_SIDED_SHADER);
        if (EditorGUI.EndChangeCheck())
        {
            
            if (cutout)
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
            
            mat.shader = Shader.Find(doubleSided ? DOUBLE_SIDED_SHADER : SINGLE_SIDED_SHADER);
        }
    }

}
