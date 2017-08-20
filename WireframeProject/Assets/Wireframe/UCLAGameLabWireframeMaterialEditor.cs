using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

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
        bool distanceAgnostic = EditorGUILayout.Toggle("Distance Agnostic", mat.IsKeywordEnabled("DISTANCE_AGNOSTIC"));
        bool doubleSided = EditorGUILayout.Toggle("Double Sided", mat.shader.name == DOUBLE_SIDED_SHADER || mat.GetFloat("_Cull") == (float)CullMode.Off);

        if (EditorGUI.EndChangeCheck())
        {
            if (cutout)
            {
                mat.EnableKeyword("CUTOUT");
                mat.SetInt("_ZWrite", 1);
                mat.renderQueue = 2000; // Geometry render queue

                // Use the single pass shader if we're trying
                // to render double-sided && cutout because 
                // cutout will write to depth
                mat.shader = Shader.Find(SINGLE_SIDED_SHADER);
                mat.SetInt("_Cull", (int) (doubleSided ? CullMode.Off : CullMode.Back));
            }
            else
            {
                mat.DisableKeyword("CUTOUT");
                mat.SetInt("_ZWrite", 0);
                mat.renderQueue = 3000; // Transparent render queue

                // Use the double pass shader if we're
                // trying to render double-sided
                mat.shader = Shader.Find(doubleSided ? DOUBLE_SIDED_SHADER : SINGLE_SIDED_SHADER);
                mat.SetInt("_Cull", (int) CullMode.Back);
            }

            // Toggle 
            if (distanceAgnostic) mat.EnableKeyword("DISTANCE_AGNOSTIC");
            else mat.DisableKeyword("DISTANCE_AGNOSTIC");
        }
    }

}
