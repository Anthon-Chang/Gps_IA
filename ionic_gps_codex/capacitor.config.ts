import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.example.gpsionicangular',
  appName: 'GPS Ionic Angular',
  webDir: 'www',
  android: {
    useLegacyBridge: true,
  },
};

export default config;
