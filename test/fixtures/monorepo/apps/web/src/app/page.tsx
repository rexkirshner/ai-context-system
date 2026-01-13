import { Button } from "@monorepo/ui";
import { formatDate } from "@monorepo/utils";

export default function Home() {
  return (
    <main>
      <h1>Web App</h1>
      <p>Today is {formatDate(new Date())}</p>
      <Button>Click me</Button>
    </main>
  );
}
