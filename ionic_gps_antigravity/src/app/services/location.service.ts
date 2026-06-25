import { Injectable } from '@angular/core';
import { Geolocation } from '@capacitor/geolocation';
import { registerPlugin } from '@capacitor/core';
import { BackgroundGeolocationPlugin } from '@capacitor-community/background-geolocation';
import { BehaviorSubject } from 'rxjs';

const BackgroundGeolocation = registerPlugin<BackgroundGeolocationPlugin>(
  'BackgroundGeolocation'
);

export interface SavedLocation {
  latitude: number;
  longitude: number;
  time: number;
  formattedTime: string;
}

@Injectable({
  providedIn: 'root'
})
export class LocationService {
  private watcherId: string | null = null;
  
  // Lista de ubicaciones registradas
  private locationsSubject = new BehaviorSubject<SavedLocation[]>([]);
  locations$ = this.locationsSubject.asObservable();

  // Estado del tracking
  private trackingSubject = new BehaviorSubject<boolean>(false);
  isTracking$ = this.trackingSubject.asObservable();

  constructor() {}

  async requestPermissions() {
    try {
      const status = await Geolocation.requestPermissions();
      return status;
    } catch (e) {
      console.error('Error solicitando permisos:', e);
      return { location: 'denied', coarseLocation: 'denied' };
    }
  }

  async startBackgroundTracking() {
    if (this.watcherId) {
      console.warn('El rastreo ya está activo.');
      return;
    }

    const permissions = await this.requestPermissions();
    if (permissions.location !== 'granted') {
      alert('Permiso de ubicación denegado. Por favor actívalo en ajustes.');
      return;
    }

    try {
      this.watcherId = await BackgroundGeolocation.addWatcher(
        {
          backgroundMessage: "Registrando tu ubicación en segundo plano...",
          backgroundTitle: "Seguimiento GPS Activo",
          requestPermissions: true,
          stale: false,
          distanceFilter: 2 // Registrar cada 2 metros para pruebas rápidas
        },
        (location, error) => {
          if (error) {
            console.error('Error del watcher background:', error);
            return;
          }

          if (location) {
            this.addLocation(location.latitude, location.longitude, location.time ?? undefined);
          }
        }
      );

      this.trackingSubject.next(true);
      console.log('Watcher de segundo plano iniciado con ID:', this.watcherId);
    } catch (err) {
      console.error('Error al iniciar background tracking:', err);
      alert('Error al iniciar el servicio de ubicación en segundo plano.');
    }
  }

  async stopBackgroundTracking() {
    if (this.watcherId) {
      try {
        await BackgroundGeolocation.removeWatcher({ id: this.watcherId });
        this.watcherId = null;
        this.trackingSubject.next(false);
        console.log('Watcher de segundo plano detenido.');
      } catch (err) {
        console.error('Error al detener background tracking:', err);
      }
    }
  }

  private addLocation(lat: number, lng: number, timestamp: number | undefined) {
    const time = timestamp || Date.now();
    const date = new Date(time);
    const formattedTime = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });

    const newLoc: SavedLocation = {
      latitude: lat,
      longitude: lng,
      time,
      formattedTime
    };

    const currentList = this.locationsSubject.value;
    // Insertar al inicio de la lista para mostrar las más recientes arriba
    this.locationsSubject.next([newLoc, ...currentList]);
  }

  clearHistory() {
    this.locationsSubject.next([]);
  }
}
