uniform float angle;

vec4 effect( vec4 color, Image txt, vec2 texture_coords, vec2 screen_coords) {
  // Calculate center of texture coordinates
  vec2 center = vec2(0.5, 0.5);

  // Rotate texture coordinates around the center
  float s = sin(angle);
  float c = cos(angle);

  vec2 rotated_coords = vec2(
    (texture_coords.x - center.x) * c - (texture_coords.y - center.y) * s + center.x,
    (texture_coords.x - center.x) * s + (texture_coords.y - center.y) * c + center.y
  );

  // Sample the texture with the rotated coordinates
  vec4 texturedColor = color * Texel(txt, rotated_coords);

  return texturedColor;
}