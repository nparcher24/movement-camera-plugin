////
////  ExerciseView.swift
////  WarriorU Fitness Test
////
////  Created by Nicholas Parrish on 6/1/21.
////
//
import SwiftUI
import AVFoundation



//
//
//struct ExerciseView: View {
//    var exercise: Exercise? {
//        didSet (newValue) {
//            if newValue != nil {
//                //                print("THE NEW EXERCISE IS:")
//                //                print(newValue?.name)
//                time = newValue!.timeLimit!
//            }
//        }
//    }
//
//
//    //    var frame: CGRect?
//    @State var startCounting = false
//    @State var startTimer = false
//    @State var reps = 0
//    @State var badReps = 0
//    @State var time = 0
//    @State var totalTime: Double = 0
//    @State var totalGrace: Double = 0
//    @State var startRoutine = true
//    @State var targetReps: Int? = nil
//    @State var showStart = true
//
//
//
//    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//
//    @State var masterRepRecord : [RepRecord] = []
//
//
//    @Binding var viewSelection: String?
//
//    @State var isoStack: [Date: Date] = [:]
//    @State var graceStack: [Date: Date] = [:]
//
//    @State var inFrame: InFrameStatus = .outOfFrame
//
//    var closeModal: ([RepRecord]) -> Void
//    var closeIsoModal: ([Date: Date], [Date: Date]) -> Void
//    var exitWorkout: ()->Void
//    var readDirections = false
//    var isPartOfWorkout: Bool = false
//    //    var delegate: ExerciseViewDelegate? = nil
//
//    enum InFrameStatus {
//        case outOfFrame
//        case intermediateFrame
//        case inFrame
//    }
//
//    let synthesizer = AVSpeechSynthesizer()
//
//    let darkBackgroundGradient = LinearGradient(gradient: Gradient(colors:[Color.init(red: 50/255, green: 56/255, blue: 62/255, opacity: 1.0), Color.init(red: 23/255, green: 25/255, blue: 28/255, opacity: 1.0)]), startPoint: .top, endPoint: .bottom)
//
//    @Environment(\.presentationMode) var presentation
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                ExerciseController(exercise: exercise!, frame: CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height), delegate: self).ignoresSafeArea()
//
//
//                VStack {
//                    HStack {
//                        if isPartOfWorkout {
//                            Menu {
//                                Button("END WORKOUT") {
//                                    self.exitWorkout()
//                                }
//                            } label: {
//
//                                Text("EXIT")
//                                    .font(.custom(secondaryFontName, size: 16))
//                                    .foregroundColor(Color.theme.text)
//                                    .padding(.vertical, 5)
//                                    .padding(.horizontal, 20)
//                                    .background(Capsule().stroke().background(Capsule().foregroundColor(Color.theme.background)).foregroundColor(Color.theme.text))
//
//                            }
//                        }
//
//                        Spacer()
//
//                        Button {
//                            self.endExercise()
//                        } label: {
//                            Text("FINISH")
//                                .font(.custom(secondaryFontName, size: 16))
//                                .foregroundColor(Color.theme.text)
//                                .padding(.vertical, 5)
//                                .padding(.horizontal, 20)
//                                .background(Capsule().stroke().background(Capsule().foregroundColor(Color.theme.background)).foregroundColor(Color.theme.text))
//                        }
//                    }
//
//                    Spacer()
//                }.edgesIgnoringSafeArea([.leading, .trailing])
//                    .padding()
//
//                if (showStart && readDirections) {
//                    VStack {
//                        Spacer()
//                        Text("Exercise will begin once start position is detected")
//                            .font(.custom(secondaryFontName, size: 24))
//                            .padding(15)
//                            .foregroundColor(Color.white)
//                            .background(Capsule()
//                                            .strokeBorder(Color.white, lineWidth: 3)
//                                            .background(Color.black)
//                                            )
//
//
//                        Spacer()
//                    }
//                    .transition(AnyTransition.scale(scale: 0.1, anchor: UnitPoint.bottomLeading).combined(with: .opacity).animation(.easeInOut(duration: 1.0)))
//                    .zIndex(1)
//                }
//
//
//
//
//                VStack {
//                    Spacer()
//                    HStack {
//                        if exercise!.isIsometric {
//                            CounterViewIsometric(startAnimation: $startRoutine, totalTime: $totalTime, totalGrace: $totalGrace, exerciseName: exercise!.name, exerciseImage: exercise!.imageAssetName, time: $time).padding()
//                        } else {
//                            CounterView(startAnimation: $startRoutine, reps: $reps, exerciseName: exercise!.name, exerciseImage: exercise!.pictureName, time: $time)
//                                .padding()
//                        }
//
//                        Spacer()
//                    }
//                }.edgesIgnoringSafeArea(.vertical)
//                    .edgesIgnoringSafeArea(.trailing)
//            }
//            .onReceive(timer, perform: { input in
//                if self.exercise?.timeLimit == nil {
//                    self.timer.upstream.connect().cancel()
//                } else {
//                    time = startTimer ? time - 1 : time
//                    if time == 0 {
//                        self.timer.upstream.connect().cancel()
//                        self.endExercise()
//                    }
//                }
//            })
//            .onAppear {
//                UIApplication.shared.isIdleTimerDisabled = true
//                if readDirections {
//
//                    let _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
//                        self.showStart = false
//                        timer.invalidate()
//                    }
//
//                    let utterance = AVSpeechUtterance(string: "The exercise will begin once you are fully inside the camera frame and in the start position")
//                    utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-US_compact")
//                    synthesizer.speak(utterance)
//                }
//
//            }.onDisappear {
//                UIApplication.shared.isIdleTimerDisabled = false
//            }
//        }
//    }
//}
//
//
//protocol ExerciseViewDelegate {
//    func didFinishExercise(results: [RepRecord]) -> Void
//}
//
//
//extension ExerciseView: ExerciseControllerDelegate {
//
//    func inFrameChanged(inFrameStatus: InFrameStatus) {
//        self.inFrame = inFrameStatus
//    }
//
//    func repWasCompleted(repRecord: [RepRecord]) {
//        masterRepRecord = repRecord
//
//        if repRecord[repRecord.count - 1].isGoodRep {
//            handleGoodRep()
//            //            print("Good Rep!")
//        } else {
//            var errorText = "Incorrect position order"
//            if repRecord[repRecord.count - 1].brokenParams.count > 0 {
//                errorText = repRecord[repRecord.count - 1].brokenParams[0].audioDescription
//            }
//            handleBadRep(text: errorText)
//        }
//    }
//
//
//    func startPositionDetected() {
//
//        startRoutine = false
//        //        startTimer = false
//        DispatchQueue.main.async {
//            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { timer in
//                self.startTimer = true
//                self.startCounting = true
//            })
//        }
//    }
//
//    private func handleGoodRep() {
//        if (startCounting) {
//            reps += 1
//            let utterance = AVSpeechUtterance(string: String(reps))
//            utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-US_compact")
//            synthesizer.speak(utterance)
//            if let desiredReps = targetReps {
//                if reps >= desiredReps {
//                    endExercise()
//                }
//            }
//        }
//    }
//
//    private func handleBadRep(text: String) {
//        if startCounting {
//            badReps += 1
//            DispatchQueue.main.async {
//                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { atimer in
//                    let utterance = AVSpeechUtterance(string: text)
//                    utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-US_compact")
//                    synthesizer.speak(utterance)
//                }
//            }
//        }
//    }
//
//    private func endExercise() {
//
//        //        self.presentation.wrappedValue.dismiss()
//        if startCounting {
//            startCounting = false
//            if exercise!.isIsometric {
//                self.closeModal(createSummaryStack())
//            } else {
//                self.closeModal(self.masterRepRecord)
//            }
//        } else {
//            self.closeModal([])
//        }
//    }
//
//
//    func isometricTimer(totalTime: Double, graceTime: Double) {
//        //Isometric exercise is open ended
//        if self.exercise?.timeLimit == nil {
//            self.time = Int(totalTime)
//            self.totalGrace = self.exercise!.isometricGraceTime - graceTime
//            if self.totalGrace <= 0.1 {
//                endExercise()
//            }
//        } else {
//            self.totalGrace = graceTime
//        }
//
//        self.totalTime = totalTime
//
//
//
//        //        print("Total Time: " + String(totalTime))
//        //        print("Total Grace: " + String(graceTime))
//
//
//
//    }
//
//    func updateIsoStack(graceStack: [Date: Date], goodStack: [Date: Date]) {
//        self.graceStack = graceStack
//        self.isoStack = goodStack
//    }
//
//    private func createSummaryStack() -> [RepRecord] {
//        var isoRecord: [RepRecord] = []
//
//        let startTime = (Array(self.isoStack.keys) + Array(self.graceStack.keys)).sorted(by: { $0.compare($1) == .orderedAscending })[0]
//        //        print("START TIME:")
//        //        print(startTime)
//
//        for (start, end) in self.isoStack {
//            let newRecord = RepRecord(id: UUID(), isGoodRep: true, didCompleteInOrder: true, didCompleteAllPositions: true, brokenParams: [], timestamp: start.timeIntervalSince(startTime), endTimeStamp: end.timeIntervalSince(startTime) )
//            isoRecord.append(newRecord)
//        }
//        for (start, end) in self.graceStack {
//            let newRecord = RepRecord(id: UUID(), isGoodRep: false, didCompleteInOrder: true, didCompleteAllPositions: true, brokenParams: [], timestamp: start.timeIntervalSince(startTime), endTimeStamp: end.timeIntervalSince(startTime) )
//            isoRecord.append(newRecord)
//        }
//        isoRecord = isoRecord.sorted(by: { $0.timestamp < $1.timestamp })
//
//        //        print("ISO RECORD")
//        //        print(isoRecord)
//        return isoRecord
//    }
//
//    //    private func createSummaryStack() -> [Date: Bool] {
//    //
//    //        var newStack: [Date: IsoStackObject] = [:]
//    //
//    //        for (startDate, endDate) in self.isoStack {
//    //            let newObj = IsoStackObject()
//    //            newObj.inPosition = true
//    //            newObj.time = endDate.timeIntervalSince(startDate)
//    //            newStack[startDate] = newObj
//    //        }
//    //
//    //        return [:]
//    //    }
//
//
//
//
//}
//
//struct ExerciseView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseView(viewSelection: .constant("pushups"), closeModal: {_ in }, closeIsoModal: {_,_ in}, exitWorkout: {})
//    }
//}
//
//class IsoStackObject {
//    var time: Double = 0
//    var inPosition: Bool = false
//}
