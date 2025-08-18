import type { AppProps } from 'next/app';
import Head from 'next/head';
import '../styles/main.css';

export default function App({ Component, pageProps }: AppProps) {
  return (
    <>
      <Head>
        <title>Plant Wall Control System</title>
        <meta name="description" content="Automated plant wall monitoring and control system" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <Component {...pageProps} />
    </>
  );
}