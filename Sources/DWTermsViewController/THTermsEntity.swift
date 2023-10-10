//
//  Created by 유태훈 on 2023/10/06.
//

import Foundation

public struct THTermsEntity {
    var name: String
    var url: String
    var isEssestial: Bool
    
    init(name: String, url: String, isEssential: Bool = true) {
        self.name = name
        self.url = url
        self.isEssestial = isEssential
    }
    
    var request: URLRequest? {
        guard let url = URL(string: self.url) else { return nil }
        return URLRequest(url: url)
    }
}
