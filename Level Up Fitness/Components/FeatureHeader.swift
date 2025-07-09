ZStack(alignment: .topLeading) {
            HStack {
                Spacer()
                
                Image("item_shop_title")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                
                Spacer()
            }
            .padding(.bottom, 24)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                    .padding(.horizontal, 24)
                    .foregroundStyle(Color.minor)
            }

        }