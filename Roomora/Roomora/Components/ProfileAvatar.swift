import SwiftUI
import ClerkKitUI

struct ProfileAvatar: View {
    var size: CGFloat = 40

    private var profilePhoto: Image? {
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

            if let photo = profilePhoto {
                photo
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.purple, 500), lineWidth: 2))
                    .allowsHitTesting(false)
            }
        }
        .frame(width: size, height: size)
    }
}
