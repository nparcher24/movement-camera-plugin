import { WebPlugin } from '@capacitor/core';
import { Camera } from '@mediapipe/camera_utils';
import { drawConnectors, drawLandmarks } from '@mediapipe/drawing_utils';
import type { Options, Results } from '@mediapipe/pose';
import { Pose, POSE_CONNECTIONS } from '@mediapipe/pose';
import DeviceDetector from 'device-detector-js';


import type { MCameraPlugin } from './definitions';


export class MCameraWeb extends WebPlugin implements MCameraPlugin {

  camera?: Camera;
  cameraRunning = false;
  activeEffect = 'mask';
  videoElement = document.getElementsByClassName('input_video')[0] as HTMLVideoElement;
  canvasElement = document.getElementsByClassName('output_canvas')[0] as HTMLCanvasElement;
  canvasCtx?: CanvasRenderingContext2D;
  lineColor = "#ffffff"

  constructor() {
    super();
    this.canvasCtx = this.canvasElement.getContext('2d')!;

    this.testSupport([{ client: 'Chrome' }])
    // this.pose.onResults(this.onResults)
    const options: Options = {
      modelComplexity: 1,
      smoothLandmarks: true,
      enableSegmentation: false,
      smoothSegmentation: true,
      minDetectionConfidence: 0.5,
      minTrackingConfidence: 0.5,
    }
    this.pose.setOptions(options);

    this.pose.onResults((res) => {
      if (this.canvasCtx) {
        this.onResults(res, this.canvasCtx)
      }
    });
  }

  pose = new Pose({
    locateFile: (file) => {
      return `https://cdn.jsdelivr.net/npm/@mediapipe/pose/${file}`;
    }
  });

  resizeAllTheThings(): void {
    console.log("called ", window.innerWidth, window.innerHeight)
    this.camera = new Camera(this.videoElement, {
      onFrame: async () => {
        await this.pose.send({ image: this.videoElement })
      },
      width: 1920,//window.innerWidth,
      height: 1080, //window.innerHeight
    })

    this.canvasElement.width = 1920//window.innerWidth
    this.canvasElement.height = 1080//window.innerHeight

    this.camera.start()
    this.cameraRunning = true
  }

  showCamera(options: { lineColor: string }): void {
    console.log("SHOW CAMERA, Options: ", options);
    this.lineColor = options.lineColor
    // const elem = document.getElementById("camera-view")
    // if (elem) {
    //   //Remove the element

    this.cameraRunning ? this.stopCamera() : this.startCamera()

    // } else {
    //   alert("Div element for camera was not found")
    // }
  }

  startCamera(): void {
    this.resizeAllTheThings()
  }

  stopCamera(): void {
    this.camera?.stop()
    this.cameraRunning = false
  }

  testSupport(supportedDevices: { client?: string; os?: string; }[]): void {
    const deviceDetector = new DeviceDetector();
    const detectedDevice = deviceDetector.parse(navigator.userAgent);

    let isSupported = false;
    for (const device of supportedDevices) {
      if (device.client !== undefined) {
        const re = new RegExp(`^${device.client}$`);
        if (detectedDevice.client) {
          if (!re.test(detectedDevice.client.name)) {
            continue;
          }
        }
      }
      if (device.os !== undefined) {
        const re = new RegExp(`^${device.os}$`);
        if (detectedDevice.os) {

          if (!re.test(detectedDevice.os.name)) {
            continue;
          }
        }
      }
      isSupported = true;
      break;
    }
    if (!isSupported && detectedDevice.client && detectedDevice.os) {
      alert(`This demo, running on ${detectedDevice.client.name}/${detectedDevice.os.name}, ` +
        `is not well supported at this time, expect some flakiness while we improve our code.`);
    }
  }

  onResults(results: Results, canvasCtx: CanvasRenderingContext2D): void {

    const formattedReults = results.poseWorldLandmarks.map((val, ind) => {
      return {
        type: landmarkMap[ind],
        position: {
          x: val.x,
          y: val.y,
          z: val.z
        },
        inFrameLikelihood: val.visibility
      }
    })

    const resultsObj = {
      data: JSON.stringify(formattedReults), angle: -90
    }


    this.notifyListeners("posedetected", resultsObj)

    canvasCtx.save();
    canvasCtx.clearRect(0, 0, this.canvasElement.width, this.canvasElement.height);

    canvasCtx.globalCompositeOperation = 'source-over';
    drawConnectors(canvasCtx, results.poseLandmarks, POSE_CONNECTIONS,
      { color: this.lineColor, lineWidth: 2 });
    drawLandmarks(canvasCtx, results.poseLandmarks,
      { color: this.lineColor, lineWidth: 1 });
    canvasCtx.restore();
  }

}

const landmarkMap = [
  'Nose',
  'LeftEyeInner',
  'LeftEye',
  'LeftEyeOuter',
  'RightEyeInner',
  'RightEye',
  'RightEyeOuter',
  'LeftEar',
  'RightEar',
  'MouthLeft',
  'MouthRight',
  'LeftShoulder',
  'RightShoulder',
  'LeftElbow',
  'RightElbow',
  'LeftWrist',
  'RightWrist',
  'LeftPinkyFinger',
  'RightPinkyFinger',
  'LeftIndexFinger',
  'RightIndexFinger',
  'LeftThumb',
  'RightThumb',
  'LeftHip',
  'RightHip',
  'LeftKnee',
  'RightKnee',
  'LeftAnkle',
  'RightAnkle',
  'LeftHeel',
  'RightHeel',
  'LeftToe',
  'RightToe',
]
