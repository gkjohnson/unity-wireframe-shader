Shader "UCLA Game Lab/Wireframe" 
{	
    Properties 
	{
		_Color ("Line Color", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_Thickness ("Thickness", Float) = 1

        [HideInInspector]
        _ZWrite("_ZWrite", Float) = 1.0

        [HideInInspector]
        _Cull("_Cull", Float) = 2.0
	}

    CustomEditor "UCLAGameLabWireframeMaterialEditor"

    SubShader{
        Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

        UsePass "UCLA Game Lab/Wireframe Double Sided/FRONTSIDE"
    }
}
