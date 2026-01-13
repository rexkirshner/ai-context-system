import { auth } from "@/lib/auth";

export default async function Home() {
  const session = await auth();

  return (
    <main>
      <h1>Welcome to the Next.js Fixture</h1>
      {session ? (
        <p>Logged in as {session.user?.email}</p>
      ) : (
        <p>Not logged in</p>
      )}
    </main>
  );
}
