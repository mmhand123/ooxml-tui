/**
 * This file exposes the native API to the Typescript side.
 * Anything we `export` in `./root.zig` needs to have a corresponding
 * definition here, and then needs to be wrapped properly (with validation)
 * to be exposed to the Typescript side
 *
 */
import { defineStruct } from "bun-ffi-structs";
import { dlopen, suffix, toArrayBuffer } from "bun:ffi";

const native = dlopen(`./zig-out/dist/ooxml-tui/libooxml-tui.${suffix}`, {
  hello: {
    args: [],
    returns: "cstring",
  },
  helloStruct: {
    args: [],
    returns: "ptr",
  },
});

export function helloZig(): string {
  const hello = native.symbols.hello();

  return hello.toString();
}

const HelloStruct = defineStruct([
  ["x", "u32"],
  ["y", "u32"],
]);

type HelloStructType = ReturnType<(typeof HelloStruct)["unpack"]>;

export function helloZigStruct(): HelloStructType {
  const helloStructPtr = native.symbols.helloStruct();

  if (!helloStructPtr) {
    return { x: 0, y: 0 };
  }

  const byteLen = HelloStruct.size;
  const raw = toArrayBuffer(helloStructPtr, 0, byteLen);

  return HelloStruct.unpack(raw);
}
