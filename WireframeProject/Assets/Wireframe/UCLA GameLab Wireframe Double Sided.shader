Shader "UCLA Game Lab/Wireframe Double Sided"
{
	Properties 
	{
		_Color ("Line Color", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_Thickness ("Thickness", Float) = 1

        [HideInInspector]
        _ZWrite("_ZWrite", Float) = 1.0
	}

    CustomEditor "UCLAGameLabWireframeMaterialEditor"

	SubShader 
	{
        Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

        // Render back faces first
        Pass
		{
            Name "BACKSIDE"
            
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite[_ZWrite]
            Cull Front

			CGPROGRAM
            #include "UnityCG.cginc"
            #include "UCLA GameLab Wireframe Functions.cginc"
            #pragma target 5.0
            #pragma vertex UCLAGL_vert
            #pragma geometry UCLAGL_geom
            #pragma fragment frag
            #pragma shader_feature CUTOUT

            // Fragment Shader
            float4 frag(UCLAGL_g2f input) : COLOR
            {
                float4 col = UCLAGL_frag(input);

                #if CUTOUT
                if (col.a < 0.5f) discard;
                else col.a = 1.0f;
                #endif

                return col;
            }
			ENDCG
		}

        // Then front faces
		Pass
		{
            Name "FRONTSIDE"

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite[_ZWrite]
            Cull Back

			CGPROGRAM
            #include "UnityCG.cginc"
            #include "UCLA GameLab Wireframe Functions.cginc"
            #pragma target 5.0
            #pragma vertex UCLAGL_vert
            #pragma geometry UCLAGL_geom
            #pragma fragment frag
            #pragma shader_feature CUTOUT

            // Fragment Shader
            float4 frag(UCLAGL_g2f input) : COLOR
            {
                float4 col = UCLAGL_frag(input);

                #if CUTOUT
                if (col.a < 0.5f) discard;
                else col.a = 1.0f;
                #endif

                return col;
            }
			ENDCG
		}
	}
}
