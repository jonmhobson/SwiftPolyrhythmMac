//
//  Sound.swift
//  Polyrhythm
//
//  Created by Jonathan Hobson on 26/06/2022.
//

import SwiftUI
import AVFoundation
import Combine

struct Dial: Shape {
    var numLines = 1

    func path(in rect: CGRect) -> Path {
        let radius = rect.size.height * 0.5
        let center = CGPoint(x: rect.origin.x + radius, y: rect.origin.y + radius)

        return Path { p in
            for n in 0..<numLines {
                let angle = Float(n) / Float(numLines) * Float.pi * 2.0
                p.move(to: center)
                p.addLine(to:
                            CGPoint(x: center.x + CGFloat(sin(angle)) * radius,
                                    y: center.y - CGFloat(cos(angle)) * radius))
            }
        }
    }
}

class Polyrhythms: ObservableObject {
    @Published var bpm = 20.0 {
        didSet {
            updateTimers()
        }
    }
    @Published var divisions: [Int] = Sound.allCases.map { $0.initialDivisions } {
        didSet {
            bpm = bpm // Changing the bpm updates the timers and resets the animation
        }
    }

    init() {
        sounds = Sound.allCases.map { $0.getPlayer() }
        bpm = 20.0
    }

    var sounds: [AVAudioPlayer]
    var cancellable = Set<AnyCancellable>()

    func updateTimers() {
        cancellable = Set<AnyCancellable>()

        for i in divisions.indices {
            if divisions[i] > 0 {
                Timer.publish(every: TimeInterval(60.0 / bpm / Double(divisions[i])), on: .main, in: .common).autoconnect().sink { [weak self] _ in
                    self?.sounds[i].currentTime = 0.0
                    self?.sounds[i].play()
                }
                .store(in: &cancellable)
            }
        }
    }
}

struct ContentView: View {
    @StateObject var polyrhythms = Polyrhythms()
    @State var appear = false

    var body: some View {
        HStack {

            VStack {
                Stepper("BPM: \(Int(polyrhythms.bpm))") {
                    polyrhythms.bpm += 5.0
                } onDecrement: {
                    if polyrhythms.bpm >= 10.0 {
                        polyrhythms.bpm -= 5.0
                    }
                }

                ForEach(polyrhythms.divisions.indices, id: \.self) { index in
                    let value = polyrhythms.divisions[index]
                    let sound = Sound.allCases[index]
                    Stepper("\(sound.rawValue): \(value > 0 ? "\(value)" : "off")") {
                        polyrhythms.divisions[index] += 1
                    } onDecrement: {
                        if polyrhythms.divisions[index] >= 1 {
                            polyrhythms.divisions[index] -= 1
                        }
                    }
                }
            }

            ZStack {
                Circle().fill(Color("Background"))

                ForEach(Sound.allCases.indices, id: \.self) { index in
                    let sound = Sound.allCases[index]
                    Dial(numLines: polyrhythms.divisions[index])
                        .stroke(sound.color, style: sound.strokeStyle)
                }

                Dial()
                    .stroke(Color("Hand"), style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                    ))
                    .rotationEffect(.degrees(appear ? 360 : 0))

                Circle().fill(Color.white).frame(width: 14, height: 14)

            }
            .aspectRatio(contentMode: .fit)
            .padding()
            .onReceive(polyrhythms.$bpm) { _ in
                withAnimation(.linear(duration: 0.0)) { // Reset the animation to its default position
                    appear = false
                }
                withAnimation(.linear(duration: Double(60.0 / polyrhythms.bpm)).repeatForever(autoreverses: false)) {
                    appear = true
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
