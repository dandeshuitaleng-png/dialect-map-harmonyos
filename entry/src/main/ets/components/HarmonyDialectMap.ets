import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { MapComponent, map, mapCommon } from '@kit.MapKit';
import { MapMarker } from '../models/DialectModels';
import { DialectMap } from './DialectMap';

@Component
export struct HarmonyDialectMap {
  @Prop markers: MapMarker[];
  @State mapReady: boolean = false;
  @State mapFailed: boolean = false;
  @State statusMessage: string = '正在连接 Map Kit';
  private mapController?: map.MapComponentController;
  private mapOptions: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: 35.8617,
        longitude: 104.1954
      },
      zoom: 4
    },
    minZoom: 3,
    maxZoom: 18,
    rotateGesturesEnabled: false,
    tiltGesturesEnabled: false,
    scrollGesturesEnabled: true,
    zoomGesturesEnabled: true,
    zoomControlsEnabled: true,
    myLocationControlsEnabled: false,
    compassControlsEnabled: false,
    scaleControlsEnabled: true
  };
  private mapCallback: AsyncCallback<map.MapComponentController> =
    async (error: BusinessError, controller: map.MapComponentController): Promise<void> => {
      if (error) {
        this.statusMessage = '地图服务暂不可用，已切换本地地图';
        this.mapFailed = true;
        return;
      }

      this.mapController = controller;
      const markersAdded = await this.addDialectMarkers(controller);
      if (markersAdded) {
        this.mapReady = true;
        this.statusMessage = 'Map Kit 地图已加载';
      } else {
        this.statusMessage = '乡音点位加载失败，已切换本地地图';
        this.mapFailed = true;
      }
    };

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.mapFailed) {
        DialectMap({ markers: this.markers })
      } else {
        MapComponent({
          mapOptions: this.mapOptions,
          mapCallback: this.mapCallback
        })
          .width('100%')
          .height('100%')

        if (!this.mapReady) {
          Text(this.statusMessage)
            .fontSize(12)
            .fontColor($r('app.color.ink_primary'))
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor($r('app.color.surface_primary'))
            .borderRadius(8)
            .accessibilityText(this.statusMessage)
        }
      }
    }
    .width('100%')
    .height('100%')
  }

  private async addDialectMarkers(controller: map.MapComponentController): Promise<boolean> {
    try {
      for (let index = 0; index < this.markers.length; index++) {
        const marker = this.markers[index];
        const markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: marker.latitude,
            longitude: marker.longitude
          },
          title: marker.dialectName,
          snippet: marker.regionName + ' · ' + this.formatCount(marker.fellowCount),
          clickable: true,
          draggable: false,
          visible: true,
          zIndex: index + 1,
          alpha: 1,
          anchorU: 0.5,
          anchorV: 1,
          flat: false
        };

        await controller.addMarker(markerOptions);
      }
      return true;
    } catch (markerError) {
      return false;
    }
  }

  private formatCount(count: number): string {
    return (count / 10000).toFixed(1) + ' 万同乡';
  }
}
