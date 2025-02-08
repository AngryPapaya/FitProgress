//
//  AddExerciseView.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//

import SwiftUI
import CoreData

struct AddExerciseView: View {
    let routine: Routine
    let routineDate: Date

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var exerciseName: String = ""
    @State private var filteredExercises: [String] = []
    @State private var sets: [SetData] = []
    @State private var showSuggestions: Bool = false
    @State private var errorMessage: String?

    struct SetData: Identifiable {
        let id = UUID()
        var weight: Double
        var repetitions: Int16
    }

    var allExercises: [String] {
        exercises.flatMap { $0.value }
    }

    var body: some View {
        NavigationView {
            Form {
                ExerciseNameSection(
                    exerciseName: $exerciseName,
                    filteredExercises: $filteredExercises,
                    showSuggestions: $showSuggestions,
                    allExercises: allExercises
                )
                
                SetsSection(sets: $sets)

                SaveButton(
                    exerciseName: $exerciseName,
                    sets: $sets,
                    errorMessage: $errorMessage,
                    routine: routine,
                    routineDate: routineDate,
                    viewContext: viewContext,
                    presentationMode: presentationMode
                )
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Añadir Ejercicio")
            .navigationBarItems(trailing: Button("Cancelar") { presentationMode.wrappedValue.dismiss() })
        }
    }

    // MARK: - Subcomponentes

    struct ExerciseNameSection: View {
        @Binding var exerciseName: String
        @Binding var filteredExercises: [String]
        @Binding var showSuggestions: Bool
        var allExercises: [String]

        var body: some View {
            Section(header: Text("Detalles del Ejercicio")) {
                TextField("Buscar Ejercicio", text: $exerciseName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: exerciseName) {
                        showSuggestions = true
                        filteredExercises = allExercises.filter { $0.lowercased().contains(exerciseName.lowercased()) }
                    }

                if showSuggestions && !filteredExercises.isEmpty {
                    List(filteredExercises, id: \.self) { exercise in
                        Text(exercise)
                            .onTapGesture {
                                exerciseName = exercise
                                showSuggestions = false
                            }
                    }
                    .frame(height: 200)
                }
            }
        }
    }

    struct SetsSection: View {
        @Binding var sets: [SetData]

        var body: some View {
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

                Button(action: {
                    sets.append(SetData(weight: 0, repetitions: 0))
                }) {
                    Text("Añadir Set")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }

    struct SaveButton: View {
        @Binding var exerciseName: String
        @Binding var sets: [SetData]
        @Binding var errorMessage: String?
        let routine: Routine
        let routineDate: Date
        let viewContext: NSManagedObjectContext
        let presentationMode: Binding<PresentationMode>

        var body: some View {
            Section {
                Button(action: { addExercise() }) {
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

        private func addExercise() {
            let newExercise = Exercise(context: viewContext)
            newExercise.id = UUID()
            newExercise.name = exerciseName
            newExercise.date = routineDate
            newExercise.routine = routine

            for setData in sets {
                let newSet = WorkoutSet(context: viewContext)
                newSet.id = UUID()
                newSet.weight = setData.weight
                newSet.repetitions = setData.repetitions
                newSet.exercise = newExercise
                newExercise.addToSets(newSet)
            }

            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                errorMessage = "Error al guardar el ejercicio: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Diccionario de Ejercicios
    let exercises: [String: [String]] = [
        "Pecho (Chest)": [
            "Bench Press (Barbell/Dumbbell) - Press de banca",
            "Incline Bench Press (Barbell/Dumbbell) - Press inclinado",
            "Decline Bench Press (Barbell/Dumbbell) - Press declinado",
            "Chest Fly (Machine/Cables/Dumbbells) - Aperturas de pecho",
            "Pec Deck Machine - Máquina de aperturas",
            "Push-Ups - Flexiones",
            "Dips (Chest-Focused) - Fondos en paralelas"
        ],
        "Espalda (Back)": [
            "Pull-Ups - Dominadas",
            "Chin-Ups - Dominadas supinas",
            "Lat Pulldown (Machine) - Jalón al pecho",
            "Seated Row (Cable/Machine) - Remo sentado",
            "Bent-Over Row (Barbell/Dumbbell) - Remo inclinado",
            "T-Bar Row - Remo en T",
            "Single-Arm Dumbbell Row - Remo con mancuerna",
            "Face Pulls - Jalones al rostro",
            "Deadlift - Peso muerto",
            "Rack Pulls - Peso muerto parcial"
        ],
        "Piernas (Legs)": [
            "Squat - Sentadilla",
            "Front Squat - Sentadilla frontal",
            "Leg Press - Prensa de piernas",
            "Lunges - Zancadas",
            "Bulgarian Split Squat - Sentadilla búlgara",
            "Step-Ups - Subida a banco",
            "Leg Extension - Extensión de pierna (máquina)",
            "Leg Curl - Curl de piernas (máquina)",
            "Romanian Deadlift - Peso muerto rumano",
            "Glute Ham Raise - Elevación de glúteos e isquiotibiales",
            "Hip Thrust - Empuje de cadera"
        ]
    ]
}
