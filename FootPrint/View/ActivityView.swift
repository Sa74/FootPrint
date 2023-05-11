//
//  ActivityView.swift
//  FootPrint
//
//  Created by Sasi Moorthy on 07.05.23.
//

import SwiftUI

struct ActivityView: View {

    @StateObject private var viewModel: ActivityViewModel

    init(viewModel: ActivityViewModel = ActivityViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            switch viewModel.state {
            case .readyForActivity:
                activityStartView
            case .duringActivity:
                duringActivityView
            case .activityEnded:
                afterActivityView
            }
        }
        .padding(.horizontal, 0)
        .padding(.vertical, 20)
    }

    private var activityStartView: some View {
        VStack {
            makeButton(
                title: "START WALKING",
                action: .didStartActivity,
                padding: 25,
                cornerRadius: 25,
                font: .title
            )
        }
    }

    private var duringActivityView: some View {
        VStack {
            HStack {
                Text(viewModel.distanceTitle +
                     "\n" +
                     viewModel.distanceString)
                    .font(.callout)
                    .bold()
                    .padding()
                Spacer()
                makeButton(
                    title: "STOP",
                    action: .didStopActivity
                )
                .padding(.trailing, 20)
            }
            activityImageList
        }
    }

    private var afterActivityView: some View {
        VStack {
            makeButton(
                title: "RESET",
                action: .didResetAfterActivity
            )
            Text(viewModel.activityEndDescription)
                .font(.callout)
                .italic()
            Spacer()
            VStack(alignment: .leading) {
                Text(viewModel.distanceTitle + viewModel.distanceString)
                    .font(.callout)
                    .italic()
                Text(viewModel.photosDownloadedString)
                    .font(.callout)
                    .italic()
                Text(viewModel.durationString)
                    .font(.callout)
                    .italic()
            }
            activityImageList
        }
        .padding(.horizontal, 20)
    }

    private var activityImageList: some View {
        List {
            ForEach(viewModel.activityPhotos) { activity in
                AsyncImage(
                    url: activity.url,
                    content: { image in
                        image.resizable()
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
                .cornerRadius(10)
                .clipped()
                .padding(.all, 20)
                .frame(
                    height: 200
                )
            }
        }
    }

    private func makeButton(
        title: String,
        action: Action,
        padding: CGFloat = 5,
        cornerRadius: CGFloat = 5,
        font: Font = .callout
    ) -> some View {
        Button {
            try? viewModel.handleAction(action)
        } label: {
            makeRoundRectLabel(
                title: title,
                padding: padding,
                cornerRadius: cornerRadius,
                font: font
            )
        }
    }

    private func makeRoundRectLabel(
        title: String,
        padding: CGFloat = 5,
        cornerRadius: CGFloat = 5,
        font: Font = .callout
    ) -> some View {
        Text(title)
            .font(font)
            .padding(padding)
            .bold()
            .foregroundColor(.black)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        .black,
                        lineWidth: 2
                    )
            )
    }
}

extension ActivityView {
    enum ViewState {
        case readyForActivity
        case duringActivity
        case activityEnded
    }

    enum Action {
        case didStartActivity
        case didStopActivity
        case didResetAfterActivity
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
