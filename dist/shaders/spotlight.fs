#version 330

in vec2 texCoord;

in vec4 fragColor;

uniform float timer;
uniform float deathTimer;
uniform int deathFlag;
uniform vec2 circCent;
uniform sampler2D tex;

out vec4 fragOut;

//how to get the pixel coord?
float screenWidth = 1280.0f;
float screenHeight = 720.0f;

void main()
{
    //vec4 sourceColor = texture(tex, texCoord);
    vec2 circCentNorm = vec2(circCent.x/screenWidth, circCent.y/screenHeight);
    if (distance(texCoord, circCentNorm) < timer) {
        fragOut = texture(tex, texCoord);
    } else {
        fragOut = vec4(1.0f, 1.0f, 1.0f, 1.0f);	  
    }        
}