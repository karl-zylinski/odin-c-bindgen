This folder contains examples of how to use the binding generator and how to configure it using `bindgen.sjson`.

Note that the bindings created by these examples are _not_ production ready. For example, within `bindgen.sjson` of each binding I haven't added every procedure parameter that should be a multi-pointer or use `#by_ptr`.

## How to generate the bindings

Make sure you've compiled the bindings generator from the source in the `../src` folder. Then run:
`bindgen examples/raylib` to create the raylib bindings. There's a test program in each example that uses the bindings.

Note that I provide pre-generated versions of the bindings, for example in `raylib/raylib` folder. They are just there to make the repository more informative while browsing online.