local lighting = {
    settings = {
        tint = nil,
        bw = false,
        fog = false
    }
}

-- Black and White Shader
local bw = love.graphics.newShader[[
#ifdef GL_ES
precision mediump float;
#endif

uniform float time; // Time to animate the grain
uniform vec2 resolution; // Resolution of the screen

// Generates random noise based on a 2D coordinate
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Sample the texture
    vec4 texColor = Texel(texture, texture_coords);

    // Convert to grayscale with darkness adjustment
    float average = (texColor.r + texColor.g + texColor.b) / 3.0;
    float darknessFactor = 0.4; // Adjust this to make the grayscale darker
    average *= darknessFactor;
    vec3 grayColor = vec3(average);

    // Scale grain effect based on resolution
    vec2 grainCoords = screen_coords / resolution.xy;

    // Add time-dependent random noise
    float grain = random(grainCoords * time) * 0.1;

    // Combine grayscale and grain
    vec3 finalColor = grayColor + vec3(grain);

    // Return the final color with the original alpha
    return vec4(finalColor, texColor.a);
}
]]

-- Enhanced Fog Shader
local fogShader = love.graphics.newShader[[
extern vec3 fogColor; // RGB color of the fog
extern number fogStart; // Distance where the fog starts
extern number fogEnd; // Distance where the fog ends
uniform vec2 resolution; // Resolution of the screen
extern float scale; // Scale factor, used for zoom
extern float zoom; // Zoom factor

// Perlin Noise functions
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(
        mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
        u.y
    );
}

// Smooth fog blending
float smoothFog(float dist, float start, float end) {
    float fogFactor = clamp((end - dist) / (end - start), 0.0, 1.0);
    return pow(fogFactor, 1.5); // Adjust the exponent for smoother fog
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Sample the texture
    vec4 texColor = Texel(texture, texture_coords);

    // Adjust resolution for scale/zoom
    vec2 adjustedResolution = resolution * scale;

    // Calculate the center of the screen (accounting for zoom and scale)
    vec2 center = adjustedResolution * 0.5;

    // Normalize screen coordinates relative to the fixed center
    vec2 normalizedCoords = (screen_coords - center) / (adjustedResolution);

    // Calculate radial distance from the center
    float dist = length(normalizedCoords) * adjustedResolution.y * 1;

    // Calculate smooth fog factor
    float fogFactor = smoothFog(dist, fogStart, fogEnd);

 

    // Blend the fog with the texture color
    vec3 blendedColor = mix(fogColor, texColor.rgb, fogFactor);

    // Return the final color with the original alpha
    return vec4(blendedColor, texColor.a);
}
]]



-- Initialize screen resolution and time
local fogColor = {0,0,0} -- Light blue fog
local fogStart = -700 -- Start fog at 200 pixels
local fogEnd = 1000 -- End fog at 1200 pixels
local time = 0

-- Send parameters to shaders
fogShader:send("fogColor", fogColor)
fogShader:send("fogStart", fogStart)
fogShader:send("fogEnd", fogEnd)
fogShader:send("scale", scale)
fogShader:send("resolution", {wW, wH}) -- Send the screen resolution
bw:send("resolution", {wW, wH})

function lighting.update(dt)
    time = time + dt * 0.5 -- Adjust speed of fog animation
    bw:send("time", time)
    fogShader:send("scale", scale/zoom)

end

function lighting.draw()
    local lS = lighting.settings
    if lS.tint then
        love.graphics.setColor(lS.tint)
        love.graphics.rectangle("fill", 0, 0, wW, wH)
        love.graphics.setColor(1, 1, 1, 1)
    end
    if lS.bw then
        love.graphics.setShader(bw)
    end
    if lS.fog then
        love.graphics.setShader(fogShader)
    end
end

return lighting
