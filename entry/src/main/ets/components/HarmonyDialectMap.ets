import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import {
  abilityAccessCtrl,
  common,
  PermissionRequestResult,
  Permissions
} from '@kit.AbilityKit';
import { MapComponent, map, mapCommon } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { MapMarker } from '../models/DialectModels';
import { LocalDialectPointMap } from './LocalDialectPointMap';

const DEFAULT_CAMERA_POSITION: mapCommon.CameraPosition = {
  target: {
    latitude: 35.8617,
    longitude: 104.1954
  },
  zoom: 2.6,
  tilt: 0,
  bearing: 0
};

// 保留本次应用运行期间的地图视角，避免从护照/群聊返回首页时回到默认地球视角。
let preservedCameraPosition: mapCommon.CameraPosition | undefined = undefined;

@Component
export struct HarmonyDialectMap {
  @Prop markers: MapMarker[];
  @Prop @Watch('onLitRegionNameChanged') litRegionName: string = '';
  @Prop selectedRegionName: string = '';
  onSelectRegion: (regionName: string) => void = (_regionName: string): void => {};
  onXiaoyiOpen?: () => void;
  @State mapReady: boolean = false;
  @State mapFailed: boolean = false;
  @State statusMessage: string = '本地点位图可用，正在连接在线地图';
  @State locationRequestInFlight: boolean = false;
  @State locationStatusMessage: string = '';
  private mapController?: map.MapComponentController;
  private dialectMarkers: map.Marker[] = [];
  private mapLoadTimeoutId: number = -1;
  private mapSurfaceLoaded: boolean = false;
  private mapMarkersReady: boolean = false;
  private mapLoadListener?: () => void;
  private mapErrorListener?: (error?: BusinessError) => void;
  private markerClickListener?: (marker: map.Marker) => void;
  private hasRequestedLocation: boolean = false;
  private locationAuthorized: boolean = false;
  private mapOptions: mapCommon.MapOptions = {
    position: preservedCameraPosition ?? DEFAULT_CAMERA_POSITION,
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
    // Map Kit 官方指南：开启球体后，缩放层级小于 4 时可清晰展示 3D 地球。
    sphereEnabled: true
  };
  private mapCallback: AsyncCallback<map.MapComponentController> =
    async (error: BusinessError, controller: map.MapComponentController): Promise<void> => {
      if (error) {
        console.error(`[HarmonyDialectMap] Map Kit initialization failed: ${error.code} ${error.message}`);
        this.failOnlineMap('真实地图暂不可用，请检查网络或 Map Kit 服务权限');
        return;
      }
      if (this.mapFailed) {
        return;
      }

      this.detachMapListeners();
      this.mapController = controller;
      this.dialectMarkers = [];
      this.mapSurfaceLoaded = false;
      this.mapMarkersReady = false;
      const activeController = controller;
      this.mapLoadListener = (): void => {
        if (this.mapController !== activeController || this.mapFailed) {
          return;
        }
        this.mapSurfaceLoaded = true;
        this.promoteOnlineMapIfReady();
      };
      this.mapErrorListener = (mapError?: BusinessError): void => {
        if (this.mapController !== activeController) {
          return;
        }
        if (mapError) {
          console.error(`[HarmonyDialectMap] Map Kit loading failed: ${mapError.code} ${mapError.message}`);
        }
        this.failOnlineMap('真实地图连接失败，请检查网络或 Map Kit 服务权限');
      };
      controller.on('error', this.mapErrorListener);
      controller.on('mapLoad', this.mapLoadListener);
      this.markerClickListener = (clickedMarker: map.Marker): void => {
        const markerIndex = this.dialectMarkers.indexOf(clickedMarker);
        if (markerIndex < 0 || markerIndex >= this.markers.length) {
          return;
        }
        const markerModel = this.markers[markerIndex];
        this.locationStatusMessage = '已选择 ' + markerModel.regionName +
          ' · 正在筛选该地区乡音信息';
        this.onSelectRegion(markerModel.regionName);
      };
      controller.on('markerClick', this.markerClickListener);
      this.startMapLoadTimeout();
      const markersAdded = await this.addDialectMarkers(controller);
      if (this.mapController !== activeController || this.mapFailed) {
        return;
      }
      if (!markersAdded) {
        this.failOnlineMap('地图点位加载失败，请重试');
        return;
      }
      const markersRefreshed = markersAdded && await this.refreshDialectMarkers();
      if (!markersRefreshed) {
        return;
      }
      this.mapMarkersReady = true;
      this.promoteOnlineMapIfReady();
    };

  aboutToDisappear(): void {
    this.preserveCameraPosition();
    this.clearMapLoadTimeout();
    this.detachMapListeners();
    this.mapController = undefined;
  }

  private preserveCameraPosition(): void {
    if (this.mapController === undefined || !this.mapSurfaceLoaded) {
      return;
    }
    try {
      const cameraPosition = this.mapController.getCameraPosition();
      preservedCameraPosition = {
        target: {
          latitude: cameraPosition.target.latitude,
          longitude: cameraPosition.target.longitude
        },
        zoom: cameraPosition.zoom,
        tilt: cameraPosition.tilt,
        bearing: cameraPosition.bearing
      };
    } catch (error) {
      const cameraError = error as BusinessError;
      console.warn(
        `[HarmonyDialectMap] Preserve camera position skipped: ${cameraError.code} ${cameraError.message}`
      );
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      LocalDialectPointMap({
        markers: this.markers,
        litRegionName: this.litRegionName,
        selectedRegionName: this.selectedRegionName,
        onSelectRegion: (regionName: string): void => {
          this.locationStatusMessage = '已选择 ' + regionName +
            ' · 正在筛选该地区乡音信息';
          this.onSelectRegion(regionName);
        }
      })
        .zIndex(0)

      if (!this.mapFailed) {
        MapComponent({
          mapOptions: this.mapOptions,
          mapCallback: this.mapCallback
        })
          .width('100%')
          .height('100%')
          .opacity(this.mapReady ? 1 : 0)
          .zIndex(1)
          .hitTestBehavior(this.mapReady ? HitTestMode.Default : HitTestMode.None)
      }

      if (this.mapFailed) {
        Row({ space: 12 }) {
          Column({ space: 2 }) {
            Text('当前使用本地点位图')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.ink_primary'))
              .width('100%')
            Text(this.statusMessage)
              .fontSize(12)
              .fontColor($r('app.color.ink_muted'))
              .maxLines(2)
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Button('重试在线地图')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.ink_primary'))
            .height(48)
            .padding({ left: 14, right: 14 })
            .backgroundColor($r('app.color.surface_primary'))
            .borderRadius(16)
            .onClick((): void => { this.retryOnlineMap(); })
            .accessibilityText('重新连接在线地图')
        }
        .width('calc(100% - 32vp)')
        .padding({ left: 14, right: 6, top: 10, bottom: 10 })
        .backgroundColor($r('app.color.surface_elevated'))
        .borderRadius(18)
        .position({ x: 16, y: 16 })
        .zIndex(3)
        .shadow({ radius: 10, color: $r('app.color.shadow_soft') })
        .accessibilityText(this.statusMessage)
      } else if (!this.mapReady) {
        Text('本地点位图可用 · 正在连接在线地图')
          .width('calc(100% - 112vp)')
          .fontSize(12)
          .fontColor($r('app.color.ink_primary'))
          .maxLines(1)
          .padding({ left: 12, right: 12, top: 9, bottom: 9 })
          .backgroundColor($r('app.color.surface_primary'))
          .borderRadius(12)
          .position({ x: 16, y: 16 })
          .zIndex(3)
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

          if (this.onXiaoyiOpen !== undefined) {
            Button('艺')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
              .width(48)
              .height(48)
              .backgroundColor($r('app.color.confirm'))
              .borderRadius(24)
              .onClick((): void => { this.onXiaoyiOpen?.(); })
              .accessibilityText('打开小艺乡音助手')
          }

          if (this.hasRequestedLocation && !this.locationAuthorized) {
            Button('去系统设置授权')
              .fontSize(13)
              .fontColor($r('app.color.accent_text'))
              .height(48)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.brand_soft'))
              .borderRadius(24)
              .onClick((): void => { this.recoverLocationPermission(); })
              .accessibilityText('前往系统设置开启位置权限')
          }

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
        .zIndex(3)
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

        this.dialectMarkers.push(await controller.addMarker(markerOptions));
      }
      return true;
    } catch (markerError) {
      return false;
    }
  }

  private startMapLoadTimeout(): void {
    this.clearMapLoadTimeout();
    this.mapLoadTimeoutId = setTimeout((): void => {
      if (!this.mapReady) {
        this.failOnlineMap('真实地图加载超时，请检查网络后重试');
      }
    }, 10000);
  }

  private clearMapLoadTimeout(): void {
    if (this.mapLoadTimeoutId >= 0) {
      clearTimeout(this.mapLoadTimeoutId);
      this.mapLoadTimeoutId = -1;
    }
  }

  private failOnlineMap(message: string): void {
    this.clearMapLoadTimeout();
    this.detachMapListeners();
    this.mapController = undefined;
    this.dialectMarkers = [];
    this.mapSurfaceLoaded = false;
    this.mapMarkersReady = false;
    this.mapReady = false;
    this.statusMessage = message;
    this.mapFailed = true;
  }

  private retryOnlineMap(): void {
    this.clearMapLoadTimeout();
    this.detachMapListeners();
    this.mapController = undefined;
    this.dialectMarkers = [];
    this.mapSurfaceLoaded = false;
    this.mapMarkersReady = false;
    this.mapReady = false;
    this.statusMessage = '本地点位图可用，正在重新连接在线地图';
    this.mapFailed = false;
  }

  private onLitRegionNameChanged(_propertyName: string): void {
    if (this.mapController && this.dialectMarkers.length === this.markers.length) {
      this.refreshDialectMarkers();
    }
  }

  private async refreshDialectMarkers(): Promise<boolean> {
    if (!this.mapController || this.dialectMarkers.length !== this.markers.length) {
      return false;
    }

    const targetLitRegionName = this.litRegionName;
    try {
      for (let index = 0; index < this.markers.length; index++) {
        const markerModel = this.markers[index];
        const marker = this.dialectMarkers[index];
        const isLit = markerModel.regionName === targetLitRegionName;
        marker.setPosition({
          latitude: markerModel.latitude,
          longitude: markerModel.longitude
        });
        marker.setTitle(markerModel.dialectName);
        marker.setSnippet((isLit ? '已点亮 · ' : '') +
          markerModel.regionName + ' · ' + this.formatCount(markerModel.fellowCount));
        marker.setZIndex(isLit ? 100 : index + 1);
        await marker.setIcon(isLit ?
          $r('app.media.dialect_marker_lit') : $r('app.media.dialect_marker'));
      }
      if (targetLitRegionName !== this.litRegionName) {
        return await this.refreshDialectMarkers();
      }
      return true;
    } catch (markerError) {
      this.failOnlineMap('地图点位刷新失败，请重试');
      return false;
    }
  }

  private promoteOnlineMapIfReady(): void {
    if (!this.mapFailed && this.mapController && this.mapSurfaceLoaded && this.mapMarkersReady) {
      this.clearMapLoadTimeout();
      this.mapReady = true;
      this.statusMessage = '在线地图已加载';
    }
  }

  private detachMapListeners(): void {
    if (this.mapController && this.mapLoadListener) {
      this.mapController.off('mapLoad', this.mapLoadListener);
    }
    if (this.mapController && this.markerClickListener) {
      // API 20 的 off 回调声明与 on 不一致；传入兼容的空回调解除监听。
      this.mapController.off('markerClick', (): void => {});
    }
    // API 20 的 controller.off('error') 声明与 on('error') 回调类型不一致。
    // 旧控制器回调由 activeController 身份校验失效，组件卸载后不再改变界面状态。
    this.mapLoadListener = undefined;
    this.mapErrorListener = undefined;
    this.markerClickListener = undefined;
  }

  private formatCount(_count: number): string {
    return '方言代表点';
  }

  private showDialectOverview(): void {
    if (!this.mapController) {
      return;
    }
    this.mapController.animateCamera(
      map.newLatLng({
        latitude: 35.8617,
        longitude: 104.1954
      }, 3.2),
      600
    );
    this.locationStatusMessage = '全国视图 · ' +
      this.markers.length.toString() + ' 个方言代表点';
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

  private async recoverLocationPermission(): Promise<void> {
    if (this.locationRequestInFlight) {
      return;
    }
    this.locationRequestInFlight = true;
    this.locationStatusMessage = '正在打开系统权限设置';
    const permissions: Permissions[] = [
      'ohos.permission.LOCATION',
      'ohos.permission.APPROXIMATELY_LOCATION'
    ];
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const results = await abilityAccessCtrl.createAtManager()
        .requestPermissionOnSetting(context, permissions);
      this.locationAuthorized = results.some((result: number): boolean => result === 0);
      if (this.locationAuthorized && this.mapController) {
        this.mapController.setMyLocationEnabled(true);
        this.mapController.setMyLocationControlsEnabled(false);
        await this.captureAndCenterLocation();
      } else {
        this.locationStatusMessage = '位置权限仍未开启，可手动选择地区继续使用';
      }
    } catch (error) {
      this.locationStatusMessage = '未能打开权限设置，可手动选择地区继续使用';
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
