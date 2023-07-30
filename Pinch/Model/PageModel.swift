//
//  PageModel.swift
//  Pinch
//
//  Created by Артём Коваленко on 29.07.2023.
//

import Foundation

struct Page: Identifiable {
    let id: Int
    let imageName: String
}

extension Page {
    // this add thumb- to image name by caling this method
    // ALSO can be added as just method in struct - SAME RESULT
    var thumbnailName: String {
        return "thumb-" + imageName
    }
}
