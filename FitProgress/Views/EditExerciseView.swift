//
//  EditExerciseView.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 09/02/2025.
//

import SwiftUI

struct EditExerciseView: View {
    let exercise: Exercise
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var exerciseName: String
    @State private var sets: [WorkoutSet]

    init(exercise: Exercise) {
        self.exercise = exercise
        _exerciseName = State(initialValue: exercise.name ?? "")
        _sets = State(initialValue: (exercise.sets?.allObjects as? [WorkoutSet] ?? []).sorted { $0.weight > $1.weight })
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del Ejercicio")) {
                    TextField("Nombre del Ejercicio", text: $exerciseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section(header: Text("Sets")) {
                    ForEach($sets.indices, id: \.self) { index in
                        HStack {
                            TextField("Peso (kg)", text: Binding(
                                get: { String(format: "%.1f", sets[index].weight) },
                                set: { sets[index].weight = Double($0) ?? sets[index].weight }
                            ))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("Repeticiones", text: Binding(
                                get: { String(sets[index].repetitions) },
                                set: { sets[index].repetitions = Int16($0) ?? sets[index].repetitions }
                            ))
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button(action: { sets.remove(at: index) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Button(action: addSet) {
                        Text("Añadir Set")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                Section {
                    Button(action: saveExercise) {
                        Text("Guardar")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(exerciseName.isEmpty || sets.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(exerciseName.isEmpty || sets.isEmpty)
                }
            }
            .navigationTitle("Editar Ejercicio")
            .navigationBarItems(trailing: Button("Cancelar") { presentationMode.wrappedValue.dismiss() })
        }
    }

    // MARK: - Acciones

    private func addSet() {
        let newSet = WorkoutSet(context: viewContext)
        newSet.id = UUID()
        newSet.weight = 0
        newSet.repetitions = 0
        newSet.exercise = exercise
        sets.append(newSet)
    }

    private func saveExercise() {
        exercise.name = exerciseName
        exercise.sets = NSSet(array: sets)

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error al guardar el ejercicio: \(error)")
        }
    }
}
