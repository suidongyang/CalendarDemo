//
//  AKTools.swift
//  Test
//
//  Created by 隋冬阳 on 2023/8/28.
//

import Foundation
import AudioKit

@objc class AudioTool: NSObject {
    
    let engine = AudioEngine()
    var instrument: MIDISampler!
    let indices: [Int] = [13, 12, 0]
    
    let effectQueue: DispatchQueue!
    var effectTaskGroup: [DispatchWorkItem] = []
    
    var midiPlayer: AppleSequencer?
    
    
    @objc init(instrumentIndex: Int) {
        effectQueue = DispatchQueue(label: "sunny.audio.effect.queue")
        super.init()
        loadInstrument(instrumentIndex)
        startEngine()
    }
    
    @objc func playMidi() {
        guard let midiFileURL = Bundle.main.url(forResource: "Sor_Menuet_op24_no1", withExtension: "mid") else {
            fatalError("MIDI file not found")
        }
        if midiPlayer == nil {
            midiPlayer = AppleSequencer(fromURL: midiFileURL)
        }
        midiPlayer?.play()
    }
    
    @objc func stopMidi() {
        midiPlayer?.stop()
    }
    
    @objc func loadInstrument(_ index: Int) {
        
        let preset = indices[index % indices.count]
        let bank: Int = 0
        
        do {
            instrument = MIDISampler(name: "Instrument \(preset)")
            try instrument.loadSoundFont("FluidR3_GM", preset: preset, bank: bank)
            engine.output = instrument
        } catch {
            Log("Could not load instrument")
        }
        // throwing -10878
    }
    
    func startEngine() {
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start!")
        }
    }
    
    func stopEngine() {
        engine.stop()
    }

    @objc func play(_ index: Int) {
        instrument.play(noteNumber: MIDINoteNumber(index), velocity: 50, channel: 0)
    }

    @objc func stop(_ index: Int) {
        instrument.stop(noteNumber: MIDINoteNumber(index), channel: 0)
    }
    
    
    //MARK: - 音效
    
    @objc func playScheduleEventSound(_ index: Int) {
        switch index {
        case 0: playNotes([66, 67])
        case 1: playNotes([72, 73])
        case 2: playNotes([78, 79])
        case 3: playNotes([84, 85])
        default: break
        }
    }

    func playInstrumentSelectionSound() {
        playNotes([62, 69, 76])
    }
    
    func playNotes(_ notes:[Int]) {
        effectTaskGroup.forEach { $0.cancel() }
        notes.forEach { asyncPlay($0) }
    }
    
    func asyncPlay(_ number: Int, wait: Int = 200) {
        let item = DispatchWorkItem {
            self.instrument.play(noteNumber: MIDINoteNumber(number + 11), velocity: 50, channel: 0)
        }
        effectTaskGroup.append(item)
        effectQueue.async { item.perform() }
        
        let item2 = DispatchWorkItem {
            usleep(useconds_t(wait * 1000))
        }
        effectTaskGroup.append(item2)
        effectQueue.async { item2.perform() }
    }
    
    
    
}

/*
 
 echo "inst 1" | fluidsynth FluidR3_GM.sf2
 
 01 Bright Yamaha Grand
 12 Marimba
 13 Xylophone
 
 
*/
