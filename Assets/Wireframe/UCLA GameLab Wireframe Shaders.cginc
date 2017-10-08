#include "UnityCG.cginc"
#include "UCLA GameLab Wireframe Functions.cginc"

// DATA STRUCTURES //
// Vertex to Geometry
struct UCLAGL_v2g
{
    float4  pos     : POSITION;     // vertex position
    float2  uv      : TEXCOORD0;    // vertex uv coordinate
};

// Geometry to  UCLAGL_fragment
struct UCLAGL_g2f
{
    float4  pos     : POSITION;     // fragment position
    float2  uv      : TEXCOORD0;    // fragment uv coordinate
    float3  dist    : TEXCOORD1;    // distance to each edge of the triangle
};

// PARAMETERS //

float _Thickness = 1;       // Thickness of the wireframe line rendering
float _Firmness = 1;        // Thickness of the wireframe line rendering
float4 _Color = {1,1,1,1};  // Color of the line
float4 _MainTex_ST;         // For the Main Tex UV transform
sampler2D _MainTex;         // Texture used for the line

// SHADER PROGRAMS //
// Vertex Shader
UCLAGL_v2g UCLAGL_vert(appdata_base v)
{
    UCLAGL_v2g output;
    output.pos = UnityObjectToClipPos(v.vertex);
    output.uv = TRANSFORM_TEX (v.texcoord, _MainTex);

    return output;
}

// Geometry Shader
[maxvertexcount(3)]
void UCLAGL_geom(triangle UCLAGL_v2g p[3], inout TriangleStream<UCLAGL_g2f> triStream)
{
    float3 dist = UCLAGL_CalculateDistToCenter(p[0].pos, p[1].pos, p[2].pos);

    UCLAGL_g2f pIn;
    
    // add the first point
    pIn.pos = p[0].pos;
    pIn.uv = p[0].uv;
    pIn.dist = float3(dist.x, 0, 0);
    triStream.Append(pIn);

    // add the second point
    pIn.pos =  p[1].pos;
    pIn.uv = p[1].uv;
    pIn.dist = float3(0, dist.y, 0);
    triStream.Append(pIn);
    
    // add the third point
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