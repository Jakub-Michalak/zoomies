//
//  ProgressBarView.swift
//  zoomies
//
//  Created by Jakub Pietkiewicz on 26/10/2022.
//

import SwiftUI

// Generowanie widoku animowanego paska postępu
struct ProgressBarView: View {
    var progress: CGFloat = 0.8
    @State var startAnimation: CGFloat = 0
    var body: some View {
        GeometryReader{proxy in
            let size = proxy.size
            ZStack{
                // Kształt
                Image(systemName: "suit.heart.fill")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.gray)
                    .opacity(0.15)
                    .shadow(radius: 2)
                // Fala
                Wave(progress: progress, waveHeight: 0.04, offset: startAnimation)
                    .fill(Color.red)
                    .mask {
                        Image(systemName: "suit.heart.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
            }
            .frame(width: size.width, height: size.height, alignment: .center)
            .onAppear{
                withAnimation(.linear(duration: 2).repeatForever(autoreverses:
                    false)){
                    startAnimation = size.width - 25
                }
            }
        }
        .frame(height: 300)
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView()
    }
}
// Definicja kształtu fali
struct Wave: Shape{
    var progress: CGFloat
    var waveHeight: CGFloat
    var offset: CGFloat
    // Animacja
    var animatableData: CGFloat{
        get{offset}
        set{offset = newValue}
    }
    func path(in rect: CGRect) -> Path {
        return Path{path in
            path.move(to: .zero)
            // Sinusioda
            let progressHeight: CGFloat = (1 - progress) * rect.height
            let height = waveHeight * rect.height
            for value in stride(from: 0, to: rect.width, by: 2){
                let x: CGFloat = value
                let sine: CGFloat = sin(Angle(degrees: value + offset).radians)
                let y: CGFloat = progressHeight + (height * sine)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            // Dolna granica
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}
