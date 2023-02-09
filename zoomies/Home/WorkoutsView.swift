//
//  WorkoutsView.swift
//  zoomies
//
//  Created by Jakub Pietkiewicz on 26/10/2022.
//

import SwiftUI

// Widok listy treningów
struct WorkoutsView: View {
    @ObservedObject var model = WorkoutsModel()
    var body: some View {
        VStack{
            // Wyświetlenie treningow z HealthKit
            List(model.list){item in
                HStack{
                    Text("🏃")
                        .padding(.horizontal, 3.0)
                        .scaleEffect(2)
                    VStack{
                        HStack{
                            Text(String(item.workoutDistance)+" km run")
                                .fontWeight(.bold)
                            Spacer()
                        }.padding(.vertical, 1)
                        HStack{
                            Text(item.workoutTime)
                            Spacer()
                            Text(String(item.workoutCalories)+" kcal")
                        }
                        .padding(.vertical, 1)
                        HStack{
                            Text(item.workoutStart, style: .date)
                            Spacer()
                            Text(item.workoutStart, style: .time)
                            Text("-")
                            Text(item.workoutEnd, style: .time)
                        }.font(.footnote)
                    }
                }
            }
        }.task {
            // Wczytanie treningow z HealthKit
            await model.readWorkouts()
            // Wysłanie treningów na serwer w celu dodania punktów
            model.uploadWorkouts()
        }
    }
}


struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView()
    }
}
