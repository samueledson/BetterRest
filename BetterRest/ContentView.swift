//
//  ContentView.swift
//  BetterRest
//
//  Created by Samuel Edson on 16/11/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var sleepTimeText = ""
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Quando você quer acordar?")
                        .font(.headline)
                    
                    DatePicker("Por favor, insira um horário", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp) {
                            calculateBedtime()
                        }
                }

                Section {
                    Text("Quantidade desejada de sono")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) horas", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) {
                            calculateBedtime()
                        }
                }
                
                Section {
                    Text("Ingestão diária de café")
                        .font(.headline)
                    
                    Stepper("^[\(coffeeAmount) xícara](inflect: true)", value: $coffeeAmount, in: 1...20)
                        .onChange(of: coffeeAmount) {
                            calculateBedtime()
                        }
                }
            }
            VStack {
                Text("Sua hora de dormir ideal é:")
                    .font(.headline)
                Text("\(sleepTimeText)")
                    .font(.title)
            }
            .padding()
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calcular", action: calculateBedtime)
//            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear() {
            calculateBedtime()
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Sua hora ideal de dormir é…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Erro"
            alertMessage = "Desculpe, ocorreu um problema ao calcular sua hora de dormir."
        }
        sleepTimeText = alertMessage
//        showingAlert = true
    }
}

#Preview {
    ContentView()
}
