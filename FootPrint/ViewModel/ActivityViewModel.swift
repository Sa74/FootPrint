//
//  ActivityViewModel.swift
//  FootPrint
//
//  Created by Sasi Moorthy on 07.05.23.
//

import CoreLocation
import Foundation
import SwiftUI

enum ActivityError: Error, Equatable {
    case runtimeError(String)
}

final class ActivityViewModel: ObservableObject {

    private let photoDownloader: FlickerPhotoDownloader
    private(set) var activityController: ActivityTrackingProtocol

    private(set) var photos: [String: FlickerPhoto] = [:]

    @MainActor @Published private(set) var activityPhotos: [ActivityPhoto] = []
    @MainActor @Published private(set) var state = ActivityView.ViewState.readyForActivity

    @MainActor @Published private(set) var totalDistance: Double = 0
    @MainActor @Published private(set) var totalDuration: TimeInterval = 0

    @MainActor
    var distanceString: String {
        return String(format: "%.0f Meters", totalDistance)
    }

    var distanceTitle: String {
        return "Distance: "
    }

    @MainActor
    var durationString: String {
        return "Duration: \(totalDuration.stringFromTimeInterval())"
    }

    @MainActor
    var photosDownloadedString: String {
        return "Photos: \(activityPhotos.count)"
    }

    @MainActor
    var activityEndDescription: String {
        return activityController.error != nil ?
        "Activity interrupted with error: \(activityController.error?.localizedDescription ?? "")" :
        "Activity Ended"
    }

    init(
        photoDownloader: FlickerPhotoDownloader = FlickerPhotoDownloader(),
        activityController: ActivityTrackingProtocol = ActivityTrackingController()
    ) {
        self.photoDownloader = photoDownloader
        self.activityController = activityController

        setupActivityController()
    }

    @MainActor
    func handleAction(_ action: ActivityView.Action) throws {
        switch (action, state) {
        case (.didStartActivity, .readyForActivity):
            activityController.startTrackingActivity()
            state = .duringActivity
        case (.didStopActivity, .duringActivity):
            activityController.stopTrackingActivity()
            state = .activityEnded
        case (.didResetAfterActivity, .activityEnded):
            resetLastActivity()
            state = .readyForActivity
        default:
            throw ActivityError.runtimeError(
                "Invalid action \(action) for state \(state)"
            )
        }
    }

    // MARK: - Private methods

    private func setupActivityController() {
        activityController.didPerformEvent = { [weak self] event in
            guard let self else {
                return
            }
            DispatchQueue.main.async {
                switch event {
                case let .didCrossMinimumDistance(coordinate):
                    self.handleDidCrossMinimumDistance(
                        coordinate: coordinate
                    )
                case .didExceedTimeLimit,
                        .didFailWithError:
                    self.state = .activityEnded
                case let .didUpdateValues(distance, duration):
                    self.totalDistance = distance
                    self.totalDuration = duration
                }
            }
        }
    }

    private func handleDidCrossMinimumDistance(coordinate: CLLocationCoordinate2D) {
        Task {
            do {
                if let photo = photos[coordinate.hashableKey] {
                    insertActivityPhoto(for: photo.urlPath)
                    return
                }

                if let photo = try await photoDownloader.fetchFlickerPhoto(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                ) {
                    photos[coordinate.hashableKey] = photo
                    insertActivityPhoto(for: photo.urlPath)
                }
            } catch {
                throw ActivityError.runtimeError("Photo fetch error: \(error.localizedDescription)")
            }
        }
    }

    private func insertActivityPhoto(for urlPath: String) {
        DispatchQueue.main.async {
            // Avoid duplicate photos as it leads to unexpected behaviour in ListView
            // Insert placeholder image with unique id instead of duplicate photo
            self.activityPhotos.insert(
                ActivityPhoto(url: URL(string: urlPath) ?? Image.placeholderImageUrl),
                at: 0
            )
        }
    }

    @MainActor
    private func resetLastActivity() {
        activityController.reset()
        photos = [:]
        activityPhotos = []
        totalDistance = 0
        totalDuration = 0
    }
}
