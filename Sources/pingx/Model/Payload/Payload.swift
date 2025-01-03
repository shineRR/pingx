//
// The MIT License (MIT)
//
// Copyright © 2025 Ilya Baryka. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

struct Payload {
    
    // MARK: Typealias
    
    typealias PayloadID = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    
    // MARK: Properties
    
    // "pingx"
    let identifier: PayloadID
    let timestamp: CFAbsoluteTime
    
    // MARK: Initializer
    
    init(
        identifier: PayloadID = (112, 105, 110, 103, 120, 0, 0, 0),
        timestamp: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    ) {
        self.identifier = identifier
        self.timestamp = timestamp
    }
}
