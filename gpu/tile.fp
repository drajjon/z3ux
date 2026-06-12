#version 140

in mediump vec2 var_texcoord0;
in mediump vec4 var_col0;
in mediump vec4 var_col1;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;

void main()
{
    mediump vec4 tex_col = texture(texture_sampler, var_texcoord0.xy);
    if ((tex_col.x + tex_col.y + tex_col.z) < 1.5) {
        out_fragColor = var_col0; // TODO as needed: pull tex_col.w alpha in
    }
    else {
    out_fragColor = var_col1;
        // out_fragColor = mix(var_col1, tex_col, 0.5);
    }
}
