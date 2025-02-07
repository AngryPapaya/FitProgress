//
//  ProgressView.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//

import SwiftUI
import Charts

struct ProgressView: View {
    let exerciseName: String
    @FetchRequest var exercises: FetchedResults<Exercise>

    init(exerciseName: String) {
        self.exerciseName = exerciseName
        _exercises = FetchRequest(entity: Exercise.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.date, ascending: true)],
            predicate: NSPredicate(format: "name == %@", exerciseName)
        )
    }

    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(exercises) { exercise in
                    LineMark(
                        x: .value("Fecha", exercise.date ?? Date(), unit: .day),
                        y: .value("Peso", exercise.weight)
                    )
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .stride(by: .day)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day())
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
            .frame(minWidth: UIScreen.main.bounds.width * 2) // Ajustar al doble del ancho de la pantalla para permitir desplazamiento
        }
        .navigationTitle(exerciseName)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ocupar toda la pantalla
    }
}
