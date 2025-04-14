	#version 330

in vec2 texCoord;

in vec4 fragColor;

uniform float deathTimer;

uniform sampler2D tex;

out vec4 fragOut;

//how to get the pixel coord?
float screenWidth = 1280.0f;
float screenHeight = 720.0f;

void main()
{
    vec4 sourceColor = texture(tex, texCoord);
    float xCoord = texCoord.x;
    float yCoord = 1.0 - texCoord.y;
    float sinVal = deathTimer*0.5*sin(xCoord*yCoord*deathTimer*20.0) + 0.5*sin(xCoord*deathTimer*30.0) + 0.25*cos(sin(xCoord*deathTimer*13.0)); // 0
    float sinScaled = 0.10 * sinVal;
    if (deathTimer <= 0.00000000001)
    {
	sinScaled = 0.0;
    }
    float yValToTest =  sinScaled + deathTimer;
    
    if (yCoord < yValToTest)
    {
	sourceColor.r = 1.0f;
    }
    
    fragOut = sourceColor;
}