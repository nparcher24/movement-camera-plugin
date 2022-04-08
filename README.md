# movement-camera

Google MLKit Pose implementation in Capacitor

## Install

```bash
npm install movement-camera
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`showCamera(...)`](#showcamera)
* [`updateUI(...)`](#updateui)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### showCamera(...)

```typescript
showCamera(options: { testValue: string; }) => void
```

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ testValue: string; }</code> |

--------------------


### updateUI(...)

```typescript
updateUI(data: { goodReps: number; time: number; badReps: number; }) => void
```

| Param      | Type                                                              |
| ---------- | ----------------------------------------------------------------- |
| **`data`** | <code>{ goodReps: number; time: number; badReps: number; }</code> |

--------------------

</docgen-api>
