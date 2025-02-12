In here are some examples of how to use the binding generator and how to configure it using `bindgen.sjson`. Note that these bindings are just examples. For example, I haven't added every procedure parameter that should be a multi-pointer or use `#by_ptr`, but I provide examples of how to accomplish that.

## How to generate the bindings

Make sure you've compiled the bindings generator from the source in the `../src` folder. Then run:
`bindgen examples/raylib` to create the raylib bindings. There's a test program in each example that uses the bindings.

Note that I provide pre-generated versions of the bindings, for example in `raylib/raylib` folder. They are just there to make the repository more informative while browsing online.