# movement-camera

Google MLKit Pose implementation in Capacitor

## Install

```bash
npm install movement-camera
npx cap sync
```

## API

<docgen-index>

* [`showCamera(...)`](#showcamera)
* [`stopCamera()`](#stopcamera)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### showCamera(...)

```typescript
showCamera(options: { lineColor: string; }) => void
```

Starts the ML Model, the camera, and displays it on the screen behind the ionic content

| Param         | Type                                | Description                                                                                              |
| ------------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ lineColor: string; }</code> | - An options object that currently only includes: a hex color string for the lines to show on the screen |

--------------------


### stopCamera()

```typescript
stopCamera() => void
```

Stops the camera from showing; deallocs the used memory and removes it from the native view stack

--------------------

</docgen-api>
