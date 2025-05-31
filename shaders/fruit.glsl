uniform vec4 darkColor;
uniform vec4 lightColor;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
  vec4 pixel = Texel(texture, texture_coords); // This is the current pixel color

  if (pixel.r == 1.0 && pixel.g == 0.0 && pixel.b == 0.0) {
    pixel = lightColor; // Replace pure red with lightColor
  }

  if (pixel.b == 1.0 && pixel.r == 0.0 && pixel.g == 0.0) {
    pixel = darkColor; // Replace pure blue with darkColor
  }

  return pixel;
}