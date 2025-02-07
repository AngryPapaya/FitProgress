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
    @State private var filteredExercises: [String] = []
    @State private var weight: String = ""
    @State private var repetitions: String = ""
    @State private var showSuggestions: Bool = false

    let exercises = [
        "Pecho (Chest)": [
            "Bench Press (Barbell/Dumbbell) – Press de banca",
            "Incline Bench Press (Barbell/Dumbbell) – Press inclinado",
            "Decline Bench Press (Barbell/Dumbbell) – Press declinado",
            "Chest Fly (Machine/Cables/Dumbbells) – Aperturas de pecho",
            "Pec Deck Machine – Máquina de aperturas",
            "Push-Ups – Flexiones",
            "Dips (Chest-Focused) – Fondos en paralelas"
        ],
        "Espalda (Back)": [
            "Pull-Ups – Dominadas",
            "Chin-Ups – Dominadas supinas",
            "Lat Pulldown (Machine) – Jalón al pecho",
            "Seated Row (Cable/Machine) – Remo sentado",
            "Bent-Over Row (Barbell/Dumbbell) – Remo inclinado",
            "T-Bar Row – Remo en T",
            "Single-Arm Dumbbell Row – Remo con mancuerna",
            "Face Pulls – Jalones al rostro",
            "Deadlift – Peso muerto",
            "Rack Pulls – Peso muerto parcial"
        ],
        "Hombros (Shoulders)": [
            "Overhead Press (Barbell/Dumbbell) – Press militar",
            "Seated Shoulder Press (Machine/Dumbbells) – Press de hombros sentado",
            "Arnold Press – Press Arnold",
            "Lateral Raises – Elevaciones laterales",
            "Front Raises – Elevaciones frontales",
            "Rear Delt Fly (Dumbbells/Cables/Machine) – Elevaciones posteriores",
            "Face Pulls – Jalones al rostro",
            "Upright Row – Remo al mentón"
        ],
        "Bíceps (Biceps)": [
            "Barbell Curl – Curl con barra",
            "Dumbbell Curl – Curl con mancuerna",
            "Hammer Curl – Curl martillo",
            "Preacher Curl – Curl en banco Scott",
            "Concentration Curl – Curl de concentración",
            "Cable Curl – Curl en polea"
        ],
        "Tríceps (Triceps)": [
            "Triceps Dips – Fondos en paralelas",
            "Triceps Pushdown – Jalón de tríceps en polea",
            "Overhead Triceps Extension (Dumbbell/Cable) – Extensión de tríceps por encima de la cabeza",
            "Skull Crushers – Rompecráneos",
            "Close-Grip Bench Press – Press de banca con agarre cerrado"
        ],
        "Piernas (Legs)": [
            "Squat – Sentadilla",
            "Front Squat – Sentadilla frontal",
            "Leg Press – Prensa de piernas",
            "Lunges – Zancadas",
            "Bulgarian Split Squat – Sentadilla búlgara",
            "Step-Ups – Subida a banco",
            "Leg Extension – Extensión de pierna (máquina)",
            "Leg Curl – Curl de piernas (máquina)",
            "Romanian Deadlift – Peso muerto rumano",
            "Glute Ham Raise – Elevación de glúteos e isquiotibiales",
            "Hip Thrust – Empuje de cadera"
        ],
        "Core (Abdominales y zona media)": [
            "Crunches – Abdominales",
            "Sit-Ups – Abdominales completos",
            "Leg Raises – Elevaciones de piernas",
            "Hanging Leg Raises – Elevaciones de piernas colgado",
            "Plank – Plancha",
            "Russian Twists – Giros rusos",
            "Ab Rollout (Ab Wheel/Barbell) – Desplazamiento con rueda",
            "Cable Woodchopper – Giros en polea",
            "Decline Sit-Ups – Abdominales en banco declinado"
        ],
        "Otros/Ejercicios Funcionales": [
            "Farmer’s Carry – Paseo del granjero",
            "Battle Ropes – Cuerdas de batalla",
            "Kettlebell Swings – Balanceo con kettlebell",
            "Box Jumps – Saltos al cajón",
            "Medicine Ball Slams – Golpes con balón medicinal"
        ]
    ]

    var allExercises: [String] {
        exercises.flatMap { $0.value }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del Ejercicio").foregroundColor(.primary)) {
                    TextField("Buscar Ejercicio", text: $exerciseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .foregroundColor(.primary)
                        .onChange(of: exerciseName) {
                            showSuggestions = true
                            filterExercises()
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
                .padding(.horizontal)

                Section {
                    Button(action: {
                        addExercise()
                    }) {
                        Text("Guardar")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(exerciseName.isEmpty || weight.isEmpty || repetitions.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(exerciseName.isEmpty || weight.isEmpty || repetitions.isEmpty)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Añadir Ejercicio")
            .navigationBarItems(trailing: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func filterExercises() {
        if exerciseName.isEmpty {
            filteredExercises = []
        } else {
            filteredExercises = allExercises.filter {
                $0.lowercased().contains(exerciseName.lowercased())
            }
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

