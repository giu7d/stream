import { useEffect } from 'react'
import { ImageBackground, View, useColorScheme } from 'react-native'

import classNames from 'classnames'
import { StatusBar } from 'expo-status-bar'
import { useColorScheme as useNativewindColorScheme } from 'nativewind'

type ColorScheme = 'light' | 'dark'

type TemplateProps = {
  colorScheme?: ColorScheme
  children: React.ReactNode
}

function Template({ colorScheme = 'light', children }: TemplateProps) {
  return (
    <View
      className={classNames(
        'bg-white dark:bg-neutral-800',
        'flex flex-grow p-8'
      )}
    >
      <ImageBackground source={{ uri: '../assets/plus.svg' }}>
        <StatusBar style={colorScheme} />
        <View className="flex flex-grow items-center justify-center">
          {children}
        </View>
      </ImageBackground>
    </View>
  )
}

export default function Home() {
  const colorScheme = useColorScheme() as ColorScheme
  const nativewindColorScheme = useNativewindColorScheme()

  useEffect(() => {
    nativewindColorScheme.setColorScheme(colorScheme)
  }, [colorScheme])

  return (
    <Template colorScheme={colorScheme as any}>
      <View
        className={classNames(
          'w-4/5 h-4/5 rounded-lg',
          'bg-neutral-200 dark:bg-neutral-950'
        )}
      >
        {/* <Text className={classNames("text-black dark:text-white")}>
          Home page {dimension.width}x{dimension.height}
        </Text>
        <TouchableOpacity
          className="bg-blue-400 rounded-lg px-6 py-2"
          onPress={() => nativewindColorScheme.toggleColorScheme()}
        >
          <Text className="text-white">Button</Text>
        </TouchableOpacity> */}
      </View>
    </Template>
  )
}
