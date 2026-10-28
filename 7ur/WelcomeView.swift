import SwiftUI

// MARK: - Welcome Screen

struct WelcomeView: View {
    var onStart: () -> Void = {}

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // تصميم الأصل 390 × 844
            let px: (CGFloat) -> CGFloat = { w * $0 / 390 }
            let py: (CGFloat) -> CGFloat = { h * $0 / 844 }

            ZStack {
                Color.appBg.ignoresSafeArea()

                LightRays()
                    .ignoresSafeArea()

                // Clouds (تنجرف ببطء)
                CloudView().frame(width: 140, height: 70)
                    .position(x: px(110), y: py(190))
                    .drifting(distance: 12, duration: 7)
                CloudView().frame(width: 150, height: 70)
                    .position(x: px(345), y: py(260))
                    .drifting(distance: 14, duration: 9)
                CloudView().frame(width: 120, height: 60)
                    .position(x: px(80), y: py(480))
                    .drifting(distance: 10, duration: 8)
                CloudView().frame(width: 120, height: 60)
                    .position(x: px(330), y: py(540))
                    .drifting(distance: 12, duration: 6)

                // Seagull (يرفرف)
                SeagullView()
                    .frame(width: 160, height: 80)
                    .position(x: px(195), y: py(90))

                // Welcome text
                Text("welcome")
                    .font(.custom("SnellRoundhand-Bold", size: 64))
                    .foregroundColor(.appGold)
                    .position(x: px(195), y: py(340))

                // Island (تطفو)
                WelcomeIslandView()
                    .frame(width: 330, height: 260)
                    .position(x: px(195), y: py(560))
                    .floating(amplitude: 5, duration: 2.4)

                // Start button
                Button(action: onStart) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.appBrownDeep)
                            .offset(y: 6)
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.appBrown)
                        Text("Start")
                            .font(.system(size: 44, weight: .regular, design: .rounded))
                            .foregroundColor(.appGold)
                    }
                    .frame(width: 296, height: 68)
                }
                .buttonStyle(.plain)
                .position(x: px(195), y: py(740))
            }
            .frame(width: w, height: h)
        }
    }
}

// MARK: - Light rays

struct LightRays: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: w * 0.10, y: 0))
                    p.addLine(to: CGPoint(x: w * 0.42, y: 0))
                    p.addLine(to: CGPoint(x: w * 0.75, y: h))
                    p.addLine(to: CGPoint(x: w * 0.45, y: h))
                    p.closeSubpath()
                }
                .fill(Color.white.opacity(0.10))

                Path { p in
                    p.move(to: CGPoint(x: w * 0.60, y: 0))
                    p.addLine(to: CGPoint(x: w * 0.90, y: 0))
                    p.addLine(to: CGPoint(x: w * 1.10, y: h * 0.8))
                    p.addLine(to: CGPoint(x: w * 0.85, y: h * 0.8))
                    p.closeSubpath()
                }
                .fill(Color.white.opacity(0.08))
            }
        }
    }
}

// MARK: - Cloud

struct CloudView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Ellipse()
                    .fill(Color.white.opacity(0.75))
                    .frame(width: w, height: h * 0.55)
                    .position(x: w * 0.45, y: h * 0.72)
                Circle()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: w * 0.42, height: w * 0.42)
                    .position(x: w * 0.50, y: h * 0.42)
                Ellipse()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: w * 0.36, height: h * 0.5)
                    .position(x: w * 0.78, y: h * 0.62)
            }
        }
    }
}

// MARK: - Seagull (يرفرف مثل نسر الهوم)

struct SeagullView: View {
    @State private var flap = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Left wing + edge
                ZStack {
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.44, y: h * 0.48))
                        p.addLine(to: CGPoint(x: w * 0.18, y: h * 0.40))
                        p.addLine(to: CGPoint(x: w * 0.00, y: h * 0.58))
                        p.addLine(to: CGPoint(x: w * 0.46, y: h * 0.58))
                        p.closeSubpath()
                    }
                    .fill(Color(hex: "8C8C8C"))

                    Path { p in
                        p.move(to: CGPoint(x: w * 0.00, y: h * 0.58))
                        p.addLine(to: CGPoint(x: w * 0.46, y: h * 0.58))
                        p.addLine(to: CGPoint(x: w * 0.46, y: h * 0.64))
                        p.closeSubpath()
                    }
                    .fill(Color.black)
                }
                .rotationEffect(.degrees(flap ? 14 : -10), anchor: UnitPoint(x: 0.45, y: 0.52))

                // Right wing + edge
                ZStack {
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.56, y: h * 0.48))
                        p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.40))
                        p.addLine(to: CGPoint(x: w * 1.00, y: h * 0.58))
                        p.addLine(to: CGPoint(x: w * 0.54, y: h * 0.58))
                        p.closeSubpath()
                    }
                    .fill(Color(hex: "6E6E6E"))

                    Path { p in
                        p.move(to: CGPoint(x: w * 1.00, y: h * 0.58))
                        p.addLine(to: CGPoint(x: w * 0.54, y: h * 0.58))
                        p.addLine(to: CGPoint(x: w * 0.54, y: h * 0.64))
                        p.closeSubpath()
                    }
                    .fill(Color.black)
                }
                .rotationEffect(.degrees(flap ? -14 : 10), anchor: UnitPoint(x: 0.55, y: 0.52))

                // Body
                Path { p in
                    p.move(to: CGPoint(x: w * 0.50, y: h * 0.10))
                    p.addLine(to: CGPoint(x: w * 0.57, y: h * 0.40))
                    p.addLine(to: CGPoint(x: w * 0.56, y: h * 0.85))
                    p.addLine(to: CGPoint(x: w * 0.44, y: h * 0.85))
                    p.addLine(to: CGPoint(x: w * 0.43, y: h * 0.40))
                    p.closeSubpath()
                }
                .fill(Color(hex: "E8E8E6"))

                // Tail
                Path { p in
                    p.move(to: CGPoint(x: w * 0.44, y: h * 0.85))
                    p.addLine(to: CGPoint(x: w * 0.56, y: h * 0.85))
                    p.addLine(to: CGPoint(x: w * 0.56, y: h * 1.00))
                    p.addLine(to: CGPoint(x: w * 0.44, y: h * 1.00))
                    p.closeSubpath()
                }
                .fill(Color.black)

                // Beak
                Path { p in
                    p.move(to: CGPoint(x: w * 0.50, y: 0))
                    p.addLine(to: CGPoint(x: w * 0.53, y: h * 0.14))
                    p.addLine(to: CGPoint(x: w * 0.47, y: h * 0.14))
                    p.closeSubpath()
                }
                .fill(Color(hex: "F4E9B0"))
            }
            .offset(y: flap ? 4 : -4)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                flap = true
            }
        }
    }
}

// MARK: - Island

struct WelcomeIslandView: View {
    var body: some View {
        ZStack {
            // Water ring
            Ellipse()
                .fill(Color(hex: "6F9A9C"))
                .frame(width: 322, height: 122)
                .offset(y: 40)

            // Shallow sand halo
            Ellipse()
                .fill(Color(hex: "C2BA84").opacity(0.85))
                .frame(width: 312, height: 100)
                .offset(y: 64)

            // Island side
            Ellipse()
                .fill(Color(hex: "A89060"))
                .frame(width: 290, height: 112)
                .offset(y: 52)

            // Island top
            Ellipse()
                .fill(Color(hex: "F8E08E"))
                .frame(width: 290, height: 108)
                .offset(y: 34)

            // النخلة الموحدة (من الهوم)
            PalmTree()
                .frame(width: 110, height: 95)
                .scaleEffect(1.5)
                .offset(x: -50, y: -45)

            // Treasure chest
            WelcomeTreasureChest()
                .frame(width: 100, height: 90)
                .offset(x: 62, y: 8)
        }
    }
}

// MARK: - Treasure chest

struct WelcomeTreasureChest: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Coins behind the open-looking lid
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: "E6C766"))
                        .frame(width: w * 0.19, height: w * 0.19)
                        .position(
                            x: w * [0.30, 0.50, 0.70][i],
                            y: h * [0.17, 0.08, 0.17][i]
                        )
                }

                // Chest body
                RoundedRectangle(cornerRadius: w * 0.045)
                    .fill(Color(hex: "7F6420"))
                    .frame(width: w * 0.80, height: h * 0.44)
                    .overlay {
                        RoundedRectangle(cornerRadius: w * 0.045)
                            .stroke(
                                Color(hex: "684B25"),
                                lineWidth: max(1, w * 0.025)
                            )
                    }
                    .position(x: w * 0.50, y: h * 0.59)

                // Golden horizontal band
                Rectangle()
                    .fill(Color(hex: "C4A747"))
                    .frame(width: w * 0.80, height: h * 0.09)
                    .position(x: w * 0.50, y: h * 0.52)

                // Lid
                RoundedRectangle(cornerRadius: w * 0.10)
                    .fill(Color(hex: "A8A296"))
                    .frame(width: w * 0.84, height: h * 0.23)
                    .overlay {
                        RoundedRectangle(cornerRadius: w * 0.10)
                            .stroke(
                                Color(hex: "8C806B"),
                                lineWidth: max(1, w * 0.025)
                            )
                    }
                    .position(x: w * 0.50, y: h * 0.35)

                // Front gold lock
                RoundedRectangle(cornerRadius: w * 0.025)
                    .fill(Color(hex: "F0C94D"))
                    .frame(width: w * 0.15, height: h * 0.25)
                    .overlay {
                        RoundedRectangle(cornerRadius: w * 0.025)
                            .stroke(
                                Color(hex: "C99D32"),
                                lineWidth: max(1, w * 0.018)
                            )
                    }
                    .position(x: w * 0.50, y: h * 0.55)

                // Coins on the sand
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: "E6C766"))
                        .frame(width: w * 0.20, height: w * 0.20)
                        .position(
                            x: w * [0.76, 0.88, 0.68][i],
                            y: h * [0.78, 0.87, 0.91][i]
                        )
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}
