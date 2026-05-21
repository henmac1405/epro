import SwiftUI

struct ImageSliderView: View {
    @EnvironmentObject var controller: Controller
    
    let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    @State private var currentIndex: Int = 0
    @State private var urlimage = ""
    
    var body: some View { 
        let sliderItems = controller.loginSlider
        
        ZStack(alignment: .bottom) {
            if sliderItems.isEmpty {
                Color.fromRGBAString(self.controller.login_body_color)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else { 
                TabView(selection: $currentIndex) {
                    ForEach(0..<sliderItems.count, id: \.self) { index in
                        let imageURLString = urlimage + sliderItems[index].login_slider_images
                         
                        AsyncImage(url: URL(string: imageURLString)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                            case .failure(_), .empty:
                                Color.fromRGBAString(self.controller.login_body_color).opacity(0.5)
                                    .overlay(ProgressView().tint(.white))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onReceive(timer) { _ in
                    withAnimation {
                        currentIndex = (currentIndex + 1) % sliderItems.count
                    }
                }
                 
                HStack(spacing: 8) {
                    ForEach(0..<sliderItems.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .onAppear() {
            urlimage = self.controller.imageUrl
        }
    }
}
