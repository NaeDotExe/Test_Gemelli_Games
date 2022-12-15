// Made with Amplify Shader Editor v1.9.0.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Gemelli/FX_Slash"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][Header(Main Texture)][Header(.)]_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MainColor("Main Color", Color) = (1,1,1,1)
		_TextureLevels("Texture Levels", Float) = 1
		_TexAlphaPower("Tex Alpha Power", Float) = 1
		_TexturePanSpeed("Texture Pan Speed", Vector) = (0,0,0,0)
		_EmissiveIntensity("EmissiveIntensity", Float) = 1
		_OpacityInt("OpacityInt", Float) = 1
		_FinalMix("FinalMix", Float) = 1
		[KeywordEnum(True,False)] _Texhasaslpha("Tex has aslpha", Float) = 0
		[Toggle(_USEGRADIENTMAP_ON)] _UseGradientMap("Use Gradient Map", Float) = 0
		_GradientMap("Gradient Map", 2D) = "white" {}
		_GradientMapValues("Gradient Map Values", Vector) = (0,0,1,1)
		[KeywordEnum(Panner,Custom)] _PanType("PanType", Float) = 0
		_VertexOffset("Vertex Offset", Float) = 0
		_DFDistance("DF Distance", Float) = 0
		_DissolveTexture("Dissolve Texture", 2D) = "white" {}
		_DIssolveSpeed("DIssolve Speed", Vector) = (0,0,0,0)
		_DissolveMask("Dissolve Mask", Float) = 1
		_FresnelMaskScale("Fresnel Mask Scale", Float) = 0
		[ASEEnd][KeywordEnum(False,True)] _FresnelMask("Fresnel Mask", Float) = 0

		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend One OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 130108
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _TEXHASASLPHA_TRUE _TEXHASASLPHA_FALSE
			#pragma shader_feature_local _PANTYPE_PANNER _PANTYPE_CUSTOM
			#pragma shader_feature_local _USEGRADIENTMAP_ON
			#pragma shader_feature_local _FRESNELMASK_FALSE _FRESNELMASK_TRUE


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _GradientMapValues;
			float4 _MainColor;
			float4 _DissolveTexture_ST;
			float2 _TexturePanSpeed;
			float2 _DIssolveSpeed;
			float _VertexOffset;
			float _TexAlphaPower;
			float _EmissiveIntensity;
			float _TextureLevels;
			float _FinalMix;
			float _DFDistance;
			float _OpacityInt;
			float _DissolveMask;
			float _FresnelMaskScale;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _GradientMap;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _DissolveTexture;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float3 appendResult213 = (float3(0.0 , _VertexOffset , 0.0));
				float2 uv_MainTex = v.ase_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(v.ase_texcoord.z , v.ase_texcoord.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2Dlod( _MainTex, float4( staticSwitch50, 0, 0.0) );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float3 lerpResult209 = lerp( temp_cast_0 , appendResult213 , texAlpha270);
				float3 lerpResult231 = lerp( float3( 0,0,0 ) , lerpResult209 , v.ase_color.a);
				float3 VertexOffset272 = lerpResult231;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset272;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(IN.ase_texcoord3.z , IN.ase_texcoord3.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2D( _MainTex, staticSwitch50 );
				float4 temp_cast_0 = (_TextureLevels).xxxx;
				float4 temp_output_72_0 = pow( tex2DNode1 , temp_cast_0 );
				float2 appendResult229 = (float2(_GradientMapValues.x , _GradientMapValues.x));
				float2 appendResult230 = (float2(_GradientMapValues.y , _GradientMapValues.y));
				float2 appendResult140 = (float2(temp_output_72_0.rg));
				float2 smoothstepResult227 = smoothstep( appendResult229 , appendResult230 , appendResult140);
				float2 clampResult291 = clamp( smoothstepResult227 , float2( 0.1,0.1 ) , float2( 0.9,0.9 ) );
				#ifdef _USEGRADIENTMAP_ON
				float4 staticSwitch137 = ( IN.ase_color * tex2D( _GradientMap, clampResult291 ) );
				#else
				float4 staticSwitch137 = ( IN.ase_color * temp_output_72_0 );
				#endif
				float3 appendResult303 = (float3(_MainColor.r , _MainColor.g , _MainColor.b));
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth305 = (SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy )*( _ProjectionParams.z - _ProjectionParams.y ));
				float distanceDepth305 = saturate( abs( ( screenDepth305 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DFDistance ) ) );
				float2 uv_DissolveTexture = IN.ase_texcoord3.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
				float2 panner315 = ( 1.0 * _Time.y * _DIssolveSpeed + uv_DissolveTexture);
				float temp_output_93_0 = ( _FinalMix * ( ( _MainColor.a * texAlpha270 * IN.ase_color.a ) * _OpacityInt ) );
				float OPLvl319 = temp_output_93_0;
				float lerpResult310 = lerp( 0.0 , tex2D( _DissolveTexture, panner315 ).r , pow( ( IN.ase_color.a * OPLvl319 ) , _DissolveMask ));
				float DissolveMask312 = saturate( lerpResult310 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float fresnelNdotV326 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode326 = ( 0.0 + _FresnelMaskScale * pow( 1.0 - fresnelNdotV326, 5.0 ) );
				#if defined(_FRESNELMASK_FALSE)
				float staticSwitch329 = 1.0;
				#elif defined(_FRESNELMASK_TRUE)
				float staticSwitch329 = saturate( fresnelNode326 );
				#else
				float staticSwitch329 = 1.0;
				#endif
				float FresnelMask331 = staticSwitch329;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( _EmissiveIntensity * ( staticSwitch137 * float4( appendResult303 , 0.0 ) * texAlpha270 ) ) * _FinalMix * distanceDepth305 * DissolveMask312 * FresnelMask331 ).rgb;
				float Alpha = saturate( ( temp_output_93_0 * distanceDepth305 * DissolveMask312 * FresnelMask331 ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif


				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 130108
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _TEXHASASLPHA_TRUE _TEXHASASLPHA_FALSE
			#pragma shader_feature_local _PANTYPE_PANNER _PANTYPE_CUSTOM
			#pragma shader_feature_local _FRESNELMASK_FALSE _FRESNELMASK_TRUE


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _GradientMapValues;
			float4 _MainColor;
			float4 _DissolveTexture_ST;
			float2 _TexturePanSpeed;
			float2 _DIssolveSpeed;
			float _VertexOffset;
			float _TexAlphaPower;
			float _EmissiveIntensity;
			float _TextureLevels;
			float _FinalMix;
			float _DFDistance;
			float _OpacityInt;
			float _DissolveMask;
			float _FresnelMaskScale;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _DissolveTexture;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float3 appendResult213 = (float3(0.0 , _VertexOffset , 0.0));
				float2 uv_MainTex = v.ase_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(v.ase_texcoord.z , v.ase_texcoord.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2Dlod( _MainTex, float4( staticSwitch50, 0, 0.0) );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float3 lerpResult209 = lerp( temp_cast_0 , appendResult213 , texAlpha270);
				float3 lerpResult231 = lerp( float3( 0,0,0 ) , lerpResult209 , v.ase_color.a);
				float3 VertexOffset272 = lerpResult231;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				o.ase_texcoord2 = v.ase_texcoord;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset272;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(IN.ase_texcoord2.z , IN.ase_texcoord2.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2D( _MainTex, staticSwitch50 );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float temp_output_93_0 = ( _FinalMix * ( ( _MainColor.a * texAlpha270 * IN.ase_color.a ) * _OpacityInt ) );
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth305 = (SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy )*( _ProjectionParams.z - _ProjectionParams.y ));
				float distanceDepth305 = saturate( abs( ( screenDepth305 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DFDistance ) ) );
				float2 uv_DissolveTexture = IN.ase_texcoord2.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
				float2 panner315 = ( 1.0 * _Time.y * _DIssolveSpeed + uv_DissolveTexture);
				float OPLvl319 = temp_output_93_0;
				float lerpResult310 = lerp( 0.0 , tex2D( _DissolveTexture, panner315 ).r , pow( ( IN.ase_color.a * OPLvl319 ) , _DissolveMask ));
				float DissolveMask312 = saturate( lerpResult310 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV326 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode326 = ( 0.0 + _FresnelMaskScale * pow( 1.0 - fresnelNdotV326, 5.0 ) );
				#if defined(_FRESNELMASK_FALSE)
				float staticSwitch329 = 1.0;
				#elif defined(_FRESNELMASK_TRUE)
				float staticSwitch329 = saturate( fresnelNode326 );
				#else
				float staticSwitch329 = 1.0;
				#endif
				float FresnelMask331 = staticSwitch329;
				
				float Alpha = saturate( ( temp_output_93_0 * distanceDepth305 * DissolveMask312 * FresnelMask331 ) );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }
			
			Blend One OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 130108
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _TEXHASASLPHA_TRUE _TEXHASASLPHA_FALSE
			#pragma shader_feature_local _PANTYPE_PANNER _PANTYPE_CUSTOM
			#pragma shader_feature_local _USEGRADIENTMAP_ON
			#pragma shader_feature_local _FRESNELMASK_FALSE _FRESNELMASK_TRUE


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _GradientMapValues;
			float4 _MainColor;
			float4 _DissolveTexture_ST;
			float2 _TexturePanSpeed;
			float2 _DIssolveSpeed;
			float _VertexOffset;
			float _TexAlphaPower;
			float _EmissiveIntensity;
			float _TextureLevels;
			float _FinalMix;
			float _DFDistance;
			float _OpacityInt;
			float _DissolveMask;
			float _FresnelMaskScale;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _GradientMap;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _DissolveTexture;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float3 appendResult213 = (float3(0.0 , _VertexOffset , 0.0));
				float2 uv_MainTex = v.ase_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(v.ase_texcoord.z , v.ase_texcoord.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2Dlod( _MainTex, float4( staticSwitch50, 0, 0.0) );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float3 lerpResult209 = lerp( temp_cast_0 , appendResult213 , texAlpha270);
				float3 lerpResult231 = lerp( float3( 0,0,0 ) , lerpResult209 , v.ase_color.a);
				float3 VertexOffset272 = lerpResult231;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset272;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(IN.ase_texcoord3.z , IN.ase_texcoord3.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2D( _MainTex, staticSwitch50 );
				float4 temp_cast_0 = (_TextureLevels).xxxx;
				float4 temp_output_72_0 = pow( tex2DNode1 , temp_cast_0 );
				float2 appendResult229 = (float2(_GradientMapValues.x , _GradientMapValues.x));
				float2 appendResult230 = (float2(_GradientMapValues.y , _GradientMapValues.y));
				float2 appendResult140 = (float2(temp_output_72_0.rg));
				float2 smoothstepResult227 = smoothstep( appendResult229 , appendResult230 , appendResult140);
				float2 clampResult291 = clamp( smoothstepResult227 , float2( 0.1,0.1 ) , float2( 0.9,0.9 ) );
				#ifdef _USEGRADIENTMAP_ON
				float4 staticSwitch137 = ( IN.ase_color * tex2D( _GradientMap, clampResult291 ) );
				#else
				float4 staticSwitch137 = ( IN.ase_color * temp_output_72_0 );
				#endif
				float3 appendResult303 = (float3(_MainColor.r , _MainColor.g , _MainColor.b));
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth305 = (SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy )*( _ProjectionParams.z - _ProjectionParams.y ));
				float distanceDepth305 = saturate( abs( ( screenDepth305 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DFDistance ) ) );
				float2 uv_DissolveTexture = IN.ase_texcoord3.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
				float2 panner315 = ( 1.0 * _Time.y * _DIssolveSpeed + uv_DissolveTexture);
				float temp_output_93_0 = ( _FinalMix * ( ( _MainColor.a * texAlpha270 * IN.ase_color.a ) * _OpacityInt ) );
				float OPLvl319 = temp_output_93_0;
				float lerpResult310 = lerp( 0.0 , tex2D( _DissolveTexture, panner315 ).r , pow( ( IN.ase_color.a * OPLvl319 ) , _DissolveMask ));
				float DissolveMask312 = saturate( lerpResult310 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float fresnelNdotV326 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode326 = ( 0.0 + _FresnelMaskScale * pow( 1.0 - fresnelNdotV326, 5.0 ) );
				#if defined(_FRESNELMASK_FALSE)
				float staticSwitch329 = 1.0;
				#elif defined(_FRESNELMASK_TRUE)
				float staticSwitch329 = saturate( fresnelNode326 );
				#else
				float staticSwitch329 = 1.0;
				#endif
				float FresnelMask331 = staticSwitch329;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( _EmissiveIntensity * ( staticSwitch137 * float4( appendResult303 , 0.0 ) * texAlpha270 ) ) * _FinalMix * distanceDepth305 * DissolveMask312 * FresnelMask331 ).rgb;
				float Alpha = saturate( ( temp_output_93_0 * distanceDepth305 * DissolveMask312 * FresnelMask331 ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif


				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}


		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }
        
			Cull Off

			HLSLPROGRAM
        
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 130108
			#define REQUIRE_DEPTH_TEXTURE 1

        
			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _TEXHASASLPHA_TRUE _TEXHASASLPHA_FALSE
			#pragma shader_feature_local _PANTYPE_PANNER _PANTYPE_CUSTOM
			#pragma shader_feature_local _FRESNELMASK_FALSE _FRESNELMASK_TRUE


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _GradientMapValues;
			float4 _MainColor;
			float4 _DissolveTexture_ST;
			float2 _TexturePanSpeed;
			float2 _DIssolveSpeed;
			float _VertexOffset;
			float _TexAlphaPower;
			float _EmissiveIntensity;
			float _TextureLevels;
			float _FinalMix;
			float _DFDistance;
			float _OpacityInt;
			float _DissolveMask;
			float _FresnelMaskScale;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _MainTex;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _DissolveTexture;


			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				float3 temp_cast_0 = (0.0).xxx;
				float3 appendResult213 = (float3(0.0 , _VertexOffset , 0.0));
				float2 uv_MainTex = v.ase_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(v.ase_texcoord.z , v.ase_texcoord.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2Dlod( _MainTex, float4( staticSwitch50, 0, 0.0) );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float3 lerpResult209 = lerp( temp_cast_0 , appendResult213 , texAlpha270);
				float3 lerpResult231 = lerp( float3( 0,0,0 ) , lerpResult209 , v.ase_color.a);
				float3 VertexOffset272 = lerpResult231;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord2.xyz = ase_worldPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset272;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif
			
			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(IN.ase_texcoord.z , IN.ase_texcoord.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2D( _MainTex, staticSwitch50 );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float temp_output_93_0 = ( _FinalMix * ( ( _MainColor.a * texAlpha270 * IN.ase_color.a ) * _OpacityInt ) );
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth305 = (SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy )*( _ProjectionParams.z - _ProjectionParams.y ));
				float distanceDepth305 = saturate( abs( ( screenDepth305 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DFDistance ) ) );
				float2 uv_DissolveTexture = IN.ase_texcoord.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
				float2 panner315 = ( 1.0 * _Time.y * _DIssolveSpeed + uv_DissolveTexture);
				float OPLvl319 = temp_output_93_0;
				float lerpResult310 = lerp( 0.0 , tex2D( _DissolveTexture, panner315 ).r , pow( ( IN.ase_color.a * OPLvl319 ) , _DissolveMask ));
				float DissolveMask312 = saturate( lerpResult310 );
				float3 ase_worldPos = IN.ase_texcoord2.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV326 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode326 = ( 0.0 + _FresnelMaskScale * pow( 1.0 - fresnelNdotV326, 5.0 ) );
				#if defined(_FRESNELMASK_FALSE)
				float staticSwitch329 = 1.0;
				#elif defined(_FRESNELMASK_TRUE)
				float staticSwitch329 = saturate( fresnelNode326 );
				#else
				float staticSwitch329 = 1.0;
				#endif
				float FresnelMask331 = staticSwitch329;
				
				surfaceDescription.Alpha = saturate( ( temp_output_93_0 * distanceDepth305 * DissolveMask312 * FresnelMask331 ) );
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}

			ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }
        
			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 130108
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY
			

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _TEXHASASLPHA_TRUE _TEXHASASLPHA_FALSE
			#pragma shader_feature_local _PANTYPE_PANNER _PANTYPE_CUSTOM
			#pragma shader_feature_local _FRESNELMASK_FALSE _FRESNELMASK_TRUE


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _GradientMapValues;
			float4 _MainColor;
			float4 _DissolveTexture_ST;
			float2 _TexturePanSpeed;
			float2 _DIssolveSpeed;
			float _VertexOffset;
			float _TexAlphaPower;
			float _EmissiveIntensity;
			float _TextureLevels;
			float _FinalMix;
			float _DFDistance;
			float _OpacityInt;
			float _DissolveMask;
			float _FresnelMaskScale;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _MainTex;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _DissolveTexture;


			
        
			float4 _SelectionID;

        
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				float3 temp_cast_0 = (0.0).xxx;
				float3 appendResult213 = (float3(0.0 , _VertexOffset , 0.0));
				float2 uv_MainTex = v.ase_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(v.ase_texcoord.z , v.ase_texcoord.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2Dlod( _MainTex, float4( staticSwitch50, 0, 0.0) );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float3 lerpResult209 = lerp( temp_cast_0 , appendResult213 , texAlpha270);
				float3 lerpResult231 = lerp( float3( 0,0,0 ) , lerpResult209 , v.ase_color.a);
				float3 VertexOffset272 = lerpResult231;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord2.xyz = ase_worldPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset272;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(IN.ase_texcoord.z , IN.ase_texcoord.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2D( _MainTex, staticSwitch50 );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float temp_output_93_0 = ( _FinalMix * ( ( _MainColor.a * texAlpha270 * IN.ase_color.a ) * _OpacityInt ) );
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth305 = (SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy )*( _ProjectionParams.z - _ProjectionParams.y ));
				float distanceDepth305 = saturate( abs( ( screenDepth305 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DFDistance ) ) );
				float2 uv_DissolveTexture = IN.ase_texcoord.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
				float2 panner315 = ( 1.0 * _Time.y * _DIssolveSpeed + uv_DissolveTexture);
				float OPLvl319 = temp_output_93_0;
				float lerpResult310 = lerp( 0.0 , tex2D( _DissolveTexture, panner315 ).r , pow( ( IN.ase_color.a * OPLvl319 ) , _DissolveMask ));
				float DissolveMask312 = saturate( lerpResult310 );
				float3 ase_worldPos = IN.ase_texcoord2.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV326 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode326 = ( 0.0 + _FresnelMaskScale * pow( 1.0 - fresnelNdotV326, 5.0 ) );
				#if defined(_FRESNELMASK_FALSE)
				float staticSwitch329 = 1.0;
				#elif defined(_FRESNELMASK_TRUE)
				float staticSwitch329 = saturate( fresnelNode326 );
				#else
				float staticSwitch329 = 1.0;
				#endif
				float FresnelMask331 = staticSwitch329;
				
				surfaceDescription.Alpha = saturate( ( temp_output_93_0 * distanceDepth305 * DissolveMask312 * FresnelMask331 ) );
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;
				
				return outColor;
			}
        
			ENDHLSL
        }
		
		
        Pass
        {
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

        
			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 130108
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma multi_compile_fog
			#pragma instancing_options renderinglayer
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _TEXHASASLPHA_TRUE _TEXHASASLPHA_FALSE
			#pragma shader_feature_local _PANTYPE_PANNER _PANTYPE_CUSTOM
			#pragma shader_feature_local _FRESNELMASK_FALSE _FRESNELMASK_TRUE


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _GradientMapValues;
			float4 _MainColor;
			float4 _DissolveTexture_ST;
			float2 _TexturePanSpeed;
			float2 _DIssolveSpeed;
			float _VertexOffset;
			float _TexAlphaPower;
			float _EmissiveIntensity;
			float _TextureLevels;
			float _FinalMix;
			float _DFDistance;
			float _OpacityInt;
			float _DissolveMask;
			float _FresnelMaskScale;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _DissolveTexture;


			      
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float3 appendResult213 = (float3(0.0 , _VertexOffset , 0.0));
				float2 uv_MainTex = v.ase_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(v.ase_texcoord.z , v.ase_texcoord.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2Dlod( _MainTex, float4( staticSwitch50, 0, 0.0) );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float3 lerpResult209 = lerp( temp_cast_0 , appendResult213 , texAlpha270);
				float3 lerpResult231 = lerp( float3( 0,0,0 ) , lerpResult209 , v.ase_color.a);
				float3 VertexOffset272 = lerpResult231;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord3.xyz = ase_worldPos;
				
				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset272;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(IN.ase_texcoord1.z , IN.ase_texcoord1.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2D( _MainTex, staticSwitch50 );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float temp_output_93_0 = ( _FinalMix * ( ( _MainColor.a * texAlpha270 * IN.ase_color.a ) * _OpacityInt ) );
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth305 = (SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy )*( _ProjectionParams.z - _ProjectionParams.y ));
				float distanceDepth305 = saturate( abs( ( screenDepth305 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DFDistance ) ) );
				float2 uv_DissolveTexture = IN.ase_texcoord1.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
				float2 panner315 = ( 1.0 * _Time.y * _DIssolveSpeed + uv_DissolveTexture);
				float OPLvl319 = temp_output_93_0;
				float lerpResult310 = lerp( 0.0 , tex2D( _DissolveTexture, panner315 ).r , pow( ( IN.ase_color.a * OPLvl319 ) , _DissolveMask ));
				float DissolveMask312 = saturate( lerpResult310 );
				float3 ase_worldPos = IN.ase_texcoord3.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV326 = dot( IN.normalWS, ase_worldViewDir );
				float fresnelNode326 = ( 0.0 + _FresnelMaskScale * pow( 1.0 - fresnelNdotV326, 5.0 ) );
				#if defined(_FRESNELMASK_FALSE)
				float staticSwitch329 = 1.0;
				#elif defined(_FRESNELMASK_TRUE)
				float staticSwitch329 = saturate( fresnelNode326 );
				#else
				float staticSwitch329 = 1.0;
				#endif
				float FresnelMask331 = staticSwitch329;
				
				surfaceDescription.Alpha = saturate( ( temp_output_93_0 * distanceDepth305 * DissolveMask312 * FresnelMask331 ) );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;
				return half4(NormalizeNormalPerPixel(normalWS), 0.0);

			}
        
			ENDHLSL
        }

		
        Pass
        {
			
            Name "DepthNormalsOnly"
            Tags { "LightMode"="DepthNormalsOnly" }
        
			ZTest LEqual
			ZWrite On
        
        
			HLSLPROGRAM
        
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 130108
			#define REQUIRE_DEPTH_TEXTURE 1

        
			#pragma exclude_renderers glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag
        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
        
			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _TEXHASASLPHA_TRUE _TEXHASASLPHA_FALSE
			#pragma shader_feature_local _PANTYPE_PANNER _PANTYPE_CUSTOM
			#pragma shader_feature_local _FRESNELMASK_FALSE _FRESNELMASK_TRUE


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _GradientMapValues;
			float4 _MainColor;
			float4 _DissolveTexture_ST;
			float2 _TexturePanSpeed;
			float2 _DIssolveSpeed;
			float _VertexOffset;
			float _TexAlphaPower;
			float _EmissiveIntensity;
			float _TextureLevels;
			float _FinalMix;
			float _DFDistance;
			float _OpacityInt;
			float _DissolveMask;
			float _FresnelMaskScale;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _DissolveTexture;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
      
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float3 appendResult213 = (float3(0.0 , _VertexOffset , 0.0));
				float2 uv_MainTex = v.ase_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(v.ase_texcoord.z , v.ase_texcoord.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2Dlod( _MainTex, float4( staticSwitch50, 0, 0.0) );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float3 lerpResult209 = lerp( temp_cast_0 , appendResult213 , texAlpha270);
				float3 lerpResult231 = lerp( float3( 0,0,0 ) , lerpResult209 , v.ase_color.a);
				float3 VertexOffset272 = lerpResult231;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord3.xyz = ase_worldPos;
				
				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset272;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner34 = ( 1.0 * _Time.y * _TexturePanSpeed + uv_MainTex);
				float2 appendResult52 = (float2(IN.ase_texcoord1.z , IN.ase_texcoord1.w));
				#if defined(_PANTYPE_PANNER)
				float2 staticSwitch50 = panner34;
				#elif defined(_PANTYPE_CUSTOM)
				float2 staticSwitch50 = ( uv_MainTex + appendResult52 );
				#else
				float2 staticSwitch50 = panner34;
				#endif
				float4 tex2DNode1 = tex2D( _MainTex, staticSwitch50 );
				#if defined(_TEXHASASLPHA_TRUE)
				float staticSwitch71 = tex2DNode1.a;
				#elif defined(_TEXHASASLPHA_FALSE)
				float staticSwitch71 = tex2DNode1.r;
				#else
				float staticSwitch71 = tex2DNode1.a;
				#endif
				float texAlpha270 = pow( staticSwitch71 , _TexAlphaPower );
				float temp_output_93_0 = ( _FinalMix * ( ( _MainColor.a * texAlpha270 * IN.ase_color.a ) * _OpacityInt ) );
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth305 = (SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy )*( _ProjectionParams.z - _ProjectionParams.y ));
				float distanceDepth305 = saturate( abs( ( screenDepth305 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DFDistance ) ) );
				float2 uv_DissolveTexture = IN.ase_texcoord1.xy * _DissolveTexture_ST.xy + _DissolveTexture_ST.zw;
				float2 panner315 = ( 1.0 * _Time.y * _DIssolveSpeed + uv_DissolveTexture);
				float OPLvl319 = temp_output_93_0;
				float lerpResult310 = lerp( 0.0 , tex2D( _DissolveTexture, panner315 ).r , pow( ( IN.ase_color.a * OPLvl319 ) , _DissolveMask ));
				float DissolveMask312 = saturate( lerpResult310 );
				float3 ase_worldPos = IN.ase_texcoord3.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV326 = dot( IN.normalWS, ase_worldViewDir );
				float fresnelNode326 = ( 0.0 + _FresnelMaskScale * pow( 1.0 - fresnelNdotV326, 5.0 ) );
				#if defined(_FRESNELMASK_FALSE)
				float staticSwitch329 = 1.0;
				#elif defined(_FRESNELMASK_TRUE)
				float staticSwitch329 = saturate( fresnelNode326 );
				#else
				float staticSwitch329 = 1.0;
				#endif
				float FresnelMask331 = staticSwitch329;
				
				surfaceDescription.Alpha = saturate( ( temp_output_93_0 * distanceDepth305 * DissolveMask312 * FresnelMask331 ) );
				surfaceDescription.AlphaClipThreshold = 0.5;
				
				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;
				return half4(NormalizeNormalPerPixel(normalWS), 0.0);

			}

			ENDHLSL
        }
		
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=19002
256;121;1414;795;-458.9649;-343.0888;1;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;51;-2482.709,174.2293;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;33;-2502.949,-9.435335;Inherit;False;Property;_TexturePanSpeed;Texture Pan Speed;4;0;Create;True;0;0;0;False;0;False;0,0;-0.5,0.7;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;-2762.196,-84.47609;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;52;-2207.609,243.4293;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;34;-2170.149,-75.73552;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-1919.312,98.92212;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;50;-1725.609,-52.57072;Inherit;False;Property;_PanType;PanType;12;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Panner;Custom;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-1294.874,-62.20654;Inherit;True;Property;_MainTex;MainTex;0;1;[Header];Create;True;2;Main Texture;.;0;0;False;0;False;-1;None;0fd74301f0dca0049a4643eed6ac0607;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;71;-682.5047,234.2672;Inherit;False;Property;_Texhasaslpha;Tex has aslpha;8;0;Create;True;0;0;0;False;0;False;0;0;1;True;;KeywordEnum;2;True;False;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;287;-530.6323,410.6998;Inherit;False;Property;_TexAlphaPower;Tex Alpha Power;3;0;Create;True;0;0;0;False;0;False;1;2.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;286;-352.6323,237.6998;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;105;211.0267,59.1167;Inherit;False;Property;_MainColor;Main Color;1;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;270;-103.833,237.4348;Inherit;False;texAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;300;329.42,415.6875;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;293;756.1365,454.5818;Inherit;False;Property;_OpacityInt;OpacityInt;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;581.787,319.7767;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;916.0898,340.6634;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;1412.649,225.8796;Float;False;Property;_FinalMix;FinalMix;7;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;1526.02,353.7219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;319;1700.419,352.7703;Inherit;False;OPLvl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;317;110.1359,1370.662;Inherit;False;Property;_DIssolveSpeed;DIssolve Speed;16;0;Create;True;0;0;0;False;0;False;0,0;0.52,-0.6;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.VertexColorNode;311;535.6101,1541.635;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;316;43.13586,1210.662;Inherit;False;0;308;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;332;-688.0064,2145.008;Inherit;False;1191.747;348.7886;Fresnel Mask;6;327;326;328;329;330;331;Fresnel Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;320;564.7974,1761.46;Inherit;False;319;OPLvl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;779.8027,1631.717;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;315;367.1359,1342.662;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;325;593.8298,1877.284;Inherit;False;Property;_DissolveMask;Dissolve Mask;17;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;328;-638.0064,2359.243;Inherit;False;Property;_FresnelMaskScale;Fresnel Mask Scale;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;326;-406.8419,2291.796;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;274;1010.248,1917.892;Inherit;False;1333.326;581.8572;Vertex Offset;8;211;213;210;232;209;231;271;272;Vertex Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;308;590.7581,1305.954;Inherit;True;Property;_DissolveTexture;Dissolve Texture;15;0;Create;True;0;0;0;False;0;False;-1;1402758e2a0168e42963097b9df5517a;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;323;969.8864,1626.581;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-104.4053,2195.008;Inherit;False;Constant;_1;1;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;310;1136.686,1314.118;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;327;-163.0065,2289.242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;1060.248,2087.892;Inherit;False;Property;_VertexOffset;Vertex Offset;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;1226.047,2239.389;Inherit;False;270;texAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;213;1256.585,2069.405;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;321;1629.904,1327.71;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;329;59.70762,2247.281;Inherit;False;Property;_FresnelMask;Fresnel Mask;19;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;False;True;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;1269.248,1967.892;Inherit;False;Constant;_Float1;Float 1;26;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;331;279.7404,2248.496;Inherit;False;FresnelMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;1803.486,1324.703;Inherit;False;DissolveMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;232;1452.762,2292.749;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;209;1497.248,2151.892;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;306;1167.047,701.6059;Inherit;False;Property;_DFDistance;DF Distance;14;0;Create;True;0;0;0;False;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;231;1818.762,2125.749;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DepthFade;305;1362.167,687.8867;Inherit;False;False;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;333;1370.596,915.9177;Inherit;False;331;FresnelMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;1374.772,805.4383;Inherit;False;312;DissolveMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;2119.574,2176.445;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;1809.444,597.3315;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;430.5312,-223.1785;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;228;-691.0458,-4.844086;Inherit;False;Property;_GradientMapValues;Gradient Map Values;11;0;Create;True;0;0;0;False;0;False;0,0,1,1;0,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;314;2004.261,334.1174;Inherit;False;312;DissolveMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;54;82.84537,-568.7377;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;301;300.4512,-569.9586;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;102;924.0078,15.78011;Float;False;Property;_EmissiveIntensity;EmissiveIntensity;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;230;-388.0458,113.1559;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;500.5389,-407.136;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;304;1465.946,-56.76116;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;227;-299.7458,-137.0441;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;72;-721.8896,-401.4174;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;1167.71,95.95685;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;137;650.3922,-195.8156;Inherit;False;Property;_UseGradientMap;Use Gradient Map;9;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;2235.301,628.3495;Inherit;False;272;VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;302;306.4512,-337.9586;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;229;-447.0458,24.15591;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;303;536.4512,68.04138;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;334;1976.368,421.9592;Inherit;False;331;FresnelMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;873.4258,126.2608;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;106;1994.597,548.6252;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;298;1284.875,531.6536;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;140;-492.4338,-76.6626;Inherit;False;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;291;-91.63232,-147.3002;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;2;FLOAT2;0.9,0.9;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;138;77.61708,-167.2225;Inherit;True;Property;_GradientMap;Gradient Map;10;0;Create;True;0;0;0;False;0;False;-1;None;5b15df7d91681b0449ace535b9f251eb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;2297.01,152.8632;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;141;-207.4338,92.3374;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;2;FLOAT2;0.9,0.9;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-890.8885,-85.16898;Inherit;False;Property;_TextureLevels;Texture Levels;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;265;3596.901,-93.46132;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;258;2515.727,141.4769;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;12;Gemelli/FX_Slash;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;3;1;False;;10;False;;2;5;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;False;;True;False;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637995355319641646;  Blend;0;637995415215642169;Two Sided;0;637994633629630260;Cast Shadows;0;637995415240947186;  Use Shadow Threshold;0;0;Receive Shadows;0;637995415252946689;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;264;3596.901,-93.46132;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;262;3596.901,-93.46132;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;3;1;False;;10;False;;2;5;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;0;False;;True;False;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;260;3596.901,-93.46132;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;257;2227.846,210.2366;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;266;3596.901,-93.46132;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;263;3596.901,-93.46132;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;259;3596.901,-93.46132;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;261;3596.901,-93.46132;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;52;0;51;3
WireConnection;52;1;51;4
WireConnection;34;0;32;0
WireConnection;34;2;33;0
WireConnection;53;0;32;0
WireConnection;53;1;52;0
WireConnection;50;1;34;0
WireConnection;50;0;53;0
WireConnection;1;1;50;0
WireConnection;71;1;1;4
WireConnection;71;0;1;1
WireConnection;286;0;71;0
WireConnection;286;1;287;0
WireConnection;270;0;286;0
WireConnection;99;0;105;4
WireConnection;99;1;270;0
WireConnection;99;2;300;4
WireConnection;101;0;99;0
WireConnection;101;1;293;0
WireConnection;93;0;96;0
WireConnection;93;1;101;0
WireConnection;319;0;93;0
WireConnection;322;0;311;4
WireConnection;322;1;320;0
WireConnection;315;0;316;0
WireConnection;315;2;317;0
WireConnection;326;2;328;0
WireConnection;308;1;315;0
WireConnection;323;0;322;0
WireConnection;323;1;325;0
WireConnection;310;1;308;1
WireConnection;310;2;323;0
WireConnection;327;0;326;0
WireConnection;213;1;211;0
WireConnection;321;0;310;0
WireConnection;329;1;330;0
WireConnection;329;0;327;0
WireConnection;331;0;329;0
WireConnection;312;0;321;0
WireConnection;209;0;210;0
WireConnection;209;1;213;0
WireConnection;209;2;271;0
WireConnection;231;1;209;0
WireConnection;231;2;232;4
WireConnection;305;0;306;0
WireConnection;272;0;231;0
WireConnection;307;0;93;0
WireConnection;307;1;305;0
WireConnection;307;2;313;0
WireConnection;307;3;333;0
WireConnection;299;0;54;0
WireConnection;299;1;138;0
WireConnection;301;0;54;1
WireConnection;301;1;54;2
WireConnection;301;2;54;3
WireConnection;230;0;228;2
WireConnection;230;1;228;2
WireConnection;55;0;54;0
WireConnection;55;1;72;0
WireConnection;227;0;140;0
WireConnection;227;1;229;0
WireConnection;227;2;230;0
WireConnection;72;0;1;0
WireConnection;72;1;74;0
WireConnection;104;0;102;0
WireConnection;104;1;103;0
WireConnection;137;1;55;0
WireConnection;137;0;299;0
WireConnection;302;0;54;1
WireConnection;302;1;54;2
WireConnection;302;2;54;3
WireConnection;229;0;228;1
WireConnection;229;1;228;1
WireConnection;303;0;105;1
WireConnection;303;1;105;2
WireConnection;303;2;105;3
WireConnection;103;0;137;0
WireConnection;103;1;303;0
WireConnection;103;2;270;0
WireConnection;106;0;307;0
WireConnection;140;0;72;0
WireConnection;291;0;227;0
WireConnection;138;1;291;0
WireConnection;94;0;104;0
WireConnection;94;1;96;0
WireConnection;94;2;305;0
WireConnection;94;3;314;0
WireConnection;94;4;334;0
WireConnection;258;2;94;0
WireConnection;258;3;106;0
WireConnection;258;5;273;0
ASEEND*/
//CHKSM=5D8BBBE7080656F7EB4A5817283C93361E4B59B6