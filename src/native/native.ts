import { dlopen, CString } from "bun:ffi";

const native = dlopen("./zig-out/dist/ooxml-tui/libooxml-tui.so", {
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
