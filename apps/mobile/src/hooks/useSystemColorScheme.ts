import { useEffect } from 'react'
import { useColorScheme as useReactNativeColorScheme } from 'react-native'

import { useColorScheme as useTailwindColorScheme } from 'nativewind'

type SystemColorScheme = 'light' | 'dark'

export default function useSystemColorScheme() {
  const reactColorScheme = useReactNativeColorScheme() as SystemColorScheme
  const tailwindColorScheme = useTailwindColorScheme()

  useEffect(() => {
    console.log('reactColorScheme', reactColorScheme)
    tailwindColorScheme.setColorScheme(reactColorScheme)
  }, [reactColorScheme])

  return reactColorScheme
}
