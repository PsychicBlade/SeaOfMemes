#version 330 

uniform mat4 mgModelMatrix;
uniform mat4 mgMVPMatrix;
uniform mat3 mgNormalMatrix;
uniform vec3 mgEyePt;
uniform vec3 mgLightDir;
uniform vec3 mgLightColor;
uniform vec3 mgLightAmbient;
uniform vec4 mgMatColor;

uniform float fogTopHeight;
uniform float fogTopInten;
uniform float fogBotHeight;
uniform float fogBotInten;
uniform float fogMaxDist;

in vec4 vertPoint;
in vec3 vertNormal;
in vec2 vertTexCoord0;
in ivec4 vertColor;

smooth out vec4 vFragColor;
smooth out vec2 vTex;
smooth out float fog;

void main(void) 
{ 
  vec3 eyeNormal = mgNormalMatrix * vertNormal;
  float lightInten = max(0.0, dot(eyeNormal, mgLightDir));

  vec4 vInColor;
  vInColor = vertColor/255.0;

  vFragColor.rgb = vInColor.rgb * (mgLightColor * lightInten + mgLightAmbient);
  vFragColor.a = vInColor.a;

  vTex = vertTexCoord0;

  gl_Position = mgMVPMatrix * vertPoint; 

  // figure world-space coordinates of point
  vec4 pt = mgModelMatrix * vertPoint;

  float startY = clamp(mgEyePt.y, fogBotHeight, fogTopHeight);
  float endY = clamp(pt.y, fogBotHeight, fogTopHeight);

  float fogSlope = (fogTopInten - fogBotInten) / (fogTopHeight - fogBotHeight);

  float startInten = fogBotInten + (startY - fogBotHeight) * fogSlope;
  float endInten = fogBotInten + (endY - fogBotHeight) * fogSlope;

  pt.xyz -= mgEyePt;
  float dy = pt.y / length(pt); 
  if (dy == 0.0)
    dy = 0.00001;  // give it small slope to get intercepts

  float startDist = (startY - mgEyePt.y) / dy;
  float endDist = (endY - mgEyePt.y) / dy;

  fog = (abs(endDist - startDist))/fogMaxDist;
  fog = clamp(fog, 0.0, 1.0);
  fog = fog*(endInten+startInten)/2;
}
