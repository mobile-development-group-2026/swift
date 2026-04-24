import SwiftUI
import ClerkKitUI

struct ProfileAvatar: View {
    @Environment(UserSession.self) private var session
    var size: CGFloat = 40

    private var diskPhoto: Image? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("profile_photo.jpg")
        guard let data = try? Data(contentsOf: url),
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }

    var body: some View {
        ZStack {
            UserButton()
                .frame(width: size, height: size)
            avatarOverlay
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var avatarOverlay: some View {
        if let urlString = session.profile?.avatarUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if let photo = diskPhoto {
                    photo.resizable().scaledToFill()
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.purple, 500), lineWidth: 2))
            .allowsHitTesting(false)
        } else if let photo = diskPhoto {
            photo
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.purple, 500), lineWidth: 2))
                .allowsHitTesting(false)
        }
    }
}
