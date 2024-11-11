import SwiftUI
import UniformTypeIdentifiers

struct MainPageView: View {
    @StateObject var login =  loginModel()
    
    var body: some View {
        
        
        if(login.authenticated){
            TabView{
                    ActivityGridView()
                        .navigationTitle("Home")
            
                    .tabItem{
                        Image(systemName: "house" )
                        Text("Home")
                    }
            
                    AccountView()
                        .navigationTitle("Account & Preferences")
    
                    .tabItem {
                        Image(systemName: "person")
                        Text("Account & Preferences")
                    }
                
            }.accentColor(Color("selectColor"))
        }else{
            LoginPage(login: login)
        }
                
            
    }
}


struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView(login: loginModel())
    }
}


//Activity grid view passes both the viewModel and watchConnector
//To ActivityDetailView
struct ActivityGridView: View {
    //Creating instances of viewModel and connector
    @StateObject var viewModel = ActivitiesViewModel()
    
    var body: some View {
        NavigationStack() {
            Spacer()
            VStack{
                //Button for recording a new activity
                Button {
                } label: {
                    Label("Record New Activity", systemImage: "figure.highintensity.intervaltraining")
                    
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .foregroundColor(.white)
                
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


