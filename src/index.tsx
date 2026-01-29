import { render } from "@opentui/solid";
import { helloZig, helloZigStruct } from "./native.ts";

const message = helloZig();
const struct = helloZigStruct();

function App() {
  return (
    <>
      <text>{message}</text>
      <text>
        From the struct, x: {struct.x} and y: {struct.y}
      </text>
    </>
  );
}

render(() => <App />);
