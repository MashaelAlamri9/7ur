import SwiftUI
import Combine

// MARK: - Colors Extension (مرتبطة بألوان التطبيق الموحدة)

extension Color {
    static let sea         = Color.appBg
    static let riverDark   = Color(hex: 0x6B8F8F)
    static let riverLight  = Color(hex: 0x8FB0AE)
    static let sandTop     = Color(hex: 0xF0DC96)
    static let sandMid     = Color(hex: 0xC9A96A)
    static let sandSide    = Color(hex: 0xAD925F)
    static let trunk       = Color(hex: 0x6B5A44)
    static let leaf        = Color(hex: 0x5E7F5F)
    static let chestBrown  = Color(hex: 0x6B4A1A)
    static let gold        = Color.appGold
    static let pillBrown   = Color.appBrown
    static let pillBorder  = Color.appBrownEdge
    static let badgeFill   = Color(hex: 0xD9C7A0)
}

// MARK: - Progress

final class IslandProgress: ObservableObject {
    static let shared = IslandProgress()
    private let key = "islands.unlockedUpTo"

    @Published private(set) var unlockedUpTo: Int

    private init() {
        let saved = UserDefaults.standard.integer(forKey: key)
        unlockedUpTo = max(saved, 1)
    }

    func completeChallenge(island id: Int) {
        let next = id + 1
        guard next > unlockedUpTo else { return }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
            unlockedUpTo = next
        }
        UserDefaults.standard.set(next, forKey: key)
    }

    func reset() {
        unlockedUpTo = 1
        UserDefaults.standard.set(1, forKey: key)
    }
}

// MARK: - Main screen

struct IslandsMapView: View {
    var userName: String = "sawsan"
    var coins: Int = 5
    var unlockedUpTo: Int = 4
    var onSelectIsland: (Int) -> Void = { _ in }
    var onOpenBoard: () -> Void = {}
    var onOpenAvatar: () -> Void = {}
    var onOpenSettings: () -> Void = {}

    @ObservedObject private var progress = IslandProgress.shared
    @State private var chunkCount: Int = 3

    private var currentUnlocked: Int {
        max(unlockedUpTo, progress.unlockedUpTo)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let topY = max(geo.safeAreaInsets.top + 50, h * 0.13)

            ZStack {
                Color.sea

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<chunkCount, id: \.self) { index in
                            MapChunk(
                                chunkIndex: index,
                                size: CGSize(width: w, height: h),
                                unlockedUpTo: currentUnlocked,
                                onSelectIsland: onSelectIsland
                            )
                            .frame(width: w, height: h)
                            .rotationEffect(.degrees(180))
                            .onAppear {
                                if index >= chunkCount - 2 {
                                    chunkCount += 3
                                }
                            }
                        }
                    }
                }
                .rotationEffect(.degrees(180))

                // Eagle
                EagleView()
                    .scaleEffect(w * 0.70 / 370)
                    .frame(width: w * 0.70, height: w * 0.70 * 180 / 370)
                    .position(x: w * 0.5, y: h * 0.185)
                    .allowsHitTesting(false)

                // Greeting pill
                GreetingPill(name: userName, coins: coins)
                    .frame(width: w, alignment: .leading)
                    .padding(.leading, 20)
                    .position(x: w / 2, y: topY)

                // أزرار التنقل: البورد / الشخصية / الإعدادات
                HStack(spacing: 8) {
                    AppCircleButton(systemName: "person.2.fill", size: 40, action: onOpenBoard)
                    AppCircleButton(systemName: "tshirt.fill", size: 40, action: onOpenAvatar)
                    AppCircleButton(systemName: "gearshape.fill", size: 40, action: onOpenSettings)
                }
                .position(x: w - 16 - 68, y: topY)

                // Bottom hint
                Text("tap an island to explore")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: 0x4A4A4A))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color.appCream.opacity(0.85))
                    .clipShape(Capsule())
                    .position(x: w * 0.5, y: h - max(geo.safeAreaInsets.bottom, 20) - 14)
                    .allowsHitTesting(false)
            }
            .frame(width: w, height: h)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Map chunk

struct MapChunk: View {
    let chunkIndex: Int
    let size: CGSize
    let unlockedUpTo: Int
    let onSelectIsland: (Int) -> Void

    private let islandsPerChunk = 6
    @State private var floatUp = false

    var body: some View {
        let w = size.width
        let h = size.height
        let uiScale = min(w / 393, 1.2)

        ZStack {
            RiverView()
                .frame(width: w, height: h)

            ForEach(0..<islandsPerChunk, id: \.self) { i in
                let id = chunkIndex * islandsPerChunk + i + 1
                let isLocked = id > unlockedUpTo
                let scale: CGFloat = isLocked ? 0.72 : (id == 1 ? 1.0 : 0.88)
                let x: CGFloat = (i % 2 == 0) ? 0.23 : 0.78
                let y: CGFloat = 0.90 - CGFloat(i) / 6.0

                IslandView(isLocked: isLocked)
                    .scaleEffect(scale * uiScale)
                    .frame(width: 200 * scale * uiScale,
                           height: 130 * scale * uiScale)
                    .position(x: w * x, y: h * y)
                    .offset(y: floatUp ? -4 : 4)
                    .animation(
                        .easeInOut(duration: 2.2)
                            .repeatForever(autoreverses: true)
                            .delay(Double(id % 4) * 0.25),
                        value: floatUp
                    )
                    .onTapGesture {
                        if !isLocked { onSelectIsland(id) }
                    }

                NumberBadge(number: id)
                    .position(x: w * x, y: h * (y + 0.07))
                    .offset(y: floatUp ? -4 : 4)
                    .animation(
                        .easeInOut(duration: 2.2)
                            .repeatForever(autoreverses: true)
                            .delay(Double(id % 4) * 0.25),
                        value: floatUp
                    )
            }
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.2)
                    .repeatForever(autoreverses: true)
                ) {
                    floatUp = true
                }
            }
        }
        .frame(width: w, height: h)
    }
}

// MARK: - Greeting pill

struct GreetingPill: View {
    let name: String
    let coins: Int

    private var avatarHead: some View {
        let sel = AvatarStore.load()
        let base = avatarHairOptions[sel.hair]
        let hair = AvatarHairOption(id: base.id, style: base.style,
                                    color: avatarHairColors[sel.hairColor])
        return AvatarHeadIcon(skin: avatarSkinTones[sel.skin], hair: hair, gender: sel.gender)
            .scaleEffect(0.5)
            .frame(width: 34, height: 34)
            .background(Circle().fill(Color.appCream))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.pillBorder, lineWidth: 2))
    }

    var body: some View {
        HStack(spacing: 8) {
            avatarHead

            ZStack {
                Circle().fill(Color.gold)
                Text("\(coins)")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.chestBrown)
            }
            .frame(width: 28, height: 28)

            Text("Hi, \(name)")
                .font(.system(size: 16, weight: .medium, design: .serif))
                .italic()
                .foregroundColor(Color.gold.opacity(0.9))
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.pillBrown)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.pillBorder, lineWidth: 3))
        .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
    }
}

// MARK: - Number badge

struct NumberBadge: View {
    let number: Int

    var body: some View {
        Text("\(number)")
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .foregroundColor(Color.appBrownDeep)
            .frame(width: 52, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.badgeFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.pillBorder, lineWidth: 2.5)
            )
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.chestBrown.opacity(0.8))
                    .offset(y: 4)
            )
    }
}

// MARK: - Island

struct IslandView: View {
    var isLocked: Bool = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.gray.opacity(0.35))
                .frame(width: 192, height: 62)
                .position(x: 100, y: 98)

            Ellipse().fill(Color.sandSide)
                .frame(width: 168, height: 54)
                .position(x: 100, y: 90)
            Ellipse().fill(Color.sandMid)
                .frame(width: 168, height: 52)
                .position(x: 100, y: 83)
            Ellipse().fill(Color.sandTop)
                .frame(width: 168, height: 50)
                .position(x: 100, y: 76)

            PalmTree()
                .frame(width: 110, height: 95)
                .position(x: 65, y: 39)

            if isLocked {
                IslandLock()
                    .frame(width: 44, height: 40)
                    .position(x: 128, y: 66)
                    .transition(.scale.combined(with: .opacity))
            } else {
                TreasureChest()
                    .frame(width: 44, height: 40)
                    .position(x: 128, y: 66)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 200, height: 130)
        .opacity(isLocked ? 0.55 : 1)
        .animation(.spring(response: 0.55, dampingFraction: 0.6), value: isLocked)
    }
}

// MARK: - Lock

struct IslandLock: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.28))
                .frame(width: 34, height: 34)
            Image(systemName: "lock.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.9))
        }
    }
}

// MARK: - Palm tree (النخلة الموحدة: تُستخدم في كل الصفحات بـ .frame(width: 110, height: 95))

struct PalmTree: View {

    var body: some View {
        ZStack {

            // Curved trunk
            Path { path in
                path.move(to: CGPoint(x: 38, y: 96))
                path.addCurve(
                    to: CGPoint(x: 63, y: 35),
                    control1: CGPoint(x: 35, y: 65),
                    control2: CGPoint(x: 48, y: 47)
                )
            }
            .stroke(
                Color(hex: 0x6B5A44),
                style: StrokeStyle(
                    lineWidth: 8,
                    lineCap: .round
                )
            )

            // Palm leaves
            ZStack {

                // Left, downward leaf
                Path { p in
                    p.move(to: CGPoint(x: 63, y: 35))
                    p.addQuadCurve(
                        to: CGPoint(x: 7, y: 48),
                        control: CGPoint(x: 30, y: 31)
                    )
                    p.addQuadCurve(
                        to: CGPoint(x: 63, y: 35),
                        control: CGPoint(x: 37, y: 43)
                    )
                    p.closeSubpath()
                }
                .fill(Color(hex: 0x386F43))

                // Left, upper leaf
                Path { p in
                    p.move(to: CGPoint(x: 63, y: 35))
                    p.addQuadCurve(
                        to: CGPoint(x: 36, y: 17),
                        control: CGPoint(x: 45, y: 10)
                    )
                    p.addQuadCurve(
                        to: CGPoint(x: 63, y: 35),
                        control: CGPoint(x: 51, y: 23)
                    )
                    p.closeSubpath()
                }
                .fill(Color(hex: 0x397749))

                // Upper-right leaf
                Path { p in
                    p.move(to: CGPoint(x: 63, y: 35))
                    p.addQuadCurve(
                        to: CGPoint(x: 94, y: 17),
                        control: CGPoint(x: 78, y: 5)
                    )
                    p.addQuadCurve(
                        to: CGPoint(x: 63, y: 35),
                        control: CGPoint(x: 79, y: 23)
                    )
                    p.closeSubpath()
                }
                .fill(Color(hex: 0x386F43))

                // Right, wide leaf
                Path { p in
                    p.move(to: CGPoint(x: 63, y: 35))
                    p.addQuadCurve(
                        to: CGPoint(x: 115, y: 43),
                        control: CGPoint(x: 93, y: 22)
                    )
                    p.addQuadCurve(
                        to: CGPoint(x: 63, y: 35),
                        control: CGPoint(x: 91, y: 31)
                    )
                    p.closeSubpath()
                }
                .fill(Color(hex: 0x477F50))

                // Lower-right leaf
                Path { p in
                    p.move(to: CGPoint(x: 63, y: 35))
                    p.addQuadCurve(
                        to: CGPoint(x: 98, y: 64),
                        control: CGPoint(x: 87, y: 42)
                    )
                    p.addQuadCurve(
                        to: CGPoint(x: 63, y: 35),
                        control: CGPoint(x: 81, y: 45)
                    )
                    p.closeSubpath()
                }
                .fill(Color(hex: 0x528B59))

                // Lower-left leaf
                Path { p in
                    p.move(to: CGPoint(x: 63, y: 35))
                    p.addQuadCurve(
                        to: CGPoint(x: 31, y: 63),
                        control: CGPoint(x: 43, y: 44)
                    )
                    p.addQuadCurve(
                        to: CGPoint(x: 63, y: 35),
                        control: CGPoint(x: 46, y: 45)
                    )
                    p.closeSubpath()
                }
                .fill(Color(hex: 0x528B59))
            }

            // Dates (Tamr)
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 62, y: 35))
                    path.addLine(to: CGPoint(x: 57, y: 43))
                    path.move(to: CGPoint(x: 64, y: 36))
                    path.addLine(to: CGPoint(x: 69, y: 44))
                    path.move(to: CGPoint(x: 61, y: 37))
                    path.addLine(to: CGPoint(x: 63, y: 46))
                }
                .stroke(
                    Color(hex: 0x78603A),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )

                ForEach(0..<5, id: \.self) { i in
                    Ellipse()
                        .fill(
                            Color(hex: i.isMultiple(of: 2)
                                  ? 0x8B542B : 0xB47A38)
                        )
                        .frame(width: 5, height: 8)
                        .rotationEffect(.degrees(-15))
                        .position(
                            x: 54 + CGFloat(i % 3) * 5,
                            y: 43 + CGFloat(i / 3) * 5
                        )
                }

                ForEach(0..<4, id: \.self) { i in
                    Ellipse()
                        .fill(Color(hex: 0x98602F))
                        .frame(width: 5, height: 8)
                        .position(
                            x: 67 + CGFloat(i % 2) * 5,
                            y: 45 + CGFloat(i / 2) * 5
                        )
                }
            }
        }
    }
}

struct TreasureChest: View {
    var body: some View {
        ZStack {

            // Gold coins above the chest
            HStack(spacing: -2) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: 0xF5C14B))
                        .frame(width: 9, height: 9)
                        .overlay {
                            Circle()
                                .stroke(
                                    Color(hex: 0xD69B2D),
                                    lineWidth: 1
                                )
                        }
                        .offset(y: i == 1 ? -3 : 1)
                }
            }
            .offset(x: 1, y: -14)

            // Chest body
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: 0x75401F))
                .frame(width: 38, height: 23)
                .offset(y: 5)

            // Golden lid
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: 0x8B4A20))
                .frame(width: 40, height: 13)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gold, lineWidth: 2.5)
                }
                .offset(y: -6)

            // Gold band across the body
            Rectangle()
                .fill(Color.gold)
                .frame(width: 38, height: 3)
                .offset(y: 1)

            // Gold vertical bands
            HStack {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.gold)
                    .frame(width: 4, height: 22)

                Spacer()

                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.gold)
                    .frame(width: 4, height: 22)
            }
            .frame(width: 36, height: 22)
            .offset(y: 5)

            // Small golden lock
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gold)
                .frame(width: 7, height: 9)
                .overlay {
                    Circle()
                        .fill(Color(hex: 0x75401F))
                        .frame(width: 2, height: 2)
                }
                .offset(y: 2)
        }
        .frame(width: 44, height: 40)
    }
}

// MARK: - River

struct RiverView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                riverBand(w: w, h: h, leftX: 0.38, width: 0.26)
                    .fill(Color.riverLight.opacity(0.6))

                riverBand(w: w, h: h, leftX: 0.45, width: 0.12)
                    .fill(Color.riverDark.opacity(0.7))
            }
        }
    }

    private func riverBand(w: CGFloat, h: CGFloat, leftX: CGFloat, width: CGFloat) -> Path {
        Path { p in
            p.move(to: CGPoint(x: w * leftX, y: 0))
            p.addCurve(to: CGPoint(x: w * leftX, y: h),
                       control1: CGPoint(x: w * (leftX + 0.20), y: h * 0.30),
                       control2: CGPoint(x: w * (leftX - 0.20), y: h * 0.70))
            p.addLine(to: CGPoint(x: w * (leftX + width), y: h))
            p.addCurve(to: CGPoint(x: w * (leftX + width), y: 0),
                       control1: CGPoint(x: w * (leftX + width - 0.20), y: h * 0.70),
                       control2: CGPoint(x: w * (leftX + width + 0.20), y: h * 0.30))
            p.closeSubpath()
        }
    }
}

// MARK: - Eagle

struct EagleView: View {
    @State private var flap = false

    private func poly(_ pts: [(CGFloat, CGFloat)]) -> Path {
        Path { p in
            guard let first = pts.first else { return }
            p.move(to: CGPoint(x: first.0, y: first.1))
            for pt in pts.dropFirst() { p.addLine(to: CGPoint(x: pt.0, y: pt.1)) }
            p.closeSubpath()
        }
    }

    private var leftWing: some View {
        ZStack {
            poly([(0, 92), (135, 50), (160, 52), (168, 100)])
                .fill(Color(hex: 0x555B5E))
            poly([(40, 90), (135, 62), (160, 64), (166, 98)])
                .fill(Color(hex: 0x3F4548))
        }
        .frame(width: 370, height: 180)
    }

    private var rightWing: some View {
        ZStack {
            poly([(370, 92), (235, 50), (210, 52), (202, 100)])
                .fill(Color(hex: 0x555B5E))
            poly([(330, 90), (235, 62), (210, 64), (204, 98)])
                .fill(Color(hex: 0x3F4548))
        }
        .frame(width: 370, height: 180)
    }

    var body: some View {
        let leftAnchor = UnitPoint(x: 165.0 / 370.0, y: 96.0 / 180.0)
        let rightAnchor = UnitPoint(x: 205.0 / 370.0, y: 96.0 / 180.0)

        return ZStack {
            leftWing
                .rotationEffect(.degrees(flap ? 18 : -14), anchor: leftAnchor)
            rightWing
                .rotationEffect(.degrees(flap ? -18 : 14), anchor: rightAnchor)

            poly([(172, 140), (200, 140), (200, 178), (172, 178)])
                .fill(Color(hex: 0x3A3D40))

            poly([(185, 6), (203, 32), (214, 96), (200, 145), (170, 145), (156, 96), (167, 32)])
                .fill(Color(hex: 0xE8E8E4))

            poly([(185, 32), (204, 52), (185, 100), (166, 52)])
                .fill(Color(hex: 0xD2D4D1))

            poly([(180, 8), (190, 0), (191, 12)])
                .fill(Color.gold)
        }
        .frame(width: 370, height: 180)
        .offset(y: flap ? 5 : -5)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                flap = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    IslandsMapView { id in
        print("Selected island \(id)")
    }
}
