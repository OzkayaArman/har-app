import SwiftUI
import UniformTypeIdentifiers

//This is the parent view of the ios app
//This struct initializes the login, viewModel and activities objects
struct MainPageView: View {
   
    /*
     Creating instance of loginModel which will be passed to AccountView
     AccountView uses login to read and display login details and
    */
    @StateObject var login =  loginModel()
    
    /*
     Creating instance of ActivityMetaData which will be passed to ActivityGridView
     ActivityGridView is the main UI for mainPageView
     It displays activities user can select to start a sensor recording
    */
    @StateObject var activities = ActivityMetaData()
    
    //Creating instance of viewModel class which will be passed down in view hierarchy
    @StateObject var viewModel = ActivitiesViewModel()

    var body: some View {
        
        
        if(login.authenticated){
            TabView{
                ActivityGridView(viewModel: viewModel,login:login,activityMetaData: activities)
                        .navigationTitle("Home")
                    .tabItem{
                        Image(systemName: "house" )
                        Text("Home")
                    }
            
                AccountView(loginModel:login)
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
    @ObservedObject var login: loginModel
    @ObservedObject var activityMetaData: ActivityMetaData
    @State var addingNewActivity = false
    @State var newActivityName = ""
    
    var body: some View {
        NavigationStack() {
            Spacer()
            VStack{
                //Button for recording a new activity
                Button {
                    addingNewActivity = true
                } label: {
                    Label("Record New Activity", systemImage: "figure.highintensity.intervaltraining")
                    
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .foregroundColor(.white)
                
                //Scrollable main grid view
                ScrollView {
                    LazyVGrid(columns: viewModel.columns) {
                        ForEach(activityMetaData.activityArray) { activitySelected in
                            NavigationLink(value: activitySelected){
                                ActivityIconViewMain(activity: activitySelected)
                            }
                        }
                    }
                }
                .navigationTitle("🎯 Start A Workout")
                //Each tap on an activity navigates the user to the ActivityDetailView UI
                .navigationDestination(for: Activities.self){ activitySelected in
                    ActivityDetailView(activity: activitySelected, viewModel: viewModel,loginModel: login)
                }
            }
        }
        //Sheet is utilized to quickly enable the user to define a new activity type
        .sheet(isPresented: $addingNewActivity, onDismiss: didDismiss, content: {
            NewActivitySheet(
                addingNewActivity: $addingNewActivity,
                newActivityName: $newActivityName,
                activityMetaData: activityMetaData
            )
        })
    }
    //Executed when sheet is dismissed to add the new activity to the data array
    func didDismiss() {
        if(!newActivityName.isEmpty) {
            activityMetaData.activityArray.append(
                Activities(name: newActivityName, imageName: "trophy.circle.fill")
            )
            // Clear the input field for future activity additions
            newActivityName = ""
        }
    }
    
}

struct NewActivitySheet: View {
    @Binding var addingNewActivity: Bool
    @Binding var newActivityName: String
    @ObservedObject var activityMetaData: ActivityMetaData

    var body: some View {
        VStack {
            // Close Button
            HStack {
                Spacer()
                Button {
                    addingNewActivity = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(.label))
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                }
            }
            .padding()
            
            // Title
            Text("Create A New Activity")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
            
            Spacer()
            
            // Form Section for Activity Name Input
            Form {
                Section {
                    TextField("Activity Name", text: $newActivityName)
                }
            }
            .frame(height: 150)
            
            Spacer()
            
            // Save Button
            Button {
                addingNewActivity = false
            } label: {
                Label("Save New Activity", systemImage: "square.and.arrow.down.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding()
        }
        .padding()
    }
}

struct ActivityIconViewMain: View {
    let activity: Activities
    
    var body: some View {
        VStack {
            Image(systemName: activity.imageName)
                .resizable()
                .frame(width: 90, height: 90)
            Text(activity.name)
                .font(.caption)
                .frame(width: 80, height: 35)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
            .padding()
            
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
