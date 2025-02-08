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
    @FetchRequest private var exercises: FetchedResults<Exercise>
    @State private var exerciseToEdit: Exercise?
    @State private var showAddExerciseSheet = false

    init(routine: Routine) {
        self.routine = routine
        self._exercises = FetchRequest(fetchRequest: ExerciseListView.fetchExercises(for: routine))
    }

    // MARK: - FetchRequest Helper
    private static func fetchExercises(for routine: Routine) -> NSFetchRequest<Exercise> {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.date, ascending: true)]
        request.predicate = NSPredicate(format: "routine == %@", routine)
        return request
    }

    var body: some View {
        List {
            ForEach(exercises, id: \.id) { exercise in
                NavigationLink(destination: ProgressView(exerciseName: exercise.name ?? "")) {
                    ExerciseRow(exercise: exercise, onEdit: { exerciseToEdit = $0 })
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
        .sheet(item: $exerciseToEdit) { exercise in
            EditExerciseView(exercise: exercise)
        }
    }

    // MARK: - Acciones

    private func deleteExercise(offsets: IndexSet) {
        offsets.forEach { viewContext.delete(exercises[$0]) }
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error al guardar cambios: \(error.localizedDescription)")
        }
    }
}

// MARK: - Subvistas

struct ExerciseRow: View {
    let exercise: Exercise
    let onEdit: (Exercise) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name ?? "Ejercicio sin nombre")
                .font(.headline)

            if let sets = exercise.sets?.allObjects as? [WorkoutSet], !sets.isEmpty {
                ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                    Text("Set \(index + 1): Peso \(set.weight, specifier: "%.1f") kg - Reps: \(set.repetitions)")
                        .font(.subheadline)
                }
            } else {
                Text("No hay sets registrados")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .swipeActions(edge: .leading) {
            Button("Editar") { onEdit(exercise) }
                .tint(.blue)
        }
    }
}
