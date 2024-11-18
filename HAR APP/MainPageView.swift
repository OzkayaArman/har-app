import SwiftUI
import UniformTypeIdentifiers

struct MainPageView: View {
    @StateObject var login =  loginModel()
    
    //Creating instance of viewModel class which will be passed down in view hierarchy
    @StateObject var viewModel = ActivitiesViewModel()

    var body: some View {
        
        
        if(login.authenticated){
            TabView{
                    ActivityGridView(viewModel: viewModel)
                        .navigationTitle("Home")
                    .tabItem{
                        Image(systemName: "house" )
                        Text("Home")
                    }
            
                AccountView(viewModel: viewModel)
                        .navigationTitle("Account & Preferences")
    
                    .tabItem {
                        Image(systemName: "person")
                        Text("Account & Preferences")
                    }
                
            }.accentColor(Color("selectColor"))
        }else{
            LoginPageView(login: login)
        }
                
            
    }
}

//Activity grid view initializes and passes the viewModel to ActivityDetailView
struct ActivityGridView: View {
    @ObservedObject var viewModel: ActivitiesViewModel
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

//This struct sets up the preview in xcode
struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        let login = loginModel()
        login.authenticated = true
        return MainPageView(login: login)
    }
}
