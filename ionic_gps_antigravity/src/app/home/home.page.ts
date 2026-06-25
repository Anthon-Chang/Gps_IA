import { Component, OnInit, OnDestroy } from '@angular/core';
import { LocationService, SavedLocation } from '../services/location.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
  standalone: false,
})
export class HomePage implements OnInit, OnDestroy {
  locations: SavedLocation[] = [];
  isTracking = false;

  private subs = new Subscription();

  constructor(public locationService: LocationService) {}

  ngOnInit() {
    // Escuchar el estado de tracking
    this.subs.add(
      this.locationService.isTracking$.subscribe(status => {
        this.isTracking = status;
      })
    );

    // Escuchar las ubicaciones registradas
    this.subs.add(
      this.locationService.locations$.subscribe(locs => {
        this.locations = locs;
      })
    );
  }

  ngOnDestroy() {
    this.subs.unsubscribe();
  }

  toggleTracking() {
    if (this.isTracking) {
      this.locationService.stopBackgroundTracking();
    } else {
      this.locationService.startBackgroundTracking();
    }
  }

  clearHistory() {
    this.locationService.clearHistory();
  }

  // Obtener el formato legible de las últimas coordenadas
  get latestCoords(): string {
    if (this.locations.length === 0) return 'Ninguna';
    const latest = this.locations[0];
    return `${latest.latitude.toFixed(6)}, ${latest.longitude.toFixed(6)}`;
  }
}
