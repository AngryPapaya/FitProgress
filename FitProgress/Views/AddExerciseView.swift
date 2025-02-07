//
//  AddExerciseView.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//

import SwiftUI

struct AddExerciseView: View {
    let routine: Routine
    let routineDate: Date
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var exerciseName: String = ""
    @State private var weight: String = ""
    @State private var repetitions: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del Ejercicio").foregroundColor(.primary)) {
                    TextField("Nombre del Ejercicio", text: $exerciseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .foregroundColor(.primary)
                    TextField("Peso (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .foregroundColor(.primary)
                    TextField("Repeticiones", text: $repetitions)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .foregroundColor(.primary)
                }
                Button("Guardar") {
                    addExercise()
                }
                .disabled(exerciseName.isEmpty || weight.isEmpty || repetitions.isEmpty)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Añadir Ejercicio")
            .navigationBarItems(trailing: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func addExercise() {
        guard let weightValue = Double(weight), !weightValue.isNaN else {
            print("Error: Peso inválido")
            return
        }

        let newExercise = Exercise(context: viewContext)
        newExercise.id = UUID()
        newExercise.name = exerciseName
        newExercise.weight = weightValue
        newExercise.repetitions = Int16(repetitions) ?? 0
        newExercise.date = routineDate
        newExercise.routine = routine

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error al guardar el contexto: \(error)")
        }
    }
}
