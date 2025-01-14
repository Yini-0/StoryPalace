import SwiftUI
import AVFoundation

// MARK: - Story Data
struct Story: Identifiable {
    let id = UUID()
    let title: String
    let audioFile: String
}

let stories = [
    Story(title: "The Magical Forest", audioFile: "forest.mp3"),
    Story(title: "The Brave Knight", audioFile: "knight.mp3"),
    Story(title: "The Lost Treasure", audioFile: "treasure.mp3"),
    Story(title: "The Space Adventure", audioFile: "space.mp3")
]

// MARK: - Main ContentView
struct ContentView: View {
    @State private var currentStoryIndex: Int = 0
    @State private var isPlaying: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            Spacer()
            
            // Story Title
            Text(stories[currentStoryIndex].title)
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            // iPod Shuffle-Inspired Circle Layout
            ZStack {
                // Circular Background
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 7)
                    .frame(width: 320, height: 320)
                
                Circle()
                    .stroke(Color.red.opacity(0.5), lineWidth: 7)
                    .frame(width: 10, height: 10)
                
                
                // Volume Control Buttons
                VStack {
                    Button(action: increaseVolume) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            //.padding()
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 5)
                    }
                    .offset(y: -50) // Move the plus button up
                    
                    Spacer()
                    
                    Button(action: decreaseVolume) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 50))
                            //.padding()
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 5)
                    }
                    .offset(y: 50) // Move the minus button down
                }
                .frame(height: 200)
                
                // Story Navigation Buttons
                HStack {
                    Button(action: previousStory) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 30))
                            .padding()
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 3)
                    }
                    .offset(x: -50) // Move the back button left
                    
                    Spacer()
                    
                    Button(action: nextStory) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 30))
                            .padding()
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 3)
                    }
                    .offset(x: 50) // Move the forward button right
                }
                .frame(width: 200)
                
                // Central Play/Pause Button
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .padding(20) // Add padding around the play/pause button
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 5)
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 1.0)
                        .onEnded { _ in
                            resetToStoryList()
                        }
                )
            }
            .frame(width: 250, height: 250)
            
            Spacer()
        }
        .padding()
        .onAppear {
            setupAudioSession()
        }
    }
    
    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Play/Pause Toggle
    private func togglePlayPause() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            playCurrentStory()
        }
        isPlaying.toggle()
    }
    
    // MARK: - Play Current Story
    private func playCurrentStory() {
        let story = stories[currentStoryIndex]
        
        // Stop any previous audio
        audioPlayer?.stop()
        
        // Load and play the new audio
        if let url = Bundle.main.url(forResource: story.audioFile, withExtension: nil) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Failed to play audio: \(error)")
            }
        } else {
            print("Audio file not found: \(story.audioFile)")
        }
        
        // Announce the story title
        let utterance = AVSpeechUtterance(string: story.title)
        synthesizer.speak(utterance)
    }
    
    // MARK: - Story Navigation
    private func nextStory() {
        currentStoryIndex = (currentStoryIndex + 1) % stories.count
        announceCurrentStory()
    }
    
    private func previousStory() {
        currentStoryIndex = (currentStoryIndex - 1 + stories.count) % stories.count
        announceCurrentStory()
    }
    
    private func announceCurrentStory() {
        let story = stories[currentStoryIndex]
        let utterance = AVSpeechUtterance(string: story.title)
        synthesizer.speak(utterance)
    }
    
    // MARK: - Volume Control
    private func increaseVolume() {
        audioPlayer?.volume += 0.1
    }
    
    private func decreaseVolume() {
        audioPlayer?.volume -= 0.1
    }
    
    // MARK: - Reset to Story List
    private func resetToStoryList() {
        audioPlayer?.stop()
        isPlaying = false
        currentStoryIndex = 0
        announceCurrentStory()
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
