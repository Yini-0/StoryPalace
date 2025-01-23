import SwiftUI
import AVFoundation

// Model to hold the list of story titles and their corresponding MP3 file paths
struct StoryModel {
    var stories: [String] = [
        "The Adventure of the Lost City",
        "The Mystery of the Hidden Treasure",
        "The Journey to the Enchanted Forest",
        "The Tale of the Brave Knight",
        "The Legend of the Golden Dragon"
    ]
    
    var mp3Files: [String: String] = [
        "The Journey to the Enchanted Forest": "Enchantedforest-e-1-WhispersofTheWoods.mp3",
        "The Adventure of the Lost City": "lost_city.mp3",
        "The Mystery of the Hidden Treasure": "hidden_treasure.mp3",
        "The Tale of the Brave Knight": "brave_knight.mp3",
        "The Legend of the Golden Dragon": "golden_dragon.mp3"
    ]
    
    var selectedStoryIndex: Int = 0
    
    var selectedStoryTitle: String {
        return stories[selectedStoryIndex]
    }
    
    var selectedStoryMP3: String? {
        return mp3Files[selectedStoryTitle]
    }
    
    mutating func moveToNextStory() {
        selectedStoryIndex = (selectedStoryIndex + 1) % stories.count
    }
    
    mutating func moveToPreviousStory() {
        selectedStoryIndex = (selectedStoryIndex - 1 + stories.count) % stories.count
    }
}

// Custom Rotation Knob View
struct RotationKnob: View {
    @Binding var rotationAngle: Double
    @Binding var selectedStoryIndex: Int
    let totalStories: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Outer Knob Circle (fixed 244x244 size)
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#EEE7E4"), Color(hex: "#F9F6F5")]),
                            startPoint: UnitPoint(x: 0.75, y: 0.933),
                            endPoint: UnitPoint(x: 0.25, y: 0.067)
                        )
                    )
                    .frame(width: 244, height: 244) // 👈 Fixed size
                    .overlay(
                        Circle()
                            .inset(by: 0.5)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "#FFFFFF"), Color(hex: "#CDC3C0")]),
                                    startPoint: UnitPoint(x: 0.75, y: 0.933),
                                    endPoint: UnitPoint(x: 0.25, y: 0.067)
                                ),
                                lineWidth: 1
                            )
                    )
                // First shadow (beige)
                    .shadow(
                        color: Color(hex: "#AE968E").opacity(0.5),
                        radius: 8,
                        x: 0,
                        y: 8
                    )
                // Second shadow (ambient black)
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 60,
                        x: 0,
                        y: 31
                    )
                // Third shadow (white highlight)
                    .shadow(
                        color: Color(hex: "#FFFFFF").opacity(0.5), // White with 50% opacity
                        radius: 8,
                        x: 3,  // Slight right offset
                        y: 3   // Slight downward offset
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Inner Knob Circle (fixed size 224x224)
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#FCFBFA"), Color(hex: "#E7DFDD")]),
                            startPoint: UnitPoint(x: 0.75, y: 0.933),
                            endPoint: UnitPoint(x: 0.25, y: 0.067)
                        )
                    )
                    .frame(width: 224, height: 224) // 👈 Fixed size
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 0.2)
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Indicator hand (like a watch hand)
                Rectangle()
                    .fill(Color(hex: "#004D3D")) // Set color to #004D3D
                    .frame(width: 6.25, height: min(geometry.size.width, geometry.size.height) * 0.12) // 12% of outer circle size (shorter)
                    .cornerRadius(5) // Rounded corners (half of the width)
                    .offset(y: -92.36) // 👈 New offset to place 5px inside inner circle
                    .rotationEffect(.degrees(rotationAngle))
                    .shadow(color: Color(hex: "#000000").opacity(0.25), radius: 4, x: 0, y: 4) // Drop shadow at the inner end
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center the hand
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let vector = CGVector(dx: value.location.x - geometry.size.width / 2, dy: value.location.y - geometry.size.height / 2)
                        let angle = atan2(vector.dy, vector.dx) * 180 / .pi
                        let newRotationAngle = (angle + 360).truncatingRemainder(dividingBy: 360)
                        rotationAngle = newRotationAngle
                        
                        // Update selected story index based on rotation
                        let stepSize = 360.0 / Double(totalStories)
                        selectedStoryIndex = Int((newRotationAngle / stepSize).rounded()) % totalStories
                    }
            )
        }
    }
}

// Main View
struct ContentView: View {
    @State private var storyModel = StoryModel()
    @State private var rotationAngle: Double = 0.0
    @State private var isPlaying: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) { // 👈 Remove default VStack spacing
                // Story Title (centered in available space above outer circle)
                Text(storyModel.selectedStoryTitle)
                    .font(.custom("Dosis-Regular", size: 25)) // 👈 Custom font
                    .foregroundColor(Color(hex: "#004D3D")) // 👈 Added color modifier
                    .frame(maxHeight: .infinity) // 👈 Take all available space
                    .padding(.horizontal)
                
                // Rotation Knob (centered)
                RotationKnob(rotationAngle: $rotationAngle, selectedStoryIndex: $storyModel.selectedStoryIndex, totalStories: storyModel.stories.count)
                    .frame(width: 244, height: 244) // 👈 Fixed size to match outer circle
                    .padding(.bottom, 103) // 👈 Maintain 103pt gap to buttons
                    .onChange(of: storyModel.selectedStoryIndex) { newIndex in
                        speakStoryTitle()
                    }
                
                // Navigation and Play/Pause Buttons in One Line
                HStack(spacing: 65) { // Adjust spacing as needed
                    // Previous Story Button
                    Button(action: {
                        moveStory(by: -1)
                    }) {
                        Image(systemName: "backward.end.fill")
                            .resizable()
                            .frame(width: 24, height: 25.76)
                            .foregroundColor(Color(hex: "#004D3D")) // Use #004D3D
                    }
                    
                    // Play/Pause Button
                    Button(action: {
                        togglePlayPause()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 58))
                            .foregroundColor(Color(hex: "#004D3D")) // Use #004D3D
                    }
                    
                    // Next Story Button
                    Button(action: {
                        moveStory(by: 1)
                    }) {
                        Image(systemName: "forward.end.fill")
                            .resizable()
                            .frame(width: 24, height: 25.76)
                            .foregroundColor(Color(hex: "#004D3D")) // Use #004D3D
                    }
                }
                .padding(.horizontal, 50)
            }
            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height) // Use full screen size
            .background(Color(hex: "#FAF1EE").ignoresSafeArea()) // Background color added here
        }
    }
    
    // Move to the next or previous story
    private func moveStory(by offset: Int) {
        // Stop the currently playing audio
        stopAudio()
        
        // Update the selected story index
        let newIndex = (storyModel.selectedStoryIndex + offset + storyModel.stories.count) % storyModel.stories.count
        storyModel.selectedStoryIndex = newIndex
        rotationAngle = Double(newIndex) * (360.0 / Double(storyModel.stories.count))
    }
    
    // Toggle play/pause for audio
    private func togglePlayPause() {
        if isPlaying {
            pauseAudio()
        } else {
            playAudio()
        }
        isPlaying.toggle()
    }
    
    private func speakStoryTitle() {
        let utterance = AVSpeechUtterance(string: storyModel.selectedStoryTitle)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "en-GB")
        speechSynthesizer.speak(utterance)
    }
    
    // Play the selected story's MP3 file
    private func playAudio() {
        if let player = audioPlayer, player.isPlaying == false {
            // If the player exists and is not playing, resume playback
            player.play()
        } else {
            // Otherwise, create a new player and start playback
            guard let mp3File = storyModel.selectedStoryMP3,
                  let path = Bundle.main.path(forResource: mp3File, ofType: nil) else {
                print("MP3 file not found")
                return
            }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Error playing MP3 file: \(error.localizedDescription)")
            }
        }
    }
    
    // Pause the audio
    private func pauseAudio() {
        audioPlayer?.pause()
    }
    
    // Stop the audio
    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
}

// Extension to use hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Preview
struct StoryTellingDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
