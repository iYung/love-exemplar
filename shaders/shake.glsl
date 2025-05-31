uniform float bendAmount;

vec4 effect( vec4 color, Image txt, vec2 texture_coords, vec2 screen_coords) {
  // Define the amount of bend from -0.1 to 0.1

  // Calculate the vertical position of the pixel (0.0 at the bottom, 1.0 at the top)
  float verticalPosition = texture_coords.y;

  // Calculate the horizontal offset based on the vertical position
  float horizontalOffset = sin(verticalPosition * 3.14159265359) * bendAmount;

  // Apply the offset to the texture coordinates
  vec2 distortedTextureCoords = vec2(texture_coords.x + horizontalOffset, texture_coords.y);

  // Sample the texture with the distorted coordinates
  vec4 texturedColor = color * Texel(txt, distortedTextureCoords);

  return texturedColor;
}