import SwiftUI

struct ContentView: View {
    // Game constants
    let gridSize = 20
    let initialSnakeLength = 3
    let timerInterval = 0.2
    
    // Game state variables
    @State private var snake: [(x: Int, y: Int)] = [(10, 10), (10, 9), (10, 8)]
    @State private var direction: Direction = .right
    @State private var foodPosition: (x: Int, y: Int) = (5, 5)
    @State private var isGameOver = false
    
    // Timer to move the snake
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if isGameOver {
                Text("Game Over")
                    .font(.largeTitle)
                    .padding()
                Button("Restart") {
                    restartGame()
                }
                .padding()
            } else {
                GridView(gridSize: gridSize, snake: snake, foodPosition: foodPosition)
                    .onReceive(timer) { _ in
                        moveSnake()
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                changeDirection(gesture: gesture)
                            }
                    )
            }
        }
    }
    
    // Restart the game
    func restartGame() {
        snake = [(10, 10), (10, 9), (10, 8)]
        direction = .right
        foodPosition = (Int.random(in: 0..<gridSize), Int.random(in: 0..<gridSize))
        isGameOver = false
    }
    
    // Change snake direction based on drag gesture
    func changeDirection(gesture: DragGesture.Value) {
        let horizontalChange = gesture.translation.width
        let verticalChange = gesture.translation.height
        
        if abs(horizontalChange) > abs(verticalChange) {
            // Horizontal swipe
            if horizontalChange > 0 && direction != .left {
                direction = .right
            } else if horizontalChange < 0 && direction != .right {
                direction = .left
            }
        } else {
            // Vertical swipe
            if verticalChange > 0 && direction != .up {
                direction = .down
            } else if verticalChange < 0 && direction != .down {
                direction = .up
            }
        }
    }
    
    // Move the snake
    func moveSnake() {
        var newHead = snake.first!
        
        switch direction {
        case .up:
            newHead.y -= 1
        case .down:
            newHead.y += 1
        case .left:
            newHead.x -= 1
        case .right:
            newHead.x += 1
        }
        
        // Check for collisions
        if newHead.x < 0 || newHead.x >= gridSize || newHead.y < 0 || newHead.y >= gridSize || snake.contains(where: { $0 == newHead }) {
            isGameOver = true
            return
        }
        
        // Add the new head
        snake.insert(newHead, at: 0)
        
        // Check for food consumption
        if newHead == foodPosition {
            foodPosition = (Int.random(in: 0..<gridSize), Int.random(in: 0..<gridSize))
        } else {
            // Remove the tail if no food is consumed
            snake.removeLast()
        }
    }
}

// Direction enum for snake movement
enum Direction {
    case up, down, left, right
}

// Grid view to display the game
struct GridView: View {
    let gridSize: Int
    let snake: [(x: Int, y: Int)]
    let foodPosition: (x: Int, y: Int)
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<gridSize, id: \.self) { column in
                        Rectangle()
                            .foregroundColor(cellColor(at: (x: column, y: row)))
                            .frame(width: 20, height: 20)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray)
        .cornerRadius(10)
    }
    
    // Determine the cell's color
    func cellColor(at position: (x: Int, y: Int)) -> Color {
        if snake.contains(where: { $0 == position }) {
            return .green
        } else if position == foodPosition {
            return .red
        } else {
            return .white
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

