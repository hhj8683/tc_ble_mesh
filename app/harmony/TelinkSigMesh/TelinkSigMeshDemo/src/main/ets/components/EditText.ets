@Component
export struct EditText {

  @BuilderParam rightRowElement: () => void

  build() {
    Column(){
      TextInput({ text: "8004" })
        .fontSize(14)
        .fontColor($r("app.color.primary"))
        .backgroundColor(Color.Transparent)
        .borderRadius(0).width("100%")
        .textAlign(TextAlign.Center)
      // only for border
      Text().borderColor($r("app.color.primary"))
        .borderWidth({ bottom: 1 })
        .width("100%")
        .margin({top: -10})
    }
  }
}

@Builder
export function getEditText(preText: string | null, text: string){
  Row() {
    if (preText){
      Text(preText)  .fontWeight(FontWeight.Normal).fontSize(14).width("40%").textAlign(TextAlign.Start)
    }
    Column(){
      TextInput({ text: text })
        .fontSize(14)
        .fontColor($r("app.color.primary"))
        .backgroundColor(Color.Transparent)
        .borderRadius(0).width("100%")
        .textAlign(TextAlign.Center)
      // only for border
      Text().borderColor($r("app.color.primary"))
        .borderWidth({ bottom: 1 })
        .width("100%")
        .margin({top: -10})
    }.layoutWeight(1)
  }.alignItems(VerticalAlign.Bottom)
  .margin(4)
}

