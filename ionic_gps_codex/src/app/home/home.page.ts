import { Component } from '@angular/core';
import { registerPlugin } from '@capacitor/core';

interface LocationRecord {
  latitude: number;
  longitude: number;
  accuracy: number;
  speed: number | null;
  time: string;
}

interface BackgroundLocation {
  latitude: number;
  longitude: number;
  accuracy: number;
  speed: number | null;
  time: number;
}

interface BackgroundGeolocationPlugin {
  addWatcher(
    options: {
      backgroundMessage?: string;
      backgroundTitle?: string;
      requestPermissions?: boolean;
      stale?: boolean;
      distanceFilter?: number;
    },
    callback: (location?: BackgroundLocation, error?: { code?: string; message?: string }) => void,
  ): Promise<string>;

  removeWatcher(options: { id: string }): Promise<void>;
  openSettings(): Promise<void>;
}

const BackgroundGeolocation = registerPlugin<BackgroundGeolocationPlugin>('BackgroundGeolocation');

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
  standalone: false,
})
export class HomePage {
  isTracking = false;
  watcherId?: string;
  errorMessage = '';
  locations: LocationRecord[] = this.loadLocations();

  async startTracking() {
    this.errorMessage = '';

    if (this.isTracking) {
      return;
    }

    try {
      this.watcherId = await BackgroundGeolocation.addWatcher(
        {
          backgroundTitle: 'GPS activo',
          backgroundMessage: 'Registrando ubicacion en segundo plano',
          requestPermissions: true,
          stale: false,
          distanceFilter: 10,
        },
        (location, error) => {
          if (error) {
            this.errorMessage = error.message || 'No se pudo obtener la ubicacion.';

            if (error.code === 'NOT_AUTHORIZED') {
              BackgroundGeolocation.openSettings();
            }

            return;
          }

          if (!location) {
            return;
          }

          const record: LocationRecord = {
            latitude: location.latitude,
            longitude: location.longitude,
            accuracy: location.accuracy,
            speed: location.speed,
            time: new Date(location.time).toLocaleString(),
          };

          this.locations = [record, ...this.locations].slice(0, 50);
          localStorage.setItem('gps_locations', JSON.stringify(this.locations));
        },
      );

      this.isTracking = true;
    } catch (error) {
      this.errorMessage = error instanceof Error ? error.message : 'No se pudo iniciar el GPS.';
    }
  }

  async stopTracking() {
    this.errorMessage = '';

    if (!this.watcherId) {
      this.isTracking = false;
      return;
    }

    await BackgroundGeolocation.removeWatcher({ id: this.watcherId });
    this.watcherId = undefined;
    this.isTracking = false;
  }

  clearLocations() {
    this.locations = [];
    localStorage.removeItem('gps_locations');
  }

  private loadLocations(): LocationRecord[] {
    const storedLocations = localStorage.getItem('gps_locations');

    if (!storedLocations) {
      return [];
    }

    try {
      return JSON.parse(storedLocations) as LocationRecord[];
    } catch {
      return [];
    }
  }

}
