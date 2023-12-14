import { StatusBar } from "expo-status-bar";
import {
  SafeAreaView,
  Text,
  TouchableOpacity,
  View,
  useColorScheme,
  useWindowDimensions,
} from "react-native";
import { useColorScheme as useNativewindColorScheme } from "nativewind";
import { useEffect } from "react";

window.addEventListener = (x: any) => x;
window.removeEventListener = (x: any) => x;

export default function Page() {
  const dimension = useWindowDimensions();
  const colorScheme = useColorScheme();
  const nativewindColorScheme = useNativewindColorScheme();
  useEffect(() => {
    nativewindColorScheme.setColorScheme(colorScheme as any);
  }, [colorScheme]);

  return (
    <SafeAreaView className="light:bg-white dark:bg-neutral-900 flex flex-grow h-full">
      <StatusBar style={colorScheme as any} />
      <View className="h-full items-center justify-center gap-8">
        <Text className="light:text-black dark:text-white">
          Home page {dimension.width}x{dimension.height}
        </Text>
        <TouchableOpacity
          className="bg-blue-400 rounded-lg px-6 py-2"
          onPress={() => nativewindColorScheme.toggleColorScheme()}
        >
          <Text className="light:text-black dark:text-white">Button</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}
