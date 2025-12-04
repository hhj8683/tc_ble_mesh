import { bytesToHex, generateRandom } from 'telinksigmeshlib'

@Entry
@Component
struct Splash {
  build() {
    RelativeContainer() {
      Text("")
        .id('TelinkSplash')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }

  onPageShow(): void {
    console.log("splash - random : " + bytesToHex(generateRandom(16)))
  }
}