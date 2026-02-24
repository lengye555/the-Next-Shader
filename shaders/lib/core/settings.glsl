/*
const int colortex0Format = RGB16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGBA8;
const int colortex3Format = RGBA8;
const int colortex4Format = RGBA16F;
const int colortex5Format = RGBA16F;
const int colortex6Format = RGBA32F;
const int colortex7Format = RGBA16F;
const int shadowcolor0Format = RGBA16F;
*/

const bool      colortex6Clear = false;
const bool      colortex7Clear = false;

const int 		noiseTextureResolution  = 128;

const int 		shadowMapResolution 	= 2048;		// [1024 2048 4096 6144 8192 16384 32768]
const float     sunPathRotation         =-40.0f;
const float 	shadowDistance 			= 192.0;	// [64.0 96.0 128.0 192.0 256.0 384.0 512.0 768.0 1024.0]
const float 	shadowIntervalSize 		= 4.0f;
const float     shadowDistanceRenderMul = 1.0f;		// [-1.0f 1.0f]

const float HALF_PI = 1.5707963267948966;
const float PI      = 3.14159265359;
const float _2PI    = 6.28318530718;
const float _4PI    = 12.5663706144;

const float GOLDEN_RATIO = 0.61803398875;
const float GOLDEN_ANGLE = 2.39996323;

const float goldenSin = sin(GOLDEN_ANGLE);
const float goldenCos = cos(GOLDEN_ANGLE);
const mat2  goldenRot = mat2(goldenCos, -goldenSin, goldenSin, goldenCos);

const float EarthRadius             = 6378.137;
const float EarthRadiusSquared      = EarthRadius * EarthRadius;
const float AtmosphereThickness     = 100.0;
const float AtmosphereRadius        = EarthRadius + AtmosphereThickness;
const float AtmosphereRadiusSquared = AtmosphereRadius * AtmosphereRadius;
const float RayleighScalarAltitude  = 8.5;
const float MieScalarAltitude       = 1.2;

#define TransmittanceLut colortex5
#define UseTransmittanceLut

#define AtmosphereType 2

#if AtmosphereType == 0
    const vec3  RayleighScatteringCoefficient = vec3(0.00559495220371, 0.0117551946648, 0.02767445204);
    const vec3  MieScatteringCoefficient      = vec3(0.0170860716184, 0.0240702118158, 0.0356570844484);
    const vec3  OzoneAbsorptionCoefficient    = vec3(4.9799463143e-10, 3.0842607592e-10, -9.1714404502e-12) * 100000.0;
    const vec3  MieAbsorptionCoefficient      = MieScatteringCoefficient * 0.1;
#elif AtmosphereType == 1
    const vec3  RayleighScatteringCoefficient = vec3(5.802, 13.558, 33.1) * 1e-3;
    const vec3  MieScatteringCoefficient      = vec3(3.996) * 1e-3;
    const vec3  OzoneAbsorptionCoefficient    = vec3(0.65, 1.881, 0.085) * 1e-3;
    const vec3  MieAbsorptionCoefficient      = vec3(4.4) * 1e-3;
#elif AtmosphereType == 2
    const vec3  RayleighScatteringCoefficient = vec3(5.802, 13.558, 33.1) * 1e-3 * vec3(1.2, 0.9, 0.9);
    const vec3  MieScatteringCoefficient      = vec3(3.996) * 1e-3 * 5.0;
    const vec3  OzoneAbsorptionCoefficient    = vec3(0.65, 1.881, 0.085) * 1e-3;
    const vec3  MieAbsorptionCoefficient      = vec3(4.4) * 1e-3;
#endif

#define ReferenceHeight 1.0
float cameraAltitude = ReferenceHeight + max(cameraPosition.y + 64.0, 0.0) * 0.001;
float cameraHeight = cameraAltitude + EarthRadius;
vec3  cameraLocation = vec3(0.0, cameraHeight, 0.0);

vec3 sunViewDir   = normalize(sunPosition);
vec3 moonViewDir  = normalize(moonPosition);
vec3 lightViewDir = normalize(shadowLightPosition);

vec3 sunDir   = mat3(gbufferModelViewInverse) * sunViewDir;
vec3 moonDir  = mat3(gbufferModelViewInverse) * moonViewDir;
vec3 lightDir = mat3(gbufferModelViewInverse) * lightViewDir;

vec3 sunLuminance   = vec3(10.0) * mix(1.0, 0.02, sqrt(sqrt(rainStrength)));
vec3 moonLuminance  = vec3(0.01);
vec3 lightLuminance = sunDir.y > 0.0 ? sunLuminance : moonLuminance;

#define SHADOW_BIAS 0.925
#define TAA
#define TAA_Intensity 0.25

#define VanillaAO
#define RSM_ON