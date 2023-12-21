import { View } from 'react-native'

import classNames from 'classnames'
import { StatusBar } from 'expo-status-bar'

import useSystemColorScheme from '@/hooks/useSystemColorScheme'

type TemplateProps = {
  children: React.ReactNode
}

function Template({ children }: TemplateProps) {
  const colorScheme = useSystemColorScheme()

  return (
    <View
      className={classNames(
        'bg-white dark:bg-neutral-800',
        'flex flex-grow p-0 md:p-8'
      )}
    >
      <StatusBar style={colorScheme} />
      <View className="flex flex-grow justify-center items-center">
        {children}
      </View>
    </View>
  )
}

export default function Home() {
  return (
    <Template>
      <View
        className={classNames(
          'w-full h-[500] md:w-4/5 md:h-4/5 rounded-lg',
          'bg-neutral-200 dark:bg-neutral-950'
        )}
      ></View>
    </Template>
  )
}
