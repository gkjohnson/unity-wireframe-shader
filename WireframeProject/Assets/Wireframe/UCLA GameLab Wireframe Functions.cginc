// Algorithms and shaders based on code from this journal
// http://cgg-journal.com/2008-2/06/index.html
// http://web.archive.org/web/20130322011415/http://cgg-journal.com/2008-2/06/index.html

#ifndef UCLA_GAMELAB_WIREFRAME
#define UCLA_GAMELAB_WIREFRAME

#include "UnityCG.cginc"

// For use in the Geometry Shader
// Takes in 3 vectors and calculates the distance to
// to center of the triangle for each vert
float3 UCLAGL_CalculateDistToCenter(float4 v0, float4 v1, float4 v2) {
    // points in screen space
    float2 ss0 = _ScreenParams.xy * v0.xy / v0.w;
    float2 ss1 = _ScreenParams.xy * v1.xy / v1.w;
    float2 ss2 = _ScreenParams.xy * v2.xy / v2.w;
    
    // edge vectors
    float2 e0 = ss2 - ss1;
    float2 e1 = ss2 - ss0;
    float2 e2 = ss1 - ss0;
    
    // area of the triangle
    float area = abs(e1.x * e2.y - e1.y * e2.x);
    
    // values based on distance to the center of the triangle
    float dist0 = area / length(e0);
    float dist1 = area / length(e1);
    float dist2 = area / length(e2);

    return float3(dist0, dist1, dist2);
}

// Computes the intensity of the wireframe at a point
// based on interpolated distances from center for the
// fragment, thickness, firmness, and perspective correction
// factor.
// w = 1 gives screen-space consistent wireframe thickness
float UCLAGL_GetWireframeAlpha(float3 dist, float thickness, float firmness, float w = 1) {
    // find the smallest distance
    float val = min(dist.x, min(dist.y, dist.z));
    val *= w;

    // calculate power to 2 to thin the line
    val = exp2(-1 / thickness * val * val);
    val = min(val * firmness, 1);
    return val;
}



// DATA STRUCTURES //
// Vertex to Geometry
struct UCLAGL_v2g
{
	float4	pos		: POSITION;		// vertex position
	float2  uv		: TEXCOORD0;	// vertex uv coordinate
};

// Geometry to  UCLAGL_fragment
struct UCLAGL_g2f
{
	float4	pos		: POSITION;		// fragment position
	float2	uv		: TEXCOORD0;	// fragment uv coordinate
	float3  dist	: TEXCOORD1;	// distance to each edge of the triangle
};

// PARAMETERS //

float _Thickness = 1;		// Thickness of the wireframe line rendering
float _Firmness = 1;		// Thickness of the wireframe line rendering
float4 _Color = {1,1,1,1};	// Color of the line
float4 _MainTex_ST;			// For the Main Tex UV transform
sampler2D _MainTex;			// Texture used for the line

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

#endif