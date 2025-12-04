import { router } from "@kit.ArkUI";

@Component
export struct TitleBar {
  @Prop showNavigation: boolean = false
  @Prop showAction: boolean = false
  @Prop public title: string
  @Prop public subTitle: string | null = null
  @Prop navIconRes: Resource | null = null
  navClick: Function | null = null //  () => void = () => {}
  // action view at end of title
  @BuilderParam public actionView: () => void = this.defaultActionBuilder;
  @BuilderParam public navigationView: () => void = this.defaultNavigationBuilder;

  @Builder
  defaultActionBuilder() {

  }

  @Builder
  defaultNavigationBuilder() {
    Image(this.navIconRes == null ? $r("app.media.ic_arrow_left") : this.navIconRes)
      .width(30)
      .height(50)
      .fillColor(Color.White)
      .objectFit(ImageFit.Contain)
      .margin({ left: 10 })
      .onClick(() => {
        if (this.navClick) {
          this.navClick()
        } else {
          router.back()
        }
      })
  }

  @Builder
  build() {
    Flex() {
      Stack({ alignContent: Alignment.Start }) {
        if (this.showNavigation) {
          this.navigationView()
        }
      }
      .layoutWeight(1)
      .height("100%")

      // .backgroundColor(Color.Green)

      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text(this.title)
            .fontSize(20).fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          if (this.subTitle) {
            Text(this.subTitle)
              .fontSize(13).fontWeight(FontWeight.Normal)
              .fontColor(Color.White)
          }
        }
      }
      // .backgroundColor(Color.Grey)
      .layoutWeight(3)
      .height("100%")

      Stack({ alignContent: Alignment.End }) {
        if (this.showAction) {
          this.actionView()
        }
      }
      .layoutWeight(1)
      .height("100%")

      // .backgroundColor(Color.Red)
    }
    .width('100%')
    .height(56)
    .backgroundColor($r("app.color.primary"))
  }
}

export function createSimple(title: ResourceStr) {
  return {
    title: title,
    showNavButton: false,
    menuShow: false,
  } as TitleAttr
}


export interface TitleAttr {
  // show back btn
  showNavButton?: boolean;
  backCallback?: () => void;
  title?: ResourceStr;
  subTitle?: ResourceStr
  menuShow?: boolean
  menuCallback?: () => void;
}

//
// @Component
// struct ChildComponent {
//   onButtonClick?: (msg: string) => void
//
//   build() {
//     Button('点击上报')
//       .onClick(() => {
//         this.onButtonClick?.('子组件事件触发')
//       })
//   }
// }
//
// @Component
// export struct ParentComponent {
//   @State message: string = ''
//
//   handleChildEvent(msg: string) {
//     this.message = msg
//   }
//
//   build() {
//     Column() {
//       ChildComponent({ onButtonClick: this.handleChildEvent.bind(this) })
//       Text(this.message)
//     }
//   }
// }