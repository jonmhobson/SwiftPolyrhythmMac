//
//  Sound.swift
//  Polyrhythm
//
//  Created by Jonathan Hobson on 26/06/2022.
//

import SwiftUI
import AVFoundation

enum Sound: String, CaseIterable {
    case bongoHi = "bongo hi"
    case bongoLo = "bongo lo"
    case clap = "clap1"
    case clap2 = "clap2"
    case donk = "donk"

    func getPlayer() -> AVAudioPlayer {
        guard let path = Bundle.main.path(forResource: self.rawValue, ofType:"wav") else { fatalError() }
        let url = URL(fileURLWithPath: path)

        do {
            return try AVAudioPlayer(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }

        fatalError()
    }

    var initialDivisions: Int {
        switch self {
        case .bongoHi:
            return 4
        case .bongoLo:
            return 3
        default:
            return 0
        }
    }

    var color: Color {
        switch self {
        case .bongoHi:
            return .red
        case .bongoLo:
            return .orange
        case .clap:
            return .green
        case .clap2:
            return .blue
        case .donk:
            return .purple
        }
    }

    var strokeStyle: StrokeStyle {
        switch self {
        case .bongoHi:
            return StrokeStyle(
                lineWidth: 5
            )
        case .bongoLo:
            return StrokeStyle(
                lineWidth: 5,
                lineCap: .round,
                lineJoin: .bevel,
                miterLimit: 0,
                dash: [5, 10],
                dashPhase: 0
            )
        case .clap:
            return StrokeStyle(
                lineWidth: 2,
                lineCap: .round,
                lineJoin: .miter,
                miterLimit: 0,
                dash: [1, 3],
                dashPhase: 0
            )
        case .clap2:
            return StrokeStyle(
                lineWidth: 5,
                lineCap: .round,
                lineJoin: .bevel,
                miterLimit: 0,
                dash: [5, 10],
                dashPhase: 0
            )
        case .donk:
            return StrokeStyle(
                lineWidth: 2,
                lineCap: .round,
                lineJoin: .miter,
                miterLimit: 0,
                dash: [1, 3],
                dashPhase: 0
            )
        }
    }
}
