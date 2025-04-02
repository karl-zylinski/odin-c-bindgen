There's a small test program in `test` that loads an FBX using these bindings and then displays it using Raylib.

Note: The `.lib` file was compiled with `-DUFBX_REAL_IS_FLOAT=1`. The bindings are also generated with this config set. That makes the floats be of type `f32` instead of `f64`.
