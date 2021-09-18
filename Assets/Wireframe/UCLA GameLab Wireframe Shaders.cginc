//https://answers.unity.com/questions/1702908/geometry-shader-in-vr-stereo-rendering-mode-single.html

#include "UnityCG.cginc"
#include "UCLA GameLab Wireframe Functions.cginc"

// DATA STRUCTURES //

struct appdata
{
    float4 vertex   : POSITION;
    float2 uv       : TEXCOORD0;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

// Vertex to Geometry
struct UCLAGL_v2g
{
    float4  pos     : POSITION;     // vertex position
    float2  uv      : TEXCOORD0;    // vertex uv coordinate

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

// Geometry to  UCLAGL_fragment
struct UCLAGL_g2f
{
    float4  pos     : POSITION;     // fragment position
    float2  uv      : TEXCOORD0;    // fragment uv coordinate
    float3  dist    : TEXCOORD1;    // distance to each edge of the triangle

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

// PARAMETERS //

float _Thickness = 1;       // Thickness of the wireframe line rendering
float _Firmness = 1;        // Thickness of the wireframe line rendering
float4 _Color = {1,1,1,1};  // Color of the line
float4 _MainTex_ST;         // For the Main Tex UV transform
sampler2D _MainTex;         // Texture used for the line

// SHADER PROGRAMS //
// Vertex Shader
UCLAGL_v2g UCLAGL_vert(appdata v)
{
    UCLAGL_v2g output;

    UNITY_INITIALIZE_OUTPUT( UCLAGL_v2g, output );
    UNITY_SETUP_INSTANCE_ID( v );
    UNITY_TRANSFER_INSTANCE_ID( v, output );

    output.pos = UnityObjectToClipPos(v.vertex);
    output.uv = TRANSFORM_TEX (v.uv, _MainTex);

    return output;
}

// Geometry Shader
[maxvertexcount(3)]
void UCLAGL_geom(triangle UCLAGL_v2g p[3], inout TriangleStream<UCLAGL_g2f> triStream)
{
    float3 dist = UCLAGL_CalculateDistToCenter(p[0].pos, p[1].pos, p[2].pos);

    UCLAGL_g2f pIn;
    
    // add the first point
    UNITY_INITIALIZE_OUTPUT( UCLAGL_g2f, pIn );
    UNITY_SETUP_INSTANCE_ID( p[0] );
    UNITY_TRANSFER_INSTANCE_ID( p[0], pIn );
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( pIn );
    pIn.pos = p[0].pos;
    pIn.uv = p[0].uv;
    pIn.dist = float3(dist.x, 0, 0);
    triStream.Append(pIn);

    // add the second point
    UNITY_INITIALIZE_OUTPUT( UCLAGL_g2f, pIn );
    UNITY_SETUP_INSTANCE_ID( p[1] );
    UNITY_TRANSFER_INSTANCE_ID( p[1], pIn );
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( pIn );
    pIn.pos =  p[1].pos;
    pIn.uv = p[1].uv;
    pIn.dist = float3(0, dist.y, 0);
    triStream.Append(pIn);
    
    // add the third point
    UNITY_INITIALIZE_OUTPUT( UCLAGL_g2f, pIn );
    UNITY_SETUP_INSTANCE_ID( p[2] );
    UNITY_TRANSFER_INSTANCE_ID( p[2], pIn );
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( pIn );
    pIn.pos = p[2].pos;
    pIn.uv = p[2].uv;
    pIn.dist = float3(0, 0, dist.z);
    triStream.Append(pIn);
}

// Fragment Shader
float4 UCLAGL_frag(UCLAGL_g2f input) : COLOR
{
    float w = input.pos.w;
    #if UCLAGL_DISTANCE_AGNOSTIC
    w = 1;
    #endif

    float alpha = UCLAGL_GetWireframeAlpha(input.dist, _Thickness, _Firmness, w);
    float4 col = _Color * tex2D(_MainTex, input.uv);
    col.a *= alpha;

    #if UCLAGL_CUTOUT
    if (col.a < 0.5f) discard;
    col.a = 1.0f;
    #endif

    return col;
}