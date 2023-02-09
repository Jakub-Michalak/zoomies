import SwiftUI

// Ekran tworzenia nowego celu dla gildii
struct NewGoalView: View {
    @State private var goalName: String = ""
    @State private var goalPointsString: String = ""
    @State var confirmed = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // Widok
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Goal name", text: $goalName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                TextField("Number of points required", text: $goalPointsString)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                Button(action: {
                    newGoal(Name: goalName, Points: goalPointsString)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Confirm")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.accentColor)
                        .cornerRadius(5)
                }
                Spacer()
            }
            .padding(20)
            .navigationBarTitle("New goal")
        }
    }
    // Funkcja tworząca nowy cel przez funkcję GCP
    func newGoal(Name: String, Points: String){
        let pointsInt = Int(Points)
        functions.httpsCallable("setGoal").call(["goalName": Name, "requiredPoints": pointsInt]){ result, error in
            if let error = error as NSError? {
                print(error)
            }
            if let data = result?.data as? [String: Any], let response = data["status"] as? String {
                print(response)                
            }
        }
    }
}

struct NewGoalView_Previews: PreviewProvider {
    static var previews: some View {
        NewGoalView()
    }
}
