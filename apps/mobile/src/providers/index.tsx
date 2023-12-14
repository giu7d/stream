type Props = {
  children: JSX.Element | JSX.Element[];
};

export default function Providers({ children }: Props) {
  return <>{children}</>;
}
