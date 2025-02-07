//
//  ExerciseListView.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//

import SwiftUI
import CoreData

struct ExerciseListView: View {
    let routine: Routine
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var exercises: FetchedResults<Exercise>
    @State private var exerciseToEdit: Exercise?
    @State private var newExerciseName: String = ""
    @State private var newWeight: String = ""
    @State private var newRepetitions: String = ""
    @State private var showAddExerciseSheet = false

    init(routine: Routine) {
        self.routine = routine
        _exercises = FetchRequest(
            entity: Exercise.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.date, ascending: true)],
            predicate: NSPredicate(format: "routine == %@", routine)
        )
    }

    var body: some View {
        List {
            ForEach(exercises, id: \.id) { exercise in
                NavigationLink(destination: ProgressView(exerciseName: exercise.name ?? "")) {
                    VStack(alignment: .leading) {
                        Text(exercise.name ?? "Ejercicio sin nombre")
                            .font(.headline)
                        Text("Peso: \(exercise.weight, specifier: "%.1f") kg - Reps: \(exercise.repetitions)")
                            .font(.subheadline)
                    }
                }
                .swipeActions(edge: .leading) {
                    Button("Editar") {
                        exerciseToEdit = exercise
                        newExerciseName = exercise.name ?? ""
                        newWeight = String(exercise.weight)
                        newRepetitions = String(exercise.repetitions)
                    }
                    .tint(.blue)
                }
            }
            .onDelete(perform: deleteExercise)
        }
        .navigationTitle(routine.name ?? "Rutina")
        .toolbar {
            Button(action: { showAddExerciseSheet = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddExerciseSheet) {
            AddExerciseView(routine: routine, routineDate: routine.date ?? Date())
        }
        .alert("Editar Ejercicio", isPresented: Binding<Bool>(
            get: { exerciseToEdit != nil },
            set: { if !$0 { exerciseToEdit = nil } }
        )) {
            VStack {
                TextField("Nombre del Ejercicio", text: $newExerciseName)
                TextField("Peso (kg)", text: $newWeight)
                    .keyboardType(.decimalPad)
                TextField("Repeticiones", text: $newRepetitions)
                    .keyboardType(.numberPad)
            }
            Button("Guardar") {
                saveExerciseEdit()
            }
            Button("Cancelar", role: .cancel) { }
        }
    }

    private func deleteExercise(offsets: IndexSet) {
        offsets.map { exercises[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }

    private func saveExerciseEdit() {
        guard let exerciseToEdit = exerciseToEdit else { return }
        exerciseToEdit.name = newExerciseName
        exerciseToEdit.weight = Double(newWeight) ?? exerciseToEdit.weight
        exerciseToEdit.repetitions = Int16(newRepetitions) ?? exerciseToEdit.repetitions
        try? viewContext.save()
        self.exerciseToEdit = nil
    }
}
