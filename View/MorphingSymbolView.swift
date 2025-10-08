// MorphingSymbolView.swift
// Walkthrough
//
// Created by Abdullah on 11.08.25.
//

import SwiftUI

struct MorphingSymbolView: View {
    var symbol: String
    var config: Config
    var isPreview: Bool = false
    
    @State private var displaySymbol: String = ""
    @State private var nextSymbol: String = ""
    
    // animation states
    @State private var blurRadius: CGFloat = 0
    @State private var scale: CGFloat = 1
    @State private var rotation: Angle = .zero
    @State private var isAnimating: Bool = false
    
    var body: some View {
        Canvas { ctx, size in
            // We still use Canvas to allow symbol masking/filtering if needed.
            // Use a simple resolved symbol (Image view in symbols closure)
            if let rendered = ctx.resolveSymbol(id: 0) {
                ctx.draw(rendered, at: CGPoint(x: size.width / 2, y: size.height / 2))
            }
        } symbols: {
            // Tag 0 -> resolved and drawn above.
            ZStack {
                Image(systemName: displaySymbol)
                    .font(config.font)
                    .frame(width: config.frame.width, height: config.frame.height)
                    .blur(radius: blurRadius)
                    .scaleEffect(scale)
                    .rotationEffect(rotation)
                    .foregroundStyle(config.foregroundColor)
            }
            .tag(0)
        }
        .frame(width: config.frame.width, height: config.frame.height)
        .onAppear {
            // initial setup
            displaySymbol = symbol
            nextSymbol = symbol
            blurRadius = 0
            scale = 1
            rotation = .zero
        }
        .onChange(of: symbol) { _, newValue in
            nextSymbol = newValue
            if isPreview {
                // In preview show immediately (no heavy anim)
                displaySymbol = newValue
                blurRadius = 0
                scale = 1
                rotation = .zero
            } else {
                playMorphAnimation()
            }
        }
    }
    
    private func playMorphAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Step 1: start with heavy blur / scaled up / small rotation
        blurRadius = config.radius
        scale = 1.15
        rotation = .degrees(18)
        
        // After short delay swap the symbol at midpoint
        let firstPhase = config.keyframeDuration
        let secondPhase = config.keyframeDuration
        
        // Schedule switching to nextSymbol at midpoint
        DispatchQueue.main.asyncAfter(deadline: .now() + firstPhase * 0.4) {
            withAnimation(config.symbolAnimation) {
                displaySymbol = nextSymbol
            }
        }
        
        // Animate blur -> 0 and scale/rotation back to normal
        withAnimation(.interpolatingSpring(stiffness: 180, damping: 18).speed(1)) {
            blurRadius = 0
            scale = 1.0
            rotation = .zero
        }
        
        // End animation flag after total duration
        DispatchQueue.main.asyncAfter(deadline: .now() + firstPhase + secondPhase) {
            isAnimating = false
        }
    }
    
    struct Config {
        var font: Font
        var frame: CGSize
        var radius: CGFloat
        var foregroundColor: Color
        var keyframeDuration: CGFloat = 0.35
        var symbolAnimation: Animation = .easeInOut(duration: 0.25)
    }
}
