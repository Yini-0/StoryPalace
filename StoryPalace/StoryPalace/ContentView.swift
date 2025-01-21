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
                // Outer Knob Circle (centered)
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.8, height: min(geometry.size.width, geometry.size.height) * 0.8) // 80% of available space
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 4)
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center the circle
                
                // Inner Knob Circle (centered)
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.5, height: min(geometry.size.width, geometry.size.height) * 0.5) // 50% of outer circle size
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 4)
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center the circle

                // Indicator hand (like a watch hand)
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 4, height: min(geometry.size.width, geometry.size.height) * 0.4) // 40% of outer circle size
                    .offset(y: -min(geometry.size.width, geometry.size.height) * 0.2) // Position the hand
                    .rotationEffect(.degrees(rotationAngle))
                    .shadow(color: .gray.opacity(0.5), radius: 3, x: 1, y: 1)
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
            VStack(spacing: 20) {
                // Selected Story Title
                Text(storyModel.selectedStoryTitle)
                    .font(.title)
                    .padding()

                // Rotation Knob (centered)
                RotationKnob(rotationAngle: $rotationAngle, selectedStoryIndex: $storyModel.selectedStoryIndex, totalStories: storyModel.stories.count)
                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.8, height: min(geometry.size.width, geometry.size.height) * 0.8) // 80% of available space
                    .onChange(of: storyModel.selectedStoryIndex) { newIndex in
                        speakStoryTitle()
                    }

                // Navigation Buttons
                HStack {
                    Button(action: {
                        moveStory(by: 1)
                    }) {
                        Image(systemName: "backward.end.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Button(action: {
                        moveStory(by: -1)
                    }) {
                        Image(systemName: "forward.end.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 50)

                // Play/Pause Button
                Button(action: {
                    togglePlayPause()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height) // Use full screen size
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

// Preview
struct StoryTellingDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
