This folder contains examples of how to use the binding generator and how to configure it using `bindgen.sjson`.

Some of these examples aren't 100% ready. However, the raylib example should output bindings that are fairly production ready (they have been made to be as close to raylib:vendor as possible).

## How to generate the bindings

Make sure you've compiled the bindings generator from the source in the `../src` folder. Then run:
`bindgen examples/raylib` to create the raylib bindings. Some examples also have a small test program.

Note that I provide pre-generated versions of the bindings. For example in the `raylib/raylib` folder there are some pre-generated bindings. They are just there to make the repository more informative while browsing online.