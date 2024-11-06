import SwiftUI
import UniformTypeIdentifiers

struct MainPageView: View {
    
    var body: some View {
        ZStack{
            VStack(){
                //Displays top Bar
                HStack {
                    profileView(imageRef: "Image", userName: "Arman Özkaya")
                } .background(.app)

                ActivityGridView()
                
                
            }
        }
    }
}

//Driver Method for preview
struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView()
    }
}


//Sets up the top bar
struct profileView: View {
    let imageRef: String
    let userName: String
    
    var body: some View {
        Image(imageRef)
            .renderingMode(.original)
            .resizable()
            .frame(width: 70, height: 70)
            .clipShape(.circle)
            .padding()
        
        Text(userName)
            .font(.title)
        Spacer()
        //Turn this image to a button
        Image(systemName: "gearshape")
            .resizable()
            .renderingMode(.original)
            .frame(width: 30, height: 30)
        Spacer()
    }
}

struct ActivityGridView: View {
    @StateObject var viewModel = ActivitiesViewModel()
    
    var body: some View {
        NavigationStack() {
            VStack{
                //Button for recording a new activity
                Button {
                } label: {
                    Label("Record New Activity", systemImage: "figure.highintensity.intervaltraining")
                    
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .foregroundColor(.black)
                
                ScrollView {
                    LazyVGrid(columns: viewModel.columns) {
                        ForEach(MockData.activityArray) { activitySelected in
                            NavigationLink(value: activitySelected){
                                ActivityIconView(activity: activitySelected)
                            }
                        }
                    }
                }
                .navigationTitle("🎯 Start A Workout")
                .navigationDestination(for: Activities.self){ activitySelected in
                    ActivityDetailView(activity: activitySelected, viewModel: viewModel)
                }
            }
        }
    }
}


