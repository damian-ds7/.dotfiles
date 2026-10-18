// Fade each frame toward the new screen contents, smoothing out sudden changes
// such as a theme switch. Enabled only briefly by ~/.local/bin/screen-transition.
vec4 screen(vec2 uv) {
  vec4 cur = umbriel_sample(uv);
  vec4 prev = umbriel_sample_previous(uv);

  // No previous frame yet: show the current one instead of fading from black
  if (prev.a == 0.0) {
    return cur;
  }

  // Snap once close enough, so 8-bit rounding can't stall the fade
  vec3 d = abs(cur.rgb - prev.rgb);
  if (max(d.r, max(d.g, d.b)) < 0.03) {
    return cur;
  }

  // Reading umbriel_time keeps frames coming while the fade settles
  float k = 0.08 + 0.0001 * fract(umbriel_time);
  return mix(prev, cur, k);
}
