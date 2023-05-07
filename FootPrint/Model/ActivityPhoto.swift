//
//  ActivityPhoto.swift
//  FootPrint
//
//  Created by Sasi Moorthy on 07.05.23.
//

import Foundation

struct ActivityPhoto: Identifiable {
    let id: UUID
    let url: URL

    init(id: UUID = UUID(),
         url: URL) {
        self.id = id
        self.url = url
    }
}
