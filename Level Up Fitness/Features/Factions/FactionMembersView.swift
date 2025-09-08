//
//  FactionMembersView.swift
//  Level Up
//
//  Created by Sam Smith on 9/3/25.
//

import SwiftUI

struct FactionMembersView: View {
    let factionMembers: [FactionMember]
    
    var body: some View {
        ForEach(factionMembers) { member in
            ProfileRowView(member: member)
        }.padding(.horizontal, 16)
    }
}

struct ProfileRowView: View {
    let member: FactionMember
    @State private var showingDetailedProfile = false

    var body: some View {
        HStack(spacing: 16) {
            if let url = member.profilePictureUrl {
                ProfilePicture(url: url, level: member.level)
                    .frame(width: 70, height: 70)
            } else {
                Image("profile_placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(member.avatarName)
                        .font(.mainFont(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.generalText)
                    if let icon = member.heroPath?.iconName {
                        Image(icon)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    
                }

                if let rank = member.rank {
                    Text(rank)
                        .font(.system(size: 12))
                        .foregroundColor(.factionRank)
                }

                Text("\(member.xpPoints)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.numbers)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: {
                showingDetailedProfile = true
            }) {
                Text("VIEW PROFILE")
                    .font(.mainFont(size: 12))
                    .fontWeight(.bold)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.factionHomeSectionTitle)
                        
                    )
                    .foregroundColor(.black)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.factionCardBg)
                .stroke(.factionCardBorder, lineWidth: 2)
                .opacity(0.6)
        )
        .fullScreenCover(isPresented: $showingDetailedProfile) {
            OtherUserProfileView(userId: member.id) {
                showingDetailedProfile = false
            }
        }
    }
}

#Preview {
    FactionMembersView(factionMembers: [])
}
