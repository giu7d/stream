const { APP_ENV = "development" } = process.env;

export function isProductionEnvironment() {
  return APP_ENV === "production";
}

export function getApplicationName() {
  if (isProductionEnvironment()) return "Stream";
  return `Stream (${APP_ENV})`;
}

export function getApplicationBundleIdentifier() {
  if (isProductionEnvironment()) return "com.prisma.stream";
  return `com.prisma.stream.${APP_ENV}`;
}
