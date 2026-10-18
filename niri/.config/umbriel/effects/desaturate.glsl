// Blend toward greyscale; 0.0 = fully grey, 1.0 = original colour.
vec4 window(vec2 uv) {
  vec4 c = umbriel_sample(uv);
  float l = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
  return vec4(mix(vec3(l), c.rgb, 0.4), c.a);
}
