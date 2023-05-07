//
//  Bundle+FileContent.swift
//  FootPrintTests
//
//  Created by Sasi Moorthy on 07.05.23.
//

import XCTest

extension Bundle {

    func contentsOfFile(
        named fileName: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Data? {
        guard let resourceURL = url(
            forResource: fileName,
            withExtension: nil
        ) else {
            XCTFail(
                "Resource '\(fileName)' no found.",
                file: file,
                line: line
            )
            return nil
        }

        do {
            return try Data(contentsOf: resourceURL)
        } catch {
            XCTFail(
                "Error loading resource '\(fileName)'",
                file: file,
                line: line
            )
            return nil
        }
    }
}
