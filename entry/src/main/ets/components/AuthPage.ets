import { common } from '@kit.AbilityKit';
import {
  LoginWithHuaweiIDButton,
  loginComponentManager
} from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { HuaweiAccountSession, signInWithHuaweiAccount } from '../services/HuaweiAccountService';

@Component
export struct AuthPage {
  onAuthenticated: (session: HuaweiAccountSession) => void = (_session: HuaweiAccountSession): void => {};
  @State loading: boolean = false;
  @State errorMessage: string = '';
  private readonly accountController: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      .onClickLoginWithHuaweiIDButton((error: BusinessError,
        credential: loginComponentManager.HuaweiIDCredential): void => {
        this.handleHuaweiAccountResult(error, credential);
      });

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('登录乡音地图').fontSize(28).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.ink_primary'))
        Text('使用鸿蒙华为账号登录后，可在本机保存你的加入状态和乡音护照。')
          .fontSize(14).lineHeight(22).fontColor($r('app.color.ink_muted')).width('100%')
        LoginWithHuaweiIDButton({
          params: {
            style: loginComponentManager.Style.BUTTON_RED,
            loginType: loginComponentManager.LoginType.ID,
            textAndIconStyle: true,
            borderRadius: 14
          },
          controller: this.accountController
        })
          .width('100%')
          .height(52)
          .enabled(!this.loading)
        if (this.errorMessage.length > 0) { Text(this.errorMessage).fontSize(13).fontColor($r('app.color.danger')).width('100%') }
        Text('由华为帐号服务完成授权；群组与消息均为本机体验数据。')
          .fontSize(12).lineHeight(18).fontColor($r('app.color.ink_muted')).width('100%')
      }.width('100%').padding({ left: 24, right: 24, top: 48, bottom: 32 })
    }.width('100%').height('100%').backgroundColor($r('app.color.background_page'))
  }

  private async handleHuaweiAccountResult(error: BusinessError,
    credential: loginComponentManager.HuaweiIDCredential): Promise<void> {
    if (error !== undefined && error !== null) {
      this.errorMessage = error.code === 1001502012 ? '已取消华为帐号授权。' : '华为帐号登录暂不可用，请检查账号、网络和应用签名。';
      return;
    }
    if (credential === undefined || credential.authorizationCode.trim().length === 0) {
      this.errorMessage = '未获得华为帐号授权码，请重试。';
      return;
    }
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.loading = true;
    this.errorMessage = '';
    try {
      this.onAuthenticated(await signInWithHuaweiAccount(context, credential.authorizationCode));
    } catch (_error) {
      this.errorMessage = '无法连接登录服务器，请检查网络后重试。';
    } finally { this.loading = false; }
  }
}
