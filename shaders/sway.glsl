uniform float bendAmount;

vec4 effect( vec4 color, Image txt, vec2 texture_coords, vec2 screen_coords) {
  vec2 original_coords = texture_coords;
  // Apply bend to the bottom half
  float angle = (0.5 - texture_coords.y) * bendAmount;
  float s = sin(angle);
  float c = cos(angle);

  vec2 center = vec2(0.5, 0.0);
  vec2 rotated_coords = vec2(
    (texture_coords.x - center.x) * c - (texture_coords.y - center.y) * s + center.x,
    (texture_coords.x - center.x) * s + (texture_coords.y - center.y) * c + center.y
  );

  return color * Texel(txt, rotated_coords);
}