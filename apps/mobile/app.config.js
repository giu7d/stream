/** @type {import('expo/config').ExpoConfig} */
module.exports = {
  expo: {
    // App Information
    name: "stream-mobile",
    slug: "stream-mobile",
    scheme: "stream-mobile",
    version: "1.0.0",
    owner: "giu7d",
    orientation: "portrait",
    // UI & Assets
    userInterfaceStyle: "light",
    icon: "./assets/icon.png",
    assetBundlePatterns: ["**/*"],
    userInterfaceStyle: "automatic",
    splash: {
      image: "./assets/splash.png",
      resizeMode: "contain",
      backgroundColor: "#ffffff",
    },
    // Build Stuff
    jsEngine: "hermes",
    runtimeVersion: "exposdk:49.0.0",
    plugins: ["expo-router"],
    experiments: {
      tsconfigPaths: true,
    },
    // Platforms
    ios: {
      supportsTablet: true,
    },
    android: {
      adaptiveIcon: {
        foregroundImage: "./assets/adaptive-icon.png",
        backgroundColor: "#ffffff",
      },
    },
    web: {
      bundler: "metro",
      favicon: "./assets/favicon.png",
    },
    // Env Variables
    extra: {
      ...process.env,
    },
  },
};
