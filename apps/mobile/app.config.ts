import "ts-node/register";

import type { ExpoConfig } from "expo/config";

import {
  getApplicationBundleIdentifier,
  getApplicationName,
} from "./config/setupApp";

const config: ExpoConfig = {
  // App Information
  name: getApplicationName(),
  slug: "stream-mobile",
  scheme: "stream-mobile",
  version: "1.0.0",
  owner: "giu7d",
  orientation: "portrait",
  // UI & Assets
  userInterfaceStyle: "automatic",
  icon: "./assets/icon.png",
  assetBundlePatterns: ["**/*"],
  splash: {
    image: "./assets/splash.png",
    resizeMode: "contain",
    backgroundColor: "#ffffff",
  },
  // Build Params
  jsEngine: "hermes",
  runtimeVersion: "exposdk:49.0.0",
  plugins: ["expo-router"],
  experiments: {
    tsconfigPaths: true,
  },
  // Env Variables
  extra: {
    ...process.env,
  },
  // Platforms
  ios: {
    supportsTablet: true,
    bundleIdentifier: getApplicationBundleIdentifier(),
  },
  android: {
    adaptiveIcon: {
      foregroundImage: "./assets/adaptive-icon.png",
      backgroundColor: "#ffffff",
    },
    package: getApplicationBundleIdentifier(),
  },
  web: {
    bundler: "metro",
    favicon: "./assets/favicon.png",
  },
};

export default config;
