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
            // Profile image with badge
            ZStack(alignment: .bottom) {
                if let url = member.avatarImageUrl {
                    ProfilePicture(url: url)
                        .frame(width: 60, height: 60)
                } else {
                    Image("profile_placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                }

                Text("\(member.level)")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.generalText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.factionCardBorder)
                    .offset(x: 0, y: 5)
            }

            // Player details
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(member.avatarName)
                        .font(.system(size: 20, weight: .bold))
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

            // "View Profile" button
            Button(action: {
                showingDetailedProfile = true
            }) {
                Text("VIEW PROFILE")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 6)
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
