//
//  ProgressView.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//

import SwiftUI
import Charts
import CoreData

struct ProgressView: View {
    let exerciseName: String
    @FetchRequest private var exercises: FetchedResults<Exercise>

    init(exerciseName: String) {
        self.exerciseName = exerciseName
        self._exercises = FetchRequest(fetchRequest: ProgressView.fetchExercises(for: exerciseName))
    }

    // MARK: - Static Helper para FetchRequest
    private static func fetchExercises(for name: String) -> NSFetchRequest<Exercise> {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.date, ascending: true)]
        request.predicate = NSPredicate(format: "name == %@", name)
        return request
    }

    // MARK: - Obtener Datos de Peso
    private func getWeightData() -> [(date: String, maxWeight: Double, averageWeight: Double)] {
        return exercises.compactMap { exercise in
            guard let sets = exercise.sets?.allObjects as? [WorkoutSet], !sets.isEmpty,
                  let date = exercise.date else { return nil }

            let maxWeight = sets.map(\.weight).max() ?? 0
            let totalWeight = sets.reduce(0.0) { $0 + $1.weight }
            let averageWeight = totalWeight / Double(sets.count)

            return (formattedDate(date), maxWeight, averageWeight)
        }
    }

    // MARK: - Obtener Datos de Repeticiones
    private func getRepData() -> [(date: String, maxReps: Int16)] {
        return exercises.compactMap { exercise in
            guard let sets = exercise.sets?.allObjects as? [WorkoutSet], !sets.isEmpty,
                  let date = exercise.date else { return nil }

            // Encontrar el set con el peso más alto del día
            if let maxWeightSet = sets.max(by: { $0.weight < $1.weight }) {
                return (formattedDate(date), maxWeightSet.repetitions)
            }

            return nil
        }
    }

    var body: some View {
        VStack {
            if let exercise = exercises.first {
                ExerciseDetailsView(exercise: exercise)
            }

            Divider().padding(.vertical, 20)

            // Gráfico de Peso
            SectionTitle(text: "Gráfico de Peso")
            WeightChart(weightData: getWeightData())

            Divider().padding(.vertical, 20)

            // Gráfico de Repeticiones
            SectionTitle(text: "Gráfico de Repeticiones")
            RepChart(repData: getRepData())
        }
        .navigationTitle(exerciseName)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Formatear Fecha para evitar espacios vacíos en la gráfica
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM" // Ejemplo: "08 Feb"
        return formatter.string(from: date)
    }
}

// MARK: - Subvistas

struct ExerciseDetailsView: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Datos de los Sets")
                .font(.title2)
                .padding(.top, 20)

            ForEach(Array((exercise.sets?.allObjects as? [WorkoutSet] ?? []).enumerated()), id: \.element.id) { index, set in
                Text("Set \(index + 1): Peso \(set.weight, specifier: "%.1f") kg - Reps: \(set.repetitions)")
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
    }
}

struct WeightChart: View {
    let weightData: [(date: String, maxWeight: Double, averageWeight: Double)]

    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(weightData, id: \.date) { data in
                    LineMark(
                        x: .value("Fecha", data.date), // ✅ Se usa como categoría
                        y: .value("Peso (kg)", data.maxWeight)
                    )
                    .interpolationMethod(.catmullRom)
                    .symbol(.circle)

                    RuleMark(
                        y: .value("Peso Medio (kg)", data.averageWeight)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color.gray)
                }
            }
            .chartStyle()
            .frame(minWidth: UIScreen.main.bounds.width * 2)
        }
    }
}

struct RepChart: View {
    let repData: [(date: String, maxReps: Int16)]

    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(repData, id: \.date) { data in
                    BarMark(
                        x: .value("Fecha", data.date), // ✅ Se usa como categoría
                        y: .value("Repeticiones", data.maxReps)
                    )
                }
            }
            .chartStyle()
            .frame(minWidth: UIScreen.main.bounds.width * 2)
        }
    }
}

// MARK: - Extensiones para Código Limpio

extension View {
    func chartStyle() -> some View {
        self
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic) { // ✅ SOLO SE MUESTRAN FECHAS DISPONIBLES
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .padding()
    }
}

struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.title2)
            .padding(.top, 10)
    }
}
