import SwiftUI

struct ContentView: View {
    var body: some View {
        Widget().padding(20)
    }
}

struct Widget: View {
    enum Constants {
        static let backgroundColor = Color(red: 0.961, green: 0.957, blue: 0.949)
        static let searchColor = Color.white
        static let textColor = Color.black
        static let highlightedColor = Color.red
        
        static let size = CGSize(width: 150.0, height: 150.0)
        static let cornerRadius: CGFloat = 10.0
        
        static let searchFieldHeight: CGFloat = 10.0
        static let searchFieldCornerRadius: CGFloat = 20.0
        
        static let symbolOffset: CGFloat = 15.0
        static let symbolFont = Font.system(size: 24.0, weight: .light)
        static let font = Font.system(size: 30.0, weight: .light)
    }
    
    @State private var isAnimating = false
    @State private var text = ""

    var body: some View {
        VStack(alignment: .center, spacing: 10.0, content: {
            ZStack(alignment: .center, content: {
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(Constants.backgroundColor)
                VStack(alignment: .leading, spacing: 30.0, content: {
                    TimeLabel(animated: isAnimating)
                    SearchField(text: $text)
                })
            })
            .frame(width: Constants.size.width,
                   height: Constants.size.height)
            Button(isAnimating ? "Stop" : "Start") {
                isAnimating.toggle()
            }
            .frame(width: Constants.size.width, height: 30.0, alignment: .center)
        })
    }
    
    struct SearchField: View {
        
        @Binding var text: String
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: Constants.searchFieldCornerRadius)
                HStack(spacing: 10.0) {
                    Text("Y")
                        .font(Constants.symbolFont)
                        .foregroundColor(Constants.highlightedColor)
                        .padding(.leading, Constants.symbolOffset)
                    TextField("", text: $text)
                        .font(Constants.font)
                        .foregroundColor(Constants.textColor)
                }
            }
            .frame(width: Constants.size.width * 0.8,
                   height: Constants.searchFieldHeight)
        }
    }
    
    struct TimeLabel: View {
        let animated: Bool

        @State var time: (hours: String, minutes: String) = ("--", "--")
        @State var inverted: Bool = false
        
        private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        private let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH mm"
            return dateFormatter
        }()
            
        var body: some View {
            HStack(alignment: .center, spacing: 10.0) {
                Text(time.hours)
                VStack {
                    Group {
                        Circle()
                            .foregroundColor(animated && inverted ? Constants.highlightedColor : Constants.textColor)
                        Circle()
                            .foregroundColor(animated && !inverted ? Constants.highlightedColor : Constants.textColor)
                    }
                    .frame(width: 4.0, height: 3.0)
                }
                .padding(.top, 8)
                Text(time.minutes)
            }
            .font(Constants.font)
            .foregroundColor(Constants.textColor)
            .onReceive(timer) {
                let dateComponents = dateFormatter.string(from: $0)
                    .components(separatedBy: " ")
                guard dateComponents.count == 2,
                      let hours = dateComponents.first,
                      let minutes = dateComponents.last else { return }
                time = (hours, minutes)
                inverted.toggle()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

