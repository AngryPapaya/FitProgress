//
//  RoutineListView.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//

import SwiftUI
import CoreData

struct RoutineListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Routine.date, ascending: false)]) private var routines: FetchedResults<Routine>
    @State private var routineToEdit: Routine?
    @State private var newRoutineName: String = ""
    @State private var newRoutineDate: Date = Date()
    @State private var showAddRoutineSheet = false
    @State private var showEditRoutineSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(groupRoutinesByWeek(), id: \.week) { week, routines in
                    Section(header: Text("Semana del \(formattedDate(week))").foregroundColor(.primary)) {
                        ForEach(routines, id: \.id) { routine in
                            NavigationLink(destination: ExerciseListView(routine: routine)) {
                                Text(routine.name ?? "Sin nombre").foregroundColor(.primary)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Eliminar", role: .destructive) {
                                    deleteRoutine(routine)
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button("Editar") {
                                    routineToEdit = routine
                                    newRoutineName = routine.name ?? ""
                                    newRoutineDate = routine.date ?? Date()
                                    showEditRoutineSheet = true
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Rutinas")
            .toolbar {
                Button(action: { showAddRoutineSheet = true }) {
                    Image(systemName: "plus").foregroundColor(.primary)
                }
            }
            .sheet(isPresented: $showAddRoutineSheet) {
                VStack {
                    Text("Nueva Rutina")
                        .font(.headline)
                    TextField("Nombre de la Rutina", text: $newRoutineName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    DatePicker("Fecha de la Rutina", selection: $newRoutineDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                    HStack {
                        Button("Cancelar") {
                            showAddRoutineSheet = false
                        }
                        .padding()
                        Spacer()
                        Button("Añadir") {
                            addRoutine()
                            showAddRoutineSheet = false
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showEditRoutineSheet) {
                VStack {
                    Text("Editar Rutina")
                        .font(.headline)
                    TextField("Nombre de la Rutina", text: $newRoutineName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    DatePicker("Fecha de la Rutina", selection: $newRoutineDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                    HStack {
                        Button("Cancelar") {
                            showEditRoutineSheet = false
                        }
                        .padding()
                        Spacer()
                        Button("Guardar") {
                            saveRoutineEdit()
                            showEditRoutineSheet = false
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
    }

    private func addRoutine() {
        let newRoutine = Routine(context: viewContext)
        newRoutine.id = UUID()
        newRoutine.name = newRoutineName
        newRoutine.date = newRoutineDate

        do {
            try viewContext.save()
            newRoutineName = ""
            newRoutineDate = Date()
        } catch {
            print("Error al guardar la nueva rutina: \(error)")
        }
    }

    private func deleteRoutine(_ routine: Routine) {
        if let exercises = routine.exercises as? Set<Exercise> {
            for exercise in exercises {
                viewContext.delete(exercise)
            }
        }

        viewContext.delete(routine)
        
        do {
            try viewContext.save()
        } catch {
            print("Error al guardar el contexto después de eliminar la rutina: \(error)")
        }
    }

    private func saveRoutineEdit() {
        routineToEdit?.name = newRoutineName
        routineToEdit?.date = newRoutineDate
        do {
            try viewContext.save()
            routineToEdit = nil
            newRoutineName = ""
            newRoutineDate = Date()
        } catch {
            print("Error al guardar el contexto después de editar la rutina: \(error)")
        }
    }

    private func groupRoutinesByWeek() -> [(week: Date, routines: [Routine])] {
        let calendar = Calendar.current
        let groupedDict = Dictionary(grouping: routines) { routine -> Date in
            let weekOfYear = calendar.component(.weekOfYear, from: routine.date ?? Date())
            let year = calendar.component(.year, from: routine.date ?? Date())
            return calendar.date(from: DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: year)) ?? Date()
        }
        return groupedDict.sorted { $0.key > $1.key }.map { (week: $0.key, routines: $0.value) }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
