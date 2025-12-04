@Component
export struct CardView {
    @Prop cdPadding: Padding | Length | LocalizedPadding = 8
    @Prop cdMargin: Margin | Length | LocalizedPadding = 8
    cdClick?: () => void = undefined
    @BuilderParam cardContent: () => void

    build() {
        Column() {
            this.cardContent()
        }
        .border({
            width: {
                bottom: 0.2,
                top: 0.6,
                left: 0.5,
                right: 0.5
            },
            color: Color.Grey,
            radius: 5
        })
        .shadow({
            radius: 5,
            offsetY: 2,
            offsetX: 2,
            fill: false,
            color: Color.Grey,
            type: ShadowType.COLOR
        })
        .alignItems(HorizontalAlign.Start)
        .margin(this.cdMargin)
        .padding(this.cdPadding)
        .onClick(() => {
            if (this.cdClick) {
                this.cdClick()
            }
        })
    }
}
