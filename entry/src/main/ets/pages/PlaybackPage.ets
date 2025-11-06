import { MediaController } from '../audio/MediaController';
import { MusicModel } from '../common/model/MusicModel';
import { CustomAudioManager } from '../audio/CustomAudioManager';
import { CustomDialogVolume } from '../common/util/CustomDialogVolume';

@Extend(Image)
function controlImageBuilder() {
  .aspectRatio(1)
  .objectFit(ImageFit.Contain)
}

@Component
export struct PlaybackPage {
  @StorageLink('selectIndex') selectIndex: number = 0;
  @StorageLink('musicList') musicList: MusicModel[] = [];
  @StorageLink('currentTime') currentTime: string = '00:00';
  @StorageLink('isPlay') isPlay: boolean = false;
  @StorageLink('progress') value: number = 0;
  @StorageLink('progressMax') max: number = 0;
  @State cumulativeDegree: number = 0;
  @State threshold: number = 10;
  @State volume: number = 50;
  @State progressValue: number = 0;
  @State totalValue: number = 0;
  @State minValue: number = 0;

  async aboutToAppear() {
    this.getUIContext().getFocusController().activate(true, false)
    await CustomAudioManager.getInstance().initAudioVolumeGroupManager()
  }

  aboutToDisappear(): void {
    this.getUIContext().getFocusController().activate(false)
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogVolume({
      progressValue: this.progressValue,
      totalValue: this.totalValue,
      minValue: this.minValue
    }),
    backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
    cornerRadius: 600
  })

  build() {

      Column() {
        Column() {
          Text(this.musicList[this.selectIndex].title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ top: 4 })
          Text(this.musicList[this.selectIndex].artist)
            .fontSize(14)
            .fontColor(Color.White)
        }
        .justifyContent(FlexAlign.Center)
        .margin({ top: 10 })

        Row(){
          Progress({
            value: this.value,
            total: this.max,
            type: ProgressType.Linear
          })
            .margin({right:15})
            .aspectRatio(1)
            .value(this.value)
            .width('85%')
            .color(Color.White)
            .style({ strokeWidth: 8 })
            .backgroundColor(Color.Gray)

          Text(this.currentTime)
            .fontColor(Color.White)
            .fontSize(14)

        }
        .height(25)

        Row() {
          // Previous
          Image($r('app.media.ic_prev'))
            .controlImageBuilder()
            .width(44)
            .height(44)
            .focusable(true)
            .onFocus(() => console.info('Prev button focused'))
            .onBlur(() => console.info('Prev button lost focus'))
            .border({ width: 2, color: $r('app.color.gray') })
            .onClick(() => {
              MediaController.getInstance().playPrevious();
            })

          // Play & Pause
          Image(this.isPlay ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
            .controlImageBuilder()
            .width(44)
            .height(44)
            .focusable(true)
            .defaultFocus(true)
            .onFocus(() => console.info('Play/Pause focused'))
            .onBlur(() => console.info('Play/Pause lost focus'))
            .border({ width: 2, color: $r('app.color.gray') })
            .onClick(() => {
              if (this.isPlay) {
                MediaController.getInstance().pause();
              } else {
                if (MediaController.getInstance().getFirst()) {
                  MediaController.getInstance().startByIndex();
                } else {
                  MediaController.getInstance().resume();
                }
              }
              this.isPlay = !this.isPlay;
            })

          // Next
          Image($r('app.media.ic_next'))
            .controlImageBuilder()
            .width(44)
            .height(44)
            .focusable(true)
            .onFocus(() => console.info('Next button focused'))
            .onBlur(() => console.info('Next button lost focus'))
            .border({ width: 2, color: $r('app.color.gray') })
            .onClick(() => {
              MediaController.getInstance().playNext();
            })
        }
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
        .layoutWeight(1)
        .padding({ left: 12, right: 12, top: 35, bottom: 4 })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .onDigitalCrown((event: CrownEvent) => {
          event.stopPropagation();
          this.cumulativeDegree += event.degree;
          if (Math.abs(this.cumulativeDegree) >= this.threshold) {
            if (this.cumulativeDegree > 0) {
              MediaController.getInstance().playPrevious();
            } else {
              MediaController.getInstance().playNext();
            }
            this.cumulativeDegree = 0;
          }
        })

        Image($r('app.media.ic_volume'))
          .margin({ top: 25 })
          .alignSelf(ItemAlign.Center)
          .controlImageBuilder()
          .width(40)
          .onClick(async () => {
            this.progressValue = await CustomAudioManager.getInstance().getVolume()
            this.totalValue = await CustomAudioManager.getInstance().getMaxVolume()
            this.minValue = await CustomAudioManager.getInstance().getMinVolume()
            this.dialogController.open()
          })


      }
      .width('100%')
      .height('100%')
      .padding(30)



  }
}