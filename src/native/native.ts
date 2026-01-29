/**
 * This file exposes the native API to the Typescript side.
 * Anything we `export` in `./root.zig` needs to have a corresponding
 * definition here, and then needs to be wrapped properly (with validation)
 * to be exposed to the Typescript side
 *
 */
import { dlopen, suffix } from "bun:ffi";

const native = dlopen(`./zig-out/dist/ooxml-tui/libooxml-tui.${suffix}`, {
  hello: {
    args: [],
    returns: "cstring",
  },
});

export function helloZig(): string {
  const hello = native.symbols.hello();

  return hello.toString();
}

export function test(): string {
  return "test";
}
