// SwiftData local storage
//
//NavigationSplitView {
//    List {
//        ForEach(items) { item in
//            NavigationLink {
//                Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//            } label: {
//                Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//            }
//        }
//        .onDelete(perform: deleteItems)
//    }
//    .toolbar {
//        ToolbarItem(placement: .navigationBarTrailing) {
//            EditButton()
//        }
//        ToolbarItem {
//            Button(action: addItem) {
//                Label("Add Item", systemImage: "plus")
//            }
//        }
//    }
//} detail: {
//    Text("Select an item")
//}
//
//private func addItem() {
//    withAnimation {
//        let newItem = Item(timestamp: Date())
//        modelContext.insert(newItem)
//    }
//}
//
//private func deleteItems(offsets: IndexSet) {
//    withAnimation {
//        for index in offsets {
//            modelContext.delete(items[index])
//        }
//    }
//}

//import SwiftUI
//import AVFoundation
//
//struct ContentView: View {
//    @State private var selectedStory: Int = 0
//    @State private var isPlaying: Bool = false
//    
//    // Fictional stories
//    let stories = [
//        """
//        Once upon a time, in a small village nestled between rolling hills, there lived a curious little fox named Felix. Felix loved exploring the forest, but one day, he stumbled upon a mysterious glowing stone. As he touched it, he was transported to a magical world filled with talking animals and enchanted trees. Felix's adventure had just begun!
//        """,
//        """
//        In a distant galaxy, a brave astronaut named Luna was on a mission to explore a newly discovered planet. As she landed, she found herself in a world where the sky was purple, and the trees sparkled like diamonds. But danger lurked in the shadows, and Luna had to use her wits to survive and uncover the planet's secrets.
//        """,
//        """
//        Deep in the ocean, a young dolphin named Splash dreamed of discovering the legendary Sunken City. One day, he gathered his courage and swam far beyond the coral reefs. Along the way, he met a wise old turtle who gave him a magical seashell. With its help, Splash found the Sunken City and learned about its ancient mysteries.
//        """,
//        """
//        In a bustling city, a clever inventor named Max created a robot named Sparky. Sparky was no ordinary robot—he could think and feel like a human! Together, Max and Sparky solved problems and helped people in the city. But one day, Sparky discovered a hidden message that led them on an exciting adventure to save the world.
//        """
//    ]
//    
//    // AVSpeechSynthesizer for text-to-speech
//    private let speechSynthesizer = AVSpeechSynthesizer()
//    
//    var body: some View {
//        VStack {
//            // Title or Story Name
//            Text("Story \(selectedStory + 1)")
//                .font(.largeTitle)
//                .padding()
//            
//            // Knob for Navigation
//            KnobView(selectedStory: $selectedStory, maxStories: stories.count)
//                .frame(width: 150, height: 150)
//                .padding()
//            
//            // Play/Pause Button
//            Button(action: {
//                togglePlayback()
//            }) {
//                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                    .resizable()
//                    .frame(width: 50, height: 50)
//                    .foregroundColor(.blue)
//            }
//            .padding()
//            
//            // Additional Controls (Optional)
//            HStack {
//                Button(action: {
//                    playPreviousStory()
//                }) {
//                    Image(systemName: "backward.end.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(.gray)
//                }
//                .padding()
//                
//                Button(action: {
//                    playNextStory()
//                }) {
//                    Image(systemName: "forward.end.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(.gray)
//                }
//                .padding()
//            }
//        }
//        .onDisappear {
//            // Stop speech when the view disappears
//            speechSynthesizer.stopSpeaking(at: .immediate)
//        }
//    }
//    
//    // Function to toggle playback
//    private func togglePlayback() {
//        if isPlaying {
//            speechSynthesizer.pauseSpeaking(at: .immediate)
//        } else {
//            if speechSynthesizer.isPaused {
//                speechSynthesizer.continueSpeaking()
//            } else {
//                speakStory()
//            }
//        }
//        isPlaying.toggle()
//    }
//    
//    // Function to speak the selected story
//    private func speakStory() {
//        let storyText = stories[selectedStory]
//        let utterance = AVSpeechUtterance(string: storyText)
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Set language
//        utterance.rate = 0.5 // Adjust speech rate (0.0 to 1.0)
//        
//        speechSynthesizer.speak(utterance)
//    }
//    
//    // Function to play the previous story
//    private func playPreviousStory() {
//        selectedStory = (selectedStory - 1 + stories.count) % stories.count
//        if isPlaying {
//            speechSynthesizer.stopSpeaking(at: .immediate)
//            speakStory()
//        }
//    }
//    
//    // Function to play the next story
//    private func playNextStory() {
//        selectedStory = (selectedStory + 1) % stories.count
//        if isPlaying {
//            speechSynthesizer.stopSpeaking(at: .immediate)
//            speakStory()
//        }
//    }
//}
//
//// Custom Knob View (same as before)
//struct KnobView: View {
//    @Binding var selectedStory: Int
//    let maxStories: Int
//    
//    @State private var rotationAngle: Double = 0.0
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(Color.gray.opacity(0.2))
//                .overlay(
//                    Circle()
//                        .stroke(Color.blue, lineWidth: 5)
//                )
//            
//            Circle()
//                .fill(Color.blue)
//                .frame(width: 20, height: 20)
//                .offset(y: -50)
//                .rotationEffect(.degrees(rotationAngle))
//                .gesture(
//                    DragGesture()
//                        .onChanged { value in
//                            let vector = CGVector(dx: value.location.x - 75, dy: value.location.y - 75)
//                            let angle = atan2(vector.dy, vector.dx) * 180 / .pi
//                            rotationAngle = angle
//                            
//                            // Calculate selected story based on rotation
//                            let step = 360.0 / Double(maxStories)
//                            selectedStory = Int((rotationAngle + 180 + step / 2).truncatingRemainder(dividingBy: 360) / step)
//                        }
//                )
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
