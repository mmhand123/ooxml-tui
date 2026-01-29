import { render } from "@opentui/solid";
import { helloZig } from "./native/native.ts";

const message = helloZig();

function App() {
  return <text>{message}</text>;
}

render(() => <App />);
