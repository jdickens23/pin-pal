import SwiftUI
import SDWebImageSwiftUI

struct SmartPlaylistView: View {
    let playlist: SmartGeneratedPlaylist
    let event: MusicEvent
    
    var body: some View {
        List {
            ForEach(playlist.tracks, id: \.title) { track in
                LabeledContent {} label: {
                    Text(track.title)
                    Text(ListFormatter.localizedString(byJoining: track.artists))
                }
            }
        }
        .navigationTitle(event.prompt ?? "Playlist")
    }
}

struct MusicCellLabeledContent: View {
    let event: MusicEvent
    let createdAt: Date
    
    @AccentColor
    private var accentColor: Color
    
    var body: some View {
        LabeledContent {
            if let id = event.albumArtUuid {
                WebImage(url: makeAlbumURL(id: id)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.bar)
                        .frame(width: 60, height: 60)
                        .overlay(ProgressView())
                }
            }
        } label: {
            if let title = event.trackTitle ?? event.prompt {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(accentColor)
            }
            if let artistName = event.artistName {
                Text(artistName)
            }
            if let albumName = event.albumName {
                Text(albumName)
            }
            Text(createdAt, format: .dateTime)
                .font(.caption)
        }
    }
    
    func makeAlbumURL(id: UUID) -> URL? {
        URL(string: "https://humane.center/_next/image?url=https://resources.tidal.com/images/\(id.uuidString.split(separator: "-").joined(separator: "/"))/160x160.jpg&w=256&q=75".lowercased())
    }
}

struct MusicCellView: View {
    let event: MusicEvent
    let createdAt: Date
    
    @AccentColor
    private var accentColor: Color
    
    @Environment(\.openURL)
    private var openURL
    
    var body: some View {
        if let playlist = event.generatedPlaylist {
            NavigationLink {
                SmartPlaylistView(playlist: playlist, event: event)
            } label: {
                LabeledContent {} label: {
                    if let title = event.prompt {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(accentColor)
                    }
                    if let length = event.length, let lengthCount = Int(length) {
                        Text("^[\(lengthCount) track](inflect: true)")
                    }
                    Text(createdAt, format: .dateTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } else if let trackId = event.trackID {
            Button {
                if let trackUrl = makeTidalTrackURL(trackID: trackId) {
                    openURL(trackUrl)
                }
            } label: {
                MusicCellLabeledContent(event: event, createdAt: createdAt)
            }
            .foregroundStyle(.primary)
        } else {
            MusicCellLabeledContent(event: event, createdAt: createdAt)
        }
    }
    
    func makeTidalTrackURL(trackID: String) -> URL? {
        URL(string: "https://tidal.com/browse/track/\(trackID)")
    }
}
