import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import {
  abilityAccessCtrl,
  common,
  PermissionRequestResult,
  Permissions
} from '@kit.AbilityKit';
import { MapComponent, map, mapCommon } from '@kit.MapKit';
import { MapMarker } from '../models/DialectModels';
import { DialectMap } from './DialectMap';

@Component
export struct HarmonyDialectMap {
  @Prop markers: MapMarker[];
  @State mapReady: boolean = false;
  @State mapFailed: boolean = false;
  @State statusMessage: string = '正在连接 Map Kit';
  @State locationRequestInFlight: boolean = false;
  @State locationStatusMessage: string = '';
  private mapController?: map.MapComponentController;
  private hasRequestedLocation: boolean = false;
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
    zoomControlsEnabled: false,
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

        if (this.mapReady) {
          Column({ space: 3 }) {
            Text('听见每一方水土')
              .fontSize(12)
              .fontColor($r('app.color.ink_secondary'))
              .fontWeight(FontWeight.Medium)
              .letterSpacing(1.2)
            Text('乡音地图')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.ink_primary'))
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor($r('app.color.surface_primary'))
          .borderRadius(14)
          .position({ x: 20, y: 16 })
          .shadow({ radius: 16, color: $r('app.color.shadow_soft') })

          Column({ space: 8 }) {
            Button(this.locationRequestInFlight ? '定位中' : '我的位置')
              .fontSize(14)
              .fontColor($r('app.color.ink_primary'))
              .height(48)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.surface_primary'))
              .borderRadius(24)
              .enabled(!this.locationRequestInFlight)
              .focusable(true)
              .accessibilityText('在地图中显示我的位置')
              .onClick(() => {
                this.requestMyLocation();
              })

            if (this.locationStatusMessage.length > 0) {
              Text(this.locationStatusMessage)
                .fontSize(12)
                .fontColor($r('app.color.ink_primary'))
                .maxLines(2)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor($r('app.color.surface_primary'))
                .borderRadius(8)
                .accessibilityText(this.locationStatusMessage)
            }
          }
          .alignItems(HorizontalAlign.End)
          .position({ x: 16, y: 16 })
          .width('calc(100% - 32vp)')
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
          icon: $r('app.media.dialect_marker'),
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

  private async requestMyLocation(): Promise<void> {
    if (!this.mapController || this.locationRequestInFlight) {
      return;
    }

    if (this.hasRequestedLocation) {
      this.locationStatusMessage = '如需开启定位，请在系统设置中允许乡音地图访问位置';
      return;
    }

    this.hasRequestedLocation = true;
    this.locationRequestInFlight = true;
    this.locationStatusMessage = '等待系统定位授权';
    const permissions: Permissions[] = [
      'ohos.permission.LOCATION',
      'ohos.permission.APPROXIMATELY_LOCATION'
    ];

    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const result: PermissionRequestResult =
        await abilityAccessCtrl.createAtManager().requestPermissionsFromUser(context, permissions);
      const granted = result.authResults.some((authResult: number) => authResult === 0);

      if (granted && this.mapController) {
        this.mapController.setMyLocationEnabled(true);
        this.mapController.setMyLocationControlsEnabled(true);
        this.locationStatusMessage = '已在地图中显示你的位置';
      } else {
        this.locationStatusMessage = '未获得定位权限，仍可浏览全国乡音地图';
      }
    } catch (permissionError) {
      this.locationStatusMessage = '定位暂不可用，仍可浏览全国乡音地图';
    } finally {
      this.locationRequestInFlight = false;
    }
  }
}
