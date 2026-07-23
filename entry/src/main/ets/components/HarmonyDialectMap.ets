import { AsyncCallback, BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import {
  abilityAccessCtrl,
  common,
  PermissionRequestResult,
  Permissions
} from '@kit.AbilityKit';
import { MapComponent, map, mapCommon } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { MapMarker } from '../models/DialectModels';
import { DialectMap } from './DialectMap';

@Component
export struct HarmonyDialectMap {
  @Prop markers: MapMarker[];
  @Prop litRegionName: string = '';
  @State mapReady: boolean = false;
  @State mapFailed: boolean = false;
  @State statusMessage: string = '正在连接 Map Kit';
  @State locationRequestInFlight: boolean = false;
  @State locationStatusMessage: string = '';
  private mapController?: map.MapComponentController;
  private hasRequestedLocation: boolean = false;
  private locationAuthorized: boolean = false;
  private mapOptions: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: 35.8617,
        longitude: 104.1954
      },
      zoom: 3.2,
      tilt: 18,
      bearing: 0
    },
    minZoom: 2,
    maxZoom: 18,
    rotateGesturesEnabled: true,
    tiltGesturesEnabled: true,
    scrollGesturesEnabled: true,
    zoomGesturesEnabled: true,
    zoomControlsEnabled: false,
    myLocationControlsEnabled: false,
    compassControlsEnabled: false,
    scaleControlsEnabled: true,
    sphereEnabled: deviceInfo.sdkApiVersion >= 15
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
        DialectMap({
          markers: this.markers,
          litRegionName: this.litRegionName
        })
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
          snippet: (marker.regionName === this.litRegionName ? '已点亮 · ' : '') +
            marker.regionName + ' · ' + this.formatCount(marker.fellowCount),
          icon: marker.regionName === this.litRegionName ?
            $r('app.media.dialect_marker_lit') : $r('app.media.dialect_marker'),
          clickable: true,
          draggable: false,
          visible: true,
          zIndex: marker.regionName === this.litRegionName ? 100 : index + 1,
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
      if (this.locationAuthorized) {
        this.locationRequestInFlight = true;
        await this.captureAndCenterLocation();
        this.locationRequestInFlight = false;
      } else {
        this.locationStatusMessage = '如需开启定位，请在系统设置中允许乡音地图访问位置';
      }
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
        this.locationAuthorized = true;
        this.mapController.setMyLocationEnabled(true);
        this.mapController.setMyLocationControlsEnabled(false);
        await this.captureAndCenterLocation();
      } else {
        this.locationStatusMessage = '未获得定位权限，仍可浏览全国乡音地图';
      }
    } catch (permissionError) {
      this.locationStatusMessage = '定位暂不可用，仍可浏览全国乡音地图';
    } finally {
      this.locationRequestInFlight = false;
    }
  }

  private async captureAndCenterLocation(): Promise<void> {
    if (!this.mapController) {
      return;
    }

    try {
      const location = await geoLocationManager.getCurrentLocation();
      this.mapController.setMyLocation(location);
      this.mapController.animateCamera(
        map.newLatLng({
          latitude: location.latitude,
          longitude: location.longitude
        }, 13),
        600
      );
      this.locationStatusMessage = '已定位到你当前所在的位置';
    } catch (locationError) {
      this.locationStatusMessage = '已获得权限，但暂时无法捕捉当前位置';
    }
  }
}
