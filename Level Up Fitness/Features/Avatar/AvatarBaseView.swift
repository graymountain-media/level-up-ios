VStack {
            Spacer()
            Image("william_vengence")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y: 40)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                Color.black.ignoresSafeArea()
                Image("citiscape")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            }
        }