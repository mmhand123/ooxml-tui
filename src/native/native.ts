/**
 * This file exposes the native API to the Typescript side.
 * Anything we `export` in `./root.zig` needs to have a corresponding
 * definition here, and then needs to be wrapped properly (with validation)
 * to be exposed to the Typescript side
 *
 */
import { dlopen, CString, suffix } from "bun:ffi";

const native = dlopen(`./zig-out/dist/ooxml-tui/libooxml-tui.${suffix}`, {
  hello: {
    args: [],
    returns: "ptr",
  },
});

export function helloZig(): string {
  const helloPtr = native.symbols.hello();

  if (!helloPtr) {
    throw new Error("Failed to get hello string from native library");
  }

  const hello = new CString(helloPtr);

  return hello.toString();
}

export function test(): string {
  return "test";
}
