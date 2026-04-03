@group(0) @binding(0) var<uniform> resolution: vec2f;
@group(0) @binding(1) var videoSampler: sampler;
@group(0) @binding(2) var<uniform> frame: f32;
@group(0) @binding(3) var backBuffer: texture_2d<f32>;
@group(0) @binding(4) var<uniform> strength: f32;
@group(0) @binding(5) var<uniform> speed: f32;
@group(0) @binding(6) var<uniform> scale: f32;
@group(0) @binding(7) var<uniform> feedback: f32;
@group(1) @binding(0) var videoBuffer: texture_external;

// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com
fn random ( st: vec2f ) -> f32 {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
fn noise ( st: vec2f ) -> f32 {
    var i = floor(st);
    var f = fract(st);

    // Four corners in 2D of a tile
    var a = random(i);
    var b = random(i + vec2f(1.0, 0.0));
    var c = random(i + vec2f(0.0, 1.0));
    var d = random(i + vec2f(1.0, 1.0));

    var u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

fn fbm ( st_in: vec2f ) -> f32 {
    // Initial values
    var st = st_in;
    var value = 0.0;
    var amplitude = .5;

    // Loop of octaves
    for (var i: i32 = 0; i < 6; i++) {
        value += amplitude * noise(st);
        st *= 2.;
        amplitude *= .5;
    }
    return value;
}

@fragment
fn fs( @builtin(position) pos: vec4f ) -> @location(0) vec4f {
    var p = pos.xy / resolution;

    var st = p;
    st.x *= resolution.x / resolution.y;

    var t = frame / speed;

    var warp = vec2f(fbm( st * scale + vec2f(0.0,  0.0) + t ), fbm( st * scale + vec2f(5.2,  1.3) + t )) - 0.5;
    var warped_p = p + warp * strength;

    var video = textureSampleBaseClampToEdge( videoBuffer, videoSampler, warped_p );
    var fb = textureSample( backBuffer, videoSampler, warped_p );
    var out = mix( video, fb, feedback );  
    
    return vec4f( out.rgb, 1.0 );
}