import { Stack } from "expo-router";

import Provider from "@/providers";

export { ErrorBoundary } from "expo-router";

export default function AppLayout() {
  return (
    <Provider>
      <Stack
        screenOptions={{
          header: () => null,
        }}
      />
    </Provider>
  );
}
