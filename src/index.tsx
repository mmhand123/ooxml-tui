import { render } from "@opentui/solid";
import { dlopen, CString } from "bun:ffi";

const lib = dlopen("./zig-out/dist/ooxml-tui/libooxml-tui.so", {
  hello: {
    args: [],
    returns: "ptr",
  },
});

const helloPtr = lib.symbols.hello();
if (!helloPtr) {
  throw new Error("Failed to get hello string from native library");
}
const message = new CString(helloPtr);

function App() {
  return <text>{message.toString()}</text>;
}

render(() => <App />);
