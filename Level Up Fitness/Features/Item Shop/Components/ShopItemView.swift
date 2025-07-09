import SwiftUI

struct ShopItemView: View {
    let item: ShopItem
    let onPurchase: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.minor.opacity(0.5))
            VStack {
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 28)
                HStack {
                    HStack(spacing: 4) {
                        Image("gold_icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                        Text("\(item.price)")
                            .foregroundStyle(.white)
                            .bold()
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white.opacity(0.5))
                    )
                    HStack(spacing: 4) {
                        Image("xp_icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                        Text("\(String(format: "%g", item.xpMultiplier))x")
                            .foregroundStyle(.white)
                            .bold()
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white.opacity(0.5))
                    )
                }
                .padding(.bottom, 28)

            }
            VStack {
                Spacer()
                Button {
                    
                } label: {
                    Image("buy_button")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                }

            }
            .offset(y: 23)
        }
        .aspectRatio(0.8, contentMode: .fit)
    }
}

#Preview {
    let sampleItem = ShopItem(
        name: "Silver Boots",
        description: "A powerful sword that deals extra damage to dragon-type enemies.",
        price: 250,
        xpMultiplier: 0.5,
        imageName: "silver_boots",
        category: .weapon,
        rarity: .epic
    )
    
    ZStack {
        Color.major
        VStack(spacing: 28) {
            HStack {
                ShopItemView(item: sampleItem) {
                    // Purchase action
                }
                ShopItemView(item: sampleItem) {
                    // Purchase action
                }
            }
            HStack {
                ShopItemView(item: sampleItem) {
                    // Purchase action
                }
                ShopItemView(item: sampleItem) {
                    // Purchase action
                }
            }
        }
        .padding()
    }
}
