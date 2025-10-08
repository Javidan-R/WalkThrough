import SwiftUI

struct IntroView: View {
    @State private var activePage: Page = .page1
    @Namespace private var animation
    @State private var showMainApp = false
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(colors: activePage.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1), value: activePage)

            VStack {
                Spacer()

                Image(systemName: activePage.rawValue)
                    .font(.system(size: 150, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .matchedGeometryEffect(id: "icon", in: animation)
                    .transition(.opacity.combined(with: .scale))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: activePage)

                VStack(spacing: 12) {
                    Text(activePage.title)
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .id("title\(activePage.rawValue)")

                    Text(activePage.subtitle)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .id("subtitle\(activePage.rawValue)")
                }
                .animation(.easeInOut(duration: 0.5), value: activePage)

                Spacer()

                indicatorView

                continueButton
                    .padding(.bottom, 30)
            }
            .padding()
            .overlay(alignment: .top) {
                headerView()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 { nextPage() }
                    if value.translation.width > 50 { previousPage() }
                }
        )
        .onAppear {
            updateProgress()
        }
        .fullScreenCover(isPresented: $showMainApp) {
            MainAppView()
                .ignoresSafeArea()
        }
    }

    // MARK: - Header View
    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            Button {
                previousPage()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
            .opacity(activePage != .page1 ? 1 : 0)
            .disabled(activePage == .page1)

            Spacer()

            Button("Skip") {
                withAnimation {
                    activePage = .page4
                    updateProgress()
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.2)))
            .opacity(activePage != .page4 ? 1 : 0)
            .disabled(activePage == .page4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .animation(.easeInOut, value: activePage)
    }

    // MARK: - Indicator
    private var indicatorView: some View {
        HStack(spacing: 8) {
            ForEach(Page.allCases, id: \.self) { page in
                Capsule()
                    .fill(Color.white.opacity(activePage == page ? 1 : 0.4))
                    .frame(width: activePage == page ? 20 : 8, height: 8)
                    .animation(.spring(), value: activePage)
            }
        }
    }

    // MARK: - Continue Button
    private var continueButton: some View {
        Button {
            if activePage == .page4 {
                showMainApp = true // FullScreenCover ilə açılır, geri dönmək mümkün deyil
            } else {
                nextPage()
            }
        } label: {
            Text(activePage == .page4 ? "Login into PS App" : "Continue")
                .bold()
                .padding(.vertical, 15)
                .padding(.horizontal, 40)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Navigation Helpers
    private func nextPage() {
        withAnimation(.easeInOut) {
            if activePage != .page4 {
                activePage = activePage.next
                updateProgress()
            }
        }
    }

    private func previousPage() {
        withAnimation(.easeInOut) {
            if activePage != .page1 {
                activePage = activePage.prev
                updateProgress()
            }
        }
    }

    private func updateProgress() {
        progress = CGFloat(activePage.index + 1) / CGFloat(Page.allCases.count)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
